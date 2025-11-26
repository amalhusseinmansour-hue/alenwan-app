<?php
/**
 * Fix CSRF and Session Issues
 */

$basePath = __DIR__;
$storagePath = $basePath . '/storage/framework/sessions';
$cachePath = $basePath . '/storage/framework/cache';
$viewsPath = $basePath . '/storage/framework/views';

echo "🔧 Fixing Laravel CSRF and Session Issues...\n\n";

// 1. Clear all sessions
echo "1️⃣ Clearing sessions...\n";
if (is_dir($storagePath)) {
    $files = glob($storagePath . '/*');
    foreach ($files as $file) {
        if (is_file($file)) {
            unlink($file);
        }
    }
    echo "   ✅ Sessions cleared\n";
} else {
    echo "   ⚠️  Sessions directory not found\n";
}

// 2. Clear cache
echo "\n2️⃣ Clearing cache...\n";
if (is_dir($cachePath)) {
    $files = glob($cachePath . '/*');
    foreach ($files as $file) {
        if (is_file($file)) {
            unlink($file);
        }
    }
    echo "   ✅ Cache cleared\n";
} else {
    echo "   ⚠️  Cache directory not found\n";
}

// 3. Clear compiled views
echo "\n3️⃣ Clearing views...\n";
if (is_dir($viewsPath)) {
    $files = glob($viewsPath . '/*');
    foreach ($files as $file) {
        if (is_file($file)) {
            unlink($file);
        }
    }
    echo "   ✅ Views cleared\n";
} else {
    echo "   ⚠️  Views directory not found\n";
}

// 4. Fix permissions
echo "\n4️⃣ Fixing permissions...\n";
$dirs = [
    $basePath . '/storage',
    $basePath . '/bootstrap/cache'
];

foreach ($dirs as $dir) {
    if (is_dir($dir)) {
        chmod($dir, 0775);
        echo "   ✅ Fixed permissions for: $dir\n";
    }
}

echo "\n✅ Done! Now try logging in again.\n";
echo "\nUse: https://alenwan.app/admin/login\n";
echo "Email: admin@alenwan.com\n";
echo "Password: NewAdmin@2025!\n";
?>
