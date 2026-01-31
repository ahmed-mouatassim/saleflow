<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

include 'db_connect.php';

// Get all users except admins
$sql = "SELECT id, username, email, course, complex, role, account_status, created_at 
        FROM users 
        WHERE role != 'admin'
        ORDER BY 
            CASE account_status 
                WHEN 'pending' THEN 1 
                WHEN 'accepted' THEN 2 
                WHEN 'rejected' THEN 3 
            END,
            created_at DESC";

$result = $conn->query($sql);

$users = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
}

echo json_encode([
    "status" => true,
    "users" => $users
]);

$conn->close();
?>
