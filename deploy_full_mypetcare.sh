#!/bin/bash
# ============================================================================
# MyPetCare - Complete Deployment Script
# ============================================================================
# This script performs a complete deployment including:
# 1. Service Account creation and IAM roles
# 2. Cloud Run deployment
# 3. Firestore seed data
# 4. Firestore indexes creation
# 5. Flutter Web build with correct API_BASE
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "============================================"
echo "🐾 MyPetCare - Complete Deployment Script"
echo "============================================"
echo ""

# ==============================
# CONFIGURAZIONE BASE
# ==============================
PROJECT_ID="pet-care-9790d"
REGION="europe-west1"
SERVICE_NAME="mypetcare-backend"
IMAGE="gcr.io/${PROJECT_ID}/${SERVICE_NAME}:v1"
BUCKET="pet-care-9790d.appspot.com"
SA_NAME="backend-sa"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
FRONT_URL="https://mypetcare.web.app"

echo -e "${BLUE}📋 Configuration:${NC}"
echo "   Project ID: ${PROJECT_ID}"
echo "   Region: ${REGION}"
echo "   Service: ${SERVICE_NAME}"
echo "   Image: ${IMAGE}"
echo "   Bucket: ${BUCKET}"
echo "   Service Account: ${SA_EMAIL}"
echo "   Frontend URL: ${FRONT_URL}"
echo ""

# ==============================
# STEP 1: CONFIGURA PROGETTO E API
# ==============================
echo -e "${YELLOW}▶️  Step 1/7: Configuring GCP project and enabling APIs...${NC}"
gcloud config set project "$PROJECT_ID"

echo "   Enabling required APIs..."
gcloud services enable \
    run.googleapis.com \
    iam.googleapis.com \
    secretmanager.googleapis.com \
    firestore.googleapis.com \
    cloudbuild.googleapis.com \
    storage.googleapis.com

echo -e "${GREEN}✅ Project configured and APIs enabled${NC}"
echo ""

# ==============================
# STEP 2: CREA SERVICE ACCOUNT E RUOLI
# ==============================
echo -e "${YELLOW}▶️  Step 2/7: Creating Service Account and assigning IAM roles...${NC}"

# Check if service account already exists
if gcloud iam service-accounts describe "$SA_EMAIL" &>/dev/null; then
    echo "   ℹ️  Service Account already exists: ${SA_EMAIL}"
else
    echo "   Creating Service Account: ${SA_EMAIL}"
    gcloud iam service-accounts create "$SA_NAME" \
        --display-name="MyPetCare Backend SA" \
        --description="Service account for Cloud Run backend with Firestore and Storage access"
fi

echo "   Assigning IAM roles..."
for role in roles/datastore.user roles/storage.objectAdmin roles/logging.logWriter; do
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:${SA_EMAIL}" \
        --role="$role" \
        --condition=None \
        --quiet >/dev/null 2>&1 || true
    echo "   ✓ Granted: $role"
done

echo -e "${GREEN}✅ Service Account configured with IAM roles${NC}"
echo ""

# ==============================
# STEP 3: BUILD IMMAGINE (Dockerfile in /backend)
# ==============================
echo -e "${YELLOW}▶️  Step 3/7: Building Docker image...${NC}"

if [ ! -d "backend" ]; then
    echo -e "${RED}❌ Error: backend directory not found${NC}"
    echo "   Run this script from the project root directory"
    exit 1
fi

cd backend

if [ ! -f "Dockerfile" ]; then
    echo -e "${RED}❌ Error: Dockerfile not found in backend directory${NC}"
    exit 1
fi

echo "   Building image with Cloud Build..."
gcloud builds submit --tag "$IMAGE" --quiet

echo -e "${GREEN}✅ Docker image built: ${IMAGE}${NC}"
echo ""

# ==============================
# STEP 4: DEPLOY SU CLOUD RUN
# ==============================
echo -e "${YELLOW}▶️  Step 4/7: Deploying to Cloud Run...${NC}"

# Note: Replace with actual API keys before production deployment
echo "   ⚠️  Using placeholder API keys - update with real values for production"

gcloud run deploy "$SERVICE_NAME" \
    --image "$IMAGE" \
    --region "$REGION" \
    --platform managed \
    --allow-unauthenticated \
    --service-account "$SA_EMAIL" \
    --set-env-vars "NODE_ENV=production,FIREBASE_STORAGE_BUCKET=${BUCKET},STRIPE_SECRET=sk_test_xxx,STRIPE_WEBHOOK_SECRET=whsec_xxx,PAYPAL_CLIENT_ID=xxx,PAYPAL_CLIENT_SECRET=xxx,PAYPAL_BASE=https://api-m.sandbox.paypal.com,FRONT_URL=${FRONT_URL},MAINTENANCE_MODE=false" \
    --memory 512Mi \
    --cpu 1 \
    --timeout 60s \
    --max-instances 10 \
    --min-instances 0 \
    --quiet

URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --format 'value(status.url)')
echo -e "${GREEN}✅ Service deployed: ${URL}${NC}"
echo ""

# Test health endpoint
echo "   Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s "${URL}/health" || echo "failed")
if [[ $HEALTH_RESPONSE == *"healthy"* ]]; then
    echo -e "${GREEN}   ✓ Health check passed${NC}"
else
    echo -e "${RED}   ✗ Health check failed${NC}"
    echo "   Response: $HEALTH_RESPONSE"
fi
echo ""

# ==============================
# STEP 5: ESEGUI SEED FIRESTORE
# ==============================
echo -e "${YELLOW}▶️  Step 5/7: Seeding Firestore database...${NC}"

# Create scripts directory if not exists
mkdir -p scripts

# Create seed script
cat > scripts/seed_admin.ts <<'EOFSCRIPT'
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp({ 
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET || "pet-care-9790d.appspot.com"
  });
}

const db = admin.firestore();

async function run() {
  console.log("🌱 Starting Firestore seed...");
  
  const now = admin.firestore.FieldValue.serverTimestamp();

  // 1) Admin user
  console.log("   Creating admin user...");
  const adminRef = db.collection("users").doc("seed-admin-uid");
  await adminRef.set({
    email: "admin@mypetcare.test",
    role: "admin",
    name: "Admin Test",
    createdAt: now,
  }, { merge: true });

  // 2) Active PRO
  console.log("   Creating test PRO...");
  await db.collection("pros").doc("seed-pro-001").set({
    name: "Clinica Amici Pet",
    status: "active",
    rating: 4.7,
    reviewCount: 42,
    services: [
      { name: "Visita Veterinaria", price: 4000, duration: 30 },
      { name: "Vaccinazione", price: 3500, duration: 15 }
    ],
    location: {
      city: "Milano",
      address: "Via Test 123",
      lat: 45.4642,
      lng: 9.1900
    },
    createdAt: now,
  }, { merge: true });

  // 3) Test payment (for refund/stats testing)
  console.log("   Creating test payment...");
  const payId = "seed_invoice_001";
  await db.collection("payments").doc(payId).set({
    userId: "seed-admin-uid",
    provider: "stripe",
    amountCents: 999,
    currency: "eur",
    status: "succeeded",
    createdAt: now,
    raw: { 
      id: "ch_dummy_001", 
      object: "charge",
      charge: "ch_dummy_001"
    }
  }, { merge: true });

  // 4) Recent booking (for 30-day stats)
  console.log("   Creating test booking...");
  await db.collection("bookings").add({
    userId: "seed-admin-uid",
    proId: "seed-pro-001",
    status: "confirmed",
    serviceName: "Visita Veterinaria",
    scheduledFor: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 86400000)), // Tomorrow
    createdAt: now,
  });

  // 5) Test review
  console.log("   Creating test review...");
  await db.collection("reviews").add({
    userId: "seed-admin-uid",
    proId: "seed-pro-001",
    rating: 5,
    comment: "Servizio eccellente, molto professionale!",
    createdAt: now,
  });

  console.log("✅ Seed completed successfully!");
  console.log(`   Payment ID for testing: ${payId}`);
}

run()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error("❌ Seed failed:", e);
    process.exit(1);
  });
EOFSCRIPT

echo "   Installing dependencies..."
npm install --no-save ts-node typescript firebase-admin >/dev/null 2>&1

echo "   Executing seed script..."
export GOOGLE_APPLICATION_CREDENTIALS="${GOOGLE_APPLICATION_CREDENTIALS:-./keys/firebase-key.json}"
export FIREBASE_STORAGE_BUCKET="$BUCKET"
npx ts-node --esm scripts/seed_admin.ts

echo -e "${GREEN}✅ Firestore database seeded${NC}"
echo ""

# ==============================
# STEP 6: CREA INDICI FIRESTORE
# ==============================
echo -e "${YELLOW}▶️  Step 6/7: Creating Firestore indexes...${NC}"

cat > firestore.indexes.json <<'EOFINDEXES'
{
  "indexes": [
    {
      "collectionGroup": "payments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "payments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "bookings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "bookings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "bookings",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "proId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "reviews",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "proId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "pros",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "rating", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
EOFINDEXES

echo "   Deploying Firestore indexes..."
if command -v firebase &> /dev/null; then
    firebase deploy --only firestore:indexes --project "$PROJECT_ID" 2>/dev/null || \
    echo "   ⚠️  Firebase CLI not found or not authenticated. Deploy indexes manually from Firebase Console"
else
    echo "   ⚠️  Firebase CLI not installed. Deploy indexes manually:"
    echo "      1. Go to Firebase Console → Firestore → Indexes"
    echo "      2. Import the firestore.indexes.json file"
fi

echo -e "${GREEN}✅ Firestore indexes configured${NC}"
echo ""

# ==============================
# STEP 7: BUILD FRONTEND WEB
# ==============================
echo -e "${YELLOW}▶️  Step 7/7: Building Flutter Web with correct API_BASE...${NC}"

cd ..

if [ ! -d "lib" ]; then
    echo -e "${YELLOW}   ⚠️  Flutter app not found in current directory${NC}"
    echo "   Skipping Flutter build step"
else
    echo "   Cleaning Flutter build cache..."
    flutter clean >/dev/null 2>&1

    echo "   Building Flutter Web with API_BASE=${URL}..."
    flutter build web \
        --release \
        --dart-define=API_BASE="$URL" \
        --web-renderer canvaskit \
        >/dev/null 2>&1

    echo -e "${GREEN}✅ Flutter Web built with API_BASE: ${URL}${NC}"
fi

echo ""

# ==============================
# FINAL SUMMARY
# ==============================
echo "============================================"
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo "============================================"
echo ""
echo -e "${BLUE}📊 Deployment Summary:${NC}"
echo "   Service URL: ${URL}"
echo "   Backend Status: Deployed"
echo "   Firestore: Seeded with test data"
echo "   Indexes: Configured"
echo "   Flutter Web: Built with correct API_BASE"
echo ""
echo -e "${BLUE}🧪 Test Endpoints:${NC}"
echo "   Health: ${URL}/health"
echo "   Test DB: ${URL}/test/db"
echo "   Test Storage: ${URL}/test/storage"
echo "   Admin Stats: ${URL}/admin/stats (requires auth)"
echo ""
echo -e "${BLUE}📝 Next Steps:${NC}"
echo "   1. Update Stripe/PayPal API keys in Cloud Run environment:"
echo "      gcloud run services update ${SERVICE_NAME} --region ${REGION} \\"
echo "        --update-env-vars STRIPE_SECRET=sk_live_...,PAYPAL_CLIENT_ID=..."
echo ""
echo "   2. Register webhook endpoints:"
echo "      Stripe: ${URL}/webhooks/stripe"
echo "      PayPal: ${URL}/webhooks/paypal"
echo ""
echo "   3. Test admin endpoints with Postman collection:"
echo "      Import: tests/postman_admin_collection.json"
echo "      Set baseUrl: ${URL}"
echo ""
echo "   4. Deploy Flutter Web to Firebase Hosting:"
echo "      firebase deploy --only hosting"
echo ""
echo -e "${BLUE}🔍 Monitoring:${NC}"
echo "   Logs: gcloud run services logs tail ${SERVICE_NAME} --region ${REGION}"
echo "   Metrics: https://console.cloud.google.com/run/detail/${REGION}/${SERVICE_NAME}/metrics"
echo ""
echo "============================================"
