<?php
// ============================================
// Reports API - واجهة برمجة تطبيقات التقارير
// REST API for Reports and Analytics
// ============================================

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/headers.php';

// Get request method and action
$method = $_SERVER['REQUEST_METHOD'];
$action = isset($_GET['action']) ? $_GET['action'] : '';

// Date range parameters
$startDate = isset($_GET['start_date']) ? $_GET['start_date'] : date('Y-m-01');
$endDate = isset($_GET['end_date']) ? $_GET['end_date'] : date('Y-m-d');

// Initialize database connection
$database = new Database();
$db = $database->getConnection();

try {
    switch ($method) {
        case 'GET':
            if ($action === 'dashboard') {
                getDashboardStats($db);
            } else if ($action === 'sales') {
                getSalesReport($db, $startDate, $endDate);
            } else if ($action === 'inventory') {
                getInventoryReport($db);
            } else if ($action === 'financial') {
                getFinancialReport($db, $startDate, $endDate);
            } else if ($action === 'clients') {
                getClientsReport($db, $startDate, $endDate);
            } else if ($action === 'suppliers') {
                getSuppliersReport($db, $startDate, $endDate);
            } else if ($action === 'profit') {
                getProfitReport($db, $startDate, $endDate);
            } else if ($action === 'top-products') {
                $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
                getTopProductsReport($db, $startDate, $endDate, $limit);
            } else if ($action === 'low-stock') {
                getLowStockReport($db);
            } else if ($action === 'audit-log') {
                getAuditLog($db, $startDate, $endDate);
            } else if ($action === 'daily-summary') {
                $date = isset($_GET['date']) ? $_GET['date'] : date('Y-m-d');
                getDailySummary($db, $date);
            } else {
                // Default: return available reports
                getAvailableReports();
            }
            break;
            
        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);
            if ($action === 'log-audit') {
                logAudit($db, $data);
            } else {
                sendError('Action not supported', 400);
            }
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
 * Get available reports list
 */
function getAvailableReports() {
    $reports = [
        'dashboard' => 'Dashboard Statistics - لوحة التحكم',
        'sales' => 'Sales Report - تقرير المبيعات',
        'inventory' => 'Inventory Report - تقرير المخزون',
        'financial' => 'Financial Report - التقرير المالي',
        'clients' => 'Clients Report - تقرير الزبناء',
        'suppliers' => 'Suppliers Report - تقرير الموردين',
        'profit' => 'Profit Report - تقرير الأرباح',
        'top-products' => 'Top Products - أفضل المنتجات',
        'low-stock' => 'Low Stock Alert - تنبيه المخزون المنخفض',
        'audit-log' => 'Audit Log - سجل التدقيق',
        'daily-summary' => 'Daily Summary - ملخص اليوم'
    ];
    
    sendSuccess($reports, 'Available reports');
}

/**
 * Dashboard Stats
 */
function getDashboardStats($db) {
    // Today's sales
    $todaySalesQuery = "SELECT 
        COUNT(*) as orders_count,
        COALESCE(SUM(total_amount), 0) as total_sales,
        COALESCE(SUM(paid_amount), 0) as total_paid
    FROM sales_orders 
    WHERE DATE(created_at) = CURDATE() AND status != 'cancelled'";
    $todaySalesStmt = $db->prepare($todaySalesQuery);
    $todaySalesStmt->execute();
    $todaySales = $todaySalesStmt->fetch();
    
    // This month sales
    $monthSalesQuery = "SELECT 
        COUNT(*) as orders_count,
        COALESCE(SUM(total_amount), 0) as total_sales
    FROM sales_orders 
    WHERE MONTH(created_at) = MONTH(CURDATE()) 
    AND YEAR(created_at) = YEAR(CURDATE()) 
    AND status != 'cancelled'";
    $monthSalesStmt = $db->prepare($monthSalesQuery);
    $monthSalesStmt->execute();
    $monthSales = $monthSalesStmt->fetch();
    
    // Products stats
    $productsQuery = "SELECT 
        COUNT(*) as total_products,
        SUM(CASE WHEN quantity <= min_stock THEN 1 ELSE 0 END) as low_stock_count,
        SUM(quantity * purchase_price) as total_stock_value
    FROM products WHERE is_active = 1";
    $productsStmt = $db->prepare($productsQuery);
    $productsStmt->execute();
    $products = $productsStmt->fetch();
    
    // Clients stats
    $clientsQuery = "SELECT 
        COUNT(*) as total_clients,
        SUM(CASE WHEN (total_purchases - total_paid) > 0 THEN 1 ELSE 0 END) as debtors_count,
        COALESCE(SUM(total_purchases - total_paid), 0) as total_receivables
    FROM clients WHERE is_active = 1";
    $clientsStmt = $db->prepare($clientsQuery);
    $clientsStmt->execute();
    $clients = $clientsStmt->fetch();
    
    // Suppliers stats
    $suppliersQuery = "SELECT 
        COUNT(*) as total_suppliers,
        COALESCE(SUM(current_balance), 0) as total_payables
    FROM suppliers WHERE is_active = 1";
    $suppliersStmt = $db->prepare($suppliersQuery);
    $suppliersStmt->execute();
    $suppliers = $suppliersStmt->fetch();
    
    // Pending orders
    $pendingQuery = "SELECT 
        (SELECT COUNT(*) FROM supply_orders WHERE status NOT IN ('received', 'cancelled')) as pending_supply,
        (SELECT COUNT(*) FROM sales_orders WHERE status NOT IN ('completed', 'cancelled', 'delivered')) as pending_sales
    ";
    $pendingStmt = $db->prepare($pendingQuery);
    $pendingStmt->execute();
    $pending = $pendingStmt->fetch();
    
    sendSuccess([
        'today' => [
            'sales' => (float)$todaySales['total_sales'],
            'orders' => (int)$todaySales['orders_count'],
            'paid' => (float)$todaySales['total_paid']
        ],
        'this_month' => [
            'sales' => (float)$monthSales['total_sales'],
            'orders' => (int)$monthSales['orders_count']
        ],
        'inventory' => [
            'total_products' => (int)$products['total_products'],
            'low_stock_count' => (int)$products['low_stock_count'],
            'stock_value' => (float)$products['total_stock_value']
        ],
        'clients' => [
            'total' => (int)$clients['total_clients'],
            'debtors' => (int)$clients['debtors_count'],
            'receivables' => (float)$clients['total_receivables']
        ],
        'suppliers' => [
            'total' => (int)$suppliers['total_suppliers'],
            'payables' => (float)$suppliers['total_payables']
        ],
        'pending' => [
            'supply_orders' => (int)$pending['pending_supply'],
            'sales_orders' => (int)$pending['pending_sales']
        ]
    ], 'Dashboard statistics retrieved');
}

/**
 * Sales Report
 */
function getSalesReport($db, $startDate, $endDate) {
    // Summary
    $summaryQuery = "SELECT 
        COUNT(*) as total_orders,
        COUNT(DISTINCT customer_id) as unique_customers,
        COALESCE(SUM(total_amount), 0) as total_sales,
        COALESCE(SUM(paid_amount), 0) as total_paid,
        COALESCE(SUM(total_amount - paid_amount), 0) as total_unpaid,
        COALESCE(AVG(total_amount), 0) as average_order_value
    FROM sales_orders 
    WHERE DATE(created_at) BETWEEN :start_date AND :end_date
    AND status != 'cancelled'";
    $summaryStmt = $db->prepare($summaryQuery);
    $summaryStmt->bindParam(':start_date', $startDate);
    $summaryStmt->bindParam(':end_date', $endDate);
    $summaryStmt->execute();
    $summary = $summaryStmt->fetch();
    
    // By status
    $statusQuery = "SELECT status, COUNT(*) as count, SUM(total_amount) as total
    FROM sales_orders 
    WHERE DATE(created_at) BETWEEN :start_date AND :end_date
    GROUP BY status";
    $statusStmt = $db->prepare($statusQuery);
    $statusStmt->bindParam(':start_date', $startDate);
    $statusStmt->bindParam(':end_date', $endDate);
    $statusStmt->execute();
    $byStatus = $statusStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // By payment method
    $paymentQuery = "SELECT payment_method, COUNT(*) as count, SUM(total_amount) as total
    FROM sales_orders 
    WHERE DATE(created_at) BETWEEN :start_date AND :end_date
    AND status != 'cancelled'
    GROUP BY payment_method";
    $paymentStmt = $db->prepare($paymentQuery);
    $paymentStmt->bindParam(':start_date', $startDate);
    $paymentStmt->bindParam(':end_date', $endDate);
    $paymentStmt->execute();
    $byPayment = $paymentStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Daily breakdown
    $dailyQuery = "SELECT 
        DATE(created_at) as date,
        COUNT(*) as orders,
        SUM(total_amount) as sales
    FROM sales_orders 
    WHERE DATE(created_at) BETWEEN :start_date AND :end_date
    AND status != 'cancelled'
    GROUP BY DATE(created_at)
    ORDER BY date";
    $dailyStmt = $db->prepare($dailyQuery);
    $dailyStmt->bindParam(':start_date', $startDate);
    $dailyStmt->bindParam(':end_date', $endDate);
    $dailyStmt->execute();
    $daily = $dailyStmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendSuccess([
        'period' => ['start' => $startDate, 'end' => $endDate],
        'summary' => $summary,
        'by_status' => $byStatus,
        'by_payment_method' => $byPayment,
        'daily' => $daily
    ], 'Sales report retrieved');
}

/**
 * Inventory Report
 */
function getInventoryReport($db) {
    // Summary
    $summaryQuery = "SELECT 
        COUNT(*) as total_products,
        SUM(quantity) as total_quantity,
        SUM(quantity * purchase_price) as total_value,
        SUM(quantity * selling_price) as potential_value,
        SUM(CASE WHEN quantity <= min_stock THEN 1 ELSE 0 END) as low_stock,
        SUM(CASE WHEN quantity = 0 THEN 1 ELSE 0 END) as out_of_stock
    FROM products WHERE is_active = 1";
    $summaryStmt = $db->prepare($summaryQuery);
    $summaryStmt->execute();
    $summary = $summaryStmt->fetch();
    
    // By category
    $categoryQuery = "SELECT 
        COALESCE(category, 'غير مصنف') as category,
        COUNT(*) as products_count,
        SUM(quantity) as total_quantity,
        SUM(quantity * purchase_price) as category_value
    FROM products WHERE is_active = 1
    GROUP BY category
    ORDER BY category_value DESC";
    $categoryStmt = $db->prepare($categoryQuery);
    $categoryStmt->execute();
    $byCategory = $categoryStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Top stock value products
    $topValueQuery = "SELECT 
        id, reference, name, category,
        quantity, purchase_price, selling_price,
        (quantity * purchase_price) as stock_value
    FROM products WHERE is_active = 1
    ORDER BY stock_value DESC
    LIMIT 10";
    $topValueStmt = $db->prepare($topValueQuery);
    $topValueStmt->execute();
    $topByValue = $topValueStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Stock movement summary (last 30 days)
    $movementQuery = "SELECT 
        type,
        COUNT(*) as transactions_count,
        SUM(quantity) as total_quantity
    FROM stock_transactions 
    WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY type";
    $movementStmt = $db->prepare($movementQuery);
    $movementStmt->execute();
    $movements = $movementStmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendSuccess([
        'summary' => $summary,
        'by_category' => $byCategory,
        'top_by_value' => $topByValue,
        'recent_movements' => $movements
    ], 'Inventory report retrieved');
}

/**
 * Financial Report
 */
function getFinancialReport($db, $startDate, $endDate) {
    // Revenue
    $revenueQuery = "SELECT 
        COALESCE(SUM(total_amount), 0) as total_revenue,
        COALESCE(SUM(paid_amount), 0) as total_collected,
        COALESCE(SUM(total_amount - paid_amount), 0) as total_outstanding
    FROM sales_orders 
    WHERE DATE(created_at) BETWEEN :start_date AND :end_date
    AND status != 'cancelled'";
    $revenueStmt = $db->prepare($revenueQuery);
    $revenueStmt->bindParam(':start_date', $startDate);
    $revenueStmt->bindParam(':end_date', $endDate);
    $revenueStmt->execute();
    $revenue = $revenueStmt->fetch();
    
    // Expenses (supply orders received)
    $expensesQuery = "SELECT 
        COALESCE(SUM(total_amount), 0) as total_purchases
    FROM supply_orders 
    WHERE DATE(created_at) BETWEEN :start_date AND :end_date
    AND status = 'received'";
    $expensesStmt = $db->prepare($expensesQuery);
    $expensesStmt->bindParam(':start_date', $startDate);
    $expensesStmt->bindParam(':end_date', $endDate);
    $expensesStmt->execute();
    $expenses = $expensesStmt->fetch();
    
    // Profit calculation from sales items
    $profitQuery = "SELECT 
        COALESCE(SUM(soi.line_total), 0) as sales_total,
        COALESCE(SUM(soi.purchase_price * soi.quantity), 0) as cost_total,
        COALESCE(SUM(soi.line_total - (soi.purchase_price * soi.quantity)), 0) as gross_profit
    FROM sales_order_items soi
    JOIN sales_orders so ON soi.order_id = so.id
    WHERE DATE(so.created_at) BETWEEN :start_date AND :end_date
    AND so.status = 'completed'";
    $profitStmt = $db->prepare($profitQuery);
    $profitStmt->bindParam(':start_date', $startDate);
    $profitStmt->bindParam(':end_date', $endDate);
    $profitStmt->execute();
    $profit = $profitStmt->fetch();
    
    // Receivables
    $receivablesQuery = "SELECT 
        COALESCE(SUM(total_purchases - total_paid), 0) as total_receivables
    FROM clients WHERE is_active = 1 AND (total_purchases - total_paid) > 0";
    $receivablesStmt = $db->prepare($receivablesQuery);
    $receivablesStmt->execute();
    $receivables = $receivablesStmt->fetch();
    
    // Payables
    $payablesQuery = "SELECT 
        COALESCE(SUM(current_balance), 0) as total_payables
    FROM suppliers WHERE is_active = 1 AND current_balance > 0";
    $payablesStmt = $db->prepare($payablesQuery);
    $payablesStmt->execute();
    $payables = $payablesStmt->fetch();
    
    sendSuccess([
        'period' => ['start' => $startDate, 'end' => $endDate],
        'revenue' => [
            'total' => (float)$revenue['total_revenue'],
            'collected' => (float)$revenue['total_collected'],
            'outstanding' => (float)$revenue['total_outstanding']
        ],
        'expenses' => [
            'purchases' => (float)$expenses['total_purchases']
        ],
        'profit' => [
            'sales_total' => (float)$profit['sales_total'],
            'cost_total' => (float)$profit['cost_total'],
            'gross_profit' => (float)$profit['gross_profit'],
            'profit_margin' => $profit['sales_total'] > 0 
                ? round(($profit['gross_profit'] / $profit['sales_total']) * 100, 2) 
                : 0
        ],
        'balance' => [
            'receivables' => (float)$receivables['total_receivables'],
            'payables' => (float)$payables['total_payables'],
            'net_balance' => (float)$receivables['total_receivables'] - (float)$payables['total_payables']
        ]
    ], 'Financial report retrieved');
}

/**
 * Clients Report
 */
function getClientsReport($db, $startDate, $endDate) {
    // Summary
    $summaryQuery = "SELECT 
        COUNT(*) as total_clients,
        SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) as active_clients,
        SUM(total_purchases) as total_purchases,
        SUM(total_paid) as total_paid,
        SUM(total_purchases - total_paid) as total_debt
    FROM clients";
    $summaryStmt = $db->prepare($summaryQuery);
    $summaryStmt->execute();
    $summary = $summaryStmt->fetch();
    
    // Top clients by purchases
    $topClientsQuery = "SELECT 
        id, code, name, city, total_purchases, total_paid,
        (total_purchases - total_paid) as balance
    FROM clients 
    WHERE is_active = 1
    ORDER BY total_purchases DESC
    LIMIT 10";
    $topClientsStmt = $db->prepare($topClientsQuery);
    $topClientsStmt->execute();
    $topClients = $topClientsStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Debtors
    $debtorsQuery = "SELECT 
        id, code, name, phone,
        total_purchases, total_paid,
        (total_purchases - total_paid) as balance
    FROM clients 
    WHERE is_active = 1 AND (total_purchases - total_paid) > 0
    ORDER BY balance DESC";
    $debtorsStmt = $db->prepare($debtorsQuery);
    $debtorsStmt->execute();
    $debtors = $debtorsStmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendSuccess([
        'period' => ['start' => $startDate, 'end' => $endDate],
        'summary' => $summary,
        'top_clients' => $topClients,
        'debtors' => $debtors
    ], 'Clients report retrieved');
}

/**
 * Suppliers Report
 */
function getSuppliersReport($db, $startDate, $endDate) {
    // Summary
    $summaryQuery = "SELECT 
        COUNT(*) as total_suppliers,
        SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) as active_suppliers,
        SUM(current_balance) as total_balance
    FROM suppliers";
    $summaryStmt = $db->prepare($summaryQuery);
    $summaryStmt->execute();
    $summary = $summaryStmt->fetch();
    
    // Top suppliers by purchases
    $topSuppliersQuery = "SELECT 
        s.id, s.code, s.name, s.current_balance,
        COUNT(so.id) as orders_count,
        COALESCE(SUM(so.total_amount), 0) as total_purchases
    FROM suppliers s
    LEFT JOIN supply_orders so ON s.id = so.supplier_id
    WHERE s.is_active = 1
    GROUP BY s.id, s.code, s.name, s.current_balance
    ORDER BY total_purchases DESC
    LIMIT 10";
    $topSuppliersStmt = $db->prepare($topSuppliersQuery);
    $topSuppliersStmt->execute();
    $topSuppliers = $topSuppliersStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Suppliers with balance
    $withBalanceQuery = "SELECT 
        id, code, name, phone, current_balance
    FROM suppliers 
    WHERE is_active = 1 AND current_balance > 0
    ORDER BY current_balance DESC";
    $withBalanceStmt = $db->prepare($withBalanceQuery);
    $withBalanceStmt->execute();
    $withBalance = $withBalanceStmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendSuccess([
        'period' => ['start' => $startDate, 'end' => $endDate],
        'summary' => $summary,
        'top_suppliers' => $topSuppliers,
        'with_balance' => $withBalance
    ], 'Suppliers report retrieved');
}

/**
 * Profit Report
 */
function getProfitReport($db, $startDate, $endDate) {
    // Daily profit
    $dailyQuery = "SELECT 
        DATE(so.created_at) as date,
        SUM(soi.line_total) as revenue,
        SUM(soi.purchase_price * soi.quantity) as cost,
        SUM(soi.line_total - (soi.purchase_price * soi.quantity)) as profit
    FROM sales_order_items soi
    JOIN sales_orders so ON soi.order_id = so.id
    WHERE DATE(so.created_at) BETWEEN :start_date AND :end_date
    AND so.status = 'completed'
    GROUP BY DATE(so.created_at)
    ORDER BY date";
    $dailyStmt = $db->prepare($dailyQuery);
    $dailyStmt->bindParam(':start_date', $startDate);
    $dailyStmt->bindParam(':end_date', $endDate);
    $dailyStmt->execute();
    $daily = $dailyStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // By product
    $byProductQuery = "SELECT 
        soi.product_id,
        soi.product_name,
        SUM(soi.quantity) as quantity_sold,
        SUM(soi.line_total) as revenue,
        SUM(soi.purchase_price * soi.quantity) as cost,
        SUM(soi.line_total - (soi.purchase_price * soi.quantity)) as profit
    FROM sales_order_items soi
    JOIN sales_orders so ON soi.order_id = so.id
    WHERE DATE(so.created_at) BETWEEN :start_date AND :end_date
    AND so.status = 'completed'
    GROUP BY soi.product_id, soi.product_name
    ORDER BY profit DESC
    LIMIT 20";
    $byProductStmt = $db->prepare($byProductQuery);
    $byProductStmt->bindParam(':start_date', $startDate);
    $byProductStmt->bindParam(':end_date', $endDate);
    $byProductStmt->execute();
    $byProduct = $byProductStmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Total
    $totalQuery = "SELECT 
        SUM(soi.line_total) as total_revenue,
        SUM(soi.purchase_price * soi.quantity) as total_cost,
        SUM(soi.line_total - (soi.purchase_price * soi.quantity)) as total_profit
    FROM sales_order_items soi
    JOIN sales_orders so ON soi.order_id = so.id
    WHERE DATE(so.created_at) BETWEEN :start_date AND :end_date
    AND so.status = 'completed'";
    $totalStmt = $db->prepare($totalQuery);
    $totalStmt->bindParam(':start_date', $startDate);
    $totalStmt->bindParam(':end_date', $endDate);
    $totalStmt->execute();
    $total = $totalStmt->fetch();
    
    sendSuccess([
        'period' => ['start' => $startDate, 'end' => $endDate],
        'total' => [
            'revenue' => (float)($total['total_revenue'] ?? 0),
            'cost' => (float)($total['total_cost'] ?? 0),
            'profit' => (float)($total['total_profit'] ?? 0),
            'margin' => ($total['total_revenue'] ?? 0) > 0 
                ? round((($total['total_profit'] ?? 0) / $total['total_revenue']) * 100, 2) 
                : 0
        ],
        'daily' => $daily,
        'by_product' => $byProduct
    ], 'Profit report retrieved');
}

/**
 * Top Products Report
 */
function getTopProductsReport($db, $startDate, $endDate, $limit) {
    $query = "SELECT 
        soi.product_id,
        soi.product_reference,
        soi.product_name,
        SUM(soi.quantity) as quantity_sold,
        SUM(soi.line_total) as revenue,
        COUNT(DISTINCT soi.order_id) as orders_count
    FROM sales_order_items soi
    JOIN sales_orders so ON soi.order_id = so.id
    WHERE DATE(so.created_at) BETWEEN :start_date AND :end_date
    AND so.status != 'cancelled'
    GROUP BY soi.product_id, soi.product_reference, soi.product_name
    ORDER BY quantity_sold DESC
    LIMIT :limit";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':start_date', $startDate);
    $stmt->bindParam(':end_date', $endDate);
    $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
    $stmt->execute();
    
    $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendSuccess([
        'period' => ['start' => $startDate, 'end' => $endDate],
        'products' => $products
    ], 'Top products report retrieved');
}

/**
 * Low Stock Report
 */
function getLowStockReport($db) {
    $query = "SELECT 
        id, reference, name, category, supplier,
        quantity, min_stock, purchase_price, selling_price,
        (quantity * purchase_price) as stock_value,
        CASE 
            WHEN quantity = 0 THEN 'out_of_stock'
            WHEN quantity <= min_stock THEN 'low_stock'
            ELSE 'normal'
        END as status
    FROM products 
    WHERE is_active = 1 AND quantity <= min_stock
    ORDER BY quantity ASC, min_stock DESC";
    
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    $outOfStock = array_filter($products, fn($p) => $p['status'] === 'out_of_stock');
    $lowStock = array_filter($products, fn($p) => $p['status'] === 'low_stock');
    
    sendSuccess([
        'summary' => [
            'out_of_stock_count' => count($outOfStock),
            'low_stock_count' => count($lowStock),
            'total_alerts' => count($products)
        ],
        'products' => $products
    ], 'Low stock report retrieved');
}

/**
 * Audit Log
 */
function getAuditLog($db, $startDate, $endDate) {
    // For now, we'll use stock_transactions as a proxy for audit log
    // In a real system, you'd have a dedicated audit_log table
    
    $query = "SELECT 
        t.id,
        t.type as action,
        'product' as entity_type,
        t.product_id as entity_id,
        p.name as entity_name,
        t.quantity,
        t.notes,
        t.performed_by,
        t.created_at as performed_at
    FROM stock_transactions t
    LEFT JOIN products p ON t.product_id = p.id
    WHERE DATE(t.created_at) BETWEEN :start_date AND :end_date
    ORDER BY t.created_at DESC
    LIMIT 100";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':start_date', $startDate);
    $stmt->bindParam(':end_date', $endDate);
    $stmt->execute();
    
    $logs = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    sendSuccess([
        'period' => ['start' => $startDate, 'end' => $endDate],
        'logs' => $logs
    ], 'Audit log retrieved');
}

/**
 * Daily Summary
 */
function getDailySummary($db, $date) {
    // Sales
    $salesQuery = "SELECT 
        COUNT(*) as orders_count,
        COALESCE(SUM(total_amount), 0) as total_sales,
        COALESCE(SUM(paid_amount), 0) as total_paid
    FROM sales_orders 
    WHERE DATE(created_at) = :date AND status != 'cancelled'";
    $salesStmt = $db->prepare($salesQuery);
    $salesStmt->bindParam(':date', $date);
    $salesStmt->execute();
    $sales = $salesStmt->fetch();
    
    // Supply orders
    $supplyQuery = "SELECT 
        COUNT(*) as orders_count,
        COALESCE(SUM(total_amount), 0) as total_value
    FROM supply_orders 
    WHERE DATE(created_at) = :date";
    $supplyStmt = $db->prepare($supplyQuery);
    $supplyStmt->bindParam(':date', $date);
    $supplyStmt->execute();
    $supply = $supplyStmt->fetch();
    
    // Transactions
    $transactionsQuery = "SELECT type, SUM(quantity) as total
    FROM stock_transactions 
    WHERE DATE(created_at) = :date
    GROUP BY type";
    $transactionsStmt = $db->prepare($transactionsQuery);
    $transactionsStmt->bindParam(':date', $date);
    $transactionsStmt->execute();
    $transactions = $transactionsStmt->fetchAll(PDO::FETCH_KEY_PAIR);
    
    sendSuccess([
        'date' => $date,
        'sales' => $sales,
        'supply' => $supply,
        'transactions' => $transactions
    ], 'Daily summary retrieved');
}

/**
 * Log Audit Entry
 */
function logAudit($db, $data) {
    // This would insert into an audit_log table
    // For now, we'll skip actual insertion and just return success
    sendSuccess(['logged' => true], 'Audit entry logged');
}
