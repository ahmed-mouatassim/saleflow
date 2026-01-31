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
        "raw" => $raw
    ]);
    exit;
}

// استخراج البيانات
$email = $data["email"] ?? "";
$password = $data["password"] ?? "";

// التحقق من أن جميع الحقول مملوءة
if ($email == "" || $password == "") {
    echo json_encode([
        "status" => false, 
        "message" => "الرجاء إدخال البريد الإلكتروني وكلمة السر"
    ]);
    exit;
}

// البحث عن المستخدم في قاعدة البيانات
$stmt = $conn->prepare("SELECT id, username, email, course, complex, role, account_status FROM users WHERE email = ? AND password = ?");
$stmt->bind_param("ss", $email, $password);
$stmt->execute();
$result = $stmt->get_result();

// التحقق من وجود المستخدم
if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    
    // التحقق من حالة الحساب
    $accountStatus = $user["account_status"];
    
    if ($accountStatus == "pending") {
        echo json_encode([
            "status" => false,
            "message" => "حسابك قيد المراجعة. يرجى الانتظار حتى تتم الموافقة عليه.",
            "account_status" => "pending"
        ]);
        exit;
    }
    
    if ($accountStatus == "rejected") {
        echo json_encode([
            "status" => false,
            "message" => "تم رفض حسابك. يرجى التواصل مع الإدارة للمزيد من المعلومات.",
            "account_status" => "rejected"
        ]);
        exit;
    }
    
    // الحساب مقبول - متابعة تسجيل الدخول
    $token = bin2hex(random_bytes(32));
    
    echo json_encode([
        "status" => true,
        "message" => "تم تسجيل الدخول بنجاح",
        "token" => $token,
        "user" => [
            "id" => $user["id"],
            "username" => $user["username"],
            "email" => $user["email"],
            "course" => $user["course"],
            "complex" => $user["complex"],
            "role" => $user["role"],
            "account_status" => $user["account_status"]
        ]
    ]);
} else {
    // بيانات خاطئة
    echo json_encode([
        "status" => false,
        "message" => "البريد الإلكتروني أو كلمة السر غير صحيحة"
    ]);
}

$stmt->close();
$conn->close();
?>
