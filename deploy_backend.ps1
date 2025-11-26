# deploy_backend.ps1
# This script uploads the fixed backend files to the server.
# Usage: Right-click and "Run with PowerShell"

$ServerIP = "46.202.180.189"
$Port = "65002"
$User = "u996186400"
$RemotePath = "./domains/alenwan.app/public_html/" 

Write-Host "=========================================="
Write-Host "  Alenwan Backend Deployment Script"
Write-Host "=========================================="
Write-Host "Target: ${User}@${ServerIP}:${Port}"
Write-Host "Path: $RemotePath"
Write-Host ""
Write-Host "Uploading 'app' directory..."

# Upload the app directory recursively
scp -P $Port -r .\deployment\app\* "${User}@${ServerIP}:${RemotePath}"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Upload successful!"
}
else {
    Write-Host ""
    Write-Host "❌ Upload failed. Please check your password and connection."
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
