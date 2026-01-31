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

$user_id = $data["user_id"] ?? 0;
$status = $data["status"] ?? "";

if ($user_id == 0 || $status == "") {
    echo json_encode(["status" => false, "message" => "Missing user_id or status"]);
    exit;
}

// Validate status
$allowed_statuses = ['pending', 'accepted', 'rejected'];
if (!in_array($status, $allowed_statuses)) {
    echo json_encode(["status" => false, "message" => "Invalid status value"]);
    exit;
}

$stmt = $conn->prepare("UPDATE users SET account_status = ? WHERE id = ? AND role != 'admin'");
$stmt->bind_param("si", $status, $user_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo json_encode([
            "status" => true,
            "message" => "User account status updated successfully"
        ]);
    } else {
        echo json_encode([
            "status" => false,
            "message" => "User not found or status unchanged"
        ]);
    }
} else {
    echo json_encode([
        "status" => false,
        "message" => "Error updating user: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
