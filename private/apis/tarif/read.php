<?php
if (!defined('API_ACCESS')) {
    die(json_encode(['error' => 'Direct access not permitted']));
}

require_once __DIR__ . '/common.php';

/**
 * معالجة طلبات GET للتعريفات
 */
function handleGet($pdo) {
    // إعادة الاتصال بقاعدة البيانات لضمان بيانات جديدة
    $pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
    
    $id = $_GET['id'] ?? null;
    $name = $_GET['name'] ?? null;
    $size = $_GET['size'] ?? null;
    
    // جلب تعريفة محددة بـ ID
    if ($id) {
        $tarif = getTarifWithDetails($pdo, (int)$id);
        
        if ($tarif) {
            jsonResponse([
                'success' => true,
                'data' => formatTarifRow($tarif)
            ]);
        } else {
            jsonResponse([
                'success' => false,
                'error' => 'Tarif not found',
                'code' => 'NOT_FOUND'
            ], 404);
        }
        return;
    }
    
    // استعلام أساسي مع إجبار قراءة جديدة من قاعدة البيانات
    $sql = "SELECT SQL_NO_CACHE
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
            LEFT JOIN tarif_details td ON t.id_price = td.id";
    
    $params = [];
    $conditions = [];
    
    if ($name) {
        $conditions[] = "t.name LIKE :name";
        $params['name'] = '%' . sanitize_input($name) . '%';
    }
    
    if ($size) {
        $conditions[] = "t.size = :size";
        $params['size'] = sanitize_input($size);
    }
    
    if (!empty($conditions)) {
        $sql .= " WHERE " . implode(' AND ', $conditions);
    }
    
    $sql .= " ORDER BY t.name, t.size";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    
    // تجميع البيانات
    $data = [];
    $count = 0;
    
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $data[] = formatTarifRow($row);
        $count++;
    }
    
    // تحرير الذاكرة
    $stmt->closeCursor();
    $stmt = null;
    
    jsonResponse([
        'success' => true,
        'count' => $count,
        'data' => $data,
        'timestamp' => time()
    ]);
    
    // تنظيف نهائي
    unset($data);
}

// Execute logic
try {
    handleGet($pdo);
} catch (Exception $e) {
    jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
} finally {
    $pdo = null;
}
?>
