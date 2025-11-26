@echo off
echo ================================
echo Flutter Web Build and Deploy
echo ================================

echo.
echo [1/3] Cleaning previous build...
flutter clean

echo.
echo [2/3] Getting dependencies...
flutter pub get

echo.
echo [3/3] Building web for production...
flutter build web --release

echo.
echo [DEPLOY] Creating deployment package...
powershell -ExecutionPolicy Bypass -File deploy_web.ps1

echo.
echo ================================
echo Build and deployment package ready!
echo ================================
pause