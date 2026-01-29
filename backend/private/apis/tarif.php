<?php
/**
 * Tarif API Endpoint - SaleFlow
 * المسار: /private/apis/tarif.php
 * 
 * نقاط النهاية:
 * - GET: جلب جميع التعريفات أو تعريفة محددة
 * - POST: إضافة تعريفة جديدة
 * - PUT: تحديث تعريفة موجودة
 * - DELETE: حذف تعريفة
 */

// التحقق من الوصول الآمن
if (!defined('API_ACCESS')) {
    http_response_code(403);
    die(json_encode(['error' => 'Direct access not permitted']));
}

// تحميل ملف قاعدة البيانات والدوال المساعدة
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/helpers.php';

$method = $_SERVER['REQUEST_METHOD'];

try {
    $pdo = getDB();
    
    switch ($method) {
        case 'GET':
            handleGet($pdo);
            break;
        case 'POST':
            handlePost($pdo);
            break;
        case 'PUT':
            handlePut($pdo);
            break;
        case 'DELETE':
            handleDelete($pdo);
            break;
        default:
            jsonResponse([
                'success' => false,
                'error' => 'Method not allowed',
                'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE']
            ], 405);
    }
} catch (PDOException $e) {
    error_log('Tarif API Error: ' . $e->getMessage());
    jsonResponse([
        'success' => false,
        'error' => 'Database error occurred',
        'code' => 'DB_ERROR'
    ], 500);
}

/**
 * معالجة طلبات GET
 */
function handleGet($pdo) {
    $id = $_GET['id'] ?? null;
    $name = $_GET['name'] ?? null;
    $size = $_GET['size'] ?? null;
    
    // استعلام أساسي
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
                td.final_price
            FROM tarif t
            LEFT JOIN tarif_details td ON t.id_price = td.id";
    
    $params = [];
    $conditions = [];
    
    if ($id) {
        $conditions[] = "t.id = :id";
        $params['id'] = (int)$id;
    }
    
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
    $rows = $stmt->fetchAll();
    
    // تنسيق البيانات
    $data = array_map(function($row) {
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
            'final_price' => (float)($row['final_price'] ?? 0)
        ];
    }, $rows);
    
    jsonResponse([
        'success' => true,
        'count' => count($data),
        'data' => $data
    ]);
}

/**
 * معالجة طلبات POST
 */
function handlePost($pdo) {
    $input = file_get_contents("php://input");
    $data = json_decode($input, true);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        jsonResponse([
            'success' => false,
            'error' => 'Invalid JSON format'
        ], 400);
    }
    
    // التحقق من الحقول المطلوبة
    $required = ['ref_mattress', 'name', 'size'];
    foreach ($required as $field) {
        if (empty($data[$field])) {
            jsonResponse([
                'success' => false,
                'error' => "Missing required field: $field"
            ], 400);
        }
    }
    
    $pdo->beginTransaction();
    
    try {
        // إدراج تفاصيل السعر أولاً
        $stmtDetails = $pdo->prepare("
            INSERT INTO tarif_details 
            (sponge_price, springs_price, dress_price, sfifa_price, footer_price, packaging_price, cost_price, final_price)
            VALUES (:sponge, :springs, :dress, :sfifa, :footer, :packaging, :cost, :final)
        ");
        
        $stmtDetails->execute([
            'sponge' => (float)($data['sponge_price'] ?? 0),
            'springs' => (float)($data['springs_price'] ?? 0),
            'dress' => (float)($data['dress_price'] ?? 0),
            'sfifa' => (float)($data['sfifa_price'] ?? 0),
            'footer' => (float)($data['footer_price'] ?? 0),
            'packaging' => (float)($data['packaging_price'] ?? 0),
            'cost' => (float)($data['cost_price'] ?? 0),
            'final' => (float)($data['final_price'] ?? 0)
        ]);
        
        $priceId = $pdo->lastInsertId();
        
        // إدراج التعريفة الرئيسية
        $stmtTarif = $pdo->prepare("
            INSERT INTO tarif (ref_mattress, name, size, id_price)
            VALUES (:ref, :name, :size, :price_id)
        ");
        
        $stmtTarif->execute([
            'ref' => sanitize_input($data['ref_mattress']),
            'name' => sanitize_input($data['name']),
            'size' => sanitize_input($data['size']),
            'price_id' => $priceId
        ]);
        
        $tarifId = $pdo->lastInsertId();
        
        $pdo->commit();
        
        jsonResponse([
            'success' => true,
            'message' => 'Tarif created successfully',
            'id' => $tarifId
        ], 201);
        
    } catch (Exception $e) {
        $pdo->rollBack();
        throw $e;
    }
}

/**
 * معالجة طلبات PUT
 */
function handlePut($pdo) {
    $input = file_get_contents("php://input");
    $data = json_decode($input, true);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        jsonResponse([
            'success' => false,
            'error' => 'Invalid JSON format'
        ], 400);
    }
    
    $id = $data['id'] ?? $_GET['id'] ?? null;
    
    if (!$id) {
        jsonResponse([
            'success' => false,
            'error' => 'Tarif ID is required'
        ], 400);
    }
    
    // التحقق من وجود التعريفة
    $checkStmt = $pdo->prepare("SELECT id_price FROM tarif WHERE id = ?");
    $checkStmt->execute([$id]);
    $existing = $checkStmt->fetch();
    
    if (!$existing) {
        jsonResponse([
            'success' => false,
            'error' => 'Tarif not found'
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
                    final_price = :final
                WHERE id = :id
            ");
            
            $stmtDetails->execute([
                'sponge' => (float)($data['sponge_price'] ?? 0),
                'springs' => (float)($data['springs_price'] ?? 0),
                'dress' => (float)($data['dress_price'] ?? 0),
                'sfifa' => (float)($data['sfifa_price'] ?? 0),
                'footer' => (float)($data['footer_price'] ?? 0),
                'packaging' => (float)($data['packaging_price'] ?? 0),
                'cost' => (float)($data['cost_price'] ?? 0),
                'final' => (float)($data['final_price'] ?? 0),
                'id' => $existing['id_price']
            ]);
        }
        
        // تحديث التعريفة الرئيسية
        $stmtTarif = $pdo->prepare("
            UPDATE tarif SET
                ref_mattress = :ref,
                name = :name,
                size = :size
            WHERE id = :id
        ");
        
        $stmtTarif->execute([
            'ref' => sanitize_input($data['ref_mattress'] ?? ''),
            'name' => sanitize_input($data['name'] ?? ''),
            'size' => sanitize_input($data['size'] ?? ''),
            'id' => $id
        ]);
        
        $pdo->commit();
        
        jsonResponse([
            'success' => true,
            'message' => 'Tarif updated successfully'
        ]);
        
    } catch (Exception $e) {
        $pdo->rollBack();
        throw $e;
    }
}

/**
 * معالجة طلبات DELETE
 */
function handleDelete($pdo) {
    $id = $_GET['id'] ?? null;
    
    if (!$id) {
        jsonResponse([
            'success' => false,
            'error' => 'Tarif ID is required'
        ], 400);
    }
    
    // التحقق من وجود التعريفة
    $checkStmt = $pdo->prepare("SELECT id_price FROM tarif WHERE id = ?");
    $checkStmt->execute([$id]);
    $existing = $checkStmt->fetch();
    
    if (!$existing) {
        jsonResponse([
            'success' => false,
            'error' => 'Tarif not found'
        ], 404);
    }
    
    $pdo->beginTransaction();
    
    try {
        // حذف التعريفة أولاً
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
            'message' => 'Tarif deleted successfully'
        ]);
        
    } catch (Exception $e) {
        $pdo->rollBack();
        throw $e;
    }
}
?>
