# Simple Deployment Script
# Run this to deploy to server

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Alenwan App Deployment" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Server info
$SERVER = "u996186400@46.202.180.189"
$PORT = "65002"
$PATH = "domains/alenwan.app/public_html"

Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "1. Upload Flutter web files from build\web" -ForegroundColor Yellow
Write-Host "2. Upload backend files from deployment" -ForegroundColor Yellow
Write-Host "3. Run post-deployment commands" -ForegroundColor Yellow
Write-Host ""
Write-Host "You will need to enter your SSH password multiple times" -ForegroundColor Yellow
Write-Host ""

$continue = Read-Host "Continue? (y/n)"
if ($continue -ne "y") {
    Write-Host "Deployment cancelled" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "[1/3] Uploading web files..." -ForegroundColor Cyan

try {
    scp -P $PORT -r "build\web\*" "${SERVER}:${PATH}/"
    Write-Host "✓ Web files uploaded" -ForegroundColor Green
}
catch {
    Write-Host "✗ Failed to upload web files" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "[2/3] Uploading backend files..." -ForegroundColor Cyan

try {
    scp -P $PORT -r "deployment\*" "${SERVER}:${PATH}/"
    Write-Host "✓ Backend files uploaded" -ForegroundColor Green
}
catch {
    Write-Host "✗ Failed to upload backend files" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "[3/3] Running post-deployment commands..." -ForegroundColor Cyan

$commands = @"
cd $PATH
php artisan optimize:clear
php artisan config:cache
chmod -R 755 storage
chmod -R 775 storage/logs
php artisan storage:link
echo 'Done!'
"@

try {
    $commands | ssh -p $PORT $SERVER "bash -s"
    Write-Host "✓ Post-deployment commands completed" -ForegroundColor Green
}
catch {
    Write-Host "⚠ Post-deployment commands failed" -ForegroundColor Yellow
    Write-Host "You may need to run them manually" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Test your app at: https://alenwan.app" -ForegroundColor Cyan
Write-Host ""
