<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

include 'db_connect.php';

$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if ($data === null) {
    echo json_encode(["status" => false, "message" => "Invalid JSON", "raw" => $raw]);
    exit;
}

$username = $data["username"] ?? "";
$email = $data["email"] ?? "";
$password = $data["password"] ?? "";
$course = $data["course"] ?? "";
$complex = $data["complex"] ?? "";

// التحقق من أن جميع الحقول مملوءة
if ($username == "" || $email == "" || $password == "" || $course == "" || $complex == "") {
    echo json_encode(["status" => false, "message" => "All fields required"]);
    exit;
}

// تحويل القيمة العربية إلى القيمة الإنجليزية الموجودة في قاعدة البيانات
$complexMapping = [
    "مركب مديونة" => "Plateforme Province Mediouna",
    "مركب الهراويين" => "Académie des Métiers Digitaux"
];

// إذا كانت القيمة بالعربية، نحولها للإنجليزية
if (isset($complexMapping[$complex])) {
    $complex = $complexMapping[$complex];
}

$stmt = $conn->prepare("
  INSERT INTO users (username, email, password, course, complex)
  VALUES (?, ?, ?, ?, ?)
");

// ✅ تغيير من "ssssi" إلى "sssss" لأن complex هو string وليس integer
$stmt->bind_param("sssss", $username, $email, $password, $course, $complex);

if ($stmt->execute()) {
    echo json_encode(["status" => true, "message" => "Account created"]);
} else {
    // التحقق من نوع الخطأ
    if ($conn->errno == 1062) {
        echo json_encode(["status" => false, "message" => "Email already exists"]);
    } else {
        echo json_encode(["status" => false, "message" => "Error: " . $stmt->error]);
    }
}

$stmt->close();
$conn->close();
?>