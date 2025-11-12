# ⚡ Quick Commands Reference - MyPetCare

Reference rapido di tutti i comandi più usati per deployment, testing e manutenzione.

---

## 🚀 Deployment

### Setup Locale (Prima Volta)
```bash
cd backend
./deployment/setup-local.sh
npm run dev
```

### Deployment Production Completo
```bash
# End-to-end deployment (tutto automatico)
./deploy_full_mypetcare.sh

# Solo backend Cloud Run
cd backend
./deployment/deploy-cloud-run.sh
```

### Update Environment Variables
```bash
cd backend
./deployment/update-cloud-run-env.sh

# O manualmente
gcloud run services update mypetcare-backend \
  --region europe-west1 \
  --set-env-vars KEY1=value1,KEY2=value2
```

---

## 🧪 Testing

### Health Check
```bash
# Locale
curl http://localhost:8080/health

# Production
curl https://YOUR-CLOUD-RUN-URL/health
```

### Diagnostica Firestore/Storage
```bash
URL="https://YOUR-CLOUD-RUN-URL"

# Firestore test
curl "$URL/test/db"

# Storage test
curl "$URL/test/storage"

# All tests
curl "$URL/test/all"
```

### Admin API (richiede auth)
```bash
TOKEN="your-firebase-admin-id-token"
URL="https://YOUR-CLOUD-RUN-URL"

# Stats
curl -H "Authorization: Bearer $TOKEN" "$URL/admin/stats"

# Refund
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"amountCents":499}' \
  "$URL/admin/refund/PAYMENT_ID"
```

### Postman
```bash
# 1. Importa collection
tests/postman_admin_collection.json

# 2. Configura variables
baseUrl = https://YOUR-CLOUD-RUN-URL
adminToken = YOUR_FIREBASE_ID_TOKEN
paymentId = FIRESTORE_PAYMENT_DOC_ID

# 3. Run Collection
```

---

## 🔥 Firebase

### Firestore Indexes
```bash
# Deploy indexes
firebase deploy --only firestore:indexes --project pet-care-9790d

# View indexes
firebase firestore:indexes --project pet-care-9790d
```

### Firestore Security Rules
```bash
# Deploy rules
firebase deploy --only firestore:rules --project pet-care-9790d

# Test rules
firebase emulators:start --only firestore
```

### Seed Database
```bash
cd backend
npx ts-node --esm scripts/seed_admin.ts
```

---

## ☁️ Cloud Run

### Get Service URL
```bash
gcloud run services describe mypetcare-backend \
  --region europe-west1 \
  --format 'value(status.url)'
```

### View Logs
```bash
# Real-time
gcloud run services logs tail mypetcare-backend --region europe-west1

# Last 100
gcloud run services logs read mypetcare-backend --region europe-west1 --limit 100

# Errors only
gcloud run services logs read mypetcare-backend \
  --region europe-west1 \
  --filter="severity>=ERROR" \
  --limit 50
```

### Update Service
```bash
# Update environment variables
gcloud run services update mypetcare-backend \
  --region europe-west1 \
  --set-env-vars NODE_ENV=production,MAINTENANCE_MODE=false

# Update secrets
gcloud run services update mypetcare-backend \
  --region europe-west1 \
  --set-secrets STRIPE_SECRET=STRIPE_SECRET:latest

# Update image
gcloud run deploy mypetcare-backend \
  --image gcr.io/pet-care-9790d/mypetcare-backend:v2 \
  --region europe-west1
```

### Traffic Management
```bash
# Deploy new revision without traffic
gcloud run deploy mypetcare-backend \
  --image gcr.io/pet-care-9790d/mypetcare-backend:v2 \
  --region europe-west1 \
  --no-traffic

# Gradual rollout (10% to new revision)
gcloud run services update-traffic mypetcare-backend \
  --region europe-west1 \
  --to-revisions LATEST=10

# Full rollout to latest
gcloud run services update-traffic mypetcare-backend \
  --region europe-west1 \
  --to-latest
```

### Rollback
```bash
# List revisions
gcloud run revisions list \
  --service mypetcare-backend \
  --region europe-west1

# Rollback to specific revision
gcloud run services update-traffic mypetcare-backend \
  --region europe-west1 \
  --to-revisions REVISION_NAME=100
```

---

## 🔐 Secret Manager

### Create Secret
```bash
gcloud secrets create STRIPE_SECRET --replication-policy="automatic"
```

### Add Secret Version
```bash
# From stdin
echo -n "sk_live_..." | gcloud secrets versions add STRIPE_SECRET --data-file=-

# From file
gcloud secrets versions add STRIPE_SECRET --data-file=stripe_secret.txt
```

### List Secrets
```bash
gcloud secrets list
```

### View Secret Value
```bash
gcloud secrets versions access latest --secret="STRIPE_SECRET"
```

---

## 🐳 Docker

### Build Image
```bash
cd backend
docker build -t gcr.io/pet-care-9790d/mypetcare-backend:v1 .
```

### Push Image
```bash
docker push gcr.io/pet-care-9790d/mypetcare-backend:v1
```

### Build with Cloud Build
```bash
cd backend
gcloud builds submit --tag gcr.io/pet-care-9790d/mypetcare-backend:v1
```

### List Images
```bash
gcloud container images list --repository=gcr.io/pet-care-9790d
```

---

## 📱 Flutter

### Build Web with API_BASE
```bash
flutter build web --release \
  --dart-define=API_BASE=https://YOUR-CLOUD-RUN-URL

# Con renderer specifico
flutter build web --release \
  --dart-define=API_BASE=https://YOUR-CLOUD-RUN-URL \
  --web-renderer canvaskit
```

### Build APK with API_BASE
```bash
flutter build apk --release \
  --dart-define=API_BASE=https://YOUR-CLOUD-RUN-URL
```

### Deploy to Firebase Hosting
```bash
flutter build web --release \
  --dart-define=API_BASE=https://YOUR-CLOUD-RUN-URL

firebase deploy --only hosting --project pet-care-9790d
```

---

## 🔧 Maintenance

### Check Service Status
```bash
gcloud run services describe mypetcare-backend \
  --region europe-west1 \
  --format="value(status.conditions)"
```

### Scale Service
```bash
gcloud run services update mypetcare-backend \
  --region europe-west1 \
  --min-instances 1 \
  --max-instances 20 \
  --concurrency 80
```

### Update Resources
```bash
gcloud run services update mypetcare-backend \
  --region europe-west1 \
  --memory 1Gi \
  --cpu 2
```

### Enable/Disable Maintenance Mode
```bash
# Enable
gcloud run services update mypetcare-backend \
  --region europe-west1 \
  --set-env-vars MAINTENANCE_MODE=true

# Disable
gcloud run services update mypetcare-backend \
  --region europe-west1 \
  --set-env-vars MAINTENANCE_MODE=false
```

---

## 📊 Monitoring

### Cloud Run Metrics
```bash
# View metrics in browser
gcloud run services describe mypetcare-backend \
  --region europe-west1 \
  --format="value(metadata.selfLink)"
# Then append /metrics to URL
```

### Create Alert Policy
```bash
# High error rate alert
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High Error Rate" \
  --condition-display-name="Error rate > 5%" \
  --condition-filter='resource.type="cloud_run_revision" AND metric.type="run.googleapis.com/request_count" AND metric.labels.response_code_class="5xx"'
```

### View Cost
```bash
# Open billing dashboard
gcloud billing accounts list

# View current project costs
gcloud billing projects describe pet-care-9790d
```

---

## 🔑 Environment Variables Cheat Sheet

### Required Variables
```bash
# Backend (.env local)
NODE_ENV=development
PORT=8080
GOOGLE_APPLICATION_CREDENTIALS=./keys/firebase-key.json
FIREBASE_STORAGE_BUCKET=pet-care-9790d.appspot.com

# Stripe
STRIPE_SECRET=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# PayPal
PAYPAL_CLIENT_ID=...
PAYPAL_CLIENT_SECRET=...
PAYPAL_BASE=https://api-m.sandbox.paypal.com

# Frontend
FRONT_URL=http://localhost:5060

# Feature Flags
MAINTENANCE_MODE=false
```

### Cloud Run Update All
```bash
gcloud run services update mypetcare-backend \
  --region europe-west1 \
  --set-env-vars "\
NODE_ENV=production,\
FIREBASE_STORAGE_BUCKET=pet-care-9790d.appspot.com,\
PAYPAL_BASE=https://api-m.paypal.com,\
FRONT_URL=https://mypetcare.web.app,\
MAINTENANCE_MODE=false"
```

---

## 📞 Quick Links

### Firebase Console
- Project: https://console.firebase.google.com/project/pet-care-9790d
- Firestore: https://console.firebase.google.com/project/pet-care-9790d/firestore
- Storage: https://console.firebase.google.com/project/pet-care-9790d/storage
- Authentication: https://console.firebase.google.com/project/pet-care-9790d/authentication

### Google Cloud Console
- Cloud Run: https://console.cloud.google.com/run?project=pet-care-9790d
- IAM: https://console.cloud.google.com/iam-admin/iam?project=pet-care-9790d
- Logs: https://console.cloud.google.com/logs?project=pet-care-9790d
- Billing: https://console.cloud.google.com/billing/linkedaccount?project=pet-care-9790d

### Stripe Dashboard
- Dashboard: https://dashboard.stripe.com/
- Webhooks: https://dashboard.stripe.com/webhooks
- Products: https://dashboard.stripe.com/products
- Test Mode: https://dashboard.stripe.com/test/dashboard

### PayPal Developer
- Dashboard: https://developer.paypal.com/dashboard
- My Apps: https://developer.paypal.com/developer/applications
- Webhooks: https://developer.paypal.com/developer/notifications

---

## 🆘 Emergency Commands

### Service Down - Quick Restart
```bash
# Force new revision deployment
gcloud run deploy mypetcare-backend \
  --image gcr.io/pet-care-9790d/mypetcare-backend:latest \
  --region europe-west1 \
  --revision-suffix=$(date +%s)
```

### High Error Rate - Immediate Rollback
```bash
# Get previous working revision
gcloud run revisions list \
  --service mypetcare-backend \
  --region europe-west1 \
  --limit 5

# Rollback to previous revision
gcloud run services update-traffic mypetcare-backend \
  --region europe-west1 \
  --to-revisions PREVIOUS_REVISION_NAME=100
```

### Database Issue - Enable Maintenance Mode
```bash
gcloud run services update mypetcare-backend \
  --region europe-west1 \
  --set-env-vars MAINTENANCE_MODE=true

# Check all requests now return 503
curl https://YOUR-CLOUD-RUN-URL/health
```

### Out of Memory - Increase Resources
```bash
gcloud run services update mypetcare-backend \
  --region europe-west1 \
  --memory 2Gi
```

---

**Versione**: 1.0.0  
**Ultimo aggiornamento**: 2025-01-15  
**Per guide complete**: Vedi `/backend/deployment/README.md`
