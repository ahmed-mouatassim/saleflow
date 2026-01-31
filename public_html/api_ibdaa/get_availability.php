<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

include 'db_connect.php';

// قراءة البيانات المرسلة
$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

// استخراج البيانات
$field_type = $data["field_type"] ?? "";
$date = $data["date"] ?? "";

// التحقق من صحة البيانات
if ($field_type == "" || $date == "") {
    echo json_encode([
        "status" => false, 
        "message" => "الرجاء إدخال نوع الملعب والتاريخ"
    ]);
    exit;
}

// جلب الأوقات المحجوزة لهذا التاريخ والملعب
$stmt = $conn->prepare("
    SELECT start_time, duration_hours 
    FROM reservations 
    WHERE field_type = ? 
    AND reservation_date = ? 
    AND status IN ('pending', 'confirmed')
");
$stmt->bind_param("ss", $field_type, $date);
$stmt->execute();
$result = $stmt->get_result();

$booked_slots = [];
while ($row = $result->fetch_assoc()) {
    // إضافة جميع الساعات المحجوزة بناءً على المدة
    $start_hour = (int) substr($row['start_time'], 0, 2);
    $duration = (int) $row['duration_hours'];
    
    for ($i = 0; $i < $duration; $i++) {
        $booked_slots[] = sprintf("%02d:00", $start_hour + $i);
    }
}

echo json_encode([
    "status" => true,
    "booked_slots" => $booked_slots,
    "date" => $date,
    "field_type" => $field_type
]);

$stmt->close();
$conn->close();
?>
