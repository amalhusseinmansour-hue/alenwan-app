<?php
/**
 * Script لإعادة تعيين كلمة مرور Admin
 *
 * الاستخدام:
 * 1. ارفع هذا الملف إلى مجلد public_html على السيرفر
 * 2. افتح الرابط: https://alenwan.app/reset_admin_password.php
 * 3. احذف الملف فوراً بعد الاستخدام لأسباب أمنية
 */

// معلومات الاتصال بقاعدة البيانات
$host = 'localhost';
$dbname = 'u996186400_alenwan'; // اسم قاعدة البيانات
$username = 'u996186400_alenwan'; // اسم المستخدم
$password = 'v.J6H3Re28AXT-T'; // كلمة مرور قاعدة البيانات

// بيانات إعادة التعيين
$adminEmail = 'admin@alenwan.com'; // البريد الإلكتروني للحساب الذي تريد إعادة تعيين كلمة مروره
$newPassword = 'NewAdmin@2025!'; // كلمة المرور الجديدة - غيرها بعد التسجيل
$hashedPassword = password_hash($newPassword, PASSWORD_BCRYPT);

try {
    // الاتصال بقاعدة البيانات
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "<html dir='rtl'><head><meta charset='UTF-8'><title>إعادة تعيين كلمة المرور</title>";
    echo "<style>body{font-family:Arial;padding:20px;background:#f5f5f5}";
    echo ".success{background:#d4edda;border:1px solid #c3e6cb;color:#155724;padding:15px;border-radius:5px;margin:10px 0}";
    echo ".error{background:#f8d7da;border:1px solid #f5c6cb;color:#721c24;padding:15px;border-radius:5px;margin:10px 0}";
    echo ".info{background:#d1ecf1;border:1px solid #bee5eb;color:#0c5460;padding:15px;border-radius:5px;margin:10px 0}";
    echo "pre{background:#fff;padding:10px;border:1px solid #ddd;border-radius:5px;direction:ltr;text-align:left}</style></head><body>";

    echo "<h1>🔐 إعادة تعيين كلمة مرور Admin</h1>";

    // التحقق من وجود المستخدم
    $checkStmt = $pdo->prepare("SELECT id, name, email, role, is_admin FROM users WHERE email = ?");
    $checkStmt->execute([$adminEmail]);
    $user = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        echo "<div class='error'>";
        echo "<h3>❌ خطأ!</h3>";
        echo "<p>لم يتم العثور على مستخدم بالبريد الإلكتروني: <strong>$adminEmail</strong></p>";
        echo "<p>تأكد من صحة البريد الإلكتروني في السكريبت.</p>";
        echo "</div>";
    } else {
        // عرض معلومات المستخدم الحالي
        echo "<div class='info'>";
        echo "<h3>📋 معلومات المستخدم الحالي:</h3>";
        echo "<pre>";
        echo "رقم المستخدم (ID): {$user['id']}\n";
        echo "الاسم: {$user['name']}\n";
        echo "البريد الإلكتروني: {$user['email']}\n";
        echo "الصلاحية: {$user['role']}\n";
        echo "هل هو Admin؟ " . ($user['is_admin'] ? 'نعم ✅' : 'لا ❌');
        echo "</pre>";
        echo "</div>";

        // إعادة تعيين كلمة المرور
        $now = date('Y-m-d H:i:s');

        $sql = "UPDATE users SET
                password = ?,
                is_admin = 1,
                role = 'admin',
                is_active = 1,
                updated_at = ?
                WHERE email = ?";

        $stmt = $pdo->prepare($sql);
        $stmt->execute([$hashedPassword, $now, $adminEmail]);

        if ($stmt->rowCount() > 0) {
            echo "<div class='success'>";
            echo "<h3>✅ تم إعادة تعيين كلمة المرور بنجاح!</h3>";
            echo "</div>";

            echo "<div class='info'>";
            echo "<h3>📋 معلومات تسجيل الدخول الجديدة:</h3>";
            echo "<pre>";
            echo "البريد الإلكتروني: $adminEmail\n";
            echo "كلمة المرور الجديدة: $newPassword\n";
            echo "الصلاحية: Admin (مدير)\n";
            echo "رابط تسجيل الدخول: https://alenwan.app/admin/login";
            echo "</pre>";
            echo "</div>";

            echo "<div class='error'>";
            echo "<h3>⚠️ تحذير أمني هام!</h3>";
            echo "<ol>";
            echo "<li>احذف هذا الملف <strong>reset_admin_password.php</strong> فوراً من السيرفر</li>";
            echo "<li>غير كلمة المرور بعد أول تسجيل دخول</li>";
            echo "<li>لا تشارك هذه المعلومات مع أحد</li>";
            echo "</ol>";
            echo "</div>";
        } else {
            echo "<div class='error'>";
            echo "<h3>⚠️ تحذير!</h3>";
            echo "<p>لم يتم تحديث أي سجلات. ربما البيانات مطابقة للبيانات الحالية.</p>";
            echo "</div>";
        }
    }

} catch(PDOException $e) {
    echo "<div class='error'>";
    echo "<h3>❌ خطأ في الاتصال بقاعدة البيانات!</h3>";
    echo "<pre>الخطأ: " . $e->getMessage() . "</pre>";
    echo "<h4>الحلول المحتملة:</h4>";
    echo "<ul>";
    echo "<li>تحقق من اسم قاعدة البيانات في cPanel</li>";
    echo "<li>تحقق من اسم المستخدم وكلمة المرور</li>";
    echo "<li>تأكد من أن جدول 'users' موجود</li>";
    echo "</ul>";
    echo "</div>";
}

echo "</body></html>";
?>
