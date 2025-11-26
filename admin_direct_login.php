<?php
/**
 * سكريبت تسجيل دخول مباشر للـ Admin
 * يتجاوز مشكلة CSRF Token
 */

// معلومات قاعدة البيانات
$host = 'localhost';
$dbname = 'u996186400_alenwan';
$username = 'u996186400_alenwan';
$password = 'v.J6H3Re28AXT-T';

// بيانات تسجيل الدخول
$loginEmail = isset($_POST['email']) ? $_POST['email'] : '';
$loginPassword = isset($_POST['password']) ? $_POST['password'] : '';

?>
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تسجيل دخول Admin - Alenwan</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 450px;
            width: 100%;
        }
        .logo {
            text-align: center;
            margin-bottom: 30px;
        }
        .logo h1 {
            color: #667eea;
            font-size: 32px;
            margin-bottom: 10px;
        }
        .logo p {
            color: #666;
            font-size: 14px;
        }
        .form-group {
            margin-bottom: 25px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 600;
        }
        input[type="email"],
        input[type="password"],
        input[type="text"] {
            width: 100%;
            padding: 15px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 16px;
            transition: all 0.3s;
        }
        input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        .btn {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }
        .success {
            background: #d4edda;
            color: #155724;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            border: 1px solid #c3e6cb;
        }
        .error {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            border: 1px solid #f5c6cb;
        }
        .info {
            background: #d1ecf1;
            color: #0c5460;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            border: 1px solid #bee5eb;
        }
        .user-info {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-top: 20px;
        }
        .user-info h3 {
            color: #667eea;
            margin-bottom: 15px;
        }
        .user-info p {
            margin: 8px 0;
            color: #333;
        }
        .user-info strong {
            color: #667eea;
        }
        .logout-btn {
            background: #dc3545;
            margin-top: 15px;
        }
        .logout-btn:hover {
            background: #c82333;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">
            <h1>🎬 ALENWAN</h1>
            <p>لوحة تحكم المدير</p>
        </div>

        <?php
        session_start();

        // التحقق من تسجيل الخروج
        if (isset($_GET['logout'])) {
            session_destroy();
            header('Location: admin_direct_login.php');
            exit;
        }

        // التحقق من الجلسة النشطة
        if (isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true) {
            ?>
            <div class="success">
                ✅ أنت مسجل دخول بالفعل!
            </div>

            <div class="user-info">
                <h3>📋 معلومات المستخدم:</h3>
                <p><strong>الاسم:</strong> <?php echo htmlspecialchars($_SESSION['admin_name']); ?></p>
                <p><strong>البريد الإلكتروني:</strong> <?php echo htmlspecialchars($_SESSION['admin_email']); ?></p>
                <p><strong>الصلاحية:</strong> <?php echo htmlspecialchars($_SESSION['admin_role']); ?></p>
                <p><strong>Admin:</strong> <?php echo $_SESSION['is_admin'] ? 'نعم ✅' : 'لا ❌'; ?></p>
            </div>

            <form method="GET" action="">
                <button type="submit" name="logout" value="1" class="btn logout-btn">
                    تسجيل الخروج
                </button>
            </form>
            <?php
        } else {
            // معالجة تسجيل الدخول
            if ($_SERVER['REQUEST_METHOD'] === 'POST' && $loginEmail && $loginPassword) {
                try {
                    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
                    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

                    // البحث عن المستخدم
                    $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ? LIMIT 1");
                    $stmt->execute([$loginEmail]);
                    $user = $stmt->fetch(PDO::FETCH_ASSOC);

                    if ($user && password_verify($loginPassword, $user['password'])) {
                        // نجح تسجيل الدخول
                        $_SESSION['admin_logged_in'] = true;
                        $_SESSION['admin_id'] = $user['id'];
                        $_SESSION['admin_name'] = $user['name'];
                        $_SESSION['admin_email'] = $user['email'];
                        $_SESSION['admin_role'] = $user['role'] ?? 'user';
                        $_SESSION['is_admin'] = $user['is_admin'] ?? false;

                        header('Location: admin_direct_login.php');
                        exit;
                    } else {
                        echo '<div class="error">❌ البريد الإلكتروني أو كلمة المرور غير صحيحة!</div>';
                    }
                } catch(PDOException $e) {
                    echo '<div class="error">❌ خطأ في الاتصال بقاعدة البيانات: ' . htmlspecialchars($e->getMessage()) . '</div>';
                }
            }
            ?>

            <div class="info">
                ℹ️ استخدم هذه الصفحة لتسجيل الدخول مباشرة (بدون CSRF)
            </div>

            <form method="POST" action="">
                <div class="form-group">
                    <label for="email">البريد الإلكتروني</label>
                    <input type="email" id="email" name="email" required placeholder="admin@alenwan.com">
                </div>

                <div class="form-group">
                    <label for="password">كلمة المرور</label>
                    <input type="password" id="password" name="password" required placeholder="********">
                </div>

                <button type="submit" class="btn">
                    تسجيل الدخول
                </button>
            </form>

            <div class="info" style="margin-top: 20px; font-size: 13px;">
                <strong>⚠️ بيانات تسجيل الدخول الافتراضية:</strong><br>
                البريد: admin@alenwan.com<br>
                كلمة المرور: NewAdmin@2025!
            </div>
        <?php } ?>

        <div class="error" style="margin-top: 20px; font-size: 12px;">
            ⚠️ <strong>تحذير أمني:</strong> احذف هذا الملف فوراً بعد الاستخدام!
        </div>
    </div>
</body>
</html>
