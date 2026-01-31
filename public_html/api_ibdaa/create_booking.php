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
        "message" => "Invalid JSON format",
        "raw_input" => $raw
    ]);
    exit;
}

// استخراج البيانات
$user_id = isset($data["user_id"]) ? intval($data["user_id"]) : 0;
$username = isset($data["username"]) ? $data["username"] : "";
$field_type = isset($data["field_type"]) ? $data["field_type"] : "";
$reservation_date = isset($data["date"]) ? $data["date"] : "";
$start_time = isset($data["start_time"]) ? $data["start_time"] : "";
$duration_hours = isset($data["duration_hours"]) ? intval($data["duration_hours"]) : 1;
$is_open = isset($data["is_open"]) ? ($data["is_open"] ? 1 : 0) : 0;
$max_players = isset($data["max_players"]) ? intval($data["max_players"]) : 4;

// التحقق من أن جميع الحقول المطلوبة مملوءة
if ($user_id == 0 || $username == "" || $field_type == "" || $reservation_date == "" || $start_time == "") {
    echo json_encode([
        "status" => false, 
        "message" => "الرجاء ملء جميع الحقول المطلوبة",
        "debug" => [
            "user_id" => $user_id,
            "username" => $username,
            "field_type" => $field_type,
            "date" => $reservation_date,
            "start_time" => $start_time
        ]
    ]);
    exit;
}

// إضافة :00 للوقت إذا لم يكن موجود
if (strlen($start_time) == 5) {
    $start_time = $start_time . ":00";
}

// التحقق من وجود جدول reservations
$table_check = $conn->query("SHOW TABLES LIKE 'reservations'");
if ($table_check->num_rows == 0) {
    // إنشاء الجدول إذا لم يكن موجوداً
    $create_table = "CREATE TABLE IF NOT EXISTS `reservations` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `user_id` int(11) NOT NULL,
        `username` varchar(100) NOT NULL,
        `field_type` varchar(20) NOT NULL,
        `reservation_date` date NOT NULL,
        `start_time` time NOT NULL,
        `duration_hours` int(11) DEFAULT 1,
        `is_open` tinyint(1) DEFAULT 0,
        `max_players` int(11) DEFAULT 4,
        `current_players` int(11) DEFAULT 1,
        `status` varchar(20) DEFAULT 'confirmed',
        `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci";
    
    if (!$conn->query($create_table)) {
        echo json_encode([
            "status" => false,
            "message" => "فشل في إنشاء جدول reservations: " . $conn->error
        ]);
        exit;
    }
}

// التحقق من وجود جدول match_participants
$table_check2 = $conn->query("SHOW TABLES LIKE 'match_participants'");
if ($table_check2->num_rows == 0) {
    $create_table2 = "CREATE TABLE IF NOT EXISTS `match_participants` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `reservation_id` int(11) NOT NULL,
        `user_id` int(11) NOT NULL,
        `username` varchar(100) NOT NULL,
        `joined_at` timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci";
    
    if (!$conn->query($create_table2)) {
        echo json_encode([
            "status" => false,
            "message" => "فشل في إنشاء جدول match_participants: " . $conn->error
        ]);
        exit;
    }
}

// التحقق من أن الوقت غير محجوز مسبقاً
$check_stmt = $conn->prepare("
    SELECT id FROM reservations 
    WHERE field_type = ? 
    AND reservation_date = ? 
    AND start_time = ? 
    AND status IN ('pending', 'confirmed')
");

if (!$check_stmt) {
    echo json_encode([
        "status" => false,
        "message" => "خطأ في التحقق من الحجز: " . $conn->error
    ]);
    exit;
}

$check_stmt->bind_param("sss", $field_type, $reservation_date, $start_time);
$check_stmt->execute();
$check_result = $check_stmt->get_result();

if ($check_result->num_rows > 0) {
    echo json_encode([
        "status" => false, 
        "message" => "هذا الوقت محجوز مسبقاً"
    ]);
    $check_stmt->close();
    $conn->close();
    exit;
}
$check_stmt->close();

// إنشاء الحجز
$stmt = $conn->prepare("
    INSERT INTO reservations 
    (user_id, username, field_type, reservation_date, start_time, duration_hours, is_open, max_players, current_players, status) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, 'confirmed')
");

if (!$stmt) {
    echo json_encode([
        "status" => false,
        "message" => "خطأ في إعداد الاستعلام: " . $conn->error
    ]);
    exit;
}

$stmt->bind_param("issssiii", $user_id, $username, $field_type, $reservation_date, $start_time, $duration_hours, $is_open, $max_players);

if ($stmt->execute()) {
    $reservation_id = $conn->insert_id;
    
    // إضافة المستخدم كأول مشارك في المباراة
    $participant_stmt = $conn->prepare("
        INSERT INTO match_participants (reservation_id, user_id, username) 
        VALUES (?, ?, ?)
    ");
    if ($participant_stmt) {
        $participant_stmt->bind_param("iis", $reservation_id, $user_id, $username);
        $participant_stmt->execute();
        $participant_stmt->close();
    }
    
    echo json_encode([
        "status" => true,
        "message" => "تم الحجز بنجاح",
        "reservation_id" => $reservation_id,
        "reservation" => [
            "id" => $reservation_id,
            "user_id" => $user_id,
            "username" => $username,
            "field_type" => $field_type,
            "date" => $reservation_date,
            "start_time" => $start_time,
            "duration_hours" => $duration_hours,
            "is_open" => $is_open == 1,
            "max_players" => $max_players,
            "current_players" => 1
        ]
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "حدث خطأ أثناء الحجز: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
