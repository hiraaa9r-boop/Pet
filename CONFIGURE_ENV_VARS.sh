#!/bin/bash
# Configurazione Variabili d'Ambiente Cloud Run
# Data: 15 Novembre 2024
# Progetto: pet-care-9790d

set -e

SERVICE_NAME="pet-care-api"
REGION="europe-west1"

echo "🔐 Configurazione Variabili d'Ambiente Cloud Run"
echo "================================================"
echo ""

# ==========================================
# ISTRUZIONI
# ==========================================

echo "📋 ISTRUZIONI:"
echo ""
echo "Questo script ti guiderà nella configurazione delle variabili d'ambiente."
echo "Per ogni variabile, dovrai fornire il valore corretto."
echo ""
echo "⚠️  IMPORTANTE:"
echo "   - Firebase Admin SDK: Usa il file /opt/flutter/firebase-admin-sdk.json"
echo "   - Stripe Keys: Da Stripe Dashboard → API Keys"
echo "   - PayPal Keys: Da PayPal Developer Dashboard"
echo ""
echo "📖 Documentazione completa: backend/docs/CLOUD_RUN_ENV_VARS.md"
echo ""

read -p "Premi ENTER per continuare o CTRL+C per uscire..."

# ==========================================
# FIREBASE CONFIGURATION
# ==========================================

echo ""
echo "🔥 FIREBASE CONFIGURATION"
echo "========================="

read -p "Firebase Project ID [pet-care-9790d]: " FIREBASE_PROJECT_ID
FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID:-pet-care-9790d}

read -p "Firebase Client Email: " FIREBASE_CLIENT_EMAIL

echo ""
echo "⚠️  Firebase Private Key:"
echo "   Copia il valore del campo 'private_key' dal file firebase-admin-sdk.json"
echo "   IMPORTANTE: Mantieni gli \\n per i newline"
read -p "Firebase Private Key: " FIREBASE_PRIVATE_KEY

# ==========================================
# STRIPE CONFIGURATION
# ==========================================

echo ""
echo "💳 STRIPE CONFIGURATION"
echo "======================"

read -p "Stripe Publishable Key (pk_live_...): " STRIPE_PUBLISHABLE_KEY
read -p "Stripe Secret Key (sk_live_...): " STRIPE_SECRET_KEY
read -p "Stripe Webhook Secret (whsec_...): " STRIPE_WEBHOOK_SECRET

# ==========================================
# PAYPAL CONFIGURATION
# ==========================================

echo ""
echo "💰 PAYPAL CONFIGURATION"
echo "======================"

read -p "PayPal Client ID: " PAYPAL_CLIENT_ID
read -p "PayPal Client Secret: " PAYPAL_CLIENT_SECRET
read -p "PayPal Webhook ID: " PAYPAL_WEBHOOK_ID
read -p "PayPal Mode [live]: " PAYPAL_MODE
PAYPAL_MODE=${PAYPAL_MODE:-live}

# ==========================================
# BACKEND/FRONTEND URLs
# ==========================================

echo ""
echo "🔗 URLs CONFIGURATION"
echo "===================="

# Get current service URL
CURRENT_URL=$(gcloud run services describe $SERVICE_NAME \
  --region $REGION \
  --format 'value(status.url)' 2>/dev/null || echo "")

if [ -n "$CURRENT_URL" ]; then
  echo "Backend URL rilevato: $CURRENT_URL"
  read -p "Backend Base URL [$CURRENT_URL]: " BACKEND_BASE_URL
  BACKEND_BASE_URL=${BACKEND_BASE_URL:-$CURRENT_URL}
else
  read -p "Backend Base URL: " BACKEND_BASE_URL
fi

read -p "Frontend Base URL [https://pet-care-9790d.web.app]: " FRONTEND_BASE_URL
FRONTEND_BASE_URL=${FRONTEND_BASE_URL:-https://pet-care-9790d.web.app}

# ==========================================
# CORS CONFIGURATION
# ==========================================

echo ""
echo "🛡️  CORS CONFIGURATION"
echo "===================="

DEFAULT_CORS="https://pet-care-9790d.web.app,https://pet-care-9790d.firebaseapp.com"
read -p "CORS Allowed Origins [$DEFAULT_CORS]: " CORS_ALLOWED_ORIGINS
CORS_ALLOWED_ORIGINS=${CORS_ALLOWED_ORIGINS:-$DEFAULT_CORS}

# ==========================================
# APPLY CONFIGURATION
# ==========================================

echo ""
echo "📝 RIEPILOGO CONFIGURAZIONE"
echo "============================"
echo "Firebase Project ID: $FIREBASE_PROJECT_ID"
echo "Firebase Client Email: $FIREBASE_CLIENT_EMAIL"
echo "Stripe Publishable Key: ${STRIPE_PUBLISHABLE_KEY:0:20}..."
echo "Stripe Secret Key: ${STRIPE_SECRET_KEY:0:15}..."
echo "PayPal Mode: $PAYPAL_MODE"
echo "Backend URL: $BACKEND_BASE_URL"
echo "Frontend URL: $FRONTEND_BASE_URL"
echo "CORS Origins: $CORS_ALLOWED_ORIGINS"
echo ""

read -p "Confermi e applichi questa configurazione? [y/N]: " CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
  echo "❌ Configurazione annullata."
  exit 1
fi

echo ""
echo "🚀 Applicazione configurazione a Cloud Run..."
echo ""

# Apply all env vars
gcloud run services update $SERVICE_NAME \
  --region $REGION \
  --set-env-vars "\
NODE_ENV=production,\
PORT=8080,\
FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID,\
FIREBASE_CLIENT_EMAIL=$FIREBASE_CLIENT_EMAIL,\
FIREBASE_PRIVATE_KEY=$FIREBASE_PRIVATE_KEY,\
STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY,\
STRIPE_SECRET_KEY=$STRIPE_SECRET_KEY,\
STRIPE_WEBHOOK_SECRET=$STRIPE_WEBHOOK_SECRET,\
PAYPAL_CLIENT_ID=$PAYPAL_CLIENT_ID,\
PAYPAL_CLIENT_SECRET=$PAYPAL_CLIENT_SECRET,\
PAYPAL_WEBHOOK_ID=$PAYPAL_WEBHOOK_ID,\
PAYPAL_MODE=$PAYPAL_MODE,\
BACKEND_BASE_URL=$BACKEND_BASE_URL,\
FRONTEND_BASE_URL=$FRONTEND_BASE_URL,\
CORS_ALLOWED_ORIGINS=$CORS_ALLOWED_ORIGINS,\
LOG_LEVEL=info"

echo ""
echo "✅ Configurazione applicata con successo!"
echo ""
echo "🏥 Test Health Check..."
sleep 5
curl -s $BACKEND_BASE_URL/health | jq '.'

echo ""
echo "================================="
echo "✅ CONFIGURAZIONE COMPLETATA!"
echo "================================="
