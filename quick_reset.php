<?php
$host = 'localhost';
$dbname = 'u996186400_alenwan';
$username = 'u996186400_alenwan';
$password = 'v.J6H3Re28AXT-T';
$adminEmail = 'admin@alenwan.com';
$newPassword = 'NewAdmin@2025!';
$hashedPassword = password_hash($newPassword, PASSWORD_BCRYPT);

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $stmt = $pdo->prepare('SELECT id, name, email FROM users WHERE email = ?');
    $stmt->execute([$adminEmail]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        $updateStmt = $pdo->prepare('UPDATE users SET password = ?, is_admin = 1, role = "admin" WHERE email = ?');
        $updateStmt->execute([$hashedPassword, $adminEmail]);
        echo "✅ Password reset successfully!\n";
        echo "Email: admin@alenwan.com\n";
        echo "Password: NewAdmin@2025!\n";
        echo "\nNow visit: https://alenwan.app/admin_direct_login.php\n";
    } else {
        echo "❌ User not found: $adminEmail\n";
    }
} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
