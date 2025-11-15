# Firebase Hosting Deploy Script (PowerShell)
# Progetto: My Pet Care (pet-care-9790d)
# Data: 15 Novembre 2024

$ErrorActionPreference = "Stop"

Write-Host "🚀 Firebase Hosting Deploy - My Pet Care" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verifica prerequisiti
Write-Host "📋 Verifica prerequisiti..." -ForegroundColor Yellow

# Check Firebase CLI
try {
    $firebaseVersion = firebase --version
    Write-Host "✅ Firebase CLI trovato: $firebaseVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Firebase CLI non trovato!" -ForegroundColor Red
    Write-Host "   Installa con: npm install -g firebase-tools" -ForegroundColor Yellow
    exit 1
}

# Check Flutter
try {
    $flutterVersion = flutter --version | Select-String "Flutter" | Select-Object -First 1
    Write-Host "✅ Flutter trovato: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter non trovato!" -ForegroundColor Red
    exit 1
}

# Verifica file
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ pubspec.yaml non trovato!" -ForegroundColor Red
    Write-Host "   Esegui questo script dalla root del progetto Flutter" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Root progetto verificata" -ForegroundColor Green

if (-not (Test-Path "firebase.json")) {
    Write-Host "❌ firebase.json non trovato!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ firebase.json trovato" -ForegroundColor Green

Write-Host ""
Write-Host "🔨 Build Flutter Web..." -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan

# Clean previous build
Write-Host "Pulizia build precedente..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "Download dipendenze..." -ForegroundColor Yellow
flutter pub get

# Build for web
Write-Host "Build in corso (questo può richiedere 1-2 minuti)..." -ForegroundColor Yellow
flutter build web --release `
  --dart-define=flutter.inspector.structuredErrors=false `
  --dart-define=debugShowCheckedModeBanner=false

if (-not (Test-Path "build/web")) {
    Write-Host "❌ Build fallita!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Build completata!" -ForegroundColor Green

Write-Host ""
Write-Host "📊 Dimensioni build:" -ForegroundColor Yellow
$buildSize = (Get-ChildItem -Path "build/web" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host "$([math]::Round($buildSize, 2)) MB"

Write-Host ""
Write-Host "🚀 Deploy su Firebase Hosting..." -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

firebase deploy --only hosting --project pet-care-9790d

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "✅ DEPLOY COMPLETATO!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "🔗 App disponibile su:" -ForegroundColor Cyan
Write-Host "   https://pet-care-9790d.web.app" -ForegroundColor White
Write-Host "   https://pet-care-9790d.firebaseapp.com" -ForegroundColor White
Write-Host ""
Write-Host "📊 Per vedere le statistiche:" -ForegroundColor Cyan
Write-Host "   https://console.firebase.google.com/project/pet-care-9790d/hosting" -ForegroundColor White
Write-Host ""
