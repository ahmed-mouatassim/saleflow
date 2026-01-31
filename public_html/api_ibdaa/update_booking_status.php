<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

include 'db_connect.php';

$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if ($data === null) {
    echo json_encode(["status" => false, "message" => "Invalid JSON"]);
    exit;
}

$booking_id = $data["booking_id"] ?? 0;
$status = $data["status"] ?? "";

if ($booking_id == 0 || $status == "") {
    echo json_encode(["status" => false, "message" => "Missing booking_id or status"]);
    exit;
}

// Validate status
$allowed_statuses = ['pending', 'confirmed', 'completed', 'cancelled'];
if (!in_array($status, $allowed_statuses)) {
    echo json_encode(["status" => false, "message" => "Invalid status value"]);
    exit;
}

$stmt = $conn->prepare("UPDATE reservations SET status = ? WHERE id = ?");
$stmt->bind_param("si", $status, $booking_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo json_encode([
            "status" => true,
            "message" => "Booking status updated successfully"
        ]);
    } else {
        echo json_encode([
            "status" => false,
            "message" => "Booking not found or status unchanged"
        ]);
    }
} else {
    echo json_encode([
        "status" => false,
        "message" => "Error updating booking: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
