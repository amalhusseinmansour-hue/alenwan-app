# PowerShell Deployment Script for Alenwan App
# This script builds Flutter web and uploads everything to the server

param(
    [switch]$BuildOnly,
    [switch]$UploadOnly,
    [switch]$BackendOnly,
    [switch]$WebOnly
)

$ErrorActionPreference = "Stop"

# Server configuration
$SERVER_USER = "u996186400"
$SERVER_HOST = "46.202.180.189"
$SERVER_PORT = "65002"
$SERVER_PATH = "domains/alenwan.app/public_html"

# Colors for output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

Write-Info "========================================="
Write-Info "Alenwan App Deployment Script"
Write-Info "========================================="
Write-Host ""

# Step 1: Build Flutter Web (unless UploadOnly or BackendOnly)
if (-not $UploadOnly -and -not $BackendOnly) {
    Write-Info "[1/4] Building Flutter Web App..."
    
    try {
        flutter build web --release --no-tree-shake-icons
        Write-Success "✓ Flutter web build completed successfully"
    }
    catch {
        Write-Error "✗ Flutter build failed: $_"
        exit 1
    }
    
    Write-Host ""
}

if ($BuildOnly) {
    Write-Success "Build completed! Files are in: build\web"
    exit 0
}

# Step 2: Prepare deployment files
Write-Info "[2/4] Preparing deployment files..."

$TEMP_DIR = "temp_deploy"
if (Test-Path $TEMP_DIR) {
    Remove-Item -Recurse -Force $TEMP_DIR
}
New-Item -ItemType Directory -Path $TEMP_DIR | Out-Null

# Copy Flutter web files (unless BackendOnly)
if (-not $BackendOnly) {
    Write-Info "  - Copying Flutter web files..."
    Copy-Item -Recurse "build\web\*" "$TEMP_DIR\web\"
    Write-Success "  ✓ Web files ready"
}

# Copy backend files (unless WebOnly)
if (-not $WebOnly) {
    Write-Info "  - Copying backend files..."
    
    # Copy deployment folder
    if (Test-Path "deployment\app") {
        Copy-Item -Recurse "deployment\app" "$TEMP_DIR\backend\app\"
    }
    
    # Copy fix scripts
    if (Test-Path "deployment\*.md") {
        Copy-Item "deployment\*.md" "$TEMP_DIR\backend\"
    }
    if (Test-Path "deployment\*.sh") {
        Copy-Item "deployment\*.sh" "$TEMP_DIR\backend\"
    }
    
    Write-Success "  ✓ Backend files ready"
}

Write-Host ""

# Step 3: Upload to server
Write-Info "[3/4] Uploading to server..."
Write-Warning "You will need to enter your SSH password"
Write-Host ""

try {
    # Upload web files (unless BackendOnly)
    if (-not $BackendOnly -and (Test-Path "$TEMP_DIR\web")) {
        Write-Info "  - Uploading web files..."
        scp -P $SERVER_PORT -r "$TEMP_DIR\web\*" "${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/"
        Write-Success "  ✓ Web files uploaded"
    }
    
    # Upload backend files (unless WebOnly)
    if (-not $WebOnly -and (Test-Path "$TEMP_DIR\backend")) {
        Write-Info "  - Uploading backend files..."
        scp -P $SERVER_PORT -r "$TEMP_DIR\backend\*" "${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/"
        Write-Success "  ✓ Backend files uploaded"
    }
}
catch {
    Write-Error "✗ Upload failed: $_"
    Write-Warning "Make sure you have SSH access to the server"
    exit 1
}

Write-Host ""

# Step 4: Run post-deployment commands
Write-Info "[4/4] Running post-deployment commands..."

$POST_DEPLOY_COMMANDS = @"
cd $SERVER_PATH
php artisan optimize:clear
php artisan config:cache
chmod -R 755 storage
chmod -R 775 storage/logs
php artisan storage:link
echo 'Deployment completed successfully!'
"@

try {
    Write-Info "  - Clearing cache and fixing permissions..."
    $POST_DEPLOY_COMMANDS | ssh -p $SERVER_PORT "${SERVER_USER}@${SERVER_HOST}" "bash -s"
    Write-Success "  ✓ Post-deployment commands executed"
}
catch {
    Write-Warning "⚠ Post-deployment commands failed (you may need to run them manually)"
}

Write-Host ""

# Cleanup
Write-Info "Cleaning up temporary files..."
Remove-Item -Recurse -Force $TEMP_DIR
Write-Success "✓ Cleanup completed"

Write-Host ""
Write-Success "========================================="
Write-Success "Deployment Completed Successfully!"
Write-Success "========================================="
Write-Host ""
Write-Info "Next steps:"
Write-Info "1. Test the app: https://alenwan.app"
Write-Info "2. Test admin panel: https://alenwan.app/admin"
Write-Info "3. Check logs if needed: ssh and run 'tail -f storage/logs/laravel.log'"
Write-Host ""
