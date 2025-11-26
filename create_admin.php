<?php
/**
 * Script لإنشاء مستخدم Admin جديد
 *
 * الاستخدام:
 * 1. ارفع هذا الملف إلى مجلد public_html على السيرفر
 * 2. افتح الرابط: https://alenwan.app/create_admin.php
 * 3. احذف الملف فوراً بعد الاستخدام لأسباب أمنية
 */

// معلومات الاتصال بقاعدة البيانات
$host = 'localhost';
$dbname = 'u996186400_alenwan'; // اسم قاعدة البيانات
$username = 'u996186400_alenwan'; // اسم المستخدم
$password = 'v.J6H3Re28AXT-T'; // كلمة مرور قاعدة البيانات

// بيانات المستخدم Admin الجديد
$adminName = 'Admin Alenwan';
$adminEmail = 'newadmin@alenwan.com';
$adminPassword = 'Admin@2025!'; // غير هذه الكلمة بعد أول تسجيل دخول
$hashedPassword = password_hash($adminPassword, PASSWORD_BCRYPT);

try {
    // الاتصال بقاعدة البيانات
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "<html dir='rtl'><head><meta charset='UTF-8'><title>إنشاء Admin</title>";
    echo "<style>body{font-family:Arial;padding:20px;background:#f5f5f5}";
    echo ".success{background:#d4edda;border:1px solid #c3e6cb;color:#155724;padding:15px;border-radius:5px;margin:10px 0}";
    echo ".error{background:#f8d7da;border:1px solid #f5c6cb;color:#721c24;padding:15px;border-radius:5px;margin:10px 0}";
    echo ".info{background:#d1ecf1;border:1px solid #bee5eb;color:#0c5460;padding:15px;border-radius:5px;margin:10px 0}";
    echo "pre{background:#fff;padding:10px;border:1px solid #ddd;border-radius:5px;direction:ltr;text-align:left}</style></head><body>";

    echo "<h1>🔐 إنشاء مستخدم Admin جديد</h1>";

    // التحقق من وجود المستخدم
    $checkStmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $checkStmt->execute([$adminEmail]);

    if ($checkStmt->fetch()) {
        echo "<div class='error'>";
        echo "<h3>❌ خطأ!</h3>";
        echo "<p>المستخدم بالبريد الإلكتروني <strong>$adminEmail</strong> موجود مسبقاً.</p>";
        echo "<p>إذا كنت تريد إعادة تعيين كلمة المرور، استخدم السكريبت المخصص لذلك.</p>";
        echo "</div>";
    } else {
        // إنشاء المستخدم الجديد
        $now = date('Y-m-d H:i:s');

        $sql = "INSERT INTO users (
            name,
            email,
            password,
            role,
            is_active,
            is_admin,
            subscription_tier,
            subscription_expires_at,
            max_devices,
            email_verified_at,
            created_at,
            updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $adminName,           // name
            $adminEmail,          // email
            $hashedPassword,      // password (hashed)
            'admin',              // role
            1,                    // is_active
            1,                    // is_admin
            'platinum',           // subscription_tier
            '2099-12-31 23:59:59', // subscription_expires_at (never expires)
            99,                   // max_devices
            $now,                 // email_verified_at
            $now,                 // created_at
            $now                  // updated_at
        ]);

        $adminId = $pdo->lastInsertId();

        echo "<div class='success'>";
        echo "<h3>✅ تم إنشاء المستخدم بنجاح!</h3>";
        echo "</div>";

        echo "<div class='info'>";
        echo "<h3>📋 معلومات تسجيل الدخول:</h3>";
        echo "<pre>";
        echo "رقم المستخدم (ID): $adminId\n";
        echo "الاسم: $adminName\n";
        echo "البريد الإلكتروني: $adminEmail\n";
        echo "كلمة المرور: $adminPassword\n";
        echo "الصلاحية: Admin (مدير)\n";
        echo "الاشتراك: Platinum (مدى الحياة)\n";
        echo "رابط تسجيل الدخول: https://alenwan.app/admin/login";
        echo "</pre>";
        echo "</div>";

        echo "<div class='error'>";
        echo "<h3>⚠️ تحذير أمني هام!</h3>";
        echo "<ol>";
        echo "<li>احذف هذا الملف <strong>create_admin.php</strong> فوراً من السيرفر</li>";
        echo "<li>غير كلمة المرور بعد أول تسجيل دخول</li>";
        echo "<li>لا تشارك هذه المعلومات مع أحد</li>";
        echo "</ol>";
        echo "</div>";
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
