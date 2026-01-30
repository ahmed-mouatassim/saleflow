<?php
/**
 * ملف الاتصال بقاعدة البيانات - SaleFlow API
 * المسار: /private/config/database.php
 * 
 * يستخدم نمط Singleton للاتصال بقاعدة البيانات
 * مع PDO للأمان والمرونة
 */

// منع الوصول المباشر
if (!defined('API_ACCESS')) {
    http_response_code(403);
    die('Direct access not permitted');
}

class Database {
    private static $instance = null;
    private $connection;
    
    // إعدادات قاعدة البيانات - cPanel
    // ملاحظة: يجب تحديث كلمة المرور الفعلية من cPanel
    private $host = 'localhost';  
    private $username = 'alidorma_saleflow_user'; // اسم مستخدم قاعدة البيانات في cPanel
    private $password = '159632003saleflow';                  // ← ضع كلمة مرور قاعدة البيانات هنا
    private $database = 'alidorma_saleflow'; // اسم قاعدة البيانات في cPanel
    private $charset = 'utf8mb4';
    
    // Private constructor لمنع إنشاء نسخ متعددة
    private function __construct() {
        try {
            $dsn = "mysql:host={$this->host};dbname={$this->database};charset={$this->charset}";
            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
                PDO::ATTR_PERSISTENT         => false,
                PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4",
                PDO::ATTR_TIMEOUT            => 5,
            ];
            
            $this->connection = new PDO($dsn, $this->username, $this->password, $options);
            
        } catch (PDOException $e) {
            error_log('SaleFlow DB Connection Error: ' . $e->getMessage());
            error_log('Connection details: Host=' . $this->host . ', DB=' . $this->database);
            
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'error' => 'Database connection failed',
                'code' => 'DB_CONNECTION_ERROR'
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
    }
    
    // الحصول على نسخة واحدة فقط (Singleton Pattern)
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    // الحصول على الاتصال
    public function getConnection() {
        return $this->connection;
    }
    
    // إعادة الاتصال إذا انقطع
    public function reconnect() {
        $this->connection = null;
        self::$instance = null;
        return self::getInstance();
    }
    
    // منع استنساخ الكائن
    private function __clone() {}
    
    // منع إلغاء التسلسل
    public function __wakeup() {
        throw new Exception("Cannot unserialize singleton");
    }
    
    // إغلاق الاتصال عند الانتهاء
    public function __destruct() {
        $this->connection = null;
    }
}

// دالة مساعدة للحصول على الاتصال بسهولة
function getDB() {
    return Database::getInstance()->getConnection();
}
?>
