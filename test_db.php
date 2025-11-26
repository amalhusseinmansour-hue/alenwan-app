<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "🔍 Testing database connection...\n\n";

try {
    // Test connection
    DB::connection()->getPdo();
    echo "✅ Database connection successful!\n";
    echo "Connection type: " . DB::connection()->getDriverName() . "\n";
    echo "Database name: " . DB::connection()->getDatabaseName() . "\n\n";

    // Test user query
    echo "🔍 Testing user query...\n";
    $user = App\Models\User::where('email', 'admin@alenwan.com')->first();

    if ($user) {
        echo "✅ User found!\n";
        echo "ID: " . $user->id . "\n";
        echo "Name: " . $user->name . "\n";
        echo "Email: " . $user->email . "\n";
        echo "Is Admin: " . ($user->is_admin ? 'Yes' : 'No') . "\n";
    } else {
        echo "❌ User not found!\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "File: " . $e->getFile() . ":" . $e->getLine() . "\n";
}

echo "\n✅ Test completed!\n";
