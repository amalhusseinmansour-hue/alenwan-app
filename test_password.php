<?php
$host = 'localhost';
$dbname = 'u996186400_alenwan';
$username = 'u996186400_alenwan';
$password = 'v.J6H3Re28AXT-T';
$testPassword = 'NewAdmin@2025!';

$pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
$stmt = $pdo->prepare('SELECT password FROM users WHERE email = ?');
$stmt->execute(['admin@alenwan.com']);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if ($user) {
    $verify = password_verify($testPassword, $user['password']);
    echo 'Password verification: ' . ($verify ? 'SUCCESS ✅' : 'FAILED ❌') . PHP_EOL;
    echo 'Hash starts with: ' . substr($user['password'], 0, 30) . '...' . PHP_EOL;
} else {
    echo 'User not found' . PHP_EOL;
}
?>
