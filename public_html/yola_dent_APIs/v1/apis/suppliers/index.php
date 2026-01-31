<?php
// ============================================
// Suppliers API - واجهة برمجة تطبيقات الموردين
// REST API for Suppliers CRUD operations
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
                getSupplier($db, $id);
            } else if ($action === 'stats') {
                getSupplierStats($db);
            } else if ($action === 'products') {
                $supplierId = isset($_GET['supplier_id']) ? $_GET['supplier_id'] : null;
                getSupplierProducts($db, $supplierId);
            } else if ($action === 'with-balance') {
                getSuppliersWithBalance($db);
            } else {
                getAllSuppliers($db);
            }
            break;
            
        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);
            if ($action === 'payment') {
                recordPayment($db, $data);
            } else {
                createSupplier($db, $data);
            }
            break;
            
        case 'PUT':
            $data = json_decode(file_get_contents("php://input"), true);
            updateSupplier($db, $id, $data);
            break;
            
        case 'DELETE':
            deleteSupplier($db, $id);
            break;
            
        default:
            sendError('Method not allowed', 405);
    }
} catch (Exception $e) {
    sendError($e->getMessage(), 500);
}

// ============================================
// API Functions
// ============================================

/**
 * Get all suppliers
 */
function getAllSuppliers($db) {
    $query = "SELECT * FROM suppliers WHERE is_active = 1 ORDER BY name ASC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $suppliers = $stmt->fetchAll();
    $formattedSuppliers = array_map('formatSupplierResponse', $suppliers);
    
    sendSuccess($formattedSuppliers, 'Suppliers retrieved successfully');
}

/**
 * Get single supplier by ID
 */
function getSupplier($db, $id) {
    $query = "SELECT * FROM suppliers WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    $stmt->execute();
    
    $supplier = $stmt->fetch();
    
    if (!$supplier) {
        sendError('Supplier not found', 404);
    }
    
    sendSuccess(formatSupplierResponse($supplier), 'Supplier retrieved successfully');
}

/**
 * Create new supplier
 */
function createSupplier($db, $data) {
    // Validate required fields
    if (!isset($data['name']) || empty($data['name'])) {
        sendError("Field 'name' is required", 400);
    }
    
    // Generate supplier code
    $codeQuery = "SELECT MAX(CAST(SUBSTRING(code, 5) AS UNSIGNED)) as max_code FROM suppliers";
    $codeStmt = $db->prepare($codeQuery);
    $codeStmt->execute();
    $result = $codeStmt->fetch();
    $nextCode = ($result['max_code'] ?? 0) + 1;
    $code = 'SUP-' . str_pad($nextCode, 3, '0', STR_PAD_LEFT);
    
    $query = "INSERT INTO suppliers (
        code, name, contact_person, phone, email, address,
        payment_terms, delivery_days, credit_limit, current_balance,
        is_active, created_at, updated_at
    ) VALUES (
        :code, :name, :contact_person, :phone, :email, :address,
        :payment_terms, :delivery_days, :credit_limit, :current_balance,
        1, NOW(), NOW()
    )";
    
    $stmt = $db->prepare($query);
    
    $stmt->bindParam(':code', $code);
    $stmt->bindParam(':name', $data['name']);
    $stmt->bindValue(':contact_person', $data['contact_person'] ?? null);
    $stmt->bindValue(':phone', $data['phone'] ?? null);
    $stmt->bindValue(':email', $data['email'] ?? null);
    $stmt->bindValue(':address', $data['address'] ?? null);
    $stmt->bindValue(':payment_terms', $data['payment_terms'] ?? null);
    $stmt->bindValue(':delivery_days', $data['delivery_days'] ?? null);
    $stmt->bindValue(':credit_limit', $data['credit_limit'] ?? 0);
    $stmt->bindValue(':current_balance', $data['current_balance'] ?? 0);
    
    if ($stmt->execute()) {
        $newId = $db->lastInsertId();
        getSupplier($db, $newId);
    } else {
        sendError('Failed to create supplier', 500);
    }
}

/**
 * Update existing supplier
 */
function updateSupplier($db, $id, $data) {
    if (!$id) {
        sendError('Supplier ID is required', 400);
    }
    
    // Check if supplier exists
    $checkQuery = "SELECT id FROM suppliers WHERE id = :id";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->bindParam(':id', $id);
    $checkStmt->execute();
    
    if (!$checkStmt->fetch()) {
        sendError('Supplier not found', 404);
    }
    
    // Build dynamic update query
    $fields = [];
    $params = [':id' => $id];
    
    $allowedFields = [
        'name', 'contact_person', 'phone', 'email', 'address',
        'payment_terms', 'delivery_days', 'credit_limit', 'current_balance', 'is_active'
    ];
    
    foreach ($allowedFields as $field) {
        if (isset($data[$field])) {
            $fields[] = "{$field} = :{$field}";
            $params[":{$field}"] = $data[$field];
        }
    }
    
    if (empty($fields)) {
        sendError('No fields to update', 400);
    }
    
    $fields[] = "updated_at = NOW()";
    
    $query = "UPDATE suppliers SET " . implode(', ', $fields) . " WHERE id = :id";
    $stmt = $db->prepare($query);
    
    if ($stmt->execute($params)) {
        getSupplier($db, $id);
    } else {
        sendError('Failed to update supplier', 500);
    }
}

/**
 * Delete supplier (soft delete)
 */
function deleteSupplier($db, $id) {
    if (!$id) {
        sendError('Supplier ID is required', 400);
    }
    
    $query = "UPDATE suppliers SET is_active = 0, updated_at = NOW() WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    
    if ($stmt->execute()) {
        if ($stmt->rowCount() > 0) {
            sendSuccess(null, 'Supplier deleted successfully');
        } else {
            sendError('Supplier not found', 404);
        }
    } else {
        sendError('Failed to delete supplier', 500);
    }
}

/**
 * Get suppliers with outstanding balance
 */
function getSuppliersWithBalance($db) {
    $query = "SELECT * FROM suppliers 
              WHERE is_active = 1 AND current_balance > 0 
              ORDER BY current_balance DESC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $suppliers = $stmt->fetchAll();
    $formattedSuppliers = array_map('formatSupplierResponse', $suppliers);
    
    sendSuccess($formattedSuppliers, 'Suppliers with balance retrieved successfully');
}

/**
 * Get supplier statistics
 */
function getSupplierStats($db) {
    $statsQuery = "SELECT 
        COUNT(*) as total_suppliers,
        SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) as active_suppliers,
        SUM(current_balance) as total_balance,
        SUM(credit_limit) as total_credit_limit,
        AVG(delivery_days) as avg_delivery_days
    FROM suppliers WHERE is_active = 1";
    
    $stmt = $db->prepare($statsQuery);
    $stmt->execute();
    
    $stats = $stmt->fetch();
    
    sendSuccess($stats, 'Statistics retrieved successfully');
}

/**
 * Get products by supplier
 */
function getSupplierProducts($db, $supplierId) {
    if (!$supplierId) {
        sendError('supplier_id is required', 400);
    }
    
    // Get supplier info first
    $supplierQuery = "SELECT code, name FROM suppliers WHERE id = :id";
    $supplierStmt = $db->prepare($supplierQuery);
    $supplierStmt->bindParam(':id', $supplierId);
    $supplierStmt->execute();
    $supplier = $supplierStmt->fetch();
    
    if (!$supplier) {
        sendError('Supplier not found', 404);
    }
    
    // Get products by supplier name or supplier_id
    $query = "SELECT * FROM products 
              WHERE (supplier_id = :supplier_id OR supplier_name = :supplier_name) 
              AND is_active = 1 
              ORDER BY name ASC";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':supplier_id', $supplierId);
    $stmt->bindParam(':supplier_name', $supplier['name']);
    $stmt->execute();
    
    $products = $stmt->fetchAll();
    
    // Format products
    $formatted = array_map(function($p) {
        return [
            'id' => (string)$p['id'],
            'reference' => $p['reference'],
            'name' => $p['name'],
            'quantity' => (int)$p['quantity'],
            'purchase_price' => (float)$p['purchase_price'],
            'selling_price' => (float)$p['selling_price'],
            'category' => $p['category']
        ];
    }, $products);
    
    sendSuccess([
        'supplier' => [
            'id' => $supplierId,
            'code' => $supplier['code'],
            'name' => $supplier['name']
        ],
        'products' => $formatted,
        'total_products' => count($formatted)
    ], 'Supplier products retrieved successfully');
}

/**
 * Record payment to supplier
 */
function recordPayment($db, $data) {
    if (!isset($data['supplier_id']) || !isset($data['amount'])) {
        sendError('supplier_id and amount are required', 400);
    }
    
    $supplierId = $data['supplier_id'];
    $amount = (float)$data['amount'];
    
    if ($amount <= 0) {
        sendError('Amount must be positive', 400);
    }
    
    // Get current supplier
    $supplierQuery = "SELECT * FROM suppliers WHERE id = :id AND is_active = 1";
    $supplierStmt = $db->prepare($supplierQuery);
    $supplierStmt->bindParam(':id', $supplierId);
    $supplierStmt->execute();
    $supplier = $supplierStmt->fetch();
    
    if (!$supplier) {
        sendError('Supplier not found', 404);
    }
    
    $newBalance = $supplier['current_balance'] - $amount;
    if ($newBalance < 0) $newBalance = 0;
    
    // Update supplier balance
    $updateQuery = "UPDATE suppliers SET current_balance = :balance, updated_at = NOW() WHERE id = :id";
    $updateStmt = $db->prepare($updateQuery);
    $updateStmt->bindParam(':balance', $newBalance);
    $updateStmt->bindParam(':id', $supplierId);
    
    if ($updateStmt->execute()) {
        getSupplier($db, $supplierId);
    } else {
        sendError('Failed to record payment', 500);
    }
}

// ============================================
// Helper Functions
// ============================================

/**
 * Format supplier response to match Flutter model
 */
function formatSupplierResponse($supplier) {
    return [
        'id' => (string)$supplier['id'],
        'code' => $supplier['code'],
        'name' => $supplier['name'],
        'contact_person' => $supplier['contact_person'],
        'phone' => $supplier['phone'],
        'email' => $supplier['email'],
        'address' => $supplier['address'],
        'payment_terms' => $supplier['payment_terms'],
        'delivery_days' => isset($supplier['delivery_days']) ? (int)$supplier['delivery_days'] : null,
        'credit_limit' => isset($supplier['credit_limit']) ? (float)$supplier['credit_limit'] : null,
        'current_balance' => (float)($supplier['current_balance'] ?? 0),
        'is_active' => (bool)$supplier['is_active'],
        'has_balance' => (float)($supplier['current_balance'] ?? 0) > 0,
        'created_at' => $supplier['created_at'],
        'updated_at' => $supplier['updated_at']
    ];
}
