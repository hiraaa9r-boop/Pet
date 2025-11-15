# Firebase Hosting Deploy Script (PowerShell)
# Progetto: My Pet Care (pet-care-9790d)
# Data: 15 Novembre 2024

$ErrorActionPreference = "Stop"

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Firebase Hosting Deploy - My Pet Care" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Verifica prerequisiti
Write-Host "Verifica prerequisiti..." -ForegroundColor Yellow

# Check Firebase CLI
try {
    $firebaseVersion = firebase --version
    Write-Host "[OK] Firebase CLI trovato: $firebaseVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERRORE] Firebase CLI non trovato!" -ForegroundColor Red
    Write-Host "         Installa con: npm install -g firebase-tools" -ForegroundColor Yellow
    exit 1
}

# Check Flutter
try {
    $flutterVersion = flutter --version | Select-String "Flutter" | Select-Object -First 1
    Write-Host "[OK] Flutter trovato: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERRORE] Flutter non trovato!" -ForegroundColor Red
    exit 1
}

# Verifica file
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "[ERRORE] pubspec.yaml non trovato!" -ForegroundColor Red
    Write-Host "         Esegui questo script dalla root del progetto Flutter" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] Root progetto verificata" -ForegroundColor Green

if (-not (Test-Path "firebase.json")) {
    Write-Host "[ERRORE] firebase.json non trovato!" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] firebase.json trovato" -ForegroundColor Green

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Build Flutter Web" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Clean previous build
Write-Host "Pulizia build precedente..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "Download dipendenze..." -ForegroundColor Yellow
flutter pub get

# Build for web
Write-Host "Build in corso (questo puo richiedere 1-2 minuti)..." -ForegroundColor Yellow
flutter build web --release `
  --dart-define=flutter.inspector.structuredErrors=false `
  --dart-define=debugShowCheckedModeBanner=false

if (-not (Test-Path "build/web")) {
    Write-Host "[ERRORE] Build fallita!" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Build completata!" -ForegroundColor Green

Write-Host ""
Write-Host "Dimensioni build:" -ForegroundColor Yellow
$buildSize = (Get-ChildItem -Path "build/web" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host "$([math]::Round($buildSize, 2)) MB" -ForegroundColor White

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Deploy su Firebase Hosting" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

firebase deploy --only hosting --project pet-care-9790d

Write-Host ""
Write-Host "=======================================" -ForegroundColor Green
Write-Host "DEPLOY COMPLETATO!" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""
Write-Host "App disponibile su:" -ForegroundColor Cyan
Write-Host "  https://pet-care-9790d.web.app" -ForegroundColor White
Write-Host "  https://pet-care-9790d.firebaseapp.com" -ForegroundColor White
Write-Host ""
Write-Host "Per vedere le statistiche:" -ForegroundColor Cyan
Write-Host "  https://console.firebase.google.com/project/pet-care-9790d/hosting" -ForegroundColor White
Write-Host ""
Write-Host "Deploy completato con successo!" -ForegroundColor Green
Write-Host ""
