<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

include 'db_connect.php';

// Get all reservations with user info
$sql = "SELECT r.*, u.email 
        FROM reservations r 
        JOIN users u ON r.user_id = u.id 
        ORDER BY r.created_at DESC";

$result = $conn->query($sql);

$bookings = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $bookings[] = $row;
    }
}

echo json_encode([
    "status" => true,
    "bookings" => $bookings
]);

$conn->close();
?>
