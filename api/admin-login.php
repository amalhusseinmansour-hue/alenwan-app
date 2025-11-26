<?php
/**
 * Admin Login API Endpoint
 * يوفر نقطة نهاية API لتسجيل دخول المسؤولين
 * Provides an API endpoint for admin login
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(json_encode(['status' => 'ok']));
}

// تحديد قاعدة البيانات - هذا مثال، قم بتعديله حسب إعدادات خادمك
function getAdminUser($email, $password) {
    try {
        // محاولة الاتصال بقاعدة البيانات
        // Replace with your actual database credentials
        $db_host = getenv('DB_HOST') ?: 'localhost';
        $db_user = getenv('DB_USERNAME') ?: 'root';
        $db_pass = getenv('DB_PASSWORD') ?: '';
        $db_name = getenv('DB_DATABASE') ?: 'alenwan';
        
        $pdo = new PDO(
            "mysql:host=$db_host;dbname=$db_name;charset=utf8mb4",
            $db_user,
            $db_pass,
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
        );
        
        // البحث عن المسؤول
        $stmt = $pdo->prepare("
            SELECT id, name, email, password, role 
            FROM users 
            WHERE email = ? AND role = 'admin'
        ");
        $stmt->execute([$email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            return ['error' => 'بيانات المسؤول غير صحيحة', 'code' => 401];
        }
        
        // التحقق من كلمة المرور
        // تحقق من خوارزمية التجزئة المستخدمة في Laravel
        if (password_verify($password, $user['password'])) {
            // إنشاء توكن بسيط (يجب استخدام JWT في الواقع)
            $token = bin2hex(random_bytes(32));
            
            return [
                'success' => true,
                'user' => [
                    'id' => $user['id'],
                    'name' => $user['name'],
                    'email' => $user['email'],
                    'role' => $user['role']
                ],
                'token' => $token
            ];
        } else {
            return ['error' => 'كلمة المرور غير صحيحة', 'code' => 401];
        }
        
    } catch (Exception $e) {
        return [
            'error' => 'خطأ في قاعدة البيانات: ' . $e->getMessage(),
            'code' => 500
        ];
    }
}

// معالجة الطلب
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $email = $input['email'] ?? null;
    $password = $input['password'] ?? null;
    
    if (!$email || !$password) {
        http_response_code(422);
        echo json_encode([
            'status' => 'error',
            'errors' => [
                'email' => $email ? [] : ['البريد الإلكتروني مطلوب'],
                'password' => $password ? [] : ['كلمة المرور مطلوبة']
            ]
        ]);
        exit;
    }
    
    $result = getAdminUser($email, $password);
    
    if (isset($result['error'])) {
        http_response_code($result['code'] ?? 401);
        echo json_encode([
            'status' => 'error',
            'message' => $result['error']
        ]);
    } else {
        http_response_code(200);
        echo json_encode([
            'status' => 'success',
            'data' => $result
        ]);
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // صفحة HTML للاختبار
    ?>
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API تسجيل دخول المسؤول</title>
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
            border-radius: 15px;
            max-width: 500px;
            width: 100%;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }
        h1 {
            color: #667eea;
            margin-bottom: 10px;
            text-align: center;
        }
        .info {
            background: #f0f4ff;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            color: #555;
            line-height: 1.6;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 600;
        }
        input {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        input:focus {
            outline: none;
            border-color: #667eea;
        }
        button {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
        }
        button:hover {
            transform: translateY(-2px);
        }
        button:active {
            transform: translateY(0);
        }
        .response {
            margin-top: 30px;
            padding: 20px;
            border-radius: 8px;
            display: none;
        }
        .response.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
            display: block;
        }
        .response.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
            display: block;
        }
        pre {
            background: #f5f5f5;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
            margin-top: 10px;
            font-size: 12px;
        }
        .endpoint-info {
            background: #e7f3ff;
            padding: 15px;
            border-radius: 8px;
            margin-top: 20px;
            font-size: 13px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 API تسجيل دخول المسؤول</h1>
        
        <div class="info">
            <strong>ملاحظة:</strong> هذه نقطة نهاية API اختبار لتسجيل دخول المسؤولين.
            استخدم بيانات حسابك الإداري.
        </div>

        <form id="loginForm">
            <div class="form-group">
                <label for="email">البريد الإلكتروني:</label>
                <input 
                    type="email" 
                    id="email" 
                    name="email" 
                    placeholder="admin@alenwan.app"
                    required
                >
            </div>

            <div class="form-group">
                <label for="password">كلمة المرور:</label>
                <input 
                    type="password" 
                    id="password" 
                    name="password" 
                    placeholder="••••••••"
                    required
                >
            </div>

            <button type="submit">تسجيل الدخول</button>
        </form>

        <div id="response" class="response"></div>

        <div class="endpoint-info">
            <strong>معلومات الـ API:</strong>
            <pre>POST /api/admin-login
Content-Type: application/json

{
    "email": "admin@alenwan.app",
    "password": "password"
}</pre>
        </div>
    </div>

    <script>
        document.getElementById('loginForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;
            const responseEl = document.getElementById('response');
            
            try {
                const response = await fetch(window.location.href, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({ email, password })
                });
                
                const data = await response.json();
                
                if (data.status === 'success') {
                    responseEl.className = 'response success';
                    responseEl.innerHTML = `
                        <strong>✅ تم تسجيل الدخول بنجاح!</strong>
                        <pre>${JSON.stringify(data.data, null, 2)}</pre>
                    `;
                } else {
                    responseEl.className = 'response error';
                    responseEl.innerHTML = `
                        <strong>❌ خطأ في تسجيل الدخول</strong>
                        <p>${data.message || 'بيانات غير صحيحة'}</p>
                    `;
                }
            } catch (error) {
                responseEl.className = 'response error';
                responseEl.innerHTML = `
                    <strong>❌ خطأ في الاتصال</strong>
                    <p>${error.message}</p>
                `;
            }
        });
    </script>
</body>
</html>
    <?php
}
?>