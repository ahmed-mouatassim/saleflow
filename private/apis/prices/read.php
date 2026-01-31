<?php
if (!defined('API_ACCESS')) {
    die(json_encode(['error' => 'Direct access not permitted']));
}

require_once __DIR__ . '/common.php';

function handleGet($pdo) {
    // إعادة الاتصال بقاعدة البيانات لضمان بيانات جديدة
    $pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
    
    $type = $_GET['type'] ?? null;
    $id = $_GET['id'] ?? null;
    
    // جلب سعر محدد بـ ID
    if ($id) {
        $stmt = $pdo->prepare("SELECT * FROM prices WHERE id = :id");
        $stmt->execute(['id' => (int)$id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // تحرير الذاكرة فوراً
        $stmt->closeCursor();
        $stmt = null;
        
        if ($row) {
            jsonResponse([
                'success' => true,
                'data' => formatPriceRow($row)
            ]);
        } else {
            jsonResponse([
                'success' => false,
                'error' => 'Price not found',
                'code' => 'NOT_FOUND'
            ], 404);
        }
        return;
    }
    
    // ===================================================
    // الخطوة 1: جلب جميع الأنواع الفريدة من قاعدة البيانات
    // ===================================================
    $typesStmt = $pdo->query("SELECT SQL_NO_CACHE DISTINCT type FROM prices ORDER BY type");
    $distinctTypes = $typesStmt->fetchAll(PDO::FETCH_COLUMN);
    $typesStmt->closeCursor();
    $typesStmt = null;
    
    // إنشاء مصفوفة ديناميكية لتخزين البيانات حسب الأنواع
    $dataByType = [];
    foreach ($distinctTypes as $typeName) {
        $dataByType[$typeName] = [];
    }
    
    // ===================================================
    // الخطوة 2: جلب جميع البيانات مع تصفية حسب الأنواع الموجودة
    // ===================================================
    $sql = "SELECT SQL_NO_CACHE p1.id, p1.name, p1.type, p1.price, p1.date, p1.edite_by
            FROM prices p1
            INNER JOIN (
                SELECT name, type, MAX(id) as max_id
                FROM prices
                GROUP BY name, type
            ) p2 ON p1.name = p2.name AND p1.type = p2.type AND p1.id = p2.max_id";
    
    $params = [];
    
    if ($type) {
        $sql .= " WHERE p1.type = :type";
        $params['type'] = sanitize_input($type);
    }
    
    $sql .= " ORDER BY p1.type, p1.name";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    
    $allProducts = [];
    $count = 0;
    
    // قراءة البيانات صف بصف وتصنيفها ديناميكياً حسب النوع
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $product = formatPriceRow($row);
        $allProducts[] = $product;
        
        $typeName = $row['type'];
        $productName = $row['name'];
        $price = (float)$row['price'];
        
        // تصنيف المنتج حسب نوعه ديناميكياً
        if (!isset($dataByType[$typeName])) {
            $dataByType[$typeName] = [];
        }
        
        // للأنواع spongeTypes نستخدم int، والباقي double
        if (strtolower($typeName) === 'spongetypes') {
            $dataByType[$typeName][$productName] = (int)$price;
        } else {
            $dataByType[$typeName][$productName] = $price;
        }
        
        $count++;
    }
    
    // تحرير الذاكرة والاتصال
    $stmt->closeCursor();
    $stmt = null;
    
    // إضافة allProducts للاستجابة
    $dataByType['allProducts'] = $allProducts;
    
    // إرسال الرد مع تنظيف الذاكرة
    jsonResponse([
        'success' => true,
        'count' => $count,
        'types' => $distinctTypes,
        'data' => $dataByType,
        'timestamp' => time()
    ]);
    
    // تنظيف نهائي
    unset($dataByType, $allProducts);
}

// Execute logic
try {
    handleGet($pdo);
} catch (Exception $e) {
    jsonResponse(['success' => false, 'error' => $e->getMessage()], 500);
} finally {
    // تحرير الاتصال بقاعدة البيانات
    $pdo = null;
}
?>