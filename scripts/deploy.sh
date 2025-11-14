#!/bin/bash
set -euo pipefail

# 🚀 MyPetCare - Production Deployment Script v2
# Features: Secret Manager, Enhanced Validation, Rollback Info

# =========================
# Colori per output
# =========================
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
echo "🚀 MyPetCare - Production Deployment v2"
echo "   Secret Manager + Enhanced Validation"
echo "=========================================="
echo ""

# =========================
# CONFIG PROGETTO
# =========================
PROJECT_ID="${GCP_PROJECT_ID:-pet-care-9790d}"
REGION="${GCP_REGION:-europe-west1}"
SERVICE_NAME="mypetcare-backend"
IMAGE="gcr.io/${PROJECT_ID}/${SERVICE_NAME}:prod-$(date +%Y%m%d-%H%M%S)"
BUCKET="${PROJECT_ID}.appspot.com"
SA_EMAIL="backend-sa@${PROJECT_ID}.iam.gserviceaccount.com"
FRONT_URL="https://mypetcare.web.app"

# =========================
# PRE-FLIGHT CHECKS
# =========================
echo "🔍 Pre-flight checks..."
echo ""

# Check required tools
REQUIRED_TOOLS=("gcloud" "firebase" "flutter" "jq" "openssl")
for tool in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v "$tool" &> /dev/null; then
    echo -e "${RED}❌ ERRORE: $tool non trovato${NC}"
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

ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
echo -e "${GREEN}✅ GCP authenticated as: $ACTIVE_ACCOUNT${NC}"

# Set project
gcloud config set project "$PROJECT_ID" >/dev/null 2>&1
echo -e "${GREEN}✅ GCP project set: $PROJECT_ID${NC}"

# Check Firebase login
if ! firebase projects:list &> /dev/null; then
  echo -e "${RED}❌ ERRORE: Non autenticato con Firebase${NC}"
  echo "Eseguire: firebase login"
  exit 1
fi

echo -e "${GREEN}✅ Firebase authentication OK${NC}"
echo ""

# =========================
# ENABLE REQUIRED APIS
# =========================
echo "🔧 Verifico API richieste..."
REQUIRED_APIS=(
  "run.googleapis.com"
  "iam.googleapis.com"
  "secretmanager.googleapis.com"
  "cloudbuild.googleapis.com"
  "cloudscheduler.googleapis.com"
  "firestore.googleapis.com"
)

for api in "${REQUIRED_APIS[@]}"; do
  if ! gcloud services list --enabled --filter="name:$api" --format="value(name)" | grep -q "$api"; then
    echo "  ↪️  Enabling $api..."
    gcloud services enable "$api" --quiet
  fi
done

echo -e "${GREEN}✅ Tutte le API necessarie sono abilitate${NC}"
echo ""

# =========================
# COLLECT SECRETS
# =========================
echo "=========================================="
echo "🔐 Configurazione Secrets"
echo "=========================================="
echo ""

echo -e "${YELLOW}Inserisci le credenziali LIVE (input nascosto):${NC}"
echo ""

read -rsp "Stripe Secret Key (sk_live_...): " STRIPE_SECRET
echo ""
if [[ ! "$STRIPE_SECRET" =~ ^sk_live_ ]]; then
  echo -e "${RED}⚠️  WARNING: Stripe key non inizia con 'sk_live_'${NC}"
fi

read -rsp "Stripe Webhook Secret (whsec_...): " STRIPE_WEBHOOK_SECRET
echo ""

read -rsp "PayPal Client ID (LIVE): " PAYPAL_CLIENT_ID
echo ""

read -rsp "PayPal Client Secret (LIVE): " PAYPAL_CLIENT_SECRET
echo ""

echo ""
read -rp "CRON_SECRET (Invio per generarlo): " CRON_SECRET
if [[ -z "${CRON_SECRET:-}" ]]; then
  CRON_SECRET="$(openssl rand -hex 24)"
  echo -e "${CYAN}✨ Generato CRON_SECRET: ${CRON_SECRET}${NC}"
fi

echo ""

# Validate non-empty
if [[ -z "$STRIPE_SECRET" ]] || [[ -z "$PAYPAL_CLIENT_ID" ]]; then
  echo -e "${RED}❌ Credenziali mancanti. Deployment annullato.${NC}"
  exit 1
fi

# =========================
# SECRET MANAGER SETUP
# =========================
echo "=========================================="
echo "🔐 Secret Manager Configuration"
echo "=========================================="
echo ""

upsert_secret () {
  local NAME="$1"
  local VALUE="$2"
  
  if gcloud secrets describe "$NAME" --project="$PROJECT_ID" >/dev/null 2>&1; then
    echo "  ↪️  Aggiornamento secret: $NAME"
    printf "%s" "$VALUE" | gcloud secrets versions add "$NAME" \
      --project="$PROJECT_ID" \
      --data-file=- >/dev/null
  else
    echo "  🆕 Creazione secret: $NAME"
    gcloud secrets create "$NAME" \
      --project="$PROJECT_ID" \
      --replication-policy="automatic" >/dev/null
    printf "%s" "$VALUE" | gcloud secrets versions add "$NAME" \
      --project="$PROJECT_ID" \
      --data-file=- >/dev/null
  fi
  
  # Grant access to service account
  gcloud secrets add-iam-policy-binding "$NAME" \
    --project="$PROJECT_ID" \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/secretmanager.secretAccessor" >/dev/null 2>&1 || true
}

echo "📦 Salvataggio secrets su Secret Manager..."
upsert_secret "STRIPE_SECRET" "$STRIPE_SECRET"
upsert_secret "STRIPE_WEBHOOK_SECRET" "$STRIPE_WEBHOOK_SECRET"
upsert_secret "PAYPAL_CLIENT_ID" "$PAYPAL_CLIENT_ID"
upsert_secret "PAYPAL_CLIENT_SECRET" "$PAYPAL_CLIENT_SECRET"
upsert_secret "CRON_SECRET" "$CRON_SECRET"

echo -e "${GREEN}✅ Tutti i secrets salvati su Secret Manager${NC}"
echo ""

# =========================
# CONFIRM PRODUCTION DEPLOYMENT
# =========================
echo "=========================================="
echo -e "${MAGENTA}⚠️  CONFERMA DEPLOYMENT PRODUZIONE${NC}"
echo "=========================================="
echo ""
echo "Progetto:       $PROJECT_ID"
echo "Region:         $REGION"
echo "Service:        $SERVICE_NAME"
echo "Payment Mode:   🔴 LIVE (Stripe + PayPal produzione)"
echo "Secret Manager: ✅ Attivo"
echo ""
read -rp "Confermi il deployment in PRODUZIONE? (scrivi 'yes'): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo "Deployment annullato"
  exit 0
fi

echo ""

# =========================
# SAVE CURRENT REVISION (for rollback)
# =========================
echo "📸 Salvataggio revisione corrente per rollback..."
PREVIOUS_REVISION=$(gcloud run revisions list \
  --service="$SERVICE_NAME" \
  --region="$REGION" \
  --format="value(metadata.name)" \
  --limit=1 2>/dev/null || echo "none")

if [[ "$PREVIOUS_REVISION" != "none" ]]; then
  echo -e "${CYAN}  📌 Revisione corrente: $PREVIOUS_REVISION${NC}"
else
  echo "  ℹ️  Nessuna revisione precedente trovata (primo deploy)"
fi

echo ""

# =========================
# BUILD BACKEND IMAGE
# =========================
echo "=========================================="
echo "🏗️  Step 1: Backend Build"
echo "=========================================="
echo ""

echo "🔨 Build immagine Docker con Cloud Build..."
cd backend

gcloud builds submit \
  --tag "$IMAGE" \
  --project="$PROJECT_ID" \
  --timeout=10m

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Build fallito${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Immagine built: $IMAGE${NC}"
echo ""

cd ..

# =========================
# DEPLOY CLOUD RUN
# =========================
echo "=========================================="
echo "☁️  Step 2: Cloud Run Deploy (LIVE)"
echo "=========================================="
echo ""

echo "🚀 Deploy backend con Secret Manager..."

gcloud run deploy "$SERVICE_NAME" \
  --image "$IMAGE" \
  --region "$REGION" \
  --platform managed \
  --allow-unauthenticated \
  --service-account "$SA_EMAIL" \
  --set-env-vars "NODE_ENV=production,FIREBASE_STORAGE_BUCKET=${BUCKET},PAYPAL_BASE=https://api-m.paypal.com,FRONT_URL=${FRONT_URL}" \
  --set-secrets "STRIPE_SECRET=STRIPE_SECRET:latest,STRIPE_WEBHOOK_SECRET=STRIPE_WEBHOOK_SECRET:latest,PAYPAL_CLIENT_ID=PAYPAL_CLIENT_ID:latest,PAYPAL_CLIENT_SECRET=PAYPAL_CLIENT_SECRET:latest,CRON_SECRET=CRON_SECRET:latest" \
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
URL=$(gcloud run services describe "$SERVICE_NAME" \
  --region "$REGION" \
  --format 'value(status.url)')

echo -e "${CYAN}🔗 Backend LIVE: $URL${NC}"
echo ""

# =========================
# HEALTH CHECK
# =========================
echo "🏥 Health check backend..."
sleep 5  # Wait for service to be ready

HEALTH_RESPONSE=$(curl -sS "$URL/health" || echo '{"status":"error"}')
HEALTH_STATUS=$(echo "$HEALTH_RESPONSE" | jq -r '.status' 2>/dev/null || echo "error")

if [ "$HEALTH_STATUS" == "healthy" ]; then
  echo -e "${GREEN}✅ Backend health OK${NC}"
  echo "$HEALTH_RESPONSE" | jq . 2>/dev/null || echo "$HEALTH_RESPONSE"
else
  echo -e "${RED}❌ Backend health check fallito${NC}"
  echo "Response: $HEALTH_RESPONSE"
  echo ""
  echo "Controlla logs:"
  echo "  gcloud run logs tail $SERVICE_NAME --region=$REGION"
  exit 1
fi

echo ""

# =========================
# CLOUD SCHEDULER
# =========================
echo "=========================================="
echo "⏰ Step 3: Cloud Scheduler"
echo "=========================================="
echo ""

JOB_NAME="booking-reminders"

if gcloud scheduler jobs describe "$JOB_NAME" --location "$REGION" >/dev/null 2>&1; then
  echo "📝 Aggiornamento job: $JOB_NAME"
  gcloud scheduler jobs update http "$JOB_NAME" \
    --location="$REGION" \
    --schedule="0 * * * *" \
    --uri="${URL}/jobs/send-reminders" \
    --http-method=POST \
    --time-zone="Europe/Rome" \
    --headers="x-cron-key:projects/$PROJECT_ID/secrets/CRON_SECRET/versions/latest" \
    --oidc-service-account-email="$SA_EMAIL" \
    --oidc-token-audience="$URL" >/dev/null
else
  echo "🆕 Creazione job: $JOB_NAME"
  gcloud scheduler jobs create http "$JOB_NAME" \
    --location="$REGION" \
    --schedule="0 * * * *" \
    --uri="${URL}/jobs/send-reminders" \
    --http-method=POST \
    --time-zone="Europe/Rome" \
    --headers="x-cron-key:projects/$PROJECT_ID/secrets/CRON_SECRET/versions/latest" \
    --oidc-service-account-email="$SA_EMAIL" \
    --oidc-token-audience="$URL" >/dev/null
fi

echo -e "${GREEN}✅ Scheduler configurato: $JOB_NAME${NC}"
echo ""

# Test scheduler job
echo "🧪 Test scheduler job..."
TEST_RESPONSE=$(curl -sS -X POST \
  -H "x-cron-key: $CRON_SECRET" \
  "${URL}/jobs/send-reminders" || echo '{"error":"failed"}')

if echo "$TEST_RESPONSE" | jq -e '.ok' >/dev/null 2>&1; then
  echo -e "${GREEN}✅ Scheduler endpoint funzionante${NC}"
else
  echo -e "${YELLOW}⚠️  Scheduler test inconclusivo${NC}"
  echo "Response: $TEST_RESPONSE"
fi

echo ""

# =========================
# FIRESTORE
# =========================
echo "=========================================="
echo "🔥 Step 4: Firestore Deploy"
echo "=========================================="
echo ""

echo "📊 Deploy Firestore indexes..."
firebase deploy --only firestore:indexes --project="$PROJECT_ID" 2>&1 | grep -v "Warning:" || true

echo ""
echo "🔒 Deploy Firestore rules..."
firebase deploy --only firestore:rules --project="$PROJECT_ID"

if [ $? -ne 0 ]; then
  echo -e "${YELLOW}⚠️  Deploy Firestore rules fallito${NC}"
else
  echo -e "${GREEN}✅ Firestore configurato${NC}"
fi

echo ""

# =========================
# FLUTTER WEB BUILD
# =========================
echo "=========================================="
echo "📱 Step 5: Flutter Web Build"
echo "=========================================="
echo ""

echo "🧹 Clean..."
flutter clean >/dev/null

echo "📦 Dependencies..."
flutter pub get >/dev/null

echo "🔨 Build web (API_BASE = $URL)..."
flutter build web \
  --release \
  --dart-define=API_BASE="$URL" \
  --web-renderer canvaskit

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Build Flutter fallito${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Flutter web compilato${NC}"
echo ""

# =========================
# FIREBASE HOSTING
# =========================
echo "=========================================="
echo "🌐 Step 6: Firebase Hosting Deploy"
echo "=========================================="
echo ""

echo "🚀 Deploy hosting..."
firebase deploy --only hosting --project="$PROJECT_ID"

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Deploy hosting fallito${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Frontend deployato: $FRONT_URL${NC}"
echo ""

# =========================
# FINAL HEALTH CHECKS
# =========================
echo "=========================================="
echo "🏥 Final Health Checks"
echo "=========================================="
echo ""

echo "🔍 Test frontend..."
FRONTEND_STATUS=$(curl -sS -o /dev/null -w "%{http_code}" "$FRONT_URL")

if [ "$FRONTEND_STATUS" == "200" ]; then
  echo -e "${GREEN}✅ Frontend accessibile (HTTP $FRONTEND_STATUS)${NC}"
else
  echo -e "${YELLOW}⚠️  Frontend status: HTTP $FRONTEND_STATUS${NC}"
fi

echo ""

# =========================
# DEPLOYMENT SUMMARY
# =========================
echo "=========================================="
echo "✅ GO-LIVE COMPLETATO"
echo "=========================================="
echo ""

echo -e "${CYAN}📊 Riepilogo:${NC}"
echo ""
echo "Backend:        $URL"
echo "Frontend:       $FRONT_URL"
echo "Project:        $PROJECT_ID"
echo "Region:         $REGION"
echo "Payment:        🔴 LIVE MODE"
echo "Secret Manager: ✅ Attivo"
echo ""

if [[ "$PREVIOUS_REVISION" != "none" ]]; then
  echo -e "${MAGENTA}🔄 Rollback Info:${NC}"
  echo ""
  echo "Revisione precedente: $PREVIOUS_REVISION"
  echo ""
  echo "Comando rollback immediato:"
  echo "  gcloud run services update-traffic $SERVICE_NAME \\"
  echo "    --region=$REGION \\"
  echo "    --to-revisions=$PREVIOUS_REVISION=100"
  echo ""
fi

echo -e "${YELLOW}📋 Next Steps:${NC}"
echo ""
echo "1️⃣  Configurare Stripe Webhooks:"
echo "    URL: $URL/webhooks/stripe"
echo "    Events: payment_intent.succeeded, charge.succeeded"
echo ""
echo "2️⃣  Configurare PayPal Webhooks:"
echo "    URL: $URL/webhooks/paypal"
echo "    Dashboard: https://developer.paypal.com/dashboard/webhooks"
echo ""
echo "3️⃣  Test rapidi:"
echo "    curl -sS \"$URL/health\" | jq"
echo ""
echo "4️⃣  QA Checklist:"
echo "    export BACKEND_URL=\"$URL\""
echo "    bash qa_production_checklist.sh"
echo ""
echo "5️⃣  Monitoraggio:"
echo "    gcloud run logs tail $SERVICE_NAME --region=$REGION"
echo ""

# Save deployment info
cat > deployment_info_$(date +%Y%m%d_%H%M%S).txt <<EOF
MyPetCare - Production Deployment
Generated: $(date)

DEPLOYMENT INFO
===============
Backend URL:        $URL
Frontend URL:       $FRONT_URL
Project ID:         $PROJECT_ID
Region:             $REGION
Service Name:       $SERVICE_NAME
Docker Image:       $IMAGE
Service Account:    $SA_EMAIL

PREVIOUS REVISION (Rollback)
=============================
$PREVIOUS_REVISION

ROLLBACK COMMAND
================
gcloud run services update-traffic $SERVICE_NAME \\
  --region=$REGION \\
  --to-revisions=$PREVIOUS_REVISION=100

SECRET MANAGER
==============
✅ STRIPE_SECRET
✅ STRIPE_WEBHOOK_SECRET
✅ PAYPAL_CLIENT_ID
✅ PAYPAL_CLIENT_SECRET
✅ CRON_SECRET

CLOUD SCHEDULER JOBS
====================
- booking-reminders (0 * * * * - hourly)
  URI: $URL/jobs/send-reminders
  Timezone: Europe/Rome

NEXT ACTIONS
============
1. Configure Stripe webhooks ($URL/webhooks/stripe)
2. Configure PayPal webhooks ($URL/webhooks/paypal)
3. Run QA checklist
4. Monitor logs for 24h
5. Test all payment flows

MONITORING
==========
Logs:     gcloud run logs tail $SERVICE_NAME --region=$REGION
Metrics:  gcloud run services describe $SERVICE_NAME --region=$REGION
Revisions: gcloud run revisions list --service=$SERVICE_NAME --region=$REGION
EOF

DEPLOY_INFO_FILE="deployment_info_$(date +%Y%m%d_%H%M%S).txt"
echo -e "${GREEN}💾 Deployment info salvato: $DEPLOY_INFO_FILE${NC}"
echo ""

echo -e "${GREEN}🎉 Production deployment completato con successo!${NC}"
echo ""

exit 0
