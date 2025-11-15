#!/bin/bash

# Deploy MyPetCare Backend to Google Cloud Run
# Usage: ./deploy-cloudrun.sh

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 MyPetCare Backend - Cloud Run Deploy"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Configuration
PROJECT_ID="pet-care-9790d"
SERVICE_NAME="mypetcare-backend"
REGION="europe-west1"
MIN_INSTANCES=0
MAX_INSTANCES=10
MEMORY="512Mi"
CPU=1
TIMEOUT=300

echo "📋 Configuration:"
echo "   Project ID: $PROJECT_ID"
echo "   Service: $SERVICE_NAME"
echo "   Region: $REGION"
echo "   Memory: $MEMORY"
echo "   CPU: $CPU"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ ERROR: gcloud CLI not found"
    echo "   Install: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

echo "✅ gcloud CLI found"

# Check if logged in
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo "❌ ERROR: Not logged in to gcloud"
    echo "   Run: gcloud auth login"
    exit 1
fi

ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
echo "✅ Logged in as: $ACTIVE_ACCOUNT"

# Set project
echo ""
echo "🔧 Setting project..."
gcloud config set project $PROJECT_ID

# Enable required APIs
echo ""
echo "🔧 Enabling required APIs..."
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Check environment variables
echo ""
echo "⚠️  ENVIRONMENT VARIABLES CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Before deploying, ensure you have these environment variables ready:"
echo ""
echo "  ✓ BACKEND_BASE_URL         (https://api.mypetcareapp.org)"
echo "  ✓ WEB_BASE_URL             (https://app.mypetcareapp.org)"
echo "  ✓ STRIPE_SECRET_KEY        (sk_live_...)"
echo "  ✓ STRIPE_WEBHOOK_SECRET    (whsec_...)"
echo "  ✓ PAYPAL_CLIENT_ID         (..."
echo "  ✓ PAYPAL_SECRET            (...)"
echo "  ✓ PAYPAL_WEBHOOK_ID        (...)"
echo "  ✓ PAYPAL_API               (https://api-m.paypal.com)"
echo ""
echo "You will configure these via Cloud Run Console after deployment."
echo ""
read -p "Press Enter to continue with deployment..."

# Deploy to Cloud Run
echo ""
echo "🚀 Deploying to Cloud Run..."
echo "   This will take 3-5 minutes..."
echo ""

gcloud run deploy $SERVICE_NAME \
  --source . \
  --region=$REGION \
  --platform=managed \
  --allow-unauthenticated \
  --min-instances=$MIN_INSTANCES \
  --max-instances=$MAX_INSTANCES \
  --memory=$MEMORY \
  --cpu=$CPU \
  --timeout=${TIMEOUT}s \
  --set-env-vars="NODE_ENV=production,PORT=8080"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ DEPLOYMENT SUCCESSFUL!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)')

echo "🔗 Service URL: $SERVICE_URL"
echo ""
echo "📋 NEXT STEPS:"
echo ""
echo "1. Configure Environment Variables:"
echo "   → Go to: https://console.cloud.google.com/run/detail/$REGION/$SERVICE_NAME/variables?project=$PROJECT_ID"
echo "   → Add all required environment variables (see .env.example)"
echo ""
echo "2. Test Health Endpoint:"
echo "   curl $SERVICE_URL/health"
echo ""
echo "3. Configure Custom Domain (api.mypetcareapp.org):"
echo "   → Go to: https://console.cloud.google.com/run/domains?project=$PROJECT_ID"
echo "   → Click 'Add Mapping'"
echo "   → Select service: $SERVICE_NAME"
echo "   → Domain: api.mypetcareapp.org"
echo ""
echo "4. Update DNS Records (Cloudflare):"
echo "   → CNAME: api.mypetcareapp.org → ghs.googlehosted.com"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
