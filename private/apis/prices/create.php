<?php
if (!defined('API_ACCESS')) {
    die(json_encode(['error' => 'Direct access not permitted']));
}

require_once __DIR__ . '/common.php';

function handlePost($pdo) {
    $input = getJsonInput();
    
    // التحقق من الحقول المطلوبة
    $required = ['name', 'type', 'price'];
    $missing = validateRequired($input, $required);
    
    if (!empty($missing)) {
        jsonResponse([
            'success' => false,
            'error' => 'Missing required fields',
            'missing_fields' => $missing,
            'code' => 'VALIDATION_ERROR'
        ], 400);
    }
    
    // تنظيف البيانات
    $name = sanitize_input($input['name']);
    $type = sanitize_input($input['type']);
    $price = (float)$input['price'];
    $editedBy = sanitize_input($input['edite_by'] ?? 'system');
    
    // إدراج السعر الجديد
    $stmt = $pdo->prepare("
        INSERT INTO prices (name, type, price, date, edite_by) 
        VALUES (:name, :type, :price, NOW(), :edite_by)
    ");
    
    $stmt->execute([
        'name' => $name,
        'type' => $type,
        'price' => $price,
        'edite_by' => $editedBy
    ]);
    
    $newId = $pdo->lastInsertId();
    
    // جلب السجل المُنشأ
    $stmt = $pdo->prepare("SELECT * FROM prices WHERE id = :id");
    $stmt->execute(['id' => $newId]);
    $newPrice = $stmt->fetch();
    
    jsonResponse([
        'success' => true,
        'message' => 'تم إنشاء السعر بنجاح',
        'data' => formatPriceRow($newPrice)
    ], 201);
}

// Execute logic
try {
    handlePost($pdo);
} catch (Exception $e) {
    jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
}
?>
