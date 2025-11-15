#!/bin/bash
# deploy-cloudrun-simple.sh
# Script bash semplificato per deployment My Pet Care backend su Cloud Run

set -e  # Exit on error

PROJECT_ID="pet-care-9790d"
SERVICE_NAME="pet-care-api"
REGION="europe-west1"
IMAGE_NAME="gcr.io/$PROJECT_ID/$SERVICE_NAME"

echo "========================================"
echo "🐾 My Pet Care Backend Deployment"
echo "========================================"
echo ""

# Verifica gcloud
echo "🔍 Verificando gcloud CLI..."
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI non trovato!"
    echo "📥 Scarica da: https://cloud.google.com/sdk/docs/install"
    exit 1
fi
echo "✅ gcloud CLI trovato"
echo ""

# Configura progetto
echo "🔧 Configurando progetto..."
gcloud config set project $PROJECT_ID
echo "✅ Progetto configurato: $PROJECT_ID"
echo ""

# Build immagine
echo "🏗️  Building Docker image con Cloud Build..."
echo "   Immagine: $IMAGE_NAME"
echo "   Tempo stimato: 3-5 minuti"
echo ""
gcloud builds submit --tag $IMAGE_NAME
echo ""
echo "✅ Build completato!"
echo ""

# Deploy su Cloud Run
echo "🚀 Deploying su Cloud Run..."
echo "   Servizio: $SERVICE_NAME"
echo "   Region: $REGION"
echo ""
gcloud run deploy $SERVICE_NAME \
    --image $IMAGE_NAME \
    --region $REGION \
    --platform managed \
    --allow-unauthenticated

echo ""
echo "✅ Deploy completato!"
echo ""

# Ottieni URL
echo "🔗 Ottenendo URL servizio..."
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
    --region $REGION \
    --format="value(status.url)")

echo ""
echo "========================================"
echo "✨ DEPLOYMENT COMPLETATO!"
echo "========================================"
echo ""
echo "📋 Informazioni servizio:"
echo "   Nome: $SERVICE_NAME"
echo "   Region: $REGION"
echo "   URL: $SERVICE_URL"
echo ""
echo "🔧 Prossimi passi:"
echo "   1. Configura variabili d'ambiente in Cloud Run Console"
echo "   2. Aggiorna lib/config.dart in Flutter con il nuovo URL"
echo "   3. Testa health: curl $SERVICE_URL/health"
echo ""
echo "📚 Documentazione: CLOUD_RUN_DEPLOYMENT_GUIDE.md"
echo ""
