<?php
if (!defined('API_ACCESS')) {
    die(json_encode(['error' => 'Direct access not permitted']));
}

require_once __DIR__ . '/common.php';

/**
 * معالجة طلبات POST لإنشاء تعريفة جديدة
 */
function handlePost($pdo) {
    $input = getJsonInput();
    
    // التحقق من الحقول المطلوبة
    $required = ['ref_mattress', 'name', 'size'];
    $missing = validateRequired($input, $required);
    
    if (!empty($missing)) {
        jsonResponse([
            'success' => false,
            'error' => 'Missing required fields',
            'missing_fields' => $missing,
            'code' => 'VALIDATION_ERROR'
        ], 400);
    }
    
    $pdo->beginTransaction();
    
    try {
        // إدراج تفاصيل السعر أولاً
        $stmtDetails = $pdo->prepare("
            INSERT INTO tarif_details 
            (sponge_price, springs_price, dress_price, sfifa_price, footer_price, packaging_price, cost_price, profit_price, final_price)
            VALUES (:sponge, :springs, :dress, :sfifa, :footer, :packaging, :cost, :profit, :final)
        ");
        
        $stmtDetails->execute([
            'sponge' => (float)($input['sponge_price'] ?? 0),
            'springs' => (float)($input['springs_price'] ?? 0),
            'dress' => (float)($input['dress_price'] ?? 0),
            'sfifa' => (float)($input['sfifa_price'] ?? 0),
            'footer' => (float)($input['footer_price'] ?? 0),
            'packaging' => (float)($input['packaging_price'] ?? 0),
            'cost' => (float)($input['cost_price'] ?? 0),
            'profit' => (float)($input['profit_price'] ?? 0),
            'final' => (float)($input['final_price'] ?? 0)
        ]);
        
        $priceId = $pdo->lastInsertId();
        
        // إدراج التعريفة الرئيسية
        $stmtTarif = $pdo->prepare("
            INSERT INTO tarif (ref_mattress, name, size, id_price)
            VALUES (:ref, :name, :size, :price_id)
        ");
        
        $stmtTarif->execute([
            'ref' => sanitize_input($input['ref_mattress']),
            'name' => sanitize_input($input['name']),
            'size' => sanitize_input($input['size']),
            'price_id' => $priceId
        ]);
        
        $tarifId = $pdo->lastInsertId();
        
        $pdo->commit();
        
        // جلب التعريفة المُنشأة
        $newTarif = getTarifWithDetails($pdo, $tarifId);
        
        jsonResponse([
            'success' => true,
            'message' => 'تم إنشاء التعريفة بنجاح',
            'data' => formatTarifRow($newTarif)
        ], 201);
        
    } catch (Exception $e) {
        $pdo->rollBack();
        throw $e;
    }
}

// Execute logic
try {
    handlePost($pdo);
} catch (Exception $e) {
    jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
}
?>
