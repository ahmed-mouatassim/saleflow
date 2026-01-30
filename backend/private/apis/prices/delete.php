<?php
if (!defined('API_ACCESS')) {
    die(json_encode(['error' => 'Direct access not permitted']));
}

require_once __DIR__ . '/common.php';

function handleDelete($pdo) {
    $id = $_GET['id'] ?? null;
    $name = $_GET['name'] ?? null;
    $type = $_GET['type'] ?? null;
    
    if (!$id && (!$name || !$type)) {
        jsonResponse([
            'success' => false,
            'error' => 'Either id or (name and type) is required',
            'code' => 'VALIDATION_ERROR'
        ], 400);
    }
    
    // البحث عن السجل
    if ($id) {
        $stmt = $pdo->prepare("SELECT * FROM prices WHERE id = :id");
        $stmt->execute(['id' => (int)$id]);
        $existing = $stmt->fetch();
        
        if (!$existing) {
            jsonResponse([
                'success' => false,
                'error' => 'Price not found',
                'code' => 'NOT_FOUND'
            ], 404);
        }
        
        // حذف السجل المحدد
        $deleteStmt = $pdo->prepare("DELETE FROM prices WHERE id = :id");
        $deleteStmt->execute(['id' => (int)$id]);
        $deletedCount = 1;
    } else {
        // حذف جميع السجلات بهذا الاسم والنوع
        $stmt = $pdo->prepare("SELECT COUNT(*) as count FROM prices WHERE name = :name AND type = :type");
        $stmt->execute([
            'name' => sanitize_input($name),
            'type' => sanitize_input($type)
        ]);
        $count = $stmt->fetch()['count'];
        
        if ($count == 0) {
            jsonResponse([
                'success' => false,
                'error' => 'Price not found',
                'code' => 'NOT_FOUND'
            ], 404);
        }
        
        $deleteStmt = $pdo->prepare("DELETE FROM prices WHERE name = :name AND type = :type");
        $deleteStmt->execute([
            'name' => sanitize_input($name),
            'type' => sanitize_input($type)
        ]);
        $deletedCount = $count;
    }
    
    jsonResponse([
        'success' => true,
        'message' => 'تم حذف السعر بنجاح',
        'deleted_count' => (int)$deletedCount
    ]);
}

// Execute logic
try {
    handleDelete($pdo);
} catch (Exception $e) {
    jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
}
?>
