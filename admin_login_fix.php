<?php
/**
 * Admin Login Page - Bypass CSRF
 * Creates a proper Laravel session after successful login
 */

session_start();

// Database configuration
$host = 'localhost';
$dbname = 'u996186400_alenwan';
$username = 'u996186400_alenwan';
$password = 'v.J6H3Re28AXT-T';

// Handle logout
if (isset($_GET['logout'])) {
    session_destroy();
    header('Location: admin_login_fix.php');
    exit;
}

// Check if already logged in
if (isset($_SESSION['laravel_session'])) {
    header('Location: /admin/dashboard');
    exit;
}

$error = '';
$success = '';

// Handle login
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    $passwordInput = $_POST['password'] ?? '';

    if ($email && $passwordInput) {
        try {
            $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

            // Get user
            $stmt = $pdo->prepare("SELECT * FROM users WHERE email = ? LIMIT 1");
            $stmt->execute([$email]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($user && password_verify($passwordInput, $user['password'])) {
                // Check if user is admin
                if ($user['is_admin'] != 1) {
                    $error = 'هذا الحساب لا يملك صلاحيات الإدارة';
                } else {
                    // Create Laravel-compatible session
                    $sessionId = bin2hex(random_bytes(20));
                    $sessionData = [
                        '_token' => bin2hex(random_bytes(20)),
                        'login_web_' . sha1('web') => $user['id'],
                        'user_id' => $user['id'],
                        'user_email' => $user['email'],
                        'user_name' => $user['name'],
                        'is_admin' => true,
                    ];

                    // Save to Laravel session file
                    $sessionPath = __DIR__ . '/storage/framework/sessions/';
                    if (!is_dir($sessionPath)) {
                        mkdir($sessionPath, 0775, true);
                    }

                    $sessionFile = $sessionPath . $sessionId;
                    file_put_contents($sessionFile, serialize($sessionData));

                    // Set session cookie
                    setcookie('laravel_session', $sessionId, [
                        'expires' => time() + 10080 * 60, // 7 days
                        'path' => '/',
                        'domain' => '.alenwan.app',
                        'secure' => true,
                        'httponly' => true,
                        'samesite' => 'Lax'
                    ]);

                    $_SESSION['laravel_session'] = $sessionId;
                    $_SESSION['user'] = $user;

                    $success = 'تم تسجيل الدخول بنجاح! جاري التحويل...';

                    // Redirect to admin dashboard
                    echo "<script>setTimeout(function(){ window.location.href = '/admin/dashboard'; }, 2000);</script>";
                }
            } else {
                $error = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
            }
        } catch (PDOException $e) {
            $error = 'خطأ في الاتصال بقاعدة البيانات: ' . $e->getMessage();
        }
    } else {
        $error = 'يرجى إدخال البريد الإلكتروني وكلمة المرور';
    }
}
?>
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تسجيل دخول المدير - Alenwan</title>
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
        .login-container {
            background: white;
            padding: 50px 40px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 450px;
            width: 100%;
            animation: slideUp 0.5s ease;
        }
        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        .logo-section {
            text-align: center;
            margin-bottom: 40px;
        }
        .logo {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.4);
        }
        .logo svg {
            width: 40px;
            height: 40px;
            fill: white;
        }
        h1 {
            color: #2d3748;
            font-size: 28px;
            margin-bottom: 8px;
        }
        .subtitle {
            color: #718096;
            font-size: 15px;
        }
        .form-group {
            margin-bottom: 25px;
        }
        label {
            display: block;
            margin-bottom: 10px;
            color: #2d3748;
            font-weight: 600;
            font-size: 14px;
        }
        input[type="email"],
        input[type="password"] {
            width: 100%;
            padding: 15px 20px;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            font-size: 16px;
            transition: all 0.3s;
            background: #f7fafc;
        }
        input:focus {
            outline: none;
            border-color: #667eea;
            background: white;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
        }
        .btn-login {
            width: 100%;
            padding: 16px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
        }
        .btn-login:active {
            transform: translateY(0);
        }
        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            font-size: 14px;
            animation: slideDown 0.3s ease;
        }
        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        .alert-error {
            background: #fed7d7;
            color: #c53030;
            border: 1px solid #fc8181;
        }
        .alert-success {
            background: #c6f6d5;
            color: #2f855a;
            border: 1px solid #68d391;
        }
        .divider {
            text-align: center;
            margin: 30px 0;
            color: #a0aec0;
            font-size: 14px;
        }
        .help-text {
            text-align: center;
            margin-top: 20px;
            color: #718096;
            font-size: 13px;
        }
        .credentials {
            background: #edf2f7;
            padding: 15px;
            border-radius: 10px;
            margin-top: 20px;
            font-size: 13px;
            color: #2d3748;
        }
        .credentials strong {
            color: #667eea;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="logo-section">
            <div class="logo">
                <svg viewBox="0 0 24 24">
                    <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 14.5v-9l6 4.5-6 4.5z"/>
                </svg>
            </div>
            <h1>ALENWAN</h1>
            <p class="subtitle">لوحة تحكم الإدارة</p>
        </div>

        <?php if ($error): ?>
            <div class="alert alert-error">
                ❌ <?php echo htmlspecialchars($error); ?>
            </div>
        <?php endif; ?>

        <?php if ($success): ?>
            <div class="alert alert-success">
                ✅ <?php echo htmlspecialchars($success); ?>
            </div>
        <?php endif; ?>

        <form method="POST" action="">
            <div class="form-group">
                <label for="email">📧 البريد الإلكتروني</label>
                <input
                    type="email"
                    id="email"
                    name="email"
                    required
                    placeholder="admin@alenwan.com"
                    value="<?php echo isset($_POST['email']) ? htmlspecialchars($_POST['email']) : ''; ?>"
                >
            </div>

            <div class="form-group">
                <label for="password">🔒 كلمة المرور</label>
                <input
                    type="password"
                    id="password"
                    name="password"
                    required
                    placeholder="••••••••"
                >
            </div>

            <button type="submit" class="btn-login">
                تسجيل الدخول
            </button>
        </form>

        <div class="credentials">
            <strong>📋 بيانات الدخول:</strong><br>
            البريد: admin@alenwan.com<br>
            كلمة المرور: NewAdmin@2025!
        </div>

        <div class="help-text">
            ⚠️ هذه صفحة مؤقتة للوصول إلى لوحة التحكم
        </div>
    </div>
</body>
</html>
