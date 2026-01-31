<?php
if (!defined('API_ACCESS')) {
    die(json_encode(['error' => 'Direct access not permitted']));
}

/**
 * Common functions for Prices API
 */

/**
 * تنظيف anass
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
 * تنسيق صف السعر للإرجاع
 */
function formatPriceRow($row) {
    return [
        'id' => (int)$row['id'],
        'name' => $row['name'],
        'type' => $row['type'],
        'price' => (float)$row['price'],
        'date' => $row['date'],
        'edite_by' => $row['edite_by']
    ];
}
?>
