<?php
if (!defined('API_ACCESS')) {
    die(json_encode(['error' => 'Direct access not permitted']));
}

require_once __DIR__ . '/common.php';

/**
 * معالجة طلبات PUT لتحديث تعريفة
 */
function handlePut($pdo) {
    $input = getJsonInput();
    
    $id = $input['id'] ?? $_GET['id'] ?? null;
    
    if (!$id) {
        jsonResponse([
            'success' => false,
            'error' => 'Tarif ID is required',
            'code' => 'VALIDATION_ERROR'
        ], 400);
    }
    
    // التحقق من وجود التعريفة
    $existing = findTarifById($pdo, $id);
    
    if (!$existing) {
        jsonResponse([
            'success' => false,
            'error' => 'Tarif not found',
            'code' => 'NOT_FOUND'
        ], 404);
    }
    
    $pdo->beginTransaction();
    
    try {
        // تحديث تفاصيل السعر
        if ($existing['id_price']) {
            $stmtDetails = $pdo->prepare("
                UPDATE tarif_details SET
                    sponge_price = :sponge,
                    springs_price = :springs,
                    dress_price = :dress,
                    sfifa_price = :sfifa,
                    footer_price = :footer,
                    packaging_price = :packaging,
                    cost_price = :cost,
                    profit_price = :profit,
                    final_price = :final
                WHERE id = :id
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
                'final' => (float)($input['final_price'] ?? 0),
                'id' => $existing['id_price']
            ]);
        }
        
        // تحديث التعريفة الرئيسية (إذا تم توفير بيانات)
        if (isset($input['ref_mattress']) || isset($input['name']) || isset($input['size'])) {
            // جلب البيانات الحالية للحفاظ على القيم غير المحدثة
            $currentTarif = getTarifWithDetails($pdo, $id);
            
            $stmtTarif = $pdo->prepare("
                UPDATE tarif SET
                    ref_mattress = :ref,
                    name = :name,
                    size = :size
                WHERE id = :id
            ");
            
            $stmtTarif->execute([
                'ref' => sanitize_input($input['ref_mattress'] ?? $currentTarif['ref_mattress']),
                'name' => sanitize_input($input['name'] ?? $currentTarif['name']),
                'size' => sanitize_input($input['size'] ?? $currentTarif['size']),
                'id' => $id
            ]);
        }
        
        $pdo->commit();
        
        // جلب التعريفة المُحدثة
        $updatedTarif = getTarifWithDetails($pdo, $id);
        
        jsonResponse([
            'success' => true,
            'message' => 'تم تحديث التعريفة بنجاح',
            'data' => formatTarifRow($updatedTarif)
        ]);
        
    } catch (Exception $e) {
        $pdo->rollBack();
        throw $e;
    }
}

// Execute logic
try {
    handlePut($pdo);
} catch (Exception $e) {
    jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
}
?>
