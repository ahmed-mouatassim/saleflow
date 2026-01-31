<?php
// ============================================
// Clients API - واجهة برمجة تطبيقات الزبناء
// REST API for Clients CRUD operations
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
                getClient($db, $id);
            } else if ($action === 'debtors') {
                getDebtors($db);
            } else if ($action === 'stats') {
                getClientStats($db);
            } else if ($action === 'transactions') {
                $clientId = isset($_GET['client_id']) ? $_GET['client_id'] : null;
                getClientTransactions($db, $clientId);
            } else if ($action === 'cities') {
                getCities($db);
            } else {
                getAllClients($db);
            }
            break;
            
        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);
            if ($action === 'payment') {
                recordPayment($db, $data);
            } else if ($action === 'purchase') {
                recordPurchase($db, $data);
            } else {
                createClient($db, $data);
            }
            break;
            
        case 'PUT':
            $data = json_decode(file_get_contents("php://input"), true);
            updateClient($db, $id, $data);
            break;
            
        case 'DELETE':
            deleteClient($db, $id);
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
 * Get all clients
 */
function getAllClients($db) {
    $query = "SELECT * FROM clients WHERE is_active = 1 ORDER BY created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $clients = $stmt->fetchAll();
    $formattedClients = array_map('formatClientResponse', $clients);
    
    sendSuccess($formattedClients, 'Clients retrieved successfully');
}

/**
 * Get single client by ID
 */
function getClient($db, $id) {
    $query = "SELECT * FROM clients WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    $stmt->execute();
    
    $client = $stmt->fetch();
    
    if (!$client) {
        sendError('Client not found', 404);
    }
    
    sendSuccess(formatClientResponse($client), 'Client retrieved successfully');
}

/**
 * Create new client
 */
function createClient($db, $data) {
    // Validate required fields
    if (!isset($data['name']) || empty($data['name'])) {
        sendError("Field 'name' is required", 400);
    }
    
    // Generate client code
    $codeQuery = "SELECT MAX(CAST(SUBSTRING(code, 5) AS UNSIGNED)) as max_code FROM clients";
    $codeStmt = $db->prepare($codeQuery);
    $codeStmt->execute();
    $result = $codeStmt->fetch();
    $nextCode = ($result['max_code'] ?? 0) + 1;
    $code = 'CLI-' . str_pad($nextCode, 4, '0', STR_PAD_LEFT);
    
    $query = "INSERT INTO clients (
        code, name, phone, email, address, city, notes,
        total_purchases, total_paid, is_active, created_at, updated_at
    ) VALUES (
        :code, :name, :phone, :email, :address, :city, :notes,
        :total_purchases, :total_paid, 1, NOW(), NOW()
    )";
    
    $stmt = $db->prepare($query);
    
    $stmt->bindParam(':code', $code);
    $stmt->bindParam(':name', $data['name']);
    $stmt->bindValue(':phone', $data['phone'] ?? null);
    $stmt->bindValue(':email', $data['email'] ?? null);
    $stmt->bindValue(':address', $data['address'] ?? null);
    $stmt->bindValue(':city', $data['city'] ?? null);
    $stmt->bindValue(':notes', $data['notes'] ?? null);
    $stmt->bindValue(':total_purchases', $data['total_purchases'] ?? 0);
    $stmt->bindValue(':total_paid', $data['total_paid'] ?? 0);
    
    if ($stmt->execute()) {
        $newId = $db->lastInsertId();
        getClient($db, $newId);
    } else {
        sendError('Failed to create client', 500);
    }
}

/**
 * Update existing client
 */
function updateClient($db, $id, $data) {
    if (!$id) {
        sendError('Client ID is required', 400);
    }
    
    // Check if client exists
    $checkQuery = "SELECT id FROM clients WHERE id = :id";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->bindParam(':id', $id);
    $checkStmt->execute();
    
    if (!$checkStmt->fetch()) {
        sendError('Client not found', 404);
    }
    
    // Build dynamic update query
    $fields = [];
    $params = [':id' => $id];
    
    $allowedFields = [
        'name', 'phone', 'email', 'address', 'city', 'notes',
        'total_purchases', 'total_paid', 'is_active'
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
    
    $query = "UPDATE clients SET " . implode(', ', $fields) . " WHERE id = :id";
    $stmt = $db->prepare($query);
    
    if ($stmt->execute($params)) {
        getClient($db, $id);
    } else {
        sendError('Failed to update client', 500);
    }
}

/**
 * Delete client (soft delete)
 */
function deleteClient($db, $id) {
    if (!$id) {
        sendError('Client ID is required', 400);
    }
    
    $query = "UPDATE clients SET is_active = 0, updated_at = NOW() WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    
    if ($stmt->execute()) {
        if ($stmt->rowCount() > 0) {
            sendSuccess(null, 'Client deleted successfully');
        } else {
            sendError('Client not found', 404);
        }
    } else {
        sendError('Failed to delete client', 500);
    }
}

/**
 * Get clients with debt
 */
function getDebtors($db) {
    $query = "SELECT * FROM clients 
              WHERE is_active = 1 AND (total_purchases - total_paid) > 0 
              ORDER BY (total_purchases - total_paid) DESC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $clients = $stmt->fetchAll();
    $formattedClients = array_map('formatClientResponse', $clients);
    
    sendSuccess($formattedClients, 'Debtors retrieved successfully');
}

/**
 * Get client statistics
 */
function getClientStats($db) {
    $statsQuery = "SELECT 
        COUNT(*) as total_clients,
        SUM(CASE WHEN (total_purchases - total_paid) > 0 THEN 1 ELSE 0 END) as clients_with_debt,
        SUM(total_purchases) as total_purchases,
        SUM(total_paid) as total_paid,
        SUM(total_purchases - total_paid) as total_debt
    FROM clients WHERE is_active = 1";
    
    $stmt = $db->prepare($statsQuery);
    $stmt->execute();
    
    $stats = $stmt->fetch();
    
    // Calculate payment rate
    $stats['payment_rate'] = $stats['total_purchases'] > 0 
        ? ($stats['total_paid'] / $stats['total_purchases']) * 100 
        : 100;
    
    sendSuccess($stats, 'Statistics retrieved successfully');
}

/**
 * Get client transactions
 */
function getClientTransactions($db, $clientId) {
    if (!$clientId) {
        sendError('client_id is required', 400);
    }
    
    $query = "SELECT * FROM client_transactions 
              WHERE client_id = :client_id 
              ORDER BY created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':client_id', $clientId);
    $stmt->execute();
    
    $transactions = $stmt->fetchAll();
    
    $formatted = array_map(function($t) {
        return [
            'id' => (string)$t['id'],
            'client_id' => (string)$t['client_id'],
            'type' => $t['type'],
            'amount' => (float)$t['amount'],
            'balance_before' => isset($t['balance_before']) ? (float)$t['balance_before'] : null,
            'balance_after' => isset($t['balance_after']) ? (float)$t['balance_after'] : null,
            'order_id' => $t['reference_id'] ?? null,
            'invoice_number' => $t['invoice_number'] ?? null,
            'notes' => $t['notes'],
            'created_at' => $t['created_at']
        ];
    }, $transactions);
    
    sendSuccess($formatted, 'Transactions retrieved successfully');
}

/**
 * Record payment
 */
function recordPayment($db, $data) {
    if (!isset($data['client_id']) || !isset($data['amount'])) {
        sendError('client_id and amount are required', 400);
    }
    
    $clientId = $data['client_id'];
    $amount = (float)$data['amount'];
    
    if ($amount <= 0) {
        sendError('Amount must be positive', 400);
    }
    
    // Get current client
    $clientQuery = "SELECT * FROM clients WHERE id = :id AND is_active = 1";
    $clientStmt = $db->prepare($clientQuery);
    $clientStmt->bindParam(':id', $clientId);
    $clientStmt->execute();
    $client = $clientStmt->fetch();
    
    if (!$client) {
        sendError('Client not found', 404);
    }
    
    $balanceBefore = $client['total_purchases'] - $client['total_paid'];
    $newTotalPaid = $client['total_paid'] + $amount;
    $balanceAfter = $client['total_purchases'] - $newTotalPaid;
    
    // Start transaction
    $db->beginTransaction();
    
    try {
        // Update client
        $updateQuery = "UPDATE clients SET total_paid = :total_paid, updated_at = NOW() WHERE id = :id";
        $updateStmt = $db->prepare($updateQuery);
        $updateStmt->bindParam(':total_paid', $newTotalPaid);
        $updateStmt->bindParam(':id', $clientId);
        $updateStmt->execute();
        
        // Record transaction
        $transQuery = "INSERT INTO client_transactions (
            client_id, type, amount, balance_before, balance_after, notes, created_at
        ) VALUES (
            :client_id, 'payment', :amount, :balance_before, :balance_after, :notes, NOW()
        )";
        $transStmt = $db->prepare($transQuery);
        $transStmt->bindParam(':client_id', $clientId);
        $transStmt->bindParam(':amount', $amount);
        $transStmt->bindParam(':balance_before', $balanceBefore);
        $transStmt->bindParam(':balance_after', $balanceAfter);
        $transStmt->bindValue(':notes', $data['notes'] ?? null);
        $transStmt->execute();
        
        $db->commit();
        
        getClient($db, $clientId);
    } catch (Exception $e) {
        $db->rollBack();
        sendError('Failed to record payment: ' . $e->getMessage(), 500);
    }
}

/**
 * Record purchase
 */
function recordPurchase($db, $data) {
    if (!isset($data['client_id']) || !isset($data['amount'])) {
        sendError('client_id and amount are required', 400);
    }
    
    $clientId = $data['client_id'];
    $amount = (float)$data['amount'];
    
    if ($amount <= 0) {
        sendError('Amount must be positive', 400);
    }
    
    // Get current client
    $clientQuery = "SELECT * FROM clients WHERE id = :id AND is_active = 1";
    $clientStmt = $db->prepare($clientQuery);
    $clientStmt->bindParam(':id', $clientId);
    $clientStmt->execute();
    $client = $clientStmt->fetch();
    
    if (!$client) {
        sendError('Client not found', 404);
    }
    
    $balanceBefore = $client['total_purchases'] - $client['total_paid'];
    $newTotalPurchases = $client['total_purchases'] + $amount;
    $balanceAfter = $newTotalPurchases - $client['total_paid'];
    
    // Start transaction
    $db->beginTransaction();
    
    try {
        // Update client
        $updateQuery = "UPDATE clients SET total_purchases = :total_purchases, updated_at = NOW() WHERE id = :id";
        $updateStmt = $db->prepare($updateQuery);
        $updateStmt->bindParam(':total_purchases', $newTotalPurchases);
        $updateStmt->bindParam(':id', $clientId);
        $updateStmt->execute();
        
        // Record transaction
        $transQuery = "INSERT INTO client_transactions (
            client_id, type, amount, balance_before, balance_after, invoice_number, notes, created_at
        ) VALUES (
            :client_id, 'purchase', :amount, :balance_before, :balance_after, :invoice_number, :notes, NOW()
        )";
        $transStmt = $db->prepare($transQuery);
        $transStmt->bindParam(':client_id', $clientId);
        $transStmt->bindParam(':amount', $amount);
        $transStmt->bindParam(':balance_before', $balanceBefore);
        $transStmt->bindParam(':balance_after', $balanceAfter);
        $transStmt->bindValue(':invoice_number', $data['invoice_number'] ?? null);
        $transStmt->bindValue(':notes', $data['notes'] ?? null);
        $transStmt->execute();
        
        $db->commit();
        
        getClient($db, $clientId);
    } catch (Exception $e) {
        $db->rollBack();
        sendError('Failed to record purchase: ' . $e->getMessage(), 500);
    }
}

/**
 * Get all cities
 */
function getCities($db) {
    $query = "SELECT DISTINCT city FROM clients WHERE city IS NOT NULL AND city != '' AND is_active = 1 ORDER BY city";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $cities = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    sendSuccess($cities, 'Cities retrieved successfully');
}

// ============================================
// Helper Functions
// ============================================

/**
 * Format client response to match Flutter model
 */
function formatClientResponse($client) {
    $totalPurchases = (float)$client['total_purchases'];
    $totalPaid = (float)$client['total_paid'];
    $balance = $totalPurchases - $totalPaid;
    
    return [
        'id' => (string)$client['id'],
        'code' => $client['code'],
        'name' => $client['name'],
        'phone' => $client['phone'],
        'email' => $client['email'],
        'address' => $client['address'],
        'city' => $client['city'],
        'notes' => $client['notes'],
        'is_active' => (bool)$client['is_active'],
        'total_purchases' => $totalPurchases,
        'total_paid' => $totalPaid,
        'balance' => $balance,
        'has_debt' => $balance > 0,
        'created_at' => $client['created_at'],
        'updated_at' => $client['updated_at']
    ];
}
