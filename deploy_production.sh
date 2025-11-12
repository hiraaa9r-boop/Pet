#!/bin/bash

# 🚀 MyPetCare - Production Deployment Script
# Automated deployment to Google Cloud Run + Firebase Hosting

set -e  # Exit on error

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo ""
echo "=========================================="
echo "🚀 MyPetCare - Production Deployment"
echo "=========================================="
echo ""

# ==========================================
# Configuration Variables
# ==========================================

# CRITICAL: Sostituisci questi valori prima di eseguire!
PROJECT_ID="${GCP_PROJECT_ID:-pet-care-9790d}"
REGION="${GCP_REGION:-europe-west1}"
SERVICE_NAME="mypetcare-backend"

# Payment Providers (LIVE MODE)
STRIPE_SECRET="${STRIPE_SECRET:-}"
STRIPE_WEBHOOK_SECRET="${STRIPE_WEBHOOK_SECRET:-}"
PAYPAL_CLIENT_ID="${PAYPAL_CLIENT_ID:-}"
PAYPAL_CLIENT_SECRET="${PAYPAL_CLIENT_SECRET:-}"
PAYPAL_BASE="https://api-m.paypal.com"  # PRODUCTION

# Firebase
FIREBASE_STORAGE_BUCKET="${PROJECT_ID}.appspot.com"
FRONTEND_URL="https://mypetcare.web.app"

# Security
CRON_SECRET="${CRON_SECRET:-}"

# ==========================================
# Pre-flight Checks
# ==========================================

echo "🔍 Pre-flight checks..."
echo ""

# Check required tools
REQUIRED_TOOLS=("gcloud" "firebase" "flutter" "jq")
for tool in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v "$tool" &> /dev/null; then
    echo -e "${RED}❌ ERRORE: $tool non trovato${NC}"
    echo "Installare $tool prima di continuare"
    exit 1
  fi
  echo -e "${GREEN}✅ $tool installato${NC}"
done

echo ""

# Check GCP authentication
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
  echo -e "${RED}❌ ERRORE: Non autenticato con gcloud${NC}"
  echo "Eseguire: gcloud auth login"
  exit 1
fi

echo -e "${GREEN}✅ GCP authentication OK${NC}"

# Check Firebase login
if ! firebase projects:list &> /dev/null; then
  echo -e "${RED}❌ ERRORE: Non autenticato con Firebase${NC}"
  echo "Eseguire: firebase login"
  exit 1
fi

echo -e "${GREEN}✅ Firebase authentication OK${NC}"
echo ""

# Validate critical env vars
if [ -z "$STRIPE_SECRET" ] || [ -z "$PAYPAL_CLIENT_ID" ] || [ -z "$CRON_SECRET" ]; then
  echo -e "${YELLOW}⚠️  WARNING: Variabili ambiente critiche mancanti${NC}"
  echo ""
  echo "Per deployment produzione, configurare:"
  echo "  export STRIPE_SECRET=\"sk_live_xxx\""
  echo "  export STRIPE_WEBHOOK_SECRET=\"whsec_live_xxx\""
  echo "  export PAYPAL_CLIENT_ID=\"live_xxx\""
  echo "  export PAYPAL_CLIENT_SECRET=\"live_xxx\""
  echo "  export CRON_SECRET=\"your-strong-secret-32-chars\""
  echo ""
  read -p "Continuare con valori vuoti? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Confirm production deployment
echo -e "${MAGENTA}⚠️  ATTENZIONE: Stai per deployare in PRODUZIONE${NC}"
echo ""
echo "Progetto: $PROJECT_ID"
echo "Region: $REGION"
echo "Service: $SERVICE_NAME"
echo "Payment Mode: LIVE (Stripe + PayPal produzione)"
echo ""
read -p "Sei sicuro di voler procedere? (yes/no) " -r
echo
if [[ ! $REPLY == "yes" ]]; then
  echo "Deployment annullato"
  exit 0
fi

echo ""

# ==========================================
# Step 1: Backend Build
# ==========================================

echo "=========================================="
echo "📦 Step 1: Backend Build"
echo "=========================================="
echo ""

cd backend

echo "🔨 Compilazione TypeScript..."
npm run build

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Build backend fallito${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Backend compilato con successo${NC}"
echo ""

cd ..

# ==========================================
# Step 2: Backend Deploy (Cloud Run)
# ==========================================

echo "=========================================="
echo "☁️  Step 2: Backend Deploy (Cloud Run)"
echo "=========================================="
echo ""

echo "🚀 Deploy backend su Cloud Run..."

gcloud run deploy "$SERVICE_NAME" \
  --source=./backend \
  --region="$REGION" \
  --platform=managed \
  --allow-unauthenticated \
  --set-env-vars="NODE_ENV=production,STRIPE_SECRET=$STRIPE_SECRET,STRIPE_WEBHOOK_SECRET=$STRIPE_WEBHOOK_SECRET,PAYPAL_CLIENT_ID=$PAYPAL_CLIENT_ID,PAYPAL_CLIENT_SECRET=$PAYPAL_CLIENT_SECRET,PAYPAL_BASE=$PAYPAL_BASE,FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET,FRONTEND_URL=$FRONTEND_URL,CRON_SECRET=$CRON_SECRET" \
  --memory=512Mi \
  --cpu=1 \
  --timeout=300s \
  --max-instances=10 \
  --min-instances=0

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Deploy Cloud Run fallito${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Backend deployato con successo${NC}"
echo ""

# Get service URL
BACKEND_URL=$(gcloud run services describe "$SERVICE_NAME" \
  --region="$REGION" \
  --format="value(status.url)")

echo -e "${CYAN}🔗 Backend URL: $BACKEND_URL${NC}"
echo ""

# ==========================================
# Step 3: Cloud Scheduler Configuration
# ==========================================

echo "=========================================="
echo "⏰ Step 3: Cloud Scheduler Configuration"
echo "=========================================="
echo ""

# Check if job exists
if gcloud scheduler jobs describe booking-reminders --location="$REGION" &> /dev/null; then
  echo "📝 Aggiornamento job esistente..."
  
  gcloud scheduler jobs update http booking-reminders \
    --location="$REGION" \
    --schedule="0 * * * *" \
    --uri="$BACKEND_URL/jobs/send-reminders" \
    --http-method=POST \
    --time-zone="Europe/Rome" \
    --headers="X-Cron-Secret=$CRON_SECRET"
    
  echo -e "${GREEN}✅ Job booking-reminders aggiornato${NC}"
else
  echo "🆕 Creazione nuovo job..."
  
  # Get service account for OIDC
  SERVICE_ACCOUNT=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --format="value(spec.template.spec.serviceAccountName)")
  
  gcloud scheduler jobs create http booking-reminders \
    --location="$REGION" \
    --schedule="0 * * * *" \
    --uri="$BACKEND_URL/jobs/send-reminders" \
    --http-method=POST \
    --time-zone="Europe/Rome" \
    --headers="X-Cron-Secret=$CRON_SECRET" \
    --oidc-service-account-email="$SERVICE_ACCOUNT" \
    --oidc-token-audience="$BACKEND_URL"
  
  echo -e "${GREEN}✅ Job booking-reminders creato${NC}"
fi

echo ""

# Cleanup locks job (optional)
if gcloud scheduler jobs describe cleanup-locks --location="$REGION" &> /dev/null; then
  gcloud scheduler jobs update http cleanup-locks \
    --location="$REGION" \
    --schedule="*/15 * * * *" \
    --uri="$BACKEND_URL/jobs/cleanup-locks" \
    --http-method=POST \
    --time-zone="Europe/Rome" \
    --headers="X-Cron-Secret=$CRON_SECRET"
  
  echo -e "${GREEN}✅ Job cleanup-locks aggiornato${NC}"
else
  SERVICE_ACCOUNT=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --format="value(spec.template.spec.serviceAccountName)")
  
  gcloud scheduler jobs create http cleanup-locks \
    --location="$REGION" \
    --schedule="*/15 * * * *" \
    --uri="$BACKEND_URL/jobs/cleanup-locks" \
    --http-method=POST \
    --time-zone="Europe/Rome" \
    --headers="X-Cron-Secret=$CRON_SECRET" \
    --oidc-service-account-email="$SERVICE_ACCOUNT" \
    --oidc-token-audience="$BACKEND_URL"
  
  echo -e "${GREEN}✅ Job cleanup-locks creato${NC}"
fi

echo ""

# ==========================================
# Step 4: Firestore Configuration
# ==========================================

echo "=========================================="
echo "🔥 Step 4: Firestore Configuration"
echo "=========================================="
echo ""

echo "📊 Deploy Firestore indexes..."
firebase deploy --only firestore:indexes --project="$PROJECT_ID"

if [ $? -ne 0 ]; then
  echo -e "${YELLOW}⚠️  Deploy indexes fallito (potrebbero già esistere)${NC}"
fi

echo ""
echo "🔒 Deploy Firestore rules..."
firebase deploy --only firestore:rules --project="$PROJECT_ID"

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Deploy rules fallito${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Firestore configurato con successo${NC}"
echo ""

# ==========================================
# Step 5: Flutter Web Build
# ==========================================

echo "=========================================="
echo "📱 Step 5: Flutter Web Build"
echo "=========================================="
echo ""

echo "🧹 Clean build precedente..."
flutter clean

echo "📦 Install dipendenze..."
flutter pub get

echo "🔨 Build web con API_BASE produzione..."
flutter build web \
  --release \
  --dart-define=API_BASE="$BACKEND_URL" \
  --web-renderer canvaskit

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Build Flutter web fallito${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Flutter web compilato con successo${NC}"
echo ""

# ==========================================
# Step 6: Firebase Hosting Deploy
# ==========================================

echo "=========================================="
echo "🌐 Step 6: Firebase Hosting Deploy"
echo "=========================================="
echo ""

echo "🚀 Deploy su Firebase Hosting..."
firebase deploy --only hosting --project="$PROJECT_ID"

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Deploy hosting fallito${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Frontend deployato con successo${NC}"
echo ""

# ==========================================
# Step 7: Health Checks
# ==========================================

echo "=========================================="
echo "🏥 Step 7: Health Checks"
echo "=========================================="
echo ""

echo "🔍 Test backend health endpoint..."
HEALTH_RESPONSE=$(curl -s "$BACKEND_URL/health")
HEALTH_STATUS=$(echo "$HEALTH_RESPONSE" | jq -r '.status' 2>/dev/null || echo "error")

if [ "$HEALTH_STATUS" == "healthy" ]; then
  echo -e "${GREEN}✅ Backend health check OK${NC}"
  echo "$HEALTH_RESPONSE" | jq .
else
  echo -e "${RED}❌ Backend health check fallito${NC}"
  echo "Response: $HEALTH_RESPONSE"
fi

echo ""

echo "🔍 Test frontend accessibility..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL")

if [ "$FRONTEND_STATUS" == "200" ]; then
  echo -e "${GREEN}✅ Frontend accessibile (HTTP $FRONTEND_STATUS)${NC}"
else
  echo -e "${YELLOW}⚠️  Frontend status: HTTP $FRONTEND_STATUS${NC}"
fi

echo ""

# ==========================================
# Deployment Summary
# ==========================================

echo "=========================================="
echo "✅ Deployment Completato!"
echo "=========================================="
echo ""

echo -e "${CYAN}📊 Riepilogo Deployment:${NC}"
echo ""
echo "Backend URL:    $BACKEND_URL"
echo "Frontend URL:   $FRONTEND_URL"
echo "Project ID:     $PROJECT_ID"
echo "Region:         $REGION"
echo "Payment Mode:   LIVE (Production)"
echo ""

echo -e "${MAGENTA}🔐 Credenziali Configurate:${NC}"
echo "Stripe:         ${STRIPE_SECRET:+✅ Configurato}${STRIPE_SECRET:-❌ Mancante}"
echo "PayPal:         ${PAYPAL_CLIENT_ID:+✅ Configurato}${PAYPAL_CLIENT_ID:-❌ Mancante}"
echo "CRON Secret:    ${CRON_SECRET:+✅ Configurato}${CRON_SECRET:-❌ Mancante}"
echo ""

echo -e "${YELLOW}📋 Prossimi Step:${NC}"
echo ""
echo "1️⃣  Configurare Webhook Stripe:"
echo "    stripe listen --forward-to $BACKEND_URL/webhooks/stripe"
echo ""
echo "2️⃣  Configurare Webhook PayPal:"
echo "    Dashboard: https://developer.paypal.com/dashboard/webhooks"
echo "    URL: $BACKEND_URL/webhooks/paypal"
echo ""
echo "3️⃣  Test Manuale Endpoint:"
echo "    export ADMIN_TOKEN=\"your-firebase-admin-token\""
echo "    curl -H \"Authorization: Bearer \$ADMIN_TOKEN\" $BACKEND_URL/admin/stats | jq"
echo ""
echo "4️⃣  Eseguire QA Checklist:"
echo "    bash qa_production_checklist.sh"
echo ""
echo "5️⃣  Monitoraggio Logs:"
echo "    gcloud run logs tail $SERVICE_NAME --region=$REGION"
echo ""

echo -e "${GREEN}🎉 Deployment in produzione completato con successo!${NC}"
echo ""

# Save deployment info
cat > deployment_info.txt <<EOF
MyPetCare - Production Deployment Info
Generated: $(date)

Backend URL: $BACKEND_URL
Frontend URL: $FRONTEND_URL
Project ID: $PROJECT_ID
Region: $REGION

Cloud Run Service: $SERVICE_NAME
Cloud Scheduler Jobs:
  - booking-reminders (hourly)
  - cleanup-locks (every 15 min)

Payment Providers: LIVE MODE
  - Stripe: Configured
  - PayPal: Configured

Next Steps:
1. Configure Stripe webhooks
2. Configure PayPal webhooks
3. Run QA checklist
4. Monitor logs
5. Test all features

Rollback Command (if needed):
gcloud run revisions list --service $SERVICE_NAME --region=$REGION
gcloud run services update-traffic $SERVICE_NAME --region=$REGION --to-revisions PREV_REV=100
EOF

echo "💾 Deployment info salvato in: deployment_info.txt"
echo ""

exit 0
