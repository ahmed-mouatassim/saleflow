<?php
// ============================================
// Products API - واجهة برمجة تطبيقات المنتجات
// REST API for Products CRUD operations
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
                getProduct($db, $id);
            } else if ($action === 'categories') {
                getCategories($db);
            } else if ($action === 'suppliers') {
                getSuppliers($db);
            } else if ($action === 'low-stock') {
                getLowStockProducts($db);
            } else if ($action === 'stats') {
                getProductStats($db);
            } else if ($action === 'transactions') {
                getStockTransactions($db);
            } else {
                getAllProducts($db);
            }
            break;
            
        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);
            if ($action === 'add-stock') {
                addStock($db, $data);
            } else if ($action === 'remove-stock') {
                removeStock($db, $data);
            } else {
                createProduct($db, $data);
            }
            break;
            
        case 'PUT':
            $data = json_decode(file_get_contents("php://input"), true);
            updateProduct($db, $id, $data);
            break;
            
        case 'DELETE':
            deleteProduct($db, $id);
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
 * Get all products
 */
function getAllProducts($db) {
    $query = "SELECT * FROM products WHERE is_active = 1 ORDER BY created_at DESC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $products = $stmt->fetchAll();
    
    // Format the data
    $formattedProducts = array_map('formatProductResponse', $products);
    
    sendSuccess($formattedProducts, 'Products retrieved successfully');
}

/**
 * Get single product by ID
 */
function getProduct($db, $id) {
    $query = "SELECT * FROM products WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    $stmt->execute();
    
    $product = $stmt->fetch();
    
    if (!$product) {
        sendError('Product not found', 404);
    }
    
    sendSuccess(formatProductResponse($product), 'Product retrieved successfully');
}

/**
 * Create new product
 */
function createProduct($db, $data) {
    // Validate required fields
    $required = ['reference', 'name', 'quantity', 'purchase_price'];
    foreach ($required as $field) {
        if (!isset($data[$field]) || empty($data[$field])) {
            sendError("Field '{$field}' is required", 400);
        }
    }
    
    // Check if reference already exists
    $checkQuery = "SELECT id FROM products WHERE reference = :reference";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->bindParam(':reference', $data['reference']);
    $checkStmt->execute();
    
    if ($checkStmt->fetch()) {
        sendError('Product reference already exists', 409);
    }
    
    // Calculate selling price if not provided
    $marginRate = isset($data['margin_rate']) ? $data['margin_rate'] : 0.20;
    $purchasePrice = $data['purchase_price'];
    $sellingPrice = isset($data['selling_price']) 
        ? $data['selling_price'] 
        : calculateSellingPrice($purchasePrice, $marginRate);
    
    $query = "INSERT INTO products (
        reference, name, quantity, min_stock, purchase_price, selling_price, 
        margin_rate, supplier_id, supplier_name, category, barcode, 
        unit, image_path, notes, is_active, created_at, updated_at
    ) VALUES (
        :reference, :name, :quantity, :min_stock, :purchase_price, :selling_price,
        :margin_rate, :supplier_id, :supplier_name, :category, :barcode,
        :unit, :image_path, :notes, :is_active, NOW(), NOW()
    )";
    
    $stmt = $db->prepare($query);
    
    $stmt->bindParam(':reference', $data['reference']);
    $stmt->bindParam(':name', $data['name']);
    $stmt->bindParam(':quantity', $data['quantity']);
    $stmt->bindValue(':min_stock', isset($data['min_stock']) ? $data['min_stock'] : 5);
    $stmt->bindParam(':purchase_price', $purchasePrice);
    $stmt->bindParam(':selling_price', $sellingPrice);
    $stmt->bindParam(':margin_rate', $marginRate);
    $stmt->bindValue(':supplier_id', $data['supplier_id'] ?? null);
    $stmt->bindValue(':supplier_name', $data['supplier_name'] ?? null);
    $stmt->bindValue(':category', $data['category'] ?? null);
    $stmt->bindValue(':barcode', $data['barcode'] ?? null);
    $stmt->bindValue(':unit', $data['unit'] ?? null);
    $stmt->bindValue(':image_path', $data['image_path'] ?? null);
    $stmt->bindValue(':notes', $data['notes'] ?? null);
    $stmt->bindValue(':is_active', isset($data['is_active']) ? $data['is_active'] : 1);
    
    if ($stmt->execute()) {
        $newId = $db->lastInsertId();
        
        // Initial stock log
        if ($data['quantity'] > 0) {
            logStockTransaction($db, $newId, 'entry', $data['quantity'], [
                'unit_price' => $purchasePrice,
                'notes' => 'Initial stock (مخزون أولي)',
                'quantity_before' => 0,
                'quantity_after' => $data['quantity'],
                'reference' => $data['reference'],
                'name' => $data['name']
            ]);
        }
        
        getProduct($db, $newId);
    } else {
        sendError('Failed to create product', 500);
    }
}

/**
 * Update existing product
 */
function updateProduct($db, $id, $data) {
    if (!$id) {
        sendError('Product ID is required', 400);
    }
    
    // Check if product exists
    $checkQuery = "SELECT id FROM products WHERE id = :id";
    $checkStmt = $db->prepare($checkQuery);
    $checkStmt->bindParam(':id', $id);
    $checkStmt->execute();
    
    if (!$checkStmt->fetch()) {
        sendError('Product not found', 404);
    }
    
    // Build dynamic update query
    $fields = [];
    $params = [':id' => $id];
    
    $allowedFields = [
        'reference', 'name', 'quantity', 'min_stock', 'purchase_price', 
        'selling_price', 'margin_rate', 'supplier_id', 'supplier_name', 
        'category', 'barcode', 'unit', 'image_path', 'notes', 'is_active'
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
    
    $query = "UPDATE products SET " . implode(', ', $fields) . " WHERE id = :id";
    $stmt = $db->prepare($query);
    
    if ($stmt->execute($params)) {
        getProduct($db, $id);
    } else {
        sendError('Failed to update product', 500);
    }
}

/**
 * Delete product (soft delete)
 */
function deleteProduct($db, $id) {
    if (!$id) {
        sendError('Product ID is required', 400);
    }
    
    $query = "UPDATE products SET is_active = 0, updated_at = NOW() WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    
    if ($stmt->execute()) {
        if ($stmt->rowCount() > 0) {
            sendSuccess(null, 'Product deleted successfully');
        } else {
            sendError('Product not found', 404);
        }
    } else {
        sendError('Failed to delete product', 500);
    }
}

/**
 * Add stock to product
 */
function addStock($db, $data) {
    if (!isset($data['product_id']) || !isset($data['quantity'])) {
        sendError('product_id and quantity are required', 400);
    }
    
    $productId = $data['product_id'];
    $quantity = (int)$data['quantity'];
    
    if ($quantity <= 0) {
        sendError('Quantity must be positive', 400);
    }

    // Get current product state
    $currentProduct = getProductRaw($db, $productId);
    if (!$currentProduct) {
        sendError('Product not found', 404);
    }

    $quantityBefore = (int)$currentProduct['quantity'];
    $quantityAfter = $quantityBefore + $quantity;
    
    // Update quantity
    $query = "UPDATE products SET quantity = :quantity, updated_at = NOW() WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':quantity', $quantityAfter);
    $stmt->bindParam(':id', $productId);
    
    if ($stmt->execute()) {
        // Log the stock transaction
        $logData = $data;
        $logData['quantity_before'] = $quantityBefore;
        $logData['quantity_after'] = $quantityAfter;
        $logData['reference'] = $currentProduct['reference'];
        $logData['name'] = $currentProduct['name'];
        
        logStockTransaction($db, $productId, 'entry', $quantity, $logData);
        getProduct($db, $productId);
    } else {
        sendError('Failed to add stock', 500);
    }
}

/**
 * Remove stock from product
 */
function removeStock($db, $data) {
    if (!isset($data['product_id']) || !isset($data['quantity'])) {
        sendError('product_id and quantity are required', 400);
    }
    
    $productId = $data['product_id'];
    $quantity = (int)$data['quantity'];
    
    if ($quantity <= 0) {
        sendError('Quantity must be positive', 400);
    }
    
    // Check current stock
    $currentProduct = getProductRaw($db, $productId);
    
    if (!$currentProduct) {
        sendError('Product not found', 404);
    }

    $quantityBefore = (int)$currentProduct['quantity'];
    
    if ($quantityBefore < $quantity) {
        sendError('Insufficient stock', 400);
    }

    $quantityAfter = $quantityBefore - $quantity;
    
    // Update quantity
    $query = "UPDATE products SET quantity = :quantity, updated_at = NOW() WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':quantity', $quantityAfter);
    $stmt->bindParam(':id', $productId);
    
    if ($stmt->execute()) {
        // Log the stock transaction
        $logData = $data;
        $logData['quantity_before'] = $quantityBefore;
        $logData['quantity_after'] = $quantityAfter;
        $logData['reference'] = $currentProduct['reference'];
        $logData['name'] = $currentProduct['name'];

        logStockTransaction($db, $productId, 'exit', $quantity, $logData);
        getProduct($db, $productId);
    } else {
        sendError('Failed to remove stock', 500);
    }
}

/**
 * Get all categories
 */
function getCategories($db) {
    $query = "SELECT DISTINCT category FROM products WHERE category IS NOT NULL AND is_active = 1 ORDER BY category";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $categories = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    sendSuccess($categories, 'Categories retrieved successfully');
}

/**
 * Get all suppliers
 */
function getSuppliers($db) {
    $query = "SELECT DISTINCT supplier_name FROM products WHERE supplier_name IS NOT NULL AND is_active = 1 ORDER BY supplier_name";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $suppliers = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    sendSuccess($suppliers, 'Suppliers retrieved successfully');
}

/**
 * Get low stock products
 */
function getLowStockProducts($db) {
    $query = "SELECT * FROM products WHERE quantity <= min_stock AND is_active = 1 ORDER BY quantity ASC";
    $stmt = $db->prepare($query);
    $stmt->execute();
    
    $products = $stmt->fetchAll();
    $formattedProducts = array_map('formatProductResponse', $products);
    
    sendSuccess($formattedProducts, 'Low stock products retrieved successfully');
}

/**
 * Get product statistics
 */
function getProductStats($db) {
    $statsQuery = "SELECT 
        COUNT(*) as total_products,
        SUM(quantity) as total_stock,
        SUM(quantity * purchase_price) as total_value_cost,
        SUM(quantity * selling_price) as total_value_selling,
        SUM(CASE WHEN quantity <= min_stock THEN 1 ELSE 0 END) as low_stock_count,
        SUM(CASE WHEN quantity = 0 THEN 1 ELSE 0 END) as out_of_stock_count
    FROM products WHERE is_active = 1";
    
    $stmt = $db->prepare($statsQuery);
    $stmt->execute();
    
    $stats = $stmt->fetch();
    
    // Calculate potential profit
    $stats['potential_profit'] = $stats['total_value_selling'] - $stats['total_value_cost'];
    
    sendSuccess($stats, 'Statistics retrieved successfully');
}

/**
 * Get stock transactions
 */
function getStockTransactions($db) {
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 100;
    
    // This query assumes JOIN can get product info if not stored in transaction
    // Uses p.reference, p.name if not in stock_transactions, OR if we want live product info
    $query = "SELECT st.*, p.reference as product_reference, p.name as product_name 
              FROM stock_transactions st
              LEFT JOIN products p ON st.product_id = p.id
              ORDER BY st.created_at DESC 
              LIMIT :limit";
              
    $stmt = $db->prepare($query);
    $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
    $stmt->execute();
    
    $transactions = $stmt->fetchAll();
    
    // Format to match Flutter StockTransaction model
    $formatted = [];
    foreach ($transactions as $t) {
        $formatted[] = [
            'id' => $t['id'],
            'product_id' => $t['product_id'],
            'product_reference' => $t['product_reference'], // From JOIN
            'product_name' => $t['product_name'], // From JOIN
            'type' => $t['type'],
            'quantity' => (int)$t['quantity'],
            'quantity_before' => isset($t['quantity_before']) ? (int)$t['quantity_before'] : 0,
            'quantity_after' => isset($t['quantity_after']) ? (int)$t['quantity_after'] : 0,
            'unit_price' => (float)$t['unit_price'],
            'total_amount' => (float)$t['unit_price'] * (int)$t['quantity'],
            'notes' => $t['notes'],
            'user_id' => $t['user_id'],
            'created_at' => $t['created_at'],
            // Add potentially missing fields as null or defaults to avoid crashes
            'supplier_id' => null,
            'supplier_name' => null,
            'document_id' => null,
            'document_number' => null,
            'customer_id' => null,
            'customer_name' => null
        ];
    }
    
    sendSuccess($formatted, 'Transactions retrieved successfully');
}


// ============================================
// Helper Functions
// ============================================

/**
 * Get raw product data
 */
function getProductRaw($db, $id) {
    $query = "SELECT * FROM products WHERE id = :id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $id);
    $stmt->execute();
    return $stmt->fetch(PDO::FETCH_ASSOC);
}

/**
 * Format product response to match Flutter model
 */
function formatProductResponse($product) {
    return [
        'id' => (string)$product['id'],
        'reference' => $product['reference'],
        'name' => $product['name'],
        'quantity' => (int)$product['quantity'],
        'min_stock' => (int)$product['min_stock'],
        'purchase_price' => (float)$product['purchase_price'],
        'selling_price' => (float)$product['selling_price'],
        'margin_rate' => (float)$product['margin_rate'],
        'supplier_id' => isset($product['supplier_id']) ? $product['supplier_id'] : null,
        'supplier_name' => isset($product['supplier_name']) ? $product['supplier_name'] : null,
        'category' => $product['category'],
        'barcode' => $product['barcode'],
        'unit' => $product['unit'],
        'image_path' => $product['image_path'],
        'notes' => $product['notes'],
        'is_active' => (bool)$product['is_active'],
        'created_at' => $product['created_at'],
        'updated_at' => $product['updated_at']
    ];
}

/**
 * Calculate selling price with margin
 */
function calculateSellingPrice($purchasePrice, $marginRate) {
    $price = $purchasePrice * (1 + $marginRate);
    // Smart rounding: round to nearest 5 or 10
    if ($price < 100) {
        return ceil($price / 5) * 5;
    } else {
        return ceil($price / 10) * 10;
    }
}

/**
 * Log stock transaction
 */
function logStockTransaction($db, $productId, $type, $quantity, $data) {
    try {
        // Attempt to insert with extended fields if columns exist
        // Falling back to standard fields if not
        $query = "INSERT INTO stock_transactions (
            product_id, type, quantity, unit_price, notes, user_id, 
            quantity_before, quantity_after, created_at
        ) VALUES (
            :product_id, :type, :quantity, :unit_price, :notes, :user_id,
            :quantity_before, :quantity_after, NOW()
        )";
        
        $stmt = $db->prepare($query);
        $stmt->bindParam(':product_id', $productId);
        $stmt->bindParam(':type', $type);
        $stmt->bindParam(':quantity', $quantity);
        $stmt->bindValue(':unit_price', $data['unit_price'] ?? 0);
        $stmt->bindValue(':notes', $data['notes'] ?? null);
        $stmt->bindValue(':user_id', $data['user_id'] ?? null);
        
        // Extended fields
        $stmt->bindValue(':quantity_before', $data['quantity_before'] ?? 0);
        $stmt->bindValue(':quantity_after', $data['quantity_after'] ?? $quantity);
        
        $stmt->execute();
    } catch (Exception $e) {
        // If it fails (likely due to missing columns), try minimal insert
        // This handles "incompatibility" if DB schema isn't updated
        try {
            $query = "INSERT INTO stock_transactions (
                product_id, type, quantity, unit_price, notes, user_id, created_at
            ) VALUES (
                :product_id, :type, :quantity, :unit_price, :notes, :user_id, NOW()
            )";
            $stmt = $db->prepare($query);
            $stmt->bindParam(':product_id', $productId);
            $stmt->bindParam(':type', $type);
            $stmt->bindParam(':quantity', $quantity);
            $stmt->bindValue(':unit_price', $data['unit_price'] ?? 0);
            $stmt->bindValue(':notes', $data['notes'] ?? null);
            $stmt->bindValue(':user_id', $data['user_id'] ?? null);
            $stmt->execute();
        } catch (Exception $e2) {
             error_log("Failed to log stock transaction: " . $e2->getMessage());
        }
    }
}
