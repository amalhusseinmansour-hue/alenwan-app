# Deploy Flutter Web Build to Server
# Run this script after successful flutter build web --release

Write-Host "Flutter Web Deployment Script" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

$webBuildPath = "build\web"
$zipFileName = "alenwan_web_build_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').zip"

# Check if web build exists
if (-not (Test-Path $webBuildPath)) {
    Write-Host "Error: Web build not found at $webBuildPath" -ForegroundColor Red
    Write-Host "Please run: flutter build web --release" -ForegroundColor Yellow
    exit 1
}

Write-Host "Web build found at: $webBuildPath" -ForegroundColor Green

# Create deployment zip
Write-Host "Creating deployment zip: $zipFileName" -ForegroundColor Blue
Compress-Archive -Path "$webBuildPath\*" -DestinationPath $zipFileName -Force

if (Test-Path $zipFileName) {
    Write-Host "Deployment zip created successfully: $zipFileName" -ForegroundColor Green
    $fileSize = [math]::Round((Get-Item $zipFileName).Length / 1MB, 2)
    Write-Host "File size: $fileSize MB" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    Write-Host "1. Upload $zipFileName to your server via cPanel File Manager" -ForegroundColor White
    Write-Host "2. Extract the zip file to your domain root directory (public_html)" -ForegroundColor White
    Write-Host "3. Delete any old files first to avoid conflicts" -ForegroundColor White
    Write-Host "4. Test your website at https://alenwan.app" -ForegroundColor White
    
    Write-Host ""
    Write-Host "Manual Upload Instructions:" -ForegroundColor Yellow
    Write-Host "- Login to your cPanel" -ForegroundColor White
    Write-Host "- Go to File Manager" -ForegroundColor White
    Write-Host "- Navigate to public_html (or your domain root)" -ForegroundColor White
    Write-Host "- Upload $zipFileName" -ForegroundColor White
    Write-Host "- Extract and move contents to root" -ForegroundColor White
} else {
    Write-Host "Failed to create deployment zip" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Deployment package ready!" -ForegroundColor Green