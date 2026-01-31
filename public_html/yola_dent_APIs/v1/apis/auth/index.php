<?php
// ============================================
// Auth API - واجهة برمجة تطبيقات المصادقة
// REST API for Authentication & User Management
// ============================================

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/headers.php';

// Get request method and action
$method = $_SERVER['REQUEST_METHOD'];
$action = isset($_GET['action']) ? $_GET['action'] : '';
$id = isset($_GET['id']) ? $_GET['id'] : null;

// Initialize database connection
$database = new Database();
$db = $database->getConnection();

try {
    switch ($method) {
        case 'GET':
            if ($id) {
                getUser($db, $id);
            } else if ($action === 'me') {
                getCurrentUser();
            } else if ($action === 'check-session') {
                checkSession();
            } else {
                getAllUsers($db);
            }
            break;
            
        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);
            if ($action === 'login') {
                login($db, $data);
            } else if ($action === 'logout') {
                logout();
            } else if ($action === 'change-password') {
                changePassword($db, $data);
            } else if ($action === 'reset-password') {
                resetPassword($db, $data);
            } else {
                createUser($db, $data);
            }
            break;
            
        case 'PUT':
            $data = json_decode(file_get_contents("php://input"), true);
            updateUser($db, $id, $data);
            break;
            
        case 'DELETE':
            deleteUser($db, $id);
            break;
            
        default:
            sendError('Method not allowed', 405);
    }
} catch (Exception $e) {
    sendError($e->getMessage(), 500);
}

// ============================================
// Authentication Functions
// ============================================

/**
 * Login user
 */
function login($db, $data) {
    if (!isset($data['username']) || !isset($data['password'])) {
        sendError('Username and password are required', 400);
    }
    
    $username = $data['username'];
    $password = $data['password'];
    
    // Find user by username
    $query = "SELECT * FROM users WHERE username = :username";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':username', $username);
    $stmt->execute();
    
    $user = $stmt->fetch();
    
    if (!$user) {
        sendError('المستخدم غير موجود', 401);
    }
    
    // Verify password
    if (!password_verify($password, $user['password_hash'])) {
        sendError('كلمة المرور غير صحيحة', 401);
    }
    
    // Check if user is active
    if (!$user['is_active']) {
        sendError('الحساب غير نشط، يرجى التواصل مع المدير', 403);
    }
    
    // Update last login
    $updateQuery = "UPDATE users SET last_login = NOW() WHERE id = :id";
    $updateStmt = $db->prepare($updateQuery);
    $updateStmt->bindParam(':id', $user['id']);
    $updateStmt->execute();
    
    // Generate simple token (in production, use JWT)
    $token = bin2hex(random_bytes(32));
    
    // Store token in session or database
    $sessionQuery = "UPDATE users SET session_token = :token WHERE id = :id";
    $sessionStmt = $db->prepare($sessionQuery);
    $sessionStmt->bindParam(':token', $token);
    $sessionStmt->bindParam(':id', $user['id']);
    $sessionStmt->execute();
    
    // Get warehouse IDs
    $warehouseIds = json_decode($user['warehouse_ids'] ?? '[]', true);
    
    sendSuccess([
        'token' => $token,
        'user' => formatUserResponse($user, $warehouseIds)
    ], 'تم تسجيل الدخول بنجاح');
}

/**
 * Logout user
 */
function logout() {
    // Clear session token
    // In production, invalidate the token in database
    sendSuccess(null, 'تم تسجيل الخروج بنجاح');
}

/**
 * Check session validity
 */
function checkSession() {
    // Get token from header
    $headers = getallheaders();
    $token = $headers['Authorization'] ?? '';
    $token = str_replace('Bearer ', '', $token);
    
    if (empty($token)) {
        sendError('No token provided', 401);
    }
    
    // In production, validate token
    sendSuccess(['valid' => true], 'Session is valid');
}

/**
 * Get current user (from token)
 */
function getCurrentUser() {
    $headers = getallheaders();
    $token = $headers['Authorization'] ?? '';
    $token = str_replace('Bearer ', '', $token);
    
    if (empty($token)) {
        sendError('Not authenticated', 401);
    }
    
    // In production, decode token and get user
    sendError('Token verification not implemented', 501);
}

/**
 * Change password
 */
function changePassword($db, $data) {
    if (!isset($data['user_id']) || !isset($data['old_password']) || !isset($data['new_password'])) {
        sendError('user_id, old_password and new_password are required', 400);
    }
    
    $userId = $data['user_id'];
    
    // Get user
    $query = "SELECT id, password_hash FROM users WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $userId);
    $stmt->execute();
    $user = $stmt->fetch();
    
    if (!$user) {
        sendError('User not found', 404);
    }
    
    // Verify old password
    if (!password_verify($data['old_password'], $user['password_hash'])) {
        sendError('كلمة المرور الحالية غير صحيحة', 401);
    }
    
    // Hash new password
    $newPasswordHash = password_hash($data['new_password'], PASSWORD_DEFAULT);
    
    // Update password
    $updateQuery = "UPDATE users SET password_hash = :password, updated_at = NOW() WHERE id = :id";
    $updateStmt = $db->prepare($updateQuery);
    $updateStmt->bindParam(':password', $newPasswordHash);
    $updateStmt->bindParam(':id', $userId);
    
    if ($updateStmt->execute()) {
        sendSuccess(null, 'تم تغيير كلمة المرور بنجاح');
    } else {
        sendError('فشل في تغيير كلمة المرور', 500);
    }
}

/**
 * Reset password (admin function)
 */
function resetPassword($db, $data) {
    if (!isset($data['user_id']) || !isset($data['new_password'])) {
        sendError('user_id and new_password are required', 400);
    }
    
    $newPasswordHash = password_hash($data['new_password'], PASSWORD_DEFAULT);
    
    $query = "UPDATE users SET password_hash = :password, updated_at = NOW() WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':password', $newPasswordHash);
    $stmt->bindParam(':id', $data['user_id']);
    
    if ($stmt->execute() && $stmt->rowCount() > 0) {
        sendSuccess(null, 'تم إعادة تعيين كلمة المرور بنجاح');
    } else {
        sendError('User not found', 404);
    }
}

// ============================================
// User CRUD Functions
// ============================================

/**
 * Get all users
 */
function getAllUsers($db) {
    $query = "SELECT * FROM users ORDER BY created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $users = $stmt->fetchAll();
    $formattedUsers = array_map(function($user) {
        $warehouseIds = json_decode($user['warehouse_ids'] ?? '[]', true);
        return formatUserResponse($user, $warehouseIds);
    }, $users);
    
    sendSuccess($formattedUsers, 'Users retrieved successfully');
}

/**
 * Get single user
 */
function getUser($db, $id) {
    $query = "SELECT * FROM users WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    $stmt->execute();
    
    $user = $stmt->fetch();
    
    if (!$user) {
        sendError('User not found', 404);
    }
    
    $warehouseIds = json_decode($user['warehouse_ids'] ?? '[]', true);
    sendSuccess(formatUserResponse($user, $warehouseIds), 'User retrieved successfully');
}

/**
 * Create new user
 */
function createUser($db, $data) {
    // Validate required fields
    $required = ['username', 'password', 'display_name', 'role'];
    foreach ($required as $field) {
        if (!isset($data[$field]) || empty($data[$field])) {
            sendError("Field '{$field}' is required", 400);
        }
    }
    
    // Check if username exists
    $checkQuery = "SELECT id FROM users WHERE username = :username";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->bindParam(':username', $data['username']);
    $checkStmt->execute();
    
    if ($checkStmt->fetch()) {
        sendError('اسم المستخدم موجود مسبقاً', 400);
    }
    
    // Hash password
    $passwordHash = password_hash($data['password'], PASSWORD_DEFAULT);
    
    // Prepare warehouse IDs
    $warehouseIds = json_encode($data['warehouse_ids'] ?? []);
    
    $query = "INSERT INTO users (
        username, password_hash, email, display_name, role,
        phone, warehouse_ids, is_active, created_at, updated_at
    ) VALUES (
        :username, :password, :email, :display_name, :role,
        :phone, :warehouse_ids, 1, NOW(), NOW()
    )";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':username', $data['username']);
    $stmt->bindParam(':password', $passwordHash);
    $stmt->bindValue(':email', $data['email'] ?? null);
    $stmt->bindParam(':display_name', $data['display_name']);
    $stmt->bindParam(':role', $data['role']);
    $stmt->bindValue(':phone', $data['phone'] ?? null);
    $stmt->bindParam(':warehouse_ids', $warehouseIds);
    
    if ($stmt->execute()) {
        getUser($db, $db->lastInsertId());
    } else {
        sendError('Failed to create user', 500);
    }
}

/**
 * Update user
 */
function updateUser($db, $id, $data) {
    if (!$id) {
        sendError('User ID is required', 400);
    }
    
    // Build dynamic update query
    $fields = [];
    $params = [':id' => $id];
    
    $allowedFields = [
        'email', 'display_name', 'role', 'phone', 'is_active'
    ];
    
    foreach ($allowedFields as $field) {
        if (isset($data[$field])) {
            $fields[] = "{$field} = :{$field}";
            $params[":{$field}"] = $data[$field];
        }
    }
    
    // Handle warehouse_ids separately (JSON)
    if (isset($data['warehouse_ids'])) {
        $fields[] = "warehouse_ids = :warehouse_ids";
        $params[':warehouse_ids'] = json_encode($data['warehouse_ids']);
    }
    
    if (empty($fields)) {
        sendError('No fields to update', 400);
    }
    
    $fields[] = "updated_at = NOW()";
    
    $query = "UPDATE users SET " . implode(', ', $fields) . " WHERE id = :id";
    $stmt = $db->prepare($query);
    
    if ($stmt->execute($params)) {
        getUser($db, $id);
    } else {
        sendError('Failed to update user', 500);
    }
}

/**
 * Delete user (soft delete)
 */
function deleteUser($db, $id) {
    if (!$id) {
        sendError('User ID is required', 400);
    }
    
    $query = "UPDATE users SET is_active = 0, updated_at = NOW() WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    
    if ($stmt->execute() && $stmt->rowCount() > 0) {
        sendSuccess(null, 'User deleted successfully');
    } else {
        sendError('User not found', 404);
    }
}

// ============================================
// Helper Functions
// ============================================

/**
 * Format user response
 */
function formatUserResponse($user, $warehouseIds = []) {
    return [
        'id' => (string)$user['id'],
        'username' => $user['username'],
        'email' => $user['email'],
        'display_name' => $user['display_name'],
        'role' => $user['role'],
        'phone' => $user['phone'],
        'warehouse_ids' => $warehouseIds,
        'is_active' => (bool)$user['is_active'],
        'last_login' => $user['last_login'],
        'created_at' => $user['created_at'],
        'updated_at' => $user['updated_at']
    ];
}
