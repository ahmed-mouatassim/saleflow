<?php
/**
 * Prices API Endpoint - SaleFlow
 * المسار: /private/apis/prices.php
 * 
 * نقاط النهاية:
 * - GET: جلب جميع الأسعار مجمعة حسب النوع
 */

// التحقق من الوصول الآمن
if (!defined('API_ACCESS')) {
    http_response_code(403);
    die(json_encode(['error' => 'Direct access not permitted']));
}

// تحميل ملف قاعدة البيانات والدوال المساعدة
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/helpers.php';

$method = $_SERVER['REQUEST_METHOD'];

try {
    $pdo = getDB();
    
    switch ($method) {
        case 'GET':
            handleGet($pdo);
            break;
        default:
            jsonResponse([
                'success' => false,
                'error' => 'Method not allowed',
                'allowed_methods' => ['GET']
            ], 405);
    }
} catch (PDOException $e) {
    error_log('Prices API Error: ' . $e->getMessage());
    jsonResponse([
        'success' => false,
        'error' => 'Database error occurred',
        'code' => 'DB_ERROR'
    ], 500);
}

/**
 * معالجة طلبات GET
 */
function handleGet($pdo) {
    $type = $_GET['type'] ?? null;
    
    // استعلام أساسي - جلب أحدث سعر لكل اسم ونوع
    $sql = "SELECT p1.id, p1.name, p1.type, p1.price, p1.date, p1.edite_by
            FROM prices p1
            INNER JOIN (
                SELECT name, type, MAX(id) as max_id
                FROM prices
                GROUP BY name, type
            ) p2 ON p1.name = p2.name AND p1.type = p2.type AND p1.id = p2.max_id";
    
    $params = [];
    
    if ($type) {
        $sql .= " WHERE p1.type = :type";
        $params['type'] = sanitize_input($type);
    }
    
    $sql .= " ORDER BY p1.type, p1.name";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $rows = $stmt->fetchAll();
    
    // تجميع البيانات حسب النوع
    $spongeTypes = [];
    $dressTypes = [];
    $footerTypes = [];
    $sfifa = [];
    $packagingDefaults = [];
    $costDefaults = [];
    $allProducts = [];
    
    foreach ($rows as $row) {
        $product = [
            'id' => (int)$row['id'],
            'name' => $row['name'],
            'type' => $row['type'],
            'price' => (float)$row['price'],
            'date' => $row['date'],
            'edite_by' => $row['edite_by']
        ];
        
        $allProducts[] = $product;
        
        $name = $row['name'];
        $price = (float)$row['price'];
        $productType = $row['type'];
        
        switch ($productType) {
            case 'spongeTypes':
                $spongeTypes[$name] = (int)$price;
                break;
            case 'dressTypes':
                $dressTypes[$name] = $price;
                break;
            case 'footerTypes':
                $footerTypes[$name] = $price;
                break;
            case 'sfifa':
            case 'spring':
                $sfifa[$name] = $price;
                break;
            case 'Packaging Defaults':
                $packagingDefaults[$name] = $price;
                break;
            case 'Cost Defaults':
                $costDefaults[$name] = $price;
                break;
        }
    }
    
    jsonResponse([
        'success' => true,
        'count' => count($allProducts),
        'data' => [
            'spongeTypes' => $spongeTypes,
            'dressTypes' => $dressTypes,
            'footerTypes' => $footerTypes,
            'sfifa' => $sfifa,
            'packagingDefaults' => $packagingDefaults,
            'costDefaults' => $costDefaults,
            'allProducts' => $allProducts
        ]
    ]);
}
?>
