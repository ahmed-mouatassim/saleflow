<?php
// ============================================
// Sales API - واجهة برمجة تطبيقات المبيعات
// REST API for Sales Orders CRUD operations
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
                getSalesOrder($db, $id);
            } else if ($action === 'stats') {
                getSalesStats($db);
            } else if ($action === 'daily-report') {
                $date = isset($_GET['date']) ? $_GET['date'] : date('Y-m-d');
                getDailyReport($db, $date);
            } else if ($action === 'top-products') {
                $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
                getTopProducts($db, $limit);
            } else if ($action === 'by-customer') {
                $customerId = isset($_GET['customer_id']) ? $_GET['customer_id'] : null;
                getOrdersByCustomer($db, $customerId);
            } else {
                getAllSalesOrders($db);
            }
            break;
            
        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);
            if ($action === 'complete') {
                completeSale($db, $data);
            } else if ($action === 'payment') {
                addPayment($db, $data);
            } else if ($action === 'cancel') {
                cancelOrder($db, $data);
            } else {
                createSalesOrder($db, $data);
            }
            break;
            
        case 'PUT':
            $data = json_decode(file_get_contents("php://input"), true);
            updateSalesOrder($db, $id, $data);
            break;
            
        case 'DELETE':
            deleteSalesOrder($db, $id);
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
 * Get all sales orders
 */
function getAllSalesOrders($db) {
    $query = "SELECT * FROM sales_orders ORDER BY created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $orders = $stmt->fetchAll();
    $formattedOrders = [];
    
    foreach ($orders as $order) {
        $formattedOrders[] = formatOrderWithItems($db, $order);
    }
    
    sendSuccess($formattedOrders, 'Sales orders retrieved successfully');
}

/**
 * Get single sales order by ID
 */
function getSalesOrder($db, $id) {
    $query = "SELECT * FROM sales_orders WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    $stmt->execute();
    
    $order = $stmt->fetch();
    
    if (!$order) {
        sendError('Sales order not found', 404);
    }
    
    sendSuccess(formatOrderWithItems($db, $order), 'Sales order retrieved successfully');
}

/**
 * Create new sales order
 */
function createSalesOrder($db, $data) {
    // Validate required fields
    if (!isset($data['items']) || empty($data['items'])) {
        sendError("Field 'items' is required", 400);
    }
    
    // Generate order number
    $orderNumber = 'SO-' . date('Ymd') . '-' . substr(time(), -4);
    
    $db->beginTransaction();
    
    try {
        // Calculate totals
        $subtotal = 0;
        foreach ($data['items'] as $item) {
            $lineTotal = $item['unit_price'] * $item['quantity'];
            if (isset($item['discount'])) {
                $lineTotal -= $item['discount'];
            } else if (isset($item['discount_percentage'])) {
                $lineTotal -= $lineTotal * ($item['discount_percentage'] / 100);
            }
            $subtotal += $lineTotal;
        }
        
        $discount = $data['discount'] ?? 0;
        $discountPercentage = $data['discount_percentage'] ?? 0;
        $totalDiscount = $discount + ($subtotal * ($discountPercentage / 100));
        $totalAmount = $subtotal - $totalDiscount;
        $paidAmount = $data['paid_amount'] ?? 0;
        
        // Insert order
        $query = "INSERT INTO sales_orders (
            order_number, invoice_number, customer_id, customer_name, customer_phone,
            seller_id, seller_name, status, payment_method, subtotal, 
            discount, discount_percentage, total_amount, paid_amount, notes, created_at, updated_at
        ) VALUES (
            :order_number, :invoice_number, :customer_id, :customer_name, :customer_phone,
            :seller_id, :seller_name, :status, :payment_method, :subtotal,
            :discount, :discount_percentage, :total_amount, :paid_amount, :notes, NOW(), NOW()
        )";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':order_number', $orderNumber);
        $stmt->bindValue(':invoice_number', $data['invoice_number'] ?? null);
        $stmt->bindValue(':customer_id', $data['customer_id'] ?? null);
        $stmt->bindValue(':customer_name', $data['customer_name'] ?? null);
        $stmt->bindValue(':customer_phone', $data['customer_phone'] ?? null);
        $stmt->bindValue(':seller_id', $data['seller_id'] ?? null);
        $stmt->bindValue(':seller_name', $data['seller_name'] ?? null);
        $stmt->bindValue(':status', $data['status'] ?? 'draft');
        $stmt->bindValue(':payment_method', $data['payment_method'] ?? 'cash');
        $stmt->bindParam(':subtotal', $subtotal);
        $stmt->bindValue(':discount', $discount);
        $stmt->bindValue(':discount_percentage', $discountPercentage);
        $stmt->bindParam(':total_amount', $totalAmount);
        $stmt->bindParam(':paid_amount', $paidAmount);
        $stmt->bindValue(':notes', $data['notes'] ?? null);
        $stmt->execute();
        
        $orderId = $db->lastInsertId();
        
        // Insert order items
        foreach ($data['items'] as $item) {
            $itemQuery = "INSERT INTO sales_order_items (
                order_id, product_id, product_reference, product_name,
                quantity, unit_price, purchase_price, discount, discount_percentage, line_total
            ) VALUES (
                :order_id, :product_id, :product_reference, :product_name,
                :quantity, :unit_price, :purchase_price, :discount, :discount_percentage, :line_total
            )";
            
            $lineTotal = $item['unit_price'] * $item['quantity'];
            if (isset($item['discount'])) {
                $lineTotal -= $item['discount'];
            } else if (isset($item['discount_percentage'])) {
                $lineTotal -= $lineTotal * ($item['discount_percentage'] / 100);
            }
            
            $itemStmt = $db->prepare($itemQuery);
            $itemStmt->bindParam(':order_id', $orderId);
            $itemStmt->bindParam(':product_id', $item['product_id']);
            $itemStmt->bindParam(':product_reference', $item['product_reference']);
            $itemStmt->bindParam(':product_name', $item['product_name']);
            $itemStmt->bindParam(':quantity', $item['quantity']);
            $itemStmt->bindParam(':unit_price', $item['unit_price']);
            $itemStmt->bindValue(':purchase_price', $item['purchase_price'] ?? 0);
            $itemStmt->bindValue(':discount', $item['discount'] ?? null);
            $itemStmt->bindValue(':discount_percentage', $item['discount_percentage'] ?? null);
            $itemStmt->bindParam(':line_total', $lineTotal);
            $itemStmt->execute();
        }
        
        $db->commit();
        getSalesOrder($db, $orderId);
        
    } catch (Exception $e) {
        $db->rollBack();
        sendError('Failed to create order: ' . $e->getMessage(), 500);
    }
}

/**
 * Complete sale - update stock and status
 */
function completeSale($db, $data) {
    if (!isset($data['order_id'])) {
        sendError('order_id is required', 400);
    }
    
    $orderId = $data['order_id'];
    $paidAmount = $data['paid_amount'] ?? 0;
    
    $db->beginTransaction();
    
    try {
        // Get order
        $orderQuery = "SELECT * FROM sales_orders WHERE id = :id";
        $orderStmt = $db->prepare($orderQuery);
        $orderStmt->bindParam(':id', $orderId);
        $orderStmt->execute();
        $order = $orderStmt->fetch();
        
        if (!$order) {
            throw new Exception('Order not found');
        }
        
        // Get order items
        $itemsQuery = "SELECT * FROM sales_order_items WHERE order_id = :order_id";
        $itemsStmt = $db->prepare($itemsQuery);
        $itemsStmt->bindParam(':order_id', $orderId);
        $itemsStmt->execute();
        $items = $itemsStmt->fetchAll();
        
        // Update stock for each item
        foreach ($items as $item) {
            $updateStockQuery = "UPDATE products SET quantity = quantity - :qty, updated_at = NOW() 
                                 WHERE id = :product_id AND quantity >= :qty";
            $updateStockStmt = $db->prepare($updateStockQuery);
            $updateStockStmt->bindParam(':qty', $item['quantity']);
            $updateStockStmt->bindParam(':product_id', $item['product_id']);
            $updateStockStmt->execute();
            
            if ($updateStockStmt->rowCount() == 0) {
                throw new Exception('Insufficient stock for product: ' . $item['product_name']);
            }
            
            // Log stock transaction
            logStockTransaction($db, $item['product_id'], 'sale', $item['quantity'], [
                'order_id' => $orderId,
                'order_number' => $order['order_number']
            ]);
        }
        
        // Update order status
        $newPaidAmount = $order['paid_amount'] + $paidAmount;
        $status = ($newPaidAmount >= $order['total_amount']) ? 'completed' : 'confirmed';
        
        $updateOrderQuery = "UPDATE sales_orders SET 
                            status = :status, 
                            paid_amount = :paid_amount, 
                            completed_at = NOW(), 
                            updated_at = NOW() 
                            WHERE id = :id";
        $updateOrderStmt = $db->prepare($updateOrderQuery);
        $updateOrderStmt->bindParam(':status', $status);
        $updateOrderStmt->bindParam(':paid_amount', $newPaidAmount);
        $updateOrderStmt->bindParam(':id', $orderId);
        $updateOrderStmt->execute();
        
        // If customer exists, update their total purchases
        if ($order['customer_id']) {
            $updateCustomerQuery = "UPDATE clients SET 
                                   total_purchases = total_purchases + :amount,
                                   total_paid = total_paid + :paid,
                                   updated_at = NOW()
                                   WHERE id = :customer_id";
            $updateCustomerStmt = $db->prepare($updateCustomerQuery);
            $updateCustomerStmt->bindParam(':amount', $order['total_amount']);
            $updateCustomerStmt->bindParam(':paid', $newPaidAmount);
            $updateCustomerStmt->bindParam(':customer_id', $order['customer_id']);
            $updateCustomerStmt->execute();
        }
        
        $db->commit();
        getSalesOrder($db, $orderId);
        
    } catch (Exception $e) {
        $db->rollBack();
        sendError($e->getMessage(), 500);
    }
}

/**
 * Add payment to order
 */
function addPayment($db, $data) {
    if (!isset($data['order_id']) || !isset($data['amount'])) {
        sendError('order_id and amount are required', 400);
    }
    
    $orderId = $data['order_id'];
    $amount = (float)$data['amount'];
    
    // Get current order
    $orderQuery = "SELECT * FROM sales_orders WHERE id = :id";
    $orderStmt = $db->prepare($orderQuery);
    $orderStmt->bindParam(':id', $orderId);
    $orderStmt->execute();
    $order = $orderStmt->fetch();
    
    if (!$order) {
        sendError('Order not found', 404);
    }
    
    $newPaidAmount = $order['paid_amount'] + $amount;
    $status = ($newPaidAmount >= $order['total_amount']) ? 'completed' : $order['status'];
    
    $updateQuery = "UPDATE sales_orders SET 
                   paid_amount = :paid_amount, 
                   status = :status,
                   completed_at = CASE WHEN :status = 'completed' THEN NOW() ELSE completed_at END,
                   updated_at = NOW() 
                   WHERE id = :id";
    $updateStmt = $db->prepare($updateQuery);
    $updateStmt->bindParam(':paid_amount', $newPaidAmount);
    $updateStmt->bindParam(':status', $status);
    $updateStmt->bindParam(':id', $orderId);
    
    if ($updateStmt->execute()) {
        // Update customer if exists
        if ($order['customer_id']) {
            $updateCustomerQuery = "UPDATE clients SET 
                                   total_paid = total_paid + :paid,
                                   updated_at = NOW()
                                   WHERE id = :customer_id";
            $updateCustomerStmt = $db->prepare($updateCustomerQuery);
            $updateCustomerStmt->bindParam(':paid', $amount);
            $updateCustomerStmt->bindParam(':customer_id', $order['customer_id']);
            $updateCustomerStmt->execute();
        }
        
        getSalesOrder($db, $orderId);
    } else {
        sendError('Failed to add payment', 500);
    }
}

/**
 * Cancel order and restore stock
 */
function cancelOrder($db, $data) {
    if (!isset($data['order_id'])) {
        sendError('order_id is required', 400);
    }
    
    $orderId = $data['order_id'];
    
    $db->beginTransaction();
    
    try {
        // Get order
        $orderQuery = "SELECT * FROM sales_orders WHERE id = :id";
        $orderStmt = $db->prepare($orderQuery);
        $orderStmt->bindParam(':id', $orderId);
        $orderStmt->execute();
        $order = $orderStmt->fetch();
        
        if (!$order) {
            throw new Exception('Order not found');
        }
        
        if ($order['status'] === 'completed') {
            // Restore stock
            $itemsQuery = "SELECT * FROM sales_order_items WHERE order_id = :order_id";
            $itemsStmt = $db->prepare($itemsQuery);
            $itemsStmt->bindParam(':order_id', $orderId);
            $itemsStmt->execute();
            $items = $itemsStmt->fetchAll();
            
            foreach ($items as $item) {
                $restoreStockQuery = "UPDATE products SET quantity = quantity + :qty, updated_at = NOW() 
                                     WHERE id = :product_id";
                $restoreStockStmt = $db->prepare($restoreStockQuery);
                $restoreStockStmt->bindParam(':qty', $item['quantity']);
                $restoreStockStmt->bindParam(':product_id', $item['product_id']);
                $restoreStockStmt->execute();
                
                // Log stock transaction
                logStockTransaction($db, $item['product_id'], 'return', $item['quantity'], [
                    'order_id' => $orderId,
                    'reason' => 'Order cancelled'
                ]);
            }
        }
        
        // Update order status
        $updateQuery = "UPDATE sales_orders SET status = 'cancelled', updated_at = NOW() WHERE id = :id";
        $updateStmt = $db->prepare($updateQuery);
        $updateStmt->bindParam(':id', $orderId);
        $updateStmt->execute();
        
        $db->commit();
        sendSuccess(null, 'Order cancelled successfully');
        
    } catch (Exception $e) {
        $db->rollBack();
        sendError($e->getMessage(), 500);
    }
}

/**
 * Update sales order
 */
function updateSalesOrder($db, $id, $data) {
    if (!$id) {
        sendError('Order ID is required', 400);
    }
    
    // Build dynamic update query
    $fields = [];
    $params = [':id' => $id];
    
    $allowedFields = [
        'status', 'payment_method', 'discount', 'discount_percentage',
        'paid_amount', 'notes', 'customer_id', 'customer_name', 'customer_phone'
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
    
    $query = "UPDATE sales_orders SET " . implode(', ', $fields) . " WHERE id = :id";
    $stmt = $db->prepare($query);
    
    if ($stmt->execute($params)) {
        getSalesOrder($db, $id);
    } else {
        sendError('Failed to update order', 500);
    }
}

/**
 * Delete sales order
 */
function deleteSalesOrder($db, $id) {
    if (!$id) {
        sendError('Order ID is required', 400);
    }
    
    $query = "DELETE FROM sales_orders WHERE id = :id AND status = 'draft'";
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
 * Get sales statistics
 */
function getSalesStats($db) {
    // Today's stats
    $todayQuery = "SELECT 
        COUNT(*) as orders_count,
        COALESCE(SUM(total_amount), 0) as total_sales,
        COALESCE(SUM(paid_amount), 0) as total_paid,
        COALESCE(SUM(total_amount - paid_amount), 0) as total_unpaid
    FROM sales_orders 
    WHERE DATE(created_at) = CURDATE() AND status != 'cancelled'";
    
    $todayStmt = $db->prepare($todayQuery);
    $todayStmt->execute();
    $today = $todayStmt->fetch();
    
    // This month stats
    $monthQuery = "SELECT 
        COUNT(*) as orders_count,
        COALESCE(SUM(total_amount), 0) as total_sales,
        COALESCE(SUM(paid_amount), 0) as total_paid
    FROM sales_orders 
    WHERE MONTH(created_at) = MONTH(CURDATE()) 
    AND YEAR(created_at) = YEAR(CURDATE()) 
    AND status != 'cancelled'";
    
    $monthStmt = $db->prepare($monthQuery);
    $monthStmt->execute();
    $month = $monthStmt->fetch();
    
    // Status breakdown
    $statusQuery = "SELECT status, COUNT(*) as count 
                   FROM sales_orders 
                   GROUP BY status";
    $statusStmt = $db->prepare($statusQuery);
    $statusStmt->execute();
    $statusBreakdown = $statusStmt->fetchAll(PDO::FETCH_KEY_PAIR);
    
    // Calculate profit (approximate)
    $profitQuery = "SELECT 
        COALESCE(SUM(soi.line_total - (soi.purchase_price * soi.quantity)), 0) as total_profit
    FROM sales_order_items soi
    JOIN sales_orders so ON soi.order_id = so.id
    WHERE so.status = 'completed'
    AND MONTH(so.created_at) = MONTH(CURDATE())";
    
    $profitStmt = $db->prepare($profitQuery);
    $profitStmt->execute();
    $profit = $profitStmt->fetch();
    
    sendSuccess([
        'today' => $today,
        'this_month' => $month,
        'status_breakdown' => $statusBreakdown,
        'monthly_profit' => (float)$profit['total_profit']
    ], 'Statistics retrieved successfully');
}

/**
 * Get daily report
 */
function getDailyReport($db, $date) {
    $query = "SELECT 
        so.*,
        (SELECT COUNT(*) FROM sales_order_items WHERE order_id = so.id) as items_count
    FROM sales_orders so
    WHERE DATE(so.created_at) = :date
    ORDER BY so.created_at DESC";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':date', $date);
    $stmt->execute();
    
    $orders = $stmt->fetchAll();
    $formattedOrders = [];
    
    foreach ($orders as $order) {
        $formattedOrders[] = formatOrderWithItems($db, $order);
    }
    
    // Summary
    $summaryQuery = "SELECT 
        COUNT(*) as total_orders,
        COALESCE(SUM(total_amount), 0) as total_sales,
        COALESCE(SUM(paid_amount), 0) as total_paid,
        COALESCE(SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END), 0) as completed_orders
    FROM sales_orders 
    WHERE DATE(created_at) = :date AND status != 'cancelled'";
    
    $summaryStmt = $db->prepare($summaryQuery);
    $summaryStmt->bindParam(':date', $date);
    $summaryStmt->execute();
    $summary = $summaryStmt->fetch();
    
    sendSuccess([
        'date' => $date,
        'summary' => $summary,
        'orders' => $formattedOrders
    ], 'Daily report retrieved successfully');
}

/**
 * Get top selling products
 */
function getTopProducts($db, $limit) {
    $query = "SELECT 
        soi.product_id,
        soi.product_reference,
        soi.product_name,
        SUM(soi.quantity) as total_quantity,
        SUM(soi.line_total) as total_revenue,
        COUNT(DISTINCT soi.order_id) as order_count
    FROM sales_order_items soi
    JOIN sales_orders so ON soi.order_id = so.id
    WHERE so.status = 'completed'
    GROUP BY soi.product_id, soi.product_reference, soi.product_name
    ORDER BY total_quantity DESC
    LIMIT :limit";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
    $stmt->execute();
    
    $products = $stmt->fetchAll();
    
    sendSuccess($products, 'Top products retrieved successfully');
}

/**
 * Get orders by customer
 */
function getOrdersByCustomer($db, $customerId) {
    if (!$customerId) {
        sendError('customer_id is required', 400);
    }
    
    $query = "SELECT * FROM sales_orders WHERE customer_id = :customer_id ORDER BY created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':customer_id', $customerId);
    $stmt->execute();
    
    $orders = $stmt->fetchAll();
    $formattedOrders = [];
    
    foreach ($orders as $order) {
        $formattedOrders[] = formatOrderWithItems($db, $order);
    }
    
    sendSuccess($formattedOrders, 'Customer orders retrieved successfully');
}

// ============================================
// Helper Functions
// ============================================

/**
 * Format order with its items
 */
function formatOrderWithItems($db, $order) {
    // Get order items
    $itemsQuery = "SELECT * FROM sales_order_items WHERE order_id = :order_id";
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
            'quantity' => (int)$item['quantity'],
            'unit_price' => (float)$item['unit_price'],
            'purchase_price' => (float)($item['purchase_price'] ?? 0),
            'discount' => isset($item['discount']) ? (float)$item['discount'] : null,
            'discount_percentage' => isset($item['discount_percentage']) ? (float)$item['discount_percentage'] : null,
            'line_total' => (float)$item['line_total']
        ];
    }, $items);
    
    return [
        'id' => (string)$order['id'],
        'order_number' => $order['order_number'],
        'invoice_number' => $order['invoice_number'],
        'customer_id' => $order['customer_id'],
        'customer_name' => $order['customer_name'],
        'customer_phone' => $order['customer_phone'],
        'seller_id' => $order['seller_id'],
        'seller_name' => $order['seller_name'],
        'items' => $formattedItems,
        'status' => $order['status'],
        'payment_method' => $order['payment_method'],
        'subtotal' => (float)$order['subtotal'],
        'discount' => isset($order['discount']) ? (float)$order['discount'] : null,
        'discount_percentage' => isset($order['discount_percentage']) ? (float)$order['discount_percentage'] : null,
        'total_amount' => (float)$order['total_amount'],
        'paid_amount' => (float)$order['paid_amount'],
        'remaining_amount' => (float)$order['total_amount'] - (float)$order['paid_amount'],
        'is_paid' => (float)$order['paid_amount'] >= (float)$order['total_amount'],
        'notes' => $order['notes'],
        'created_at' => $order['created_at'],
        'completed_at' => $order['completed_at'],
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
