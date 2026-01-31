<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

include 'db_connect.php';

// قراءة البيانات المرسلة
$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

// التحقق من صحة JSON
if ($data === null) {
    echo json_encode([
        "status" => false, 
        "message" => "Invalid JSON format"
    ]);
    exit;
}

// استخراج البيانات
$reservation_id = $data["reservation_id"] ?? 0;
$user_id = $data["user_id"] ?? 0;
$username = $data["username"] ?? "";

// التحقق من أن جميع الحقول المطلوبة مملوءة
if ($reservation_id == 0 || $user_id == 0 || $username == "") {
    echo json_encode([
        "status" => false, 
        "message" => "الرجاء ملء جميع الحقول المطلوبة"
    ]);
    exit;
}

// التحقق من وجود الحجز وأنه مفتوح للانضمام
$check_stmt = $conn->prepare("
    SELECT id, max_players, current_players, is_open 
    FROM reservations 
    WHERE id = ? AND status = 'confirmed'
");
$check_stmt->bind_param("i", $reservation_id);
$check_stmt->execute();
$check_result = $check_stmt->get_result();
$reservation = $check_result->fetch_assoc();

if (!$reservation) {
    echo json_encode([
        "status" => false, 
        "message" => "الحجز غير موجود"
    ]);
    $check_stmt->close();
    $conn->close();
    exit;
}

if (!$reservation['is_open']) {
    echo json_encode([
        "status" => false, 
        "message" => "هذه المباراة مغلقة ولا تقبل مشاركين جدد"
    ]);
    $check_stmt->close();
    $conn->close();
    exit;
}

if ($reservation['current_players'] >= $reservation['max_players']) {
    echo json_encode([
        "status" => false, 
        "message" => "المباراة ممتلئة"
    ]);
    $check_stmt->close();
    $conn->close();
    exit;
}
$check_stmt->close();

// التحقق من أن المستخدم لم ينضم مسبقاً
$already_joined_stmt = $conn->prepare("
    SELECT id FROM match_participants 
    WHERE reservation_id = ? AND user_id = ?
");
$already_joined_stmt->bind_param("ii", $reservation_id, $user_id);
$already_joined_stmt->execute();
$already_joined_result = $already_joined_stmt->get_result();

if ($already_joined_result->num_rows > 0) {
    echo json_encode([
        "status" => false, 
        "message" => "لقد انضممت لهذه المباراة مسبقاً"
    ]);
    $already_joined_stmt->close();
    $conn->close();
    exit;
}
$already_joined_stmt->close();

// بدء المعاملة
$conn->begin_transaction();

try {
    // إضافة المشارك
    $join_stmt = $conn->prepare("
        INSERT INTO match_participants (reservation_id, user_id, username) 
        VALUES (?, ?, ?)
    ");
    $join_stmt->bind_param("iis", $reservation_id, $user_id, $username);
    $join_stmt->execute();
    $join_stmt->close();
    
    // تحديث عدد اللاعبين الحاليين
    $update_stmt = $conn->prepare("
        UPDATE reservations 
        SET current_players = current_players + 1 
        WHERE id = ?
    ");
    $update_stmt->bind_param("i", $reservation_id);
    $update_stmt->execute();
    $update_stmt->close();
    
    $conn->commit();
    
    echo json_encode([
        "status" => true,
        "message" => "تم الانضمام للمباراة بنجاح",
        "reservation_id" => $reservation_id
    ]);
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode([
        "status" => false,
        "message" => "حدث خطأ أثناء الانضمام: " . $e->getMessage()
    ]);
}

$conn->close();
?>
