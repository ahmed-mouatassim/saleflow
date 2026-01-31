<?php
// ============================================
// Transactions API - واجهة برمجة تطبيقات الحركات
// REST API for Stock Transactions CRUD operations
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
                getTransaction($db, $id);
            } else if ($action === 'stats') {
                getTransactionStats($db);
            } else if ($action === 'by-product') {
                $productId = isset($_GET['product_id']) ? $_GET['product_id'] : null;
                getTransactionsByProduct($db, $productId);
            } else if ($action === 'by-type') {
                $type = isset($_GET['type']) ? $_GET['type'] : null;
                getTransactionsByType($db, $type);
            } else if ($action === 'by-date') {
                $startDate = isset($_GET['start_date']) ? $_GET['start_date'] : null;
                $endDate = isset($_GET['end_date']) ? $_GET['end_date'] : null;
                getTransactionsByDate($db, $startDate, $endDate);
            } else if ($action === 'pending-approval') {
                getPendingApproval($db);
            } else {
                getAllTransactions($db);
            }
            break;
            
        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);
            if ($action === 'approve') {
                approveTransaction($db, $data);
            } else {
                createTransaction($db, $data);
            }
            break;
            
        case 'PUT':
            $data = json_decode(file_get_contents("php://input"), true);
            updateTransaction($db, $id, $data);
            break;
            
        case 'DELETE':
            deleteTransaction($db, $id);
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
 * Get all transactions
 */
function getAllTransactions($db) {
    $query = "SELECT t.*, p.name as product_name, p.reference as product_reference
              FROM stock_transactions t
              LEFT JOIN products p ON t.product_id = p.id
              ORDER BY t.created_at DESC
              LIMIT 500";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $transactions = $stmt->fetchAll();
    $formattedTransactions = array_map('formatTransactionResponse', $transactions);
    
    sendSuccess($formattedTransactions, 'Transactions retrieved successfully');
}

/**
 * Get single transaction by ID
 */
function getTransaction($db, $id) {
    $query = "SELECT t.*, p.name as product_name, p.reference as product_reference
              FROM stock_transactions t
              LEFT JOIN products p ON t.product_id = p.id
              WHERE t.id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    $stmt->execute();
    
    $transaction = $stmt->fetch();
    
    if (!$transaction) {
        sendError('Transaction not found', 404);
    }
    
    sendSuccess(formatTransactionResponse($transaction), 'Transaction retrieved successfully');
}

/**
 * Create new transaction
 */
function createTransaction($db, $data) {
    // Validate required fields
    $required = ['type', 'product_id', 'quantity'];
    foreach ($required as $field) {
        if (!isset($data[$field]) || empty($data[$field])) {
            sendError("Field '{$field}' is required", 400);
        }
    }
    
    $db->beginTransaction();
    
    try {
        // Get current product stock
        $productQuery = "SELECT id, quantity FROM products WHERE id = :id";
        $productStmt = $db->prepare($productQuery);
        $productStmt->bindParam(':id', $data['product_id']);
        $productStmt->execute();
        $product = $productStmt->fetch();
        
        if (!$product) {
            throw new Exception('Product not found');
        }
        
        $type = $data['type'];
        $quantity = (int)$data['quantity'];
        $currentStock = (int)$product['quantity'];
        
        // Calculate new stock based on transaction type
        $stockChange = 0;
        $positiveTypes = ['receive', 'purchase', 'returnCustomer', 'adjust_add'];
        $negativeTypes = ['dispense', 'sale', 'expired', 'damaged', 'returnSupplier', 'adjust_remove', 'transfer'];
        
        if (in_array($type, $positiveTypes)) {
            $stockChange = $quantity;
        } else if (in_array($type, $negativeTypes)) {
            $stockChange = -$quantity;
            
            // Check if we have enough stock
            if (($currentStock + $stockChange) < 0) {
                throw new Exception('Insufficient stock. Current: ' . $currentStock);
            }
        }
        
        // Insert transaction
        $query = "INSERT INTO stock_transactions (
            type, product_id, quantity, warehouse_id, to_warehouse_id,
            reference_id, reason, notes, performed_by, approved_by,
            requires_approval, is_approved, created_at
        ) VALUES (
            :type, :product_id, :quantity, :warehouse_id, :to_warehouse_id,
            :reference_id, :reason, :notes, :performed_by, :approved_by,
            :requires_approval, :is_approved, NOW()
        )";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':type', $type);
        $stmt->bindParam(':product_id', $data['product_id']);
        $stmt->bindParam(':quantity', $quantity);
        $stmt->bindValue(':warehouse_id', $data['warehouse_id'] ?? null);
        $stmt->bindValue(':to_warehouse_id', $data['to_warehouse_id'] ?? null);
        $stmt->bindValue(':reference_id', $data['reference_id'] ?? null);
        $stmt->bindValue(':reason', $data['reason'] ?? null);
        $stmt->bindValue(':notes', $data['notes'] ?? null);
        $stmt->bindValue(':performed_by', $data['performed_by'] ?? 'system');
        $stmt->bindValue(':approved_by', $data['approved_by'] ?? null);
        $stmt->bindValue(':requires_approval', $data['requires_approval'] ?? false, PDO::PARAM_BOOL);
        $stmt->bindValue(':is_approved', $data['is_approved'] ?? true, PDO::PARAM_BOOL);
        $stmt->execute();
        
        $transactionId = $db->lastInsertId();
        
        // Update product stock
        $newStock = $currentStock + $stockChange;
        $updateStockQuery = "UPDATE products SET quantity = :quantity, updated_at = NOW() WHERE id = :id";
        $updateStockStmt = $db->prepare($updateStockQuery);
        $updateStockStmt->bindParam(':quantity', $newStock);
        $updateStockStmt->bindParam(':id', $data['product_id']);
        $updateStockStmt->execute();
        
        $db->commit();
        getTransaction($db, $transactionId);
        
    } catch (Exception $e) {
        $db->rollBack();
        sendError($e->getMessage(), 500);
    }
}

/**
 * Approve transaction
 */
function approveTransaction($db, $data) {
    if (!isset($data['transaction_id'])) {
        sendError('transaction_id is required', 400);
    }
    
    $query = "UPDATE stock_transactions SET 
              is_approved = 1, 
              approved_by = :approved_by 
              WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindValue(':approved_by', $data['approved_by'] ?? 'admin');
    $stmt->bindParam(':id', $data['transaction_id']);
    
    if ($stmt->execute()) {
        getTransaction($db, $data['transaction_id']);
    } else {
        sendError('Failed to approve transaction', 500);
    }
}

/**
 * Update transaction
 */
function updateTransaction($db, $id, $data) {
    if (!$id) {
        sendError('Transaction ID is required', 400);
    }
    
    // Only allow updating notes and reason
    $fields = [];
    $params = [':id' => $id];
    
    $allowedFields = ['notes', 'reason'];
    
    foreach ($allowedFields as $field) {
        if (isset($data[$field])) {
            $fields[] = "{$field} = :{$field}";
            $params[":{$field}"] = $data[$field];
        }
    }
    
    if (empty($fields)) {
        sendError('No fields to update', 400);
    }
    
    $query = "UPDATE stock_transactions SET " . implode(', ', $fields) . " WHERE id = :id";
    $stmt = $db->prepare($query);
    
    if ($stmt->execute($params)) {
        getTransaction($db, $id);
    } else {
        sendError('Failed to update transaction', 500);
    }
}

/**
 * Delete transaction (only recent and unapproved)
 */
function deleteTransaction($db, $id) {
    if (!$id) {
        sendError('Transaction ID is required', 400);
    }
    
    // Only allow deleting transactions from today and not approved
    $query = "DELETE FROM stock_transactions 
              WHERE id = :id 
              AND DATE(created_at) = CURDATE()
              AND is_approved = 0";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    
    if ($stmt->execute()) {
        if ($stmt->rowCount() > 0) {
            sendSuccess(null, 'Transaction deleted successfully');
        } else {
            sendError('Transaction not found or cannot be deleted', 404);
        }
    } else {
        sendError('Failed to delete transaction', 500);
    }
}

/**
 * Get transactions by product
 */
function getTransactionsByProduct($db, $productId) {
    if (!$productId) {
        sendError('product_id is required', 400);
    }
    
    $query = "SELECT t.*, p.name as product_name, p.reference as product_reference
              FROM stock_transactions t
              LEFT JOIN products p ON t.product_id = p.id
              WHERE t.product_id = :product_id
              ORDER BY t.created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':product_id', $productId);
    $stmt->execute();
    
    $transactions = $stmt->fetchAll();
    $formattedTransactions = array_map('formatTransactionResponse', $transactions);
    
    sendSuccess($formattedTransactions, 'Product transactions retrieved successfully');
}

/**
 * Get transactions by type
 */
function getTransactionsByType($db, $type) {
    if (!$type) {
        sendError('type is required', 400);
    }
    
    $query = "SELECT t.*, p.name as product_name, p.reference as product_reference
              FROM stock_transactions t
              LEFT JOIN products p ON t.product_id = p.id
              WHERE t.type = :type
              ORDER BY t.created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':type', $type);
    $stmt->execute();
    
    $transactions = $stmt->fetchAll();
    $formattedTransactions = array_map('formatTransactionResponse', $transactions);
    
    sendSuccess($formattedTransactions, 'Transactions by type retrieved successfully');
}

/**
 * Get transactions by date range
 */
function getTransactionsByDate($db, $startDate, $endDate) {
    if (!$startDate) {
        $startDate = date('Y-m-d', strtotime('-30 days'));
    }
    if (!$endDate) {
        $endDate = date('Y-m-d');
    }
    
    $query = "SELECT t.*, p.name as product_name, p.reference as product_reference
              FROM stock_transactions t
              LEFT JOIN products p ON t.product_id = p.id
              WHERE DATE(t.created_at) BETWEEN :start_date AND :end_date
              ORDER BY t.created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':start_date', $startDate);
    $stmt->bindParam(':end_date', $endDate);
    $stmt->execute();
    
    $transactions = $stmt->fetchAll();
    $formattedTransactions = array_map('formatTransactionResponse', $transactions);
    
    sendSuccess([
        'start_date' => $startDate,
        'end_date' => $endDate,
        'transactions' => $formattedTransactions
    ], 'Transactions retrieved successfully');
}

/**
 * Get pending approval transactions
 */
function getPendingApproval($db) {
    $query = "SELECT t.*, p.name as product_name, p.reference as product_reference
              FROM stock_transactions t
              LEFT JOIN products p ON t.product_id = p.id
              WHERE t.requires_approval = 1 AND t.is_approved = 0
              ORDER BY t.created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $transactions = $stmt->fetchAll();
    $formattedTransactions = array_map('formatTransactionResponse', $transactions);
    
    sendSuccess($formattedTransactions, 'Pending transactions retrieved successfully');
}

/**
 * Get transaction statistics
 */
function getTransactionStats($db) {
    // Today stats
    $todayQuery = "SELECT 
        type,
        COUNT(*) as count,
        SUM(quantity) as total_quantity
    FROM stock_transactions 
    WHERE DATE(created_at) = CURDATE()
    GROUP BY type";
    
    $todayStmt = $db->prepare($todayQuery);
    $todayStmt->execute();
    $todayStats = $todayStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // This month stats
    $monthQuery = "SELECT 
        type,
        COUNT(*) as count,
        SUM(quantity) as total_quantity
    FROM stock_transactions 
    WHERE MONTH(created_at) = MONTH(CURDATE()) 
    AND YEAR(created_at) = YEAR(CURDATE())
    GROUP BY type";
    
    $monthStmt = $db->prepare($monthQuery);
    $monthStmt->execute();
    $monthStats = $monthStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Recent transactions
    $recentQuery = "SELECT t.*, p.name as product_name, p.reference as product_reference
                   FROM stock_transactions t
                   LEFT JOIN products p ON t.product_id = p.id
                   ORDER BY t.created_at DESC
                   LIMIT 10";
    $recentStmt = $db->prepare($recentQuery);
    $recentStmt->execute();
    $recentTransactions = $recentStmt->fetchAll();
    
    sendSuccess([
        'today' => $todayStats,
        'this_month' => $monthStats,
        'recent' => array_map('formatTransactionResponse', $recentTransactions)
    ], 'Statistics retrieved successfully');
}

// ============================================
// Helper Functions
// ============================================

/**
 * Format transaction response
 */
function formatTransactionResponse($transaction) {
    return [
        'id' => (string)$transaction['id'],
        'type' => $transaction['type'],
        'product_id' => (string)$transaction['product_id'],
        'product_name' => $transaction['product_name'] ?? null,
        'product_reference' => $transaction['product_reference'] ?? null,
        'quantity' => (int)$transaction['quantity'],
        'warehouse_id' => $transaction['warehouse_id'],
        'to_warehouse_id' => $transaction['to_warehouse_id'],
        'reference_id' => $transaction['reference_id'],
        'reason' => $transaction['reason'] ?? null,
        'notes' => $transaction['notes'],
        'performed_by' => $transaction['performed_by'] ?? 'system',
        'approved_by' => $transaction['approved_by'],
        'requires_approval' => (bool)($transaction['requires_approval'] ?? false),
        'is_approved' => (bool)($transaction['is_approved'] ?? true),
        'created_at' => $transaction['created_at']
    ];
}
