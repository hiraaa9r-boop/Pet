# ============================================================================
# MY PET CARE - Backend Deploy Script (PowerShell)
# ============================================================================
# 
# Deploy del backend Node.js su Google Cloud Run
# 
# PREREQUISITI:
# 1. Google Cloud SDK installato (gcloud CLI)
# 2. Autenticato con: gcloud auth login
# 3. Progetto selezionato: gcloud config set project pet-care-9790d
# 4. File .env configurato con valori reali
# 
# ESECUZIONE:
#   .\DEPLOY_COMMANDS.ps1
# 
# ============================================================================

$ErrorActionPreference = "Stop"

# -----------------------------------------------------------------------------
# CONFIGURAZIONE
# -----------------------------------------------------------------------------

$PROJECT_ID = "pet-care-9790d"
$SERVICE_NAME = "mypetcare-backend"
$REGION = "europe-west1"
$PLATFORM = "managed"

# -----------------------------------------------------------------------------
# VERIFICA PREREQUISITI
# -----------------------------------------------------------------------------

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host " MY PET CARE - Backend Deploy su Cloud Run" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Verifica gcloud CLI
Write-Host "Verifica Google Cloud SDK..." -ForegroundColor Yellow
try {
    $gcloudVersion = gcloud --version 2>&1 | Select-String "Google Cloud SDK" | Select-Object -First 1
    Write-Host "[OK] Google Cloud SDK installato: $gcloudVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERRORE] Google Cloud SDK non trovato!" -ForegroundColor Red
    Write-Host "" -ForegroundColor Red
    Write-Host "Installa da: https://cloud.google.com/sdk/docs/install" -ForegroundColor Yellow
    exit 1
}

# Verifica autenticazione
Write-Host "Verifica autenticazione..." -ForegroundColor Yellow
try {
    $account = gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>&1 | Select-Object -First 1
    if ($account) {
        Write-Host "[OK] Autenticato come: $account" -ForegroundColor Green
    } else {
        throw "Non autenticato"
    }
} catch {
    Write-Host "[ERRORE] Non sei autenticato!" -ForegroundColor Red
    Write-Host "" -ForegroundColor Red
    Write-Host "Esegui: gcloud auth login" -ForegroundColor Yellow
    exit 1
}

# Verifica progetto
Write-Host "Verifica progetto Google Cloud..." -ForegroundColor Yellow
try {
    $currentProject = gcloud config get-value project 2>&1
    if ($currentProject -eq $PROJECT_ID) {
        Write-Host "[OK] Progetto corretto: $PROJECT_ID" -ForegroundColor Green
    } else {
        Write-Host "[ATTENZIONE] Progetto corrente: $currentProject" -ForegroundColor Yellow
        Write-Host "              Progetto atteso: $PROJECT_ID" -ForegroundColor Yellow
        Write-Host "" -ForegroundColor Yellow
        $response = Read-Host "Vuoi cambiare progetto in $PROJECT_ID? (s/n)"
        if ($response -eq "s" -or $response -eq "S") {
            gcloud config set project $PROJECT_ID
            Write-Host "[OK] Progetto cambiato in: $PROJECT_ID" -ForegroundColor Green
        } else {
            Write-Host "Deploy annullato" -ForegroundColor Red
            exit 1
        }
    }
} catch {
    Write-Host "[ERRORE] Impossibile verificare il progetto" -ForegroundColor Red
    exit 1
}

# Verifica file .env
Write-Host "Verifica file .env..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "[OK] File .env trovato" -ForegroundColor Green
    
    # Conta variabili configurate
    $envContent = Get-Content .env
    $configuredVars = ($envContent | Where-Object { $_ -match "^[A-Z_]+=.+" }).Count
    Write-Host "     Variabili configurate: $configuredVars" -ForegroundColor Cyan
    
    # Verifica variabili critiche
    $criticalVars = @(
        "FIREBASE_PROJECT_ID",
        "STRIPE_SECRET_KEY",
        "PAYPAL_CLIENT_ID",
        "CORS_ALLOWED_ORIGINS"
    )
    
    foreach ($var in $criticalVars) {
        $found = $envContent | Where-Object { $_ -match "^$var=" }
        if ($found) {
            Write-Host "     [OK] $var configurata" -ForegroundColor Green
        } else {
            Write-Host "     [ATTENZIONE] $var mancante o non configurata" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "[ERRORE] File .env non trovato!" -ForegroundColor Red
    Write-Host "" -ForegroundColor Red
    Write-Host "Crea il file .env da .env.example:" -ForegroundColor Yellow
    Write-Host "  Copy-Item .env.example .env" -ForegroundColor Yellow
    Write-Host "  notepad .env" -ForegroundColor Yellow
    exit 1
}

# -----------------------------------------------------------------------------
# CONFERMA DEPLOY
# -----------------------------------------------------------------------------

Write-Host "" -ForegroundColor White
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host " RIEPILOGO DEPLOY" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "  Progetto:  $PROJECT_ID" -ForegroundColor White
Write-Host "  Servizio:  $SERVICE_NAME" -ForegroundColor White
Write-Host "  Regione:   $REGION" -ForegroundColor White
Write-Host "  Platform:  $PLATFORM" -ForegroundColor White
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White

$confirm = Read-Host "Procedere con il deploy? (s/n)"
if ($confirm -ne "s" -and $confirm -ne "S") {
    Write-Host "Deploy annullato" -ForegroundColor Yellow
    exit 0
}

# -----------------------------------------------------------------------------
# DEPLOY SU CLOUD RUN
# -----------------------------------------------------------------------------

Write-Host "" -ForegroundColor White
Write-Host "Inizio deploy su Cloud Run..." -ForegroundColor Yellow
Write-Host "Questo processo può richiedere 3-5 minuti..." -ForegroundColor Cyan
Write-Host "" -ForegroundColor White

try {
    # Carica variabili da .env
    $envVars = @()
    Get-Content .env | ForEach-Object {
        if ($_ -match "^([A-Z_]+)=(.+)$") {
            $envVars += "$($matches[1])=$($matches[2])"
        }
    }
    
    $envVarsString = $envVars -join ","
    
    # Esegui deploy
    gcloud run deploy $SERVICE_NAME `
        --source . `
        --platform $PLATFORM `
        --region $REGION `
        --allow-unauthenticated `
        --set-env-vars $envVarsString `
        --memory 512Mi `
        --cpu 1 `
        --timeout 60 `
        --max-instances 10 `
        --min-instances 0
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "" -ForegroundColor White
        Write-Host "============================================================================" -ForegroundColor Green
        Write-Host " DEPLOY COMPLETATO CON SUCCESSO!" -ForegroundColor Green
        Write-Host "============================================================================" -ForegroundColor Green
        
        # Ottieni URL del servizio
        $serviceUrl = gcloud run services describe $SERVICE_NAME `
            --platform $PLATFORM `
            --region $REGION `
            --format "value(status.url)"
        
        Write-Host "" -ForegroundColor White
        Write-Host "Backend URL:" -ForegroundColor Cyan
        Write-Host "  $serviceUrl" -ForegroundColor White
        Write-Host "" -ForegroundColor White
        Write-Host "Endpoint disponibili:" -ForegroundColor Cyan
        Write-Host "  Health check:      $serviceUrl/health" -ForegroundColor White
        Write-Host "  Stripe checkout:   $serviceUrl/api/payments/stripe/checkout" -ForegroundColor White
        Write-Host "  PayPal orders:     $serviceUrl/api/payments/paypal/create-order" -ForegroundColor White
        Write-Host "  Admin stats:       $serviceUrl/api/admin/stats" -ForegroundColor White
        Write-Host "" -ForegroundColor White
        Write-Host "Dashboard Cloud Run:" -ForegroundColor Cyan
        Write-Host "  https://console.cloud.google.com/run/detail/$REGION/$SERVICE_NAME" -ForegroundColor White
        Write-Host "" -ForegroundColor White
        
        # Test health check
        Write-Host "Test health check..." -ForegroundColor Yellow
        try {
            $health = Invoke-RestMethod -Uri "$serviceUrl/health" -Method Get
            Write-Host "[OK] Backend risponde correttamente" -ForegroundColor Green
            Write-Host "     Service: $($health.service)" -ForegroundColor Cyan
            Write-Host "     Version: $($health.version)" -ForegroundColor Cyan
            Write-Host "     Environment: $($health.env)" -ForegroundColor Cyan
        } catch {
            Write-Host "[ATTENZIONE] Impossibile raggiungere health check" -ForegroundColor Yellow
            Write-Host "              Il backend potrebbe richiedere qualche secondo per avviarsi" -ForegroundColor Yellow
        }
        
        Write-Host "" -ForegroundColor White
        Write-Host "PROSSIMI PASSI:" -ForegroundColor Cyan
        Write-Host "1. Aggiorna lib/config.dart nel frontend con il nuovo backend URL" -ForegroundColor White
        Write-Host "2. Configura webhook Stripe con URL: $serviceUrl/api/payments/stripe/webhook" -ForegroundColor White
        Write-Host "3. Configura webhook PayPal con URL: $serviceUrl/api/payments/paypal/webhook" -ForegroundColor White
        Write-Host "4. Rideploy frontend Flutter con nuovo backend URL" -ForegroundColor White
        Write-Host "" -ForegroundColor White
        
    } else {
        throw "Deploy fallito con exit code $LASTEXITCODE"
    }
    
} catch {
    Write-Host "" -ForegroundColor White
    Write-Host "============================================================================" -ForegroundColor Red
    Write-Host " DEPLOY FALLITO" -ForegroundColor Red
    Write-Host "============================================================================" -ForegroundColor Red
    Write-Host "" -ForegroundColor White
    Write-Host "Errore: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "" -ForegroundColor White
    Write-Host "Suggerimenti:" -ForegroundColor Yellow
    Write-Host "1. Verifica che tutte le variabili in .env siano configurate" -ForegroundColor White
    Write-Host "2. Verifica la connessione internet" -ForegroundColor White
    Write-Host "3. Controlla i logs: gcloud run logs read --service=$SERVICE_NAME" -ForegroundColor White
    Write-Host "4. Verifica billing su Google Cloud Console" -ForegroundColor White
    Write-Host "" -ForegroundColor White
    exit 1
}

# -----------------------------------------------------------------------------
# FINE
# -----------------------------------------------------------------------------

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host " Deploy completato!" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
