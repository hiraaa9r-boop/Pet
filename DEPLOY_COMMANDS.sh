#!/bin/bash
# Deploy Commands per PET-CARE-2
# Data: 15 Novembre 2024

set -e

echo "🚀 Deploy Script per My Pet Care"
echo "================================="
echo ""

# Configurazione
PROJECT_ID="pet-care-9790d"
SERVICE_NAME="pet-care-api"
REGION="europe-west1"
IMAGE="gcr.io/$PROJECT_ID/$SERVICE_NAME"

echo "📦 Configurazione:"
echo "   Project ID: $PROJECT_ID"
echo "   Service Name: $SERVICE_NAME"
echo "   Region: $REGION"
echo "   Image: $IMAGE"
echo ""

# ==========================================
# BACKEND DEPLOY
# ==========================================

echo "🔨 STEP 1: Build Docker Image su Cloud Build"
echo "==========================================="
cd backend

gcloud builds submit --tag $IMAGE

echo ""
echo "✅ Docker image buildato con successo!"
echo ""

# ==========================================
# DEPLOY SU CLOUD RUN
# ==========================================

echo "🚀 STEP 2: Deploy su Cloud Run"
echo "==============================="

gcloud run deploy $SERVICE_NAME \
  --image $IMAGE \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --memory 512Mi \
  --timeout 60s \
  --max-instances 10 \
  --set-env-vars "NODE_ENV=production,FIREBASE_PROJECT_ID=pet-care-9790d,PORT=8080"

echo ""
echo "✅ Backend deployed su Cloud Run!"
echo ""

# ==========================================
# GET SERVICE URL
# ==========================================

echo "🔗 STEP 3: Recupera URL del servizio"
echo "===================================="

SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
  --region $REGION \
  --format 'value(status.url)')

echo ""
echo "✅ Service URL: $SERVICE_URL"
echo ""

# ==========================================
# HEALTH CHECK
# ==========================================

echo "🏥 STEP 4: Health Check"
echo "======================"

echo "Attendo 10 secondi per l'avvio del servizio..."
sleep 10

curl -s $SERVICE_URL/health | jq '.'

echo ""
echo "================================="
echo "✅ DEPLOY BACKEND COMPLETATO!"
echo "================================="
echo ""
echo "📋 Prossimi Step:"
echo ""
echo "1️⃣ Configura variabili d'ambiente:"
echo "   Vedi: backend/docs/CLOUD_RUN_ENV_VARS.md"
echo ""
echo "2️⃣ Aggiorna Flutter config con Service URL:"
echo "   Modifica: lib/config.dart"
echo "   backendBaseUrl = '$SERVICE_URL'"
echo ""
echo "3️⃣ Deploy Frontend Flutter:"
echo "   flutter build web --release"
echo "   firebase deploy --only hosting"
echo ""
echo "🔗 Service URL: $SERVICE_URL"
echo ""
