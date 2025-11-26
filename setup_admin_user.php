<?php
// Quick test to check admin users
$baseDir = __DIR__;
$configPath = $baseDir . '/alenwan/config/database.php';

// Check if config exists
if (!file_exists($configPath)) {
    die("Database config not found at: $configPath\n");
}

// Load env variables
require_once $baseDir . '/alenwan/vendor/autoload.php';
$dotenv = \Dotenv\Dotenv::createImmutable($baseDir . '/alenwan');
try {
    $dotenv->load();
} catch (Exception $e) {
    echo "Warning: Could not load .env file\n";
}

try {
    $host = getenv('DB_HOST') ?: 'localhost';
    $database = getenv('DB_DATABASE') ?: 'alenwan';
    $username = getenv('DB_USERNAME') ?: 'root';
    $password = getenv('DB_PASSWORD') ?: '';

    echo "Attempting connection to: $host / $database\n";
    
    $pdo = new PDO(
        "mysql:host=$host;dbname=$database;charset=utf8mb4",
        $username,
        $password,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );

    // Check admin users
    $stmt = $pdo->query("SELECT id, name, email, role FROM users WHERE role = 'admin' LIMIT 5");
    $admins = $stmt->fetchAll();
    
    if (empty($admins)) {
        echo "No admin users found. Creating test admin...\n";
        
        // Create test admin
        $testEmail = 'admin@alenwan.app';
        $testPassword = password_hash('Admin@123', PASSWORD_BCRYPT);
        
        $insertStmt = $pdo->prepare("
            INSERT INTO users (name, email, password, role, email_verified_at, created_at, updated_at)
            VALUES (?, ?, ?, 'admin', NOW(), NOW(), NOW())
        ");
        
        $insertStmt->execute([
            'Admin User',
            $testEmail,
            $testPassword
        ]);
        
        echo "✓ Created test admin user\n";
        echo "  Email: $testEmail\n";
        echo "  Password: Admin@123\n";
    } else {
        echo "Found " . count($admins) . " admin user(s):\n";
        foreach ($admins as $admin) {
            echo "- {$admin['email']} ({$admin['name']})\n";
        }
    }
} catch (PDOException $e) {
    echo "Database Error: " . $e->getMessage() . "\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
