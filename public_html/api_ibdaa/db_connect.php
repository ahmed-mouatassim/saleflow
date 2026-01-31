<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

$servername = "localhost"; // Usually localhost for cPanel
$username = "alidorma_user_ibdaa";
$password = "159632003Ahmed@";
$dbname = "alidorma_ibdaa";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["status" => false, "message" => "Database connection failed: " . $conn->connect_error]));
}

$conn->set_charset("utf8");
?>
