<?php
// ============================================
// Warehouses API - واجهة برمجة تطبيقات المستودعات
// REST API for Warehouses CRUD operations
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
                getWarehouse($db, $id);
            } else if ($action === 'stats') {
                getWarehouseStats($db);
            } else if ($action === 'stock') {
                $warehouseId = isset($_GET['warehouse_id']) ? $_GET['warehouse_id'] : null;
                getWarehouseStock($db, $warehouseId);
            } else if ($action === 'default') {
                getDefaultWarehouse($db);
            } else {
                getAllWarehouses($db);
            }
            break;
            
        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);
            if ($action === 'set-default') {
                setDefaultWarehouse($db, $data);
            } else if ($action === 'transfer') {
                transferStock($db, $data);
            } else {
                createWarehouse($db, $data);
            }
            break;
            
        case 'PUT':
            $data = json_decode(file_get_contents("php://input"), true);
            updateWarehouse($db, $id, $data);
            break;
            
        case 'DELETE':
            deleteWarehouse($db, $id);
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
 * Get all warehouses
 */
function getAllWarehouses($db) {
    $query = "SELECT * FROM warehouses WHERE is_active = 1 ORDER BY is_default DESC, name ASC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $warehouses = $stmt->fetchAll();
    $formattedWarehouses = array_map('formatWarehouseResponse', $warehouses);
    
    sendSuccess($formattedWarehouses, 'Warehouses retrieved successfully');
}

/**
 * Get single warehouse by ID
 */
function getWarehouse($db, $id) {
    $query = "SELECT * FROM warehouses WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    $stmt->execute();
    
    $warehouse = $stmt->fetch();
    
    if (!$warehouse) {
        sendError('Warehouse not found', 404);
    }
    
    sendSuccess(formatWarehouseResponse($warehouse), 'Warehouse retrieved successfully');
}

/**
 * Create new warehouse
 */
function createWarehouse($db, $data) {
    // Validate required fields
    if (!isset($data['name']) || empty($data['name'])) {
        sendError("Field 'name' is required", 400);
    }
    
    // Generate warehouse code
    $codeQuery = "SELECT MAX(CAST(SUBSTRING(code, 4) AS UNSIGNED)) as max_code FROM warehouses";
    $codeStmt = $db->prepare($codeQuery);
    $codeStmt->execute();
    $result = $codeStmt->fetch();
    $nextCode = ($result['max_code'] ?? 0) + 1;
    $code = 'WH-' . str_pad($nextCode, 3, '0', STR_PAD_LEFT);
    
    // Check if this is the first warehouse
    $countQuery = "SELECT COUNT(*) as count FROM warehouses";
    $countStmt = $db->prepare($countQuery);
    $countStmt->execute();
    $count = $countStmt->fetch();
    $isDefault = $count['count'] == 0 || ($data['is_default'] ?? false);
    
    $db->beginTransaction();
    
    try {
        // If setting as default, remove default from others
        if ($isDefault) {
            $updateQuery = "UPDATE warehouses SET is_default = 0";
            $db->exec($updateQuery);
        }
        
        $query = "INSERT INTO warehouses (
            code, name, address, phone, email, manager_id,
            is_active, is_default, created_at, updated_at
        ) VALUES (
            :code, :name, :address, :phone, :email, :manager_id,
            1, :is_default, NOW(), NOW()
        )";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':code', $code);
        $stmt->bindParam(':name', $data['name']);
        $stmt->bindValue(':address', $data['address'] ?? null);
        $stmt->bindValue(':phone', $data['phone'] ?? null);
        $stmt->bindValue(':email', $data['email'] ?? null);
        $stmt->bindValue(':manager_id', $data['manager_id'] ?? null);
        $stmt->bindParam(':is_default', $isDefault, PDO::PARAM_BOOL);
        
        if ($stmt->execute()) {
            $db->commit();
            $newId = $db->lastInsertId();
            getWarehouse($db, $newId);
        } else {
            throw new Exception('Failed to create warehouse');
        }
    } catch (Exception $e) {
        $db->rollBack();
        sendError($e->getMessage(), 500);
    }
}

/**
 * Update existing warehouse
 */
function updateWarehouse($db, $id, $data) {
    if (!$id) {
        sendError('Warehouse ID is required', 400);
    }
    
    // Check if warehouse exists
    $checkQuery = "SELECT id FROM warehouses WHERE id = :id";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->bindParam(':id', $id);
    $checkStmt->execute();
    
    if (!$checkStmt->fetch()) {
        sendError('Warehouse not found', 404);
    }
    
    $db->beginTransaction();
    
    try {
        // If setting as default, remove default from others
        if (isset($data['is_default']) && $data['is_default']) {
            $updateQuery = "UPDATE warehouses SET is_default = 0 WHERE id != :id";
            $updateStmt = $db->prepare($updateQuery);
            $updateStmt->bindParam(':id', $id);
            $updateStmt->execute();
        }
        
        // Build dynamic update query
        $fields = [];
        $params = [':id' => $id];
        
        $allowedFields = [
            'name', 'address', 'phone', 'email', 'manager_id', 'is_active', 'is_default'
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
        
        $query = "UPDATE warehouses SET " . implode(', ', $fields) . " WHERE id = :id";
        $stmt = $db->prepare($query);
        
        if ($stmt->execute($params)) {
            $db->commit();
            getWarehouse($db, $id);
        } else {
            throw new Exception('Failed to update warehouse');
        }
    } catch (Exception $e) {
        $db->rollBack();
        sendError($e->getMessage(), 500);
    }
}

/**
 * Delete warehouse (soft delete)
 */
function deleteWarehouse($db, $id) {
    if (!$id) {
        sendError('Warehouse ID is required', 400);
    }
    
    // Check if it's the default warehouse
    $checkQuery = "SELECT is_default FROM warehouses WHERE id = :id";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->bindParam(':id', $id);
    $checkStmt->execute();
    $warehouse = $checkStmt->fetch();
    
    if (!$warehouse) {
        sendError('Warehouse not found', 404);
    }
    
    $db->beginTransaction();
    
    try {
        // If deleting default, set another as default
        if ($warehouse['is_default']) {
            $setDefaultQuery = "UPDATE warehouses SET is_default = 1 
                               WHERE id != :id AND is_active = 1 
                               ORDER BY created_at ASC LIMIT 1";
            $setDefaultStmt = $db->prepare($setDefaultQuery);
            $setDefaultStmt->bindParam(':id', $id);
            $setDefaultStmt->execute();
        }
        
        $query = "UPDATE warehouses SET is_active = 0, updated_at = NOW() WHERE id = :id";
        $stmt = $db->prepare($query);
        $stmt->bindParam(':id', $id);
        
        if ($stmt->execute()) {
            $db->commit();
            sendSuccess(null, 'Warehouse deleted successfully');
        } else {
            throw new Exception('Failed to delete warehouse');
        }
    } catch (Exception $e) {
        $db->rollBack();
        sendError($e->getMessage(), 500);
    }
}

/**
 * Get default warehouse
 */
function getDefaultWarehouse($db) {
    $query = "SELECT * FROM warehouses WHERE is_default = 1 AND is_active = 1 LIMIT 1";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $warehouse = $stmt->fetch();
    
    if (!$warehouse) {
        // If no default, return first active
        $query = "SELECT * FROM warehouses WHERE is_active = 1 ORDER BY created_at ASC LIMIT 1";
        $stmt = $db->prepare($query);
        $stmt->execute();
        $warehouse = $stmt->fetch();
    }
    
    if (!$warehouse) {
        sendError('No warehouses found', 404);
    }
    
    sendSuccess(formatWarehouseResponse($warehouse), 'Default warehouse retrieved successfully');
}

/**
 * Set default warehouse
 */
function setDefaultWarehouse($db, $data) {
    if (!isset($data['warehouse_id'])) {
        sendError('warehouse_id is required', 400);
    }
    
    $warehouseId = $data['warehouse_id'];
    
    $db->beginTransaction();
    
    try {
        // Remove default from all
        $removeQuery = "UPDATE warehouses SET is_default = 0";
        $db->exec($removeQuery);
        
        // Set new default
        $setQuery = "UPDATE warehouses SET is_default = 1, updated_at = NOW() WHERE id = :id";
        $setStmt = $db->prepare($setQuery);
        $setStmt->bindParam(':id', $warehouseId);
        
        if ($setStmt->execute() && $setStmt->rowCount() > 0) {
            $db->commit();
            getWarehouse($db, $warehouseId);
        } else {
            throw new Exception('Warehouse not found');
        }
    } catch (Exception $e) {
        $db->rollBack();
        sendError($e->getMessage(), 500);
    }
}

/**
 * Get warehouse stock (products in warehouse)
 */
function getWarehouseStock($db, $warehouseId) {
    // For now, products are not warehouse-specific
    // This is a placeholder for future multi-warehouse stock management
    
    $query = "SELECT 
        p.id, p.reference, p.name, p.category, p.quantity,
        p.min_stock, p.purchase_price, p.selling_price,
        (p.quantity * p.purchase_price) as stock_value
    FROM products p 
    WHERE p.is_active = 1
    ORDER BY p.name ASC";
    
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $products = $stmt->fetchAll();
    
    $totalProducts = count($products);
    $totalQuantity = array_sum(array_column($products, 'quantity'));
    $totalValue = array_sum(array_column($products, 'stock_value'));
    $lowStockCount = count(array_filter($products, function($p) {
        return $p['quantity'] <= $p['min_stock'];
    }));
    
    sendSuccess([
        'warehouse_id' => $warehouseId,
        'summary' => [
            'total_products' => $totalProducts,
            'total_quantity' => $totalQuantity,
            'total_value' => $totalValue,
            'low_stock_count' => $lowStockCount
        ],
        'products' => $products
    ], 'Warehouse stock retrieved successfully');
}

/**
 * Transfer stock between warehouses
 */
function transferStock($db, $data) {
    // Placeholder for future multi-warehouse stock transfer
    if (!isset($data['from_warehouse']) || !isset($data['to_warehouse']) || 
        !isset($data['product_id']) || !isset($data['quantity'])) {
        sendError('from_warehouse, to_warehouse, product_id and quantity are required', 400);
    }
    
    // For now, just log the transfer request
    sendSuccess([
        'message' => 'Stock transfer feature coming soon',
        'request' => $data
    ], 'Transfer request received');
}

/**
 * Get warehouse statistics
 */
function getWarehouseStats($db) {
    $query = "SELECT 
        COUNT(*) as total_warehouses,
        SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) as active_warehouses,
        SUM(CASE WHEN is_default = 1 THEN 1 ELSE 0 END) as default_count
    FROM warehouses";
    
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $stats = $stmt->fetch();
    
    // Get total stock value (across all products)
    $stockQuery = "SELECT 
        COUNT(*) as total_products,
        SUM(quantity) as total_quantity,
        SUM(quantity * purchase_price) as total_stock_value
    FROM products WHERE is_active = 1";
    
    $stockStmt = $db->prepare($stockQuery);
    $stockStmt->execute();
    $stockStats = $stockStmt->fetch();
    
    sendSuccess([
        'warehouses' => $stats,
        'stock' => $stockStats
    ], 'Statistics retrieved successfully');
}

// ============================================
// Helper Functions
// ============================================

/**
 * Format warehouse response to match Flutter model
 */
function formatWarehouseResponse($warehouse) {
    return [
        'id' => (string)$warehouse['id'],
        'code' => $warehouse['code'],
        'name' => $warehouse['name'],
        'address' => $warehouse['address'],
        'phone' => $warehouse['phone'],
        'email' => $warehouse['email'],
        'manager_id' => $warehouse['manager_id'],
        'is_active' => (bool)$warehouse['is_active'],
        'is_default' => (bool)$warehouse['is_default'],
        'created_at' => $warehouse['created_at'],
        'updated_at' => $warehouse['updated_at']
    ];
}
