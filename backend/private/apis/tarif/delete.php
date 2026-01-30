<?php
if (!defined('API_ACCESS')) {
    die(json_encode(['error' => 'Direct access not permitted']));
}

require_once __DIR__ . '/common.php';

/**
 * معالجة طلبات DELETE لحذف تعريفة
 */
function handleDelete($pdo) {
    $id = $_GET['id'] ?? null;
    
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
        // حذف التعريفة أولاً (بسبب العلاقة مع tarif_details)
        $stmtTarif = $pdo->prepare("DELETE FROM tarif WHERE id = ?");
        $stmtTarif->execute([$id]);
        
        // حذف تفاصيل السعر
        if ($existing['id_price']) {
            $stmtDetails = $pdo->prepare("DELETE FROM tarif_details WHERE id = ?");
            $stmtDetails->execute([$existing['id_price']]);
        }
        
        $pdo->commit();
        
        jsonResponse([
            'success' => true,
            'message' => 'تم حذف التعريفة بنجاح',
            'deleted_id' => (int)$id
        ]);
        
    } catch (Exception $e) {
        $pdo->rollBack();
        throw $e;
    }
}

// Execute logic
try {
    handleDelete($pdo);
} catch (Exception $e) {
    jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
}
?>
