<?php
/**
 * Prices API Dispatcher - SaleFlow
 * المسار: /private/apis/prices.php
 * 
 * نقطة توزيع الطلبات على ملفات CRUD المنفصلة
 */

// التحقق من الوصول الآمن
if (!defined('API_ACCESS')) {
    http_response_code(403);
    die(json_encode(['error' => 'Direct access not permitted']));
}

// تحميل ملف قاعدة البيانات
require_once __DIR__ . '/../../config/database.php';

// يمكننا تحديد المسار للملفات الفرعية
$basePath = __DIR__ . '/';

try {
    $pdo = getDB();
    $method = $_SERVER['REQUEST_METHOD'];

    switch ($method) {
        case 'GET':
            require_once $basePath . 'read.php';
            break;
        case 'POST':
            require_once $basePath . 'create.php';
            break;
        case 'PUT':
            require_once $basePath . 'update.php';
            break;
        case 'DELETE':
            require_once $basePath . 'delete.php';
            break;
        default:
            jsonResponse([
                'success' => false,
                'error' => 'Method not allowed',
                'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE']
            ], 405);
    }
} catch (PDOException $e) {
    error_log('Prices API Dispatcher Error: ' . $e->getMessage());
    jsonResponse([
        'success' => false,
        'error' => 'Database error occurred',
        'code' => 'DB_ERROR'
    ], 500);
}
?>
