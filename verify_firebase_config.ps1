# Firebase Configuration Verification Script
# This script helps verify your Firebase configuration

Write-Host "=== Firebase Configuration Verification ===" -ForegroundColor Green
Write-Host ""

# Check if we're in the correct directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "Error: pubspec.yaml not found. Please run this script from the project root directory." -ForegroundColor Red
    exit 1
}

Write-Host "1. Checking Flutter dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to get Flutter dependencies" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. Checking for Firebase configuration files..." -ForegroundColor Yellow

# Check firebase_options.dart
if (Test-Path "lib\firebase_options.dart") {
    Write-Host "✓ lib/firebase_options.dart found" -ForegroundColor Green
} else {
    Write-Host "✗ lib/firebase_options.dart not found" -ForegroundColor Red
}

# Check index.html
if (Test-Path "web\index.html") {
    Write-Host "✓ web/index.html found" -ForegroundColor Green
} else {
    Write-Host "✗ web/index.html not found" -ForegroundColor Red
}

# Check auth_provider.dart
if (Test-Path "lib\providers\auth_provider.dart") {
    Write-Host "✓ lib/providers/auth_provider.dart found" -ForegroundColor Green
} else {
    Write-Host "✗ lib/providers/auth_provider.dart not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Checking for common configuration issues..." -ForegroundColor Yellow

# Read firebase_options.dart and check for placeholder values
$firebaseOptions = Get-Content "lib\firebase_options.dart" -Raw
if ($firebaseOptions -match "AIzaSyDc5mJ8FqJ5_0gRQEPG7vZMbXl2dKjdXQk") {
    Write-Host "⚠️  Default API key found in firebase_options.dart - should be updated with your actual key" -ForegroundColor Yellow
}

if ($firebaseOptions -match "478965214123") {
    Write-Host "⚠️  Default project number found in firebase_options.dart - should be updated with your actual project number" -ForegroundColor Yellow
}

# Read auth_provider.dart and check for placeholder values
$authProvider = Get-Content "lib\providers\auth_provider.dart" -Raw
if ($authProvider -match "478965214123-abcdef123456789.apps.googleusercontent.com") {
    Write-Host "⚠️  Default Google Client ID found in auth_provider.dart - should be updated with your actual client ID" -ForegroundColor Yellow
}

# Read index.html and check for placeholder values
$indexHtml = Get-Content "web\index.html" -Raw
if ($indexHtml -match "478965214123-abcdef123456789.apps.googleusercontent.com") {
    Write-Host "⚠️  Default Google Client ID found in web/index.html - should be updated with your actual client ID" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "4. Verification Complete" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Check Firebase Console → Project Settings → General for your actual configuration values" -ForegroundColor Cyan
Write-Host "2. Update lib/firebase_options.dart with your actual Firebase configuration" -ForegroundColor Cyan
Write-Host "3. Update lib/providers/auth_provider.dart with your actual Google Client ID" -ForegroundColor Cyan
Write-Host "4. Update web/index.html with your actual Google Client ID and Firebase configuration" -ForegroundColor Cyan
Write-Host "5. In Firebase Console → Authentication → Settings, add 'localhost' and 'localhost:3000' to authorized domains" -ForegroundColor Cyan
Write-Host ""
Write-Host "After updating configuration, run 'flutter clean' and 'flutter pub get' then test the app" -ForegroundColor Green