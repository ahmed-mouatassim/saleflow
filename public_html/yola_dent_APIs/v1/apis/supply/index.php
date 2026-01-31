<?php
// ============================================
// Supply API - واجهة برمجة تطبيقات التوريد
// REST API for Supply/Purchase Orders CRUD operations
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
                getSupplyOrder($db, $id);
            } else if ($action === 'stats') {
                getSupplyStats($db);
            } else if ($action === 'by-supplier') {
                $supplierId = isset($_GET['supplier_id']) ? $_GET['supplier_id'] : null;
                getOrdersBySupplier($db, $supplierId);
            } else if ($action === 'pending') {
                getPendingOrders($db);
            } else {
                getAllSupplyOrders($db);
            }
            break;
            
        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);
            if ($action === 'receive') {
                receiveOrder($db, $data);
            } else if ($action === 'receive-item') {
                receiveItem($db, $data);
            } else if ($action === 'approve') {
                approveOrder($db, $data);
            } else if ($action === 'cancel') {
                cancelOrder($db, $data);
            } else {
                createSupplyOrder($db, $data);
            }
            break;
            
        case 'PUT':
            $data = json_decode(file_get_contents("php://input"), true);
            updateSupplyOrder($db, $id, $data);
            break;
            
        case 'DELETE':
            deleteSupplyOrder($db, $id);
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
 * Get all supply orders
 */
function getAllSupplyOrders($db) {
    $query = "SELECT * FROM supply_orders ORDER BY created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $orders = $stmt->fetchAll();
    $formattedOrders = [];
    
    foreach ($orders as $order) {
        $formattedOrders[] = formatOrderWithItems($db, $order);
    }
    
    sendSuccess($formattedOrders, 'Supply orders retrieved successfully');
}

/**
 * Get single supply order by ID
 */
function getSupplyOrder($db, $id) {
    $query = "SELECT * FROM supply_orders WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    $stmt->execute();
    
    $order = $stmt->fetch();
    
    if (!$order) {
        sendError('Supply order not found', 404);
    }
    
    sendSuccess(formatOrderWithItems($db, $order), 'Supply order retrieved successfully');
}

/**
 * Create new supply order
 */
function createSupplyOrder($db, $data) {
    // Validate required fields
    if (!isset($data['items']) || empty($data['items'])) {
        sendError("Field 'items' is required", 400);
    }
    
    // Generate order number
    $orderNumber = 'PO-' . date('Ymd') . '-' . substr(time(), -4);
    
    $db->beginTransaction();
    
    try {
        // Calculate total
        $totalAmount = 0;
        foreach ($data['items'] as $item) {
            $totalAmount += $item['unit_price'] * $item['quantity_ordered'];
        }
        
        // Insert order
        $query = "INSERT INTO supply_orders (
            order_number, supplier_id, supplier_name, status, notes,
            created_by, total_amount, expected_delivery, created_at, updated_at
        ) VALUES (
            :order_number, :supplier_id, :supplier_name, :status, :notes,
            :created_by, :total_amount, :expected_delivery, NOW(), NOW()
        )";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':order_number', $orderNumber);
        $stmt->bindValue(':supplier_id', $data['supplier_id'] ?? null);
        $stmt->bindValue(':supplier_name', $data['supplier_name'] ?? null);
        $stmt->bindValue(':status', $data['status'] ?? 'draft');
        $stmt->bindValue(':notes', $data['notes'] ?? null);
        $stmt->bindValue(':created_by', $data['created_by'] ?? null);
        $stmt->bindParam(':total_amount', $totalAmount);
        $stmt->bindValue(':expected_delivery', $data['expected_delivery'] ?? null);
        $stmt->execute();
        
        $orderId = $db->lastInsertId();
        
        // Insert order items
        foreach ($data['items'] as $item) {
            $itemQuery = "INSERT INTO supply_order_items (
                order_id, product_id, product_reference, product_name,
                quantity_ordered, quantity_received, unit_price, line_total
            ) VALUES (
                :order_id, :product_id, :product_reference, :product_name,
                :quantity_ordered, 0, :unit_price, :line_total
            )";
            
            $lineTotal = $item['unit_price'] * $item['quantity_ordered'];
            
            $itemStmt = $db->prepare($itemQuery);
            $itemStmt->bindParam(':order_id', $orderId);
            $itemStmt->bindParam(':product_id', $item['product_id']);
            $itemStmt->bindParam(':product_reference', $item['product_reference']);
            $itemStmt->bindParam(':product_name', $item['product_name']);
            $itemStmt->bindParam(':quantity_ordered', $item['quantity_ordered']);
            $itemStmt->bindParam(':unit_price', $item['unit_price']);
            $itemStmt->bindParam(':line_total', $lineTotal);
            $itemStmt->execute();
        }
        
        $db->commit();
        getSupplyOrder($db, $orderId);
        
    } catch (Exception $e) {
        $db->rollBack();
        sendError('Failed to create order: ' . $e->getMessage(), 500);
    }
}

/**
 * Approve order
 */
function approveOrder($db, $data) {
    if (!isset($data['order_id'])) {
        sendError('order_id is required', 400);
    }
    
    $query = "UPDATE supply_orders SET status = 'approved', updated_at = NOW() WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $data['order_id']);
    
    if ($stmt->execute()) {
        getSupplyOrder($db, $data['order_id']);
    } else {
        sendError('Failed to approve order', 500);
    }
}

/**
 * Receive full order - update stock
 */
function receiveOrder($db, $data) {
    if (!isset($data['order_id'])) {
        sendError('order_id is required', 400);
    }
    
    $orderId = $data['order_id'];
    
    $db->beginTransaction();
    
    try {
        // Get order
        $orderQuery = "SELECT * FROM supply_orders WHERE id = :id";
        $orderStmt = $db->prepare($orderQuery);
        $orderStmt->bindParam(':id', $orderId);
        $orderStmt->execute();
        $order = $orderStmt->fetch();
        
        if (!$order) {
            throw new Exception('Order not found');
        }
        
        // Get order items
        $itemsQuery = "SELECT * FROM supply_order_items WHERE order_id = :order_id";
        $itemsStmt = $db->prepare($itemsQuery);
        $itemsStmt->bindParam(':order_id', $orderId);
        $itemsStmt->execute();
        $items = $itemsStmt->fetchAll();
        
        // Update stock for each item
        foreach ($items as $item) {
            $remainingQty = $item['quantity_ordered'] - $item['quantity_received'];
            
            if ($remainingQty > 0) {
                // Update product stock
                $updateStockQuery = "UPDATE products SET quantity = quantity + :qty, updated_at = NOW() WHERE id = :product_id";
                $updateStockStmt = $db->prepare($updateStockQuery);
                $updateStockStmt->bindParam(':qty', $remainingQty);
                $updateStockStmt->bindParam(':product_id', $item['product_id']);
                $updateStockStmt->execute();
                
                // Update item received quantity
                $updateItemQuery = "UPDATE supply_order_items SET quantity_received = quantity_ordered WHERE id = :id";
                $updateItemStmt = $db->prepare($updateItemQuery);
                $updateItemStmt->bindParam(':id', $item['id']);
                $updateItemStmt->execute();
                
                // Log stock transaction
                logStockTransaction($db, $item['product_id'], 'purchase', $remainingQty, [
                    'order_id' => $orderId,
                    'order_number' => $order['order_number']
                ]);
            }
        }
        
        // Update order status
        $updateOrderQuery = "UPDATE supply_orders SET 
                            status = 'received', 
                            received_at = NOW(), 
                            updated_at = NOW() 
                            WHERE id = :id";
        $updateOrderStmt = $db->prepare($updateOrderQuery);
        $updateOrderStmt->bindParam(':id', $orderId);
        $updateOrderStmt->execute();
        
        // Update supplier balance if exists
        if ($order['supplier_id']) {
            $updateSupplierQuery = "UPDATE suppliers SET 
                                   current_balance = current_balance + :amount,
                                   updated_at = NOW()
                                   WHERE id = :supplier_id";
            $updateSupplierStmt = $db->prepare($updateSupplierQuery);
            $updateSupplierStmt->bindParam(':amount', $order['total_amount']);
            $updateSupplierStmt->bindParam(':supplier_id', $order['supplier_id']);
            $updateSupplierStmt->execute();
        }
        
        $db->commit();
        getSupplyOrder($db, $orderId);
        
    } catch (Exception $e) {
        $db->rollBack();
        sendError($e->getMessage(), 500);
    }
}

/**
 * Receive single item
 */
function receiveItem($db, $data) {
    if (!isset($data['item_id']) || !isset($data['quantity'])) {
        sendError('item_id and quantity are required', 400);
    }
    
    $itemId = $data['item_id'];
    $quantity = (int)$data['quantity'];
    
    $db->beginTransaction();
    
    try {
        // Get item with order info
        $itemQuery = "SELECT soi.*, so.order_number, so.supplier_id, so.id as order_id
                     FROM supply_order_items soi
                     JOIN supply_orders so ON soi.order_id = so.id
                     WHERE soi.id = :id";
        $itemStmt = $db->prepare($itemQuery);
        $itemStmt->bindParam(':id', $itemId);
        $itemStmt->execute();
        $item = $itemStmt->fetch();
        
        if (!$item) {
            throw new Exception('Item not found');
        }
        
        $maxReceivable = $item['quantity_ordered'] - $item['quantity_received'];
        if ($quantity > $maxReceivable) {
            $quantity = $maxReceivable;
        }
        
        if ($quantity <= 0) {
            throw new Exception('Item already fully received');
        }
        
        // Update product stock
        $updateStockQuery = "UPDATE products SET quantity = quantity + :qty, updated_at = NOW() WHERE id = :product_id";
        $updateStockStmt = $db->prepare($updateStockQuery);
        $updateStockStmt->bindParam(':qty', $quantity);
        $updateStockStmt->bindParam(':product_id', $item['product_id']);
        $updateStockStmt->execute();
        
        // Update item received quantity
        $newReceived = $item['quantity_received'] + $quantity;
        $updateItemQuery = "UPDATE supply_order_items SET quantity_received = :received WHERE id = :id";
        $updateItemStmt = $db->prepare($updateItemQuery);
        $updateItemStmt->bindParam(':received', $newReceived);
        $updateItemStmt->bindParam(':id', $itemId);
        $updateItemStmt->execute();
        
        // Log stock transaction
        logStockTransaction($db, $item['product_id'], 'purchase', $quantity, [
            'order_id' => $item['order_id'],
            'order_number' => $item['order_number'],
            'partial' => true
        ]);
        
        // Check if all items are received and update order status
        $checkQuery = "SELECT SUM(quantity_ordered) as total_ordered, SUM(quantity_received) as total_received 
                      FROM supply_order_items WHERE order_id = :order_id";
        $checkStmt = $db->prepare($checkQuery);
        $checkStmt->bindParam(':order_id', $item['order_id']);
        $checkStmt->execute();
        $totals = $checkStmt->fetch();
        
        $newStatus = 'partiallyReceived';
        if ($totals['total_received'] >= $totals['total_ordered']) {
            $newStatus = 'received';
        }
        
        $updateOrderQuery = "UPDATE supply_orders SET 
                            status = :status, 
                            received_at = CASE WHEN :status = 'received' THEN NOW() ELSE received_at END,
                            updated_at = NOW() 
                            WHERE id = :id";
        $updateOrderStmt = $db->prepare($updateOrderQuery);
        $updateOrderStmt->bindParam(':status', $newStatus);
        $updateOrderStmt->bindParam(':id', $item['order_id']);
        $updateOrderStmt->execute();
        
        $db->commit();
        getSupplyOrder($db, $item['order_id']);
        
    } catch (Exception $e) {
        $db->rollBack();
        sendError($e->getMessage(), 500);
    }
}

/**
 * Cancel order
 */
function cancelOrder($db, $data) {
    if (!isset($data['order_id'])) {
        sendError('order_id is required', 400);
    }
    
    $query = "UPDATE supply_orders SET status = 'cancelled', updated_at = NOW() WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $data['order_id']);
    
    if ($stmt->execute()) {
        sendSuccess(null, 'Order cancelled successfully');
    } else {
        sendError('Failed to cancel order', 500);
    }
}

/**
 * Update supply order
 */
function updateSupplyOrder($db, $id, $data) {
    if (!$id) {
        sendError('Order ID is required', 400);
    }
    
    // Build dynamic update query
    $fields = [];
    $params = [':id' => $id];
    
    $allowedFields = [
        'status', 'notes', 'supplier_id', 'supplier_name', 'expected_delivery'
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
    
    $query = "UPDATE supply_orders SET " . implode(', ', $fields) . " WHERE id = :id";
    $stmt = $db->prepare($query);
    
    if ($stmt->execute($params)) {
        getSupplyOrder($db, $id);
    } else {
        sendError('Failed to update order', 500);
    }
}

/**
 * Delete supply order
 */
function deleteSupplyOrder($db, $id) {
    if (!$id) {
        sendError('Order ID is required', 400);
    }
    
    $query = "DELETE FROM supply_orders WHERE id = :id AND status = 'draft'";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    
    if ($stmt->execute()) {
        if ($stmt->rowCount() > 0) {
            sendSuccess(null, 'Order deleted successfully');
        } else {
            sendError('Order not found or cannot be deleted', 404);
        }
    } else {
        sendError('Failed to delete order', 500);
    }
}

/**
 * Get pending orders
 */
function getPendingOrders($db) {
    $query = "SELECT * FROM supply_orders 
              WHERE status IN ('draft', 'pending', 'approved', 'ordered', 'partiallyReceived') 
              ORDER BY created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $orders = $stmt->fetchAll();
    $formattedOrders = [];
    
    foreach ($orders as $order) {
        $formattedOrders[] = formatOrderWithItems($db, $order);
    }
    
    sendSuccess($formattedOrders, 'Pending orders retrieved successfully');
}

/**
 * Get orders by supplier
 */
function getOrdersBySupplier($db, $supplierId) {
    if (!$supplierId) {
        sendError('supplier_id is required', 400);
    }
    
    $query = "SELECT * FROM supply_orders WHERE supplier_id = :supplier_id ORDER BY created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':supplier_id', $supplierId);
    $stmt->execute();
    
    $orders = $stmt->fetchAll();
    $formattedOrders = [];
    
    foreach ($orders as $order) {
        $formattedOrders[] = formatOrderWithItems($db, $order);
    }
    
    sendSuccess($formattedOrders, 'Supplier orders retrieved successfully');
}

/**
 * Get supply statistics
 */
function getSupplyStats($db) {
    // This month stats
    $monthQuery = "SELECT 
        COUNT(*) as orders_count,
        COALESCE(SUM(total_amount), 0) as total_value,
        SUM(CASE WHEN status = 'received' THEN 1 ELSE 0 END) as received_count,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_count
    FROM supply_orders 
    WHERE MONTH(created_at) = MONTH(CURDATE()) 
    AND YEAR(created_at) = YEAR(CURDATE())";
    
    $monthStmt = $db->prepare($monthQuery);
    $monthStmt->execute();
    $month = $monthStmt->fetch();
    
    // Status breakdown
    $statusQuery = "SELECT status, COUNT(*) as count 
                   FROM supply_orders 
                   WHERE status != 'cancelled'
                   GROUP BY status";
    $statusStmt = $db->prepare($statusQuery);
    $statusStmt->execute();
    $statusBreakdown = $statusStmt->fetchAll(PDO::FETCH_KEY_PAIR);
    
    // Top suppliers
    $suppliersQuery = "SELECT supplier_name, COUNT(*) as order_count, SUM(total_amount) as total_value
                      FROM supply_orders 
                      WHERE supplier_name IS NOT NULL 
                      GROUP BY supplier_name 
                      ORDER BY total_value DESC 
                      LIMIT 5";
    $suppliersStmt = $db->prepare($suppliersQuery);
    $suppliersStmt->execute();
    $topSuppliers = $suppliersStmt->fetchAll();
    
    sendSuccess([
        'this_month' => $month,
        'status_breakdown' => $statusBreakdown,
        'top_suppliers' => $topSuppliers
    ], 'Statistics retrieved successfully');
}

// ============================================
// Helper Functions
// ============================================

/**
 * Format order with its items
 */
function formatOrderWithItems($db, $order) {
    // Get order items
    $itemsQuery = "SELECT * FROM supply_order_items WHERE order_id = :order_id";
    $itemsStmt = $db->prepare($itemsQuery);
    $itemsStmt->bindParam(':order_id', $order['id']);
    $itemsStmt->execute();
    $items = $itemsStmt->fetchAll();
    
    $formattedItems = array_map(function($item) {
        return [
            'id' => (string)$item['id'],
            'product_id' => (string)$item['product_id'],
            'product_reference' => $item['product_reference'],
            'product_name' => $item['product_name'],
            'quantity_ordered' => (int)$item['quantity_ordered'],
            'quantity_received' => (int)$item['quantity_received'],
            'unit_price' => (float)$item['unit_price'],
            'line_total' => (float)$item['line_total'],
            'is_fully_received' => (int)$item['quantity_received'] >= (int)$item['quantity_ordered']
        ];
    }, $items);
    
    $totalOrdered = array_sum(array_column($items, 'quantity_ordered'));
    $totalReceived = array_sum(array_column($items, 'quantity_received'));
    
    return [
        'id' => (string)$order['id'],
        'order_number' => $order['order_number'],
        'supplier_id' => $order['supplier_id'],
        'supplier_name' => $order['supplier_name'],
        'items' => $formattedItems,
        'status' => $order['status'],
        'notes' => $order['notes'],
        'created_by' => $order['created_by'],
        'total_amount' => (float)$order['total_amount'],
        'total_items' => count($items),
        'total_quantity' => $totalOrdered,
        'total_received' => $totalReceived,
        'received_percentage' => $totalOrdered > 0 ? ($totalReceived / $totalOrdered) * 100 : 0,
        'is_fully_received' => $totalReceived >= $totalOrdered,
        'expected_delivery' => $order['expected_delivery'],
        'received_at' => $order['received_at'],
        'created_at' => $order['created_at'],
        'updated_at' => $order['updated_at']
    ];
}

/**
 * Log stock transaction
 */
function logStockTransaction($db, $productId, $type, $quantity, $data = []) {
    $query = "INSERT INTO stock_transactions (
        product_id, type, quantity, reference_id, notes, created_at
    ) VALUES (
        :product_id, :type, :quantity, :reference_id, :notes, NOW()
    )";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':product_id', $productId);
    $stmt->bindParam(':type', $type);
    $stmt->bindParam(':quantity', $quantity);
    $stmt->bindValue(':reference_id', $data['order_id'] ?? null);
    $stmt->bindValue(':notes', json_encode($data));
    $stmt->execute();
}
