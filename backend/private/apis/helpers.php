<?php
/**
 * ملف الدوال المساعدة - SaleFlow API
 * المسار: /private/apis/helpers.php
 * 
 * يحتوي على دوال مساعدة للتحقق، التنظيف، والأمان
 */

if (!defined('API_ACCESS')) {
    die('Direct access not permitted');
}

/**
 * تنظيف وتطهير البيانات
 */
function sanitize_input($data, $type = 'string') {
    if (is_array($data)) {
        return array_map(function($item) use ($type) {
            return sanitize_input($item, $type);
        }, $data);
    }
    
    $data = trim($data);
    $data = stripslashes($data);
    
    switch ($type) {
        case 'email':
            return filter_var($data, FILTER_SANITIZE_EMAIL);
        case 'int':
            return filter_var($data, FILTER_SANITIZE_NUMBER_INT);
        case 'float':
            return filter_var($data, FILTER_SANITIZE_NUMBER_FLOAT, FILTER_FLAG_ALLOW_FRACTION);
        case 'url':
            return filter_var($data, FILTER_SANITIZE_URL);
        case 'string':
        default:
            return htmlspecialchars($data, ENT_QUOTES, 'UTF-8');
    }
}

/**
 * التحقق من صحة البريد الإلكتروني
 */
function validate_email($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

/**
 * تسجيل النشاط
 */
function log_activity($user_id, $action, $details = null) {
    try {
        $db = getDB();
        
        $stmt = $db->prepare("
            INSERT INTO activity_logs 
            (user_id, action, details, ip_address, user_agent, created_at) 
            VALUES (:user_id, :action, :details, :ip, :user_agent, NOW())
        ");
        
        $stmt->execute([
            'user_id' => $user_id,
            'action' => $action,
            'details' => $details ? json_encode($details) : null,
            'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown'
        ]);
        
        return true;
    } catch (Exception $e) {
        error_log('Activity logging error: ' . $e->getMessage());
        return false;
    }
}

/**
 * تنسيق التاريخ للعرض
 */
function format_date($date, $format = 'Y-m-d H:i:s') {
    if (empty($date)) return null;
    
    $timestamp = is_numeric($date) ? $date : strtotime($date);
    return date($format, $timestamp);
}

/**
 * حساب الوقت النسبي
 */
function time_ago($timestamp) {
    $time = is_numeric($timestamp) ? $timestamp : strtotime($timestamp);
    $diff = time() - $time;
    
    if ($diff < 60) {
        return 'منذ ' . $diff . ' ثانية';
    } elseif ($diff < 3600) {
        return 'منذ ' . floor($diff / 60) . ' دقيقة';
    } elseif ($diff < 86400) {
        return 'منذ ' . floor($diff / 3600) . ' ساعة';
    } elseif ($diff < 2592000) {
        return 'منذ ' . floor($diff / 86400) . ' يوم';
    } elseif ($diff < 31536000) {
        return 'منذ ' . floor($diff / 2592000) . ' شهر';
    } else {
        return 'منذ ' . floor($diff / 31536000) . ' سنة';
    }
}

/**
 * تحويل الحجم بالبايت إلى صيغة قابلة للقراءة
 */
function format_bytes($bytes, $precision = 2) {
    $units = ['B', 'KB', 'MB', 'GB', 'TB'];
    
    for ($i = 0; $bytes > 1024 && $i < count($units) - 1; $i++) {
        $bytes /= 1024;
    }
    
    return round($bytes, $precision) . ' ' . $units[$i];
}

/**
 * معالجة أخطاء PDO بشكل آمن
 */
function handle_db_error($e, $context = '') {
    $error_message = sprintf(
        "[%s] %s - Error: %s | File: %s | Line: %d",
        date('Y-m-d H:i:s'),
        $context,
        $e->getMessage(),
        $e->getFile(),
        $e->getLine()
    );
    
    error_log($error_message);
    
    return [
        'success' => false,
        'error' => 'A database error occurred',
        'code' => 'DB_ERROR'
    ];
}

/**
 * إنشاء Token عشوائي آمن
 */
function generate_secure_token($length = 32) {
    return bin2hex(random_bytes($length));
}

/**
 * التحقق من صلاحية JSON Web Token (JWT)
 */
function verify_jwt($token, $secret_key) {
    $parts = explode('.', $token);
    
    if (count($parts) !== 3) {
        return false;
    }
    
    list($header, $payload, $signature) = $parts;
    
    $valid_signature = hash_hmac(
        'sha256',
        "$header.$payload",
        $secret_key,
        true
    );
    
    $valid_signature = rtrim(strtr(base64_encode($valid_signature), '+/', '-_'), '=');
    
    if (!hash_equals($signature, $valid_signature)) {
        return false;
    }
    
    $payload_data = json_decode(base64_decode(strtr($payload, '-_', '+/')), true);
    
    if (isset($payload_data['exp']) && $payload_data['exp'] < time()) {
        return false;
    }
    
    return $payload_data;
}

/**
 * إنشاء JSON Web Token (JWT)
 */
function create_jwt($payload, $secret_key, $expiry = 86400) {
    $payload['exp'] = time() + $expiry;
    $payload['iat'] = time();
    
    $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
    $header = rtrim(strtr(base64_encode($header), '+/', '-_'), '=');
    
    $payload = json_encode($payload);
    $payload = rtrim(strtr(base64_encode($payload), '+/', '-_'), '=');
    
    $signature = hash_hmac('sha256', "$header.$payload", $secret_key, true);
    $signature = rtrim(strtr(base64_encode($signature), '+/', '-_'), '=');
    
    return "$header.$payload.$signature";
}

/**
 * إنشاء معرف فريد UUID v4
 */
function generate_uuid() {
    return sprintf(
        '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        mt_rand(0, 0xffff), mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),
        mt_rand(0, 0x0fff) | 0x4000,
        mt_rand(0, 0x3fff) | 0x8000,
        mt_rand(0, 0xffff), mt_rand(0, 0xffff), mt_rand(0, 0xffff)
    );
}

/**
 * حماية من XSS في النصوص
 */
function xss_clean($data) {
    if (is_array($data)) {
        return array_map('xss_clean', $data);
    }
    
    $data = str_replace(chr(0), '', $data);
    $data = preg_replace('/<script\b[^>]*>(.*?)<\/script>/is', '', $data);
    $data = preg_replace('/<iframe\b[^>]*>(.*?)<\/iframe>/is', '', $data);
    
    return htmlspecialchars($data, ENT_QUOTES, 'UTF-8');
}

/**
 * الحصول على IP الحقيقي للمستخدم
 */
function get_real_ip() {
    $ip_keys = [
        'HTTP_CLIENT_IP',
        'HTTP_X_FORWARDED_FOR',
        'HTTP_X_FORWARDED',
        'HTTP_X_CLUSTER_CLIENT_IP',
        'HTTP_FORWARDED_FOR',
        'HTTP_FORWARDED',
        'REMOTE_ADDR'
    ];
    
    foreach ($ip_keys as $key) {
        if (array_key_exists($key, $_SERVER) === true) {
            foreach (explode(',', $_SERVER[$key]) as $ip) {
                $ip = trim($ip);
                
                if (filter_var($ip, FILTER_VALIDATE_IP, 
                    FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) !== false) {
                    return $ip;
                }
            }
        }
    }
    
    return $_SERVER['REMOTE_ADDR'] ?? 'unknown';
}

/**
 * التحقق من كون الطلب AJAX
 */
function is_ajax_request() {
    return !empty($_SERVER['HTTP_X_REQUESTED_WITH']) 
        && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest';
}

/**
 * تصفية وتنظيف مصفوفة البيانات
 */
function filter_array($array, $allowed_keys) {
    return array_intersect_key($array, array_flip($allowed_keys));
}

/**
 * التحقق من تنسيق رقم الهاتف المغربي
 */
function validate_phone($phone, $country_code = 'MA') {
    if ($country_code === 'MA') {
        $pattern = '/^(?:\+212|0)[5-7][0-9]{8}$/';
        return preg_match($pattern, preg_replace('/[\s\-\(\)]/', '', $phone));
    }
    
    return preg_match('/^[\+]?[0-9]{10,15}$/', preg_replace('/[\s\-\(\)]/', '', $phone));
}

/**
 * تحويل الوقت إلى المنطقة الزمنية المغربية
 */
function convert_timezone($datetime, $from_tz = 'UTC', $to_tz = 'Africa/Casablanca') {
    $dt = new DateTime($datetime, new DateTimeZone($from_tz));
    $dt->setTimezone(new DateTimeZone($to_tz));
    return $dt->format('Y-m-d H:i:s');
}
?>
