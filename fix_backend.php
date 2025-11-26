<?php
/**
 * Alenwan Backend Fix Script v3
 * Fixes Database Schema, Missing Routes, and Adds Requested Slider
 */

// Database Credentials
$host = 'localhost';
$dbname = 'u996186400_alenwan';
$username = 'u996186400_alenwan';
$password = 'Alenwanapp33510421@';

echo "<h1>Alenwan Backend Fixer v3</h1>";

// 1. Fix Database
echo "<h2>1. Database Schema Fixes</h2>";
try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "<p style='color:green'>✅ Connected to Database</p>";

    // Fix live_streams table
    try {
        $stmt = $pdo->query("SHOW COLUMNS FROM live_streams LIKE 'is_active'");
        if ($stmt->rowCount() == 0) {
            $pdo->exec("ALTER TABLE live_streams ADD COLUMN is_active TINYINT(1) DEFAULT 1");
            echo "<p style='color:green'>✅ Added 'is_active' column to 'live_streams' table.</p>";
        } else {
            echo "<p style='color:blue'>ℹ️ 'is_active' column already exists in 'live_streams'.</p>";
        }
    } catch (PDOException $e) {
        echo "<p style='color:red'>❌ Error checking/fixing live_streams: " . $e->getMessage() . "</p>";
    }

    // Fix live_stream_comments table
    try {
        $stmt = $pdo->query("SHOW COLUMNS FROM live_stream_comments LIKE 'is_active'");
        if ($stmt->rowCount() == 0) {
            $pdo->exec("ALTER TABLE live_stream_comments ADD COLUMN is_active TINYINT(1) DEFAULT 1");
            echo "<p style='color:green'>✅ Added 'is_active' column to 'live_stream_comments' table.</p>";
        } else {
            echo "<p style='color:blue'>ℹ️ 'is_active' column already exists in 'live_stream_comments'.</p>";
        }
    } catch (PDOException $e) {
        echo "<p style='color:red'>❌ Error checking/fixing live_stream_comments: " . $e->getMessage() . "</p>";
    }

    // Fix sliders table
    $sliderColumns = [
        'media_type' => "VARCHAR(50) DEFAULT 'image'",
        'video_type' => "VARCHAR(50) NULL",
        'video_url' => "VARCHAR(500) NULL",
        'button_text' => "VARCHAR(255) NULL",
        'order' => "INT DEFAULT 0"
    ];

    foreach ($sliderColumns as $col => $def) {
        try {
            $stmt = $pdo->query("SHOW COLUMNS FROM sliders LIKE '$col'");
            if ($stmt->rowCount() == 0) {
                $pdo->exec("ALTER TABLE sliders ADD COLUMN $col $def");
                echo "<p style='color:green'>✅ Added '$col' column to 'sliders' table.</p>";
            } else {
                echo "<p style='color:blue'>ℹ️ '$col' column already exists in 'sliders'.</p>";
            }
        } catch (PDOException $e) {
            echo "<p style='color:red'>❌ Error checking/fixing sliders ($col): " . $e->getMessage() . "</p>";
        }
    }

    // 4. Add Requested Slider
    echo "<h2>4. Adding Requested Slider</h2>";
    $vimeoId = '1110521673';
    $vimeoUrl = 'https://vimeo.com/1110521673?share=copy&fl=sv&fe=ci';
    $title = 'New Vimeo Video';

    try {
        // Check if exists
        $stmt = $pdo->prepare("SELECT id FROM sliders WHERE video_url LIKE ?");
        $stmt->execute(["%$vimeoId%"]);
        if ($stmt->rowCount() > 0) {
            echo "<p style='color:blue'>ℹ️ Slider with this video already exists.</p>";
        } else {
            $stmt = $pdo->prepare("INSERT INTO sliders (title, description, media_type, video_type, video_url, is_active, `order`, created_at, updated_at) VALUES (?, ?, 'video', 'vimeo', ?, 1, 0, NOW(), NOW())");
            $stmt->execute([$title, 'Added via Fix Script', $vimeoUrl]);
            echo "<p style='color:green'>✅ Added new slider for Vimeo video: $vimeoId</p>";
        }
    } catch (PDOException $e) {
        echo "<p style='color:red'>❌ Error adding slider: " . $e->getMessage() . "</p>";
    }

} catch (PDOException $e) {
    echo "<p style='color:red'>❌ Database Connection Failed: " . $e->getMessage() . "</p>";
}

// 2. Fix Routes
echo "<h2>2. Route Fixes</h2>";
$routesFile = '../routes/api.php';

if (file_exists($routesFile)) {
    $content = file_get_contents($routesFile);
    
    // Check if route exists
    if (strpos($content, 'live-streams/{id}/comments') === false) {
        $newRoutes = "\n\n// Fixed Live Stream Comments Routes (Added by Fixer)\n" .
                     "Route::get('live-streams/{id}/comments', [App\Http\Controllers\Api\LiveStreamController::class, 'comments']);\n" .
                     "Route::post('live-streams/{id}/comments', [App\Http\Controllers\Api\LiveStreamController::class, 'addComment']);\n";
        
        if (file_put_contents($routesFile, $newRoutes, FILE_APPEND)) {
            echo "<p style='color:green'>✅ Appended missing routes to api.php</p>";
        } else {
            echo "<p style='color:red'>❌ Failed to write to api.php (Permission denied?)</p>";
        }
    } else {
        echo "<p style='color:blue'>ℹ️ Routes already exist in api.php</p>";
    }
} else {
    echo "<p style='color:red'>❌ routes/api.php not found at $routesFile</p>";
}

// 3. Clear Cache
echo "<h2>3. Cache Clearing</h2>";
$bootstrapCache = '../bootstrap/cache';
if (is_dir($bootstrapCache)) {
    $files = glob($bootstrapCache . '/*.php');
    foreach ($files as $file) {
        if (is_file($file)) {
            @unlink($file);
            echo "<p>Deleted cache file: " . basename($file) . "</p>";
        }
    }
    echo "<p style='color:green'>✅ Cleared bootstrap cache</p>";
}

echo "<h3>Done! Try the app and admin panel now.</h3>";
?>
