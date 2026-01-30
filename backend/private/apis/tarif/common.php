<?php
if (!defined('API_ACCESS')) {
    die(json_encode(['error' => 'Direct access not permitted']));
}

/**
 * Common functions for Tarif API
 * الدوال المشتركة لـ API التعريفات
 */

/**
 * تنظيف المدخلات
 */
function sanitize_input($data) {
    if (is_array($data)) {
        return array_map('sanitize_input', $data);
    }
    return htmlspecialchars(trim($data), ENT_QUOTES, 'UTF-8');
}

/**
 * الحصول على بيانات JSON من body الطلب
 */
function getJsonInput() {
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        jsonResponse([
            'success' => false,
            'error' => 'Invalid JSON input',
            'code' => 'INVALID_JSON'
        ], 400);
    }
    
    return $data ?? [];
}

/**
 * التحقق من الحقول المطلوبة
 */
function validateRequired($data, $required) {
    $missing = [];
    foreach ($required as $field) {
        if (!isset($data[$field]) || (is_string($data[$field]) && trim($data[$field]) === '')) {
            $missing[] = $field;
        }
    }
    return $missing;
}

/**
 * تنسيق صف التعريفة للإرجاع
 */
function formatTarifRow($row) {
    return [
        'id' => (int)$row['id'],
        'ref_mattress' => $row['ref_mattress'],
        'name' => $row['name'],
        'size' => $row['size'],
        'sponge_price' => (float)($row['sponge_price'] ?? 0),
        'springs_price' => (float)($row['springs_price'] ?? 0),
        'dress_price' => (float)($row['dress_price'] ?? 0),
        'sfifa_price' => (float)($row['sfifa_price'] ?? 0),
        'footer_price' => (float)($row['footer_price'] ?? 0),
        'packaging_price' => (float)($row['packaging_price'] ?? 0),
        'cost_price' => (float)($row['cost_price'] ?? 0),
        'profit_price' => (float)($row['profit_price'] ?? 0),
        'final_price' => (float)($row['final_price'] ?? 0)
    ];
}

/**
 * التحقق من وجود التعريفة
 */
function findTarifById($pdo, $id) {
    $stmt = $pdo->prepare("SELECT id, id_price FROM tarif WHERE id = ?");
    $stmt->execute([$id]);
    return $stmt->fetch(PDO::FETCH_ASSOC);
}

/**
 * جلب التعريفة مع تفاصيلها
 */
function getTarifWithDetails($pdo, $id) {
    $sql = "SELECT 
                t.id,
                t.ref_mattress,
                t.name,
                t.size,
                td.sponge_price,
                td.springs_price,
                td.dress_price,
                td.sfifa_price,
                td.footer_price,
                td.packaging_price,
                td.cost_price,
                td.profit_price,
                td.final_price
            FROM tarif t
            LEFT JOIN tarif_details td ON t.id_price = td.id
            WHERE t.id = :id";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute(['id' => $id]);
    return $stmt->fetch(PDO::FETCH_ASSOC);
}
?>
