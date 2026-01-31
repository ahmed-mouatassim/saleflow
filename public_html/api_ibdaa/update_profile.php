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
$id = $data["id"] ?? "";
$username = $data["username"] ?? "";
$email = $data["email"] ?? "";
$password = $data["password"] ?? "";
$course = $data["course"] ?? "";
$complex = $data["complex"] ?? "";

// التحقق من أن جميع الحقول المطلوبة موجودة
if ($id == "" || $username == "" || $email == "" || $password == "" || $course == "" || $complex == "") {
    echo json_encode([
        "status" => false, 
        "message" => "جميع الحقول مطلوبة"
    ]);
    exit;
}

// تحديث بيانات المستخدم
$stmt = $conn->prepare("UPDATE users SET username = ?, email = ?, password = ?, course = ?, complex = ? WHERE id = ?");
$stmt->bind_param("sssssi", $username, $email, $password, $course, $complex, $id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0 || $stmt->errno == 0) {
        // تم التحديث بنجاح (أو لم تتغير البيانات ولكن الاستعلام صحيح)
        echo json_encode([
            "status" => true,
            "message" => "تم تحديث البيانات بنجاح",
            "user" => [
                "id" => $id,
                "username" => $username,
                "email" => $email,
                "course" => $course,
                "complex" => $complex
                // لا نعيد كلمة المرور لأسباب أمنية عادة، ولكن حسب الطلب يمكن إضافتها
            ]
        ]);
    } else {
        echo json_encode([
            "status" => false,
            "message" => "لم يتم إجراء أي تغييرات"
        ]);
    }
} else {
    echo json_encode([
        "status" => false,
        "message" => "حدث خطأ أثناء التحديث: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
