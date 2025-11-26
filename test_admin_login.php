<?php
// Test Admin Login

// Test 1: GET request to see HTML form
echo "=== Test 1: GET request ===\n";
echo "Go to: https://alenwan.app/api/admin-login\n\n";

// Test 2: cURL POST request
echo "=== Test 2: POST request ===\n";

$email = "admin@alenwan.app"; // Update with your admin email
$password = "password123"; // Update with your admin password

$curl = curl_init();
curl_setopt_array($curl, [
    CURLOPT_URL => "https://alenwan.app/api/admin-login",
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_ENCODING => "",
    CURLOPT_MAXREDIRS => 10,
    CURLOPT_TIMEOUT => 30,
    CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
    CURLOPT_CUSTOMREQUEST => "POST",
    CURLOPT_POSTFIELDS => json_encode([
        "email" => $email,
        "password" => $password
    ]),
    CURLOPT_HTTPHEADER => [
        "Content-Type: application/json"
    ],
]);

$response = curl_exec($curl);
$err = curl_error($curl);
curl_close($curl);

if ($err) {
    echo "Error: $err\n";
} else {
    echo "Response:\n";
    echo $response . "\n";
}

// Test 3: Check admin users in database
echo "\n=== Test 3: Check admin users ===\n";

require 'alenwan/config/database.php';

try {
    $pdo = new PDO(
        "mysql:host=" . env('DB_HOST') . ";dbname=" . env('DB_DATABASE'),
        env('DB_USERNAME'),
        env('DB_PASSWORD'),
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    $stmt = $pdo->query("SELECT id, name, email, role FROM users WHERE role = 'admin'");
    $admins = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "Admin users found: " . count($admins) . "\n";
    foreach ($admins as $admin) {
        echo "- ID: {$admin['id']}, Name: {$admin['name']}, Email: {$admin['email']}, Role: {$admin['role']}\n";
    }
} catch (Exception $e) {
    echo "Database error: " . $e->getMessage() . "\n";
}
?>
