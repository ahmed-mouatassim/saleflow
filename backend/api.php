<?php
/**
 * SaleFlow API Router - نقطة الدخول الوحيدة
 * المسار: /public_html/api.php
 * 
 * الاستخدام:
 * https://yourdomain.com/api.php?endpoint=tarif
 * https://yourdomain.com/api.php?endpoint=auth
 */

// تعريف ثابت للوصول الآمن
define('API_ACCESS', true);

// إعدادات الأمان
header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('X-XSS-Protection: 1; mode=block');

// CORS Headers
$allowed_origins = [
    'https://yourdomain.com',
    'https://www.yourdomain.com',
    'http://localhost:3000',
    'http://localhost:8080',
    '*' // للتطوير - قم بإزالتها في الإنتاج
];

$origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
if (in_array($origin, $allowed_origins) || in_array('*', $allowed_origins)) {
    header("Access-Control-Allow-Origin: $origin");
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-API-Key');
    header('Access-Control-Allow-Credentials: true');
    header('Access-Control-Max-Age: 86400');
}

// معالجة طلبات OPTIONS (Preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// تفعيل تسجيل الأخطاء
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/../private/logs/api_errors.log');

// دالة للاستجابة بـ JSON
function jsonResponse($data, $code = 200) {
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

// التحقق من API Key
function validateApiKey() {
    $api_key = $_SERVER['HTTP_X_API_KEY'] ?? '';
    
    // قائمة المفاتيح الصالحة
    $valid_keys = [
        'saleflow_api_key_2025_secure',  // مفتاح الإنتاج
        'saleflow_test_key_67890'         // مفتاح الاختبار
    ];
    
    // للتطوير: السماح بالوصول بدون مفتاح (قم بإزالة هذا في الإنتاج)
    if (empty($api_key)) {
        return true; // تخطي التحقق للتطوير
    }
    
    if (!in_array($api_key, $valid_keys)) {
        jsonResponse([
            'success' => false,
            'error' => 'Unauthorized - Invalid or missing API Key',
            'code' => 'INVALID_API_KEY'
        ], 401);
    }
}

// Rate Limiting بسيط
function checkRateLimit() {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    
    $max_requests = 100; // 100 طلب
    $time_window = 3600; // في الساعة
    
    if (!isset($_SESSION['api_requests'])) {
        $_SESSION['api_requests'] = [
            'count' => 0,
            'start_time' => time(),
            'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
        ];
    }
    
    // إعادة تعيين العداد إذا انتهت الفترة
    if (time() - $_SESSION['api_requests']['start_time'] > $time_window) {
        $_SESSION['api_requests'] = [
            'count' => 0,
            'start_time' => time(),
            'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
        ];
    }
    
    // التحقق من الحد الأقصى
    if ($_SESSION['api_requests']['count'] >= $max_requests) {
        jsonResponse([
            'success' => false,
            'error' => 'Too many requests. Please try again later.',
            'code' => 'RATE_LIMIT_EXCEEDED',
            'retry_after' => $time_window - (time() - $_SESSION['api_requests']['start_time'])
        ], 429);
    }
    
    $_SESSION['api_requests']['count']++;
}

// تطبيق الفحوصات الأمنية
validateApiKey();
checkRateLimit();

// الحصول على Endpoint المطلوب
$endpoint = $_GET['endpoint'] ?? '';
$endpoint = preg_replace('/[^a-zA-Z0-9_-]/', '', $endpoint); // تنظيف الإدخال

// مسار مجلد الـ APIs
$api_base_path = __DIR__ . '/../private/apis/';

// قائمة الـ Endpoints المتاحة
$available_endpoints = [
    'tarif' => 'tarif.php',
    'prices' => 'prices.php',
    'auth' => 'auth.php',
    'products' => 'products.php',
    'orders' => 'orders.php',
    'customers' => 'customers.php'
];

// عرض المعلومات إذا لم يتم تحديد endpoint
if (empty($endpoint)) {
    jsonResponse([
        'success' => true,
        'message' => 'مرحباً بك في SaleFlow API',
        'version' => '2.0.0',
        'available_endpoints' => array_keys($available_endpoints),
        'usage' => 'api.php?endpoint={name}',
        'documentation' => [
            'tarif' => [
                'GET' => 'Get all tarifs or specific by id/name/size',
                'POST' => 'Create new tarif',
                'PUT' => 'Update existing tarif',
                'DELETE' => 'Delete tarif by id'
            ]
        ]
    ], 200);
}

// التحقق من وجود الـ Endpoint
if (!isset($available_endpoints[$endpoint])) {
    jsonResponse([
        'success' => false,
        'error' => 'Invalid endpoint',
        'requested' => $endpoint,
        'available_endpoints' => array_keys($available_endpoints)
    ], 404);
}

// بناء المسار الكامل
$api_file = $api_base_path . $available_endpoints[$endpoint];

// التحقق من وجود الملف
if (!file_exists($api_file)) {
    error_log("SaleFlow API: File not found - $api_file");
    jsonResponse([
        'success' => false,
        'error' => 'API endpoint not implemented yet',
        'code' => 'ENDPOINT_NOT_IMPLEMENTED'
    ], 501);
}

// تحميل ملف الـ API
try {
    require_once $api_file;
} catch (Exception $e) {
    error_log("SaleFlow API Error: " . $e->getMessage());
    jsonResponse([
        'success' => false,
        'error' => 'Internal server error',
        'code' => 'EXECUTION_ERROR'
    ], 500);
}
?>
