<?php
if (!defined('API_ACCESS')) {
    die(json_encode(['error' => 'Direct access not permitted']));
}

require_once __DIR__ . '/common.php';

function handlePut($pdo) {
    $input = getJsonInput();
    
    // التحقق من وجود معرف أو (اسم ونوع)
    if (empty($input['id']) && (empty($input['name']) || empty($input['type']))) {
        jsonResponse([
            'success' => false,
            'error' => 'Either id or (name and type) is required',
            'code' => 'VALIDATION_ERROR'
        ], 400);
    }
    
    // التحقق من وجود السعر
    if (!isset($input['price'])) {
        jsonResponse([
            'success' => false,
            'error' => 'Price is required',
            'code' => 'VALIDATION_ERROR'
        ], 400);
    }
    
    $price = (float)$input['price'];
    $editedBy = sanitize_input($input['edite_by'] ?? 'system');
    
    // البحث بـ ID أو بـ name + type
    if (!empty($input['id'])) {
        $stmt = $pdo->prepare("SELECT * FROM prices WHERE id = :id");
        $stmt->execute(['id' => (int)$input['id']]);
    } else {
        // جلب أحدث سجل لهذا الاسم والنوع
        $stmt = $pdo->prepare("
            SELECT * FROM prices 
            WHERE name = :name AND type = :type 
            ORDER BY id DESC LIMIT 1
        ");
        $stmt->execute([
            'name' => sanitize_input($input['name']),
            'type' => sanitize_input($input['type'])
        ]);
    }
    
    $existing = $stmt->fetch();
    
    if (!$existing) {
        jsonResponse([
            'success' => false,
            'error' => 'Price not found',
            'code' => 'NOT_FOUND'
        ], 404);
    }
    
    // تحديث السجل الموجود بدلاً من إنشاء جديد
    if (!empty($input['id'])) {
        $stmt = $pdo->prepare("
            UPDATE prices 
            SET price = :price, edite_by = :edite_by, date = NOW() 
            WHERE id = :id
        ");
        $stmt->execute([
            'price' => $price,
            'edite_by' => $editedBy,
            'id' => (int)$input['id']
        ]);
        $updatedId = (int)$input['id'];
    } else {
        // تحديث جميع السجلات التي تحمل نفس الاسم والنوع لضمان الاتساق
        $stmt = $pdo->prepare("
            UPDATE prices 
            SET price = :price, edite_by = :edite_by, date = NOW() 
            WHERE name = :name AND type = :type
        ");
        $stmt->execute([
            'price' => $price,
            'edite_by' => $editedBy,
            'name' => $existing['name'],
            'type' => $existing['type']
        ]);
        $updatedId = $existing['id'];
    }
    
    // جلب السجل المُحدث
    $stmt = $pdo->prepare("SELECT * FROM prices WHERE id = :id");
    $stmt->execute(['id' => $updatedId]);
    $updatedPrice = $stmt->fetch();
    
    if (!$updatedPrice && empty($input['id'])) {
        // Fallback if we updated by name/type but the specific ID we have is tricky
        // Just fetch one by name/type
         $stmt = $pdo->prepare("SELECT * FROM prices WHERE name = :name AND type = :type ORDER BY id DESC LIMIT 1");
         $stmt->execute(['name' => $existing['name'], 'type' => $existing['type']]);
         $updatedPrice = $stmt->fetch();
    }
    
    jsonResponse([
        'success' => true,
        'message' => 'تم تحديث السعر بنجاح',
        'data' => formatPriceRow($updatedPrice),
        'previous_price' => (float)$existing['price']
    ]);
}

// Execute logic
try {
    handlePut($pdo);
} catch (Exception $e) {
    jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
}
?>
