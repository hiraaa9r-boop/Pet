# deploy-cloudrun.ps1
# Script PowerShell per deployment backend My Pet Care su Google Cloud Run

param(
    [switch]$BuildOnly,
    [switch]$DeployOnly,
    [string]$Region = "europe-west1"
)

$PROJECT_ID = "pet-care-9790d"
$SERVICE_NAME = "pet-care-api"
$IMAGE_NAME = "gcr.io/$PROJECT_ID/$SERVICE_NAME"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "🐾 My Pet Care Backend Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verifica gcloud installato
Write-Host "🔍 Verificando gcloud CLI..." -ForegroundColor Yellow
$gcloudVersion = gcloud --version 2>&1 | Select-String "Google Cloud SDK"
if (-not $gcloudVersion) {
    Write-Host "❌ gcloud CLI non trovato!" -ForegroundColor Red
    Write-Host "📥 Scarica da: https://cloud.google.com/sdk/docs/install" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ gcloud CLI trovato" -ForegroundColor Green
Write-Host ""

# Configura progetto
Write-Host "🔧 Configurando progetto..." -ForegroundColor Yellow
gcloud config set project $PROJECT_ID
Write-Host "✅ Progetto configurato: $PROJECT_ID" -ForegroundColor Green
Write-Host ""

# Build immagine (se non --DeployOnly)
if (-not $DeployOnly) {
    Write-Host "🏗️  Building Docker image con Cloud Build..." -ForegroundColor Yellow
    Write-Host "   Immagine: $IMAGE_NAME" -ForegroundColor Cyan
    Write-Host "   Tempo stimato: 3-5 minuti" -ForegroundColor Cyan
    Write-Host ""
    
    gcloud builds submit --tag $IMAGE_NAME
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Build fallito!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "✅ Build completato con successo!" -ForegroundColor Green
    Write-Host ""
}

# Stop se --BuildOnly
if ($BuildOnly) {
    Write-Host "🎯 Build completato. Esci (--BuildOnly specificato)" -ForegroundColor Yellow
    exit 0
}

# Deploy su Cloud Run
Write-Host "🚀 Deploying su Cloud Run..." -ForegroundColor Yellow
Write-Host "   Servizio: $SERVICE_NAME" -ForegroundColor Cyan
Write-Host "   Region: $Region" -ForegroundColor Cyan
Write-Host ""

gcloud run deploy $SERVICE_NAME `
    --image $IMAGE_NAME `
    --region $Region `
    --platform managed `
    --allow-unauthenticated

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Deploy fallito!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Deploy completato con successo!" -ForegroundColor Green
Write-Host ""

# Ottieni URL servizio
Write-Host "🔗 Ottenendo URL servizio..." -ForegroundColor Yellow
$SERVICE_URL = gcloud run services describe $SERVICE_NAME `
    --region $Region `
    --format="value(status.url)"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✨ DEPLOYMENT COMPLETATO!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Informazioni servizio:" -ForegroundColor Cyan
Write-Host "   Nome: $SERVICE_NAME" -ForegroundColor White
Write-Host "   Region: $Region" -ForegroundColor White
Write-Host "   URL: $SERVICE_URL" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔧 Prossimi passi:" -ForegroundColor Cyan
Write-Host "   1. Configura variabili d'ambiente in Cloud Run Console" -ForegroundColor White
Write-Host "   2. Aggiorna lib/config.dart in Flutter con il nuovo URL" -ForegroundColor White
Write-Host "   3. Testa health endpoint: curl $SERVICE_URL/health" -ForegroundColor White
Write-Host ""
Write-Host "📚 Documentazione completa: CLOUD_RUN_DEPLOYMENT_GUIDE.md" -ForegroundColor Cyan
Write-Host ""
