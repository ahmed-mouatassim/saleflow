<?php
// fix_db.php
// سكربت لإصلاح قاعدة البيانات وإضافة الأعمدة الناقصة

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// تعريف ثابت الوصول لتجاوز الحماية في database.php
define('API_ACCESS', true);

// محاولة تضمين ملف الاتصال بقاعدة البيانات
$configFile = __DIR__ . '/../private/config/database.php';

if (!file_exists($configFile)) {
    die("خطأ: لم يتم العثور على ملف الإعدادات في: $configFile");
}

require_once $configFile;

try {
    echo "<h1>جاري تحديث قاعدة البيانات...</h1>";
    
    $pdo = getDB();
    
    // التحقق من وجود العمود profit_price
    $stmt = $pdo->query("SHOW COLUMNS FROM tarif_details LIKE 'profit_price'");
    $exists = $stmt->fetch();
    
    if (!$exists) {
        // إضافة العمود إذا لم يكن موجوداً
        $sql = "ALTER TABLE tarif_details ADD COLUMN profit_price DECIMAL(10,3) DEFAULT 0 AFTER cost_price";
        $pdo->exec($sql);
        echo "<p style='color: green;'>✅ تم إضافة عمود <strong>profit_price</strong> بنجاح إلى جدول tarif_details.</p>";
    } else {
        echo "<p style='color: blue;'>ℹ️ العمود <strong>profit_price</strong> موجود بالفعل.</p>";
    }
    
    echo "<p>تم الانتهاء. يمكنك الآن استخدام التطبيق.</p>";
    echo "<br><a href='api.php?endpoint=tarif'>تجربة API الآن</a>";
    
} catch (PDOException $e) {
    echo "<p style='color: red;'>خطأ في قاعدة البيانات: " . $e->getMessage() . "</p>";
} catch (Exception $e) {
    echo "<p style='color: red;'>خطأ غير متوقع: " . $e->getMessage() . "</p>";
}
?>
