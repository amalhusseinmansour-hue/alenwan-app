#!/usr/bin/env powershell

# GitHub Push Helper Script
# استخدام: .\github-push.ps1

Write-Host "`n=== GitHub Push Helper ===" -ForegroundColor Cyan
Write-Host "لرفع alenwan إلى GitHub`n" -ForegroundColor Yellow

# الخطوة 1
Write-Host "1️⃣  أنسخ Personal Access Token من:" -ForegroundColor Green
Write-Host "   https://github.com/settings/tokens`n" -ForegroundColor White

# الخطوة 2
$token = Read-Host "الصق الرمز (Token)"

if ($token -eq "" -or $token.Length -lt 10) {
    Write-Host "`n❌ الرمز غير صحيح!" -ForegroundColor Red
    exit 1
}

# الخطوة 3
Write-Host "`n2️⃣  جاري تحديث الـ URL..." -ForegroundColor Green

cd C:\Users\HP\Desktop\flutter\alenwan

$url = "https://amalhusseinmansour-hue:$token@github.com/amalhusseinmansour-hue/alenwan.git"
git remote set-url origin $url

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ تم تحديث الـ URL" -ForegroundColor Green
} else {
    Write-Host "❌ فشل التحديث" -ForegroundColor Red
    exit 1
}

# الخطوة 4
Write-Host "`n3️⃣  جاري الرفع..." -ForegroundColor Green
Write-Host "   قد يستغرق وقتاً..." -ForegroundColor Yellow

git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ تم الرفع بنجاح!" -ForegroundColor Green
    Write-Host "`n   اذهب إلى: https://github.com/amalhusseinmansour-hue/alenwan" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ فشل الرفع" -ForegroundColor Red
    Write-Host "   تحقق من الرمز أو الاتصال بالإنترنت" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n" -ForegroundColor Green
