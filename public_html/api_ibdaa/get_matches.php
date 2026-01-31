<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

include 'db_connect.php';

// قراءة البيانات المرسلة (اختياري - للتصفية)
$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

$field_type = $data["field_type"] ?? null;

// جلب المباريات المفتوحة المتاحة للانضمام
$query = "
    SELECT 
        r.id,
        r.user_id,
        r.username,
        r.field_type,
        r.reservation_date,
        r.start_time,
        r.duration_hours,
        r.is_open,
        r.max_players,
        r.current_players,
        r.status,
        r.created_at
    FROM reservations r
    WHERE r.is_open = 1 
    AND r.current_players < r.max_players
    AND r.status = 'confirmed'
    AND r.reservation_date >= CURDATE()
";

if ($field_type) {
    $query .= " AND r.field_type = ?";
}

$query .= " ORDER BY r.reservation_date ASC, r.start_time ASC";

if ($field_type) {
    $stmt = $conn->prepare($query);
    $stmt->bind_param("s", $field_type);
} else {
    $stmt = $conn->prepare($query);
}

$stmt->execute();
$result = $stmt->get_result();

$matches = [];
while ($row = $result->fetch_assoc()) {
    // جلب المشاركين في هذه المباراة
    $participants_stmt = $conn->prepare("
        SELECT user_id, username FROM match_participants 
        WHERE reservation_id = ?
    ");
    $participants_stmt->bind_param("i", $row['id']);
    $participants_stmt->execute();
    $participants_result = $participants_stmt->get_result();
    
    $participants = [];
    while ($p = $participants_result->fetch_assoc()) {
        $participants[] = $p;
    }
    $participants_stmt->close();
    
    $matches[] = [
        "id" => (int) $row['id'],
        "user_id" => (int) $row['user_id'],
        "username" => $row['username'],
        "field_type" => $row['field_type'],
        "date" => $row['reservation_date'],
        "start_time" => $row['start_time'],
        "duration_hours" => (int) $row['duration_hours'],
        "is_open" => (bool) $row['is_open'],
        "max_players" => (int) $row['max_players'],
        "current_players" => (int) $row['current_players'],
        "spots_left" => (int) $row['max_players'] - (int) $row['current_players'],
        "participants" => $participants
    ];
}

echo json_encode([
    "status" => true,
    "matches" => $matches,
    "count" => count($matches)
]);

$stmt->close();
$conn->close();
?>
