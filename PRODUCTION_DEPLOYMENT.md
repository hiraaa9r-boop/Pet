## 🚀 MyPetCare - Production Deployment Guide

Guida completa per deployment in produzione con script automatizzati, QA checklist e procedure di rollback.

---

## 📋 Overview

Questo documento fornisce istruzioni step-by-step per deployare MyPetCare in produzione su:
- **Backend**: Google Cloud Run
- **Frontend**: Firebase Hosting  
- **Database**: Firestore
- **Jobs**: Cloud Scheduler
- **Payments**: Stripe + PayPal (LIVE MODE)

---

## ⚠️ Pre-Requisiti Critici

### 1. Credenziali Produzione

**Stripe (LIVE MODE):**
```bash
export STRIPE_SECRET="sk_live_xxxxxxxxxxxx"
export STRIPE_WEBHOOK_SECRET="whsec_xxxxxxxxxxxx"
```

**PayPal (LIVE MODE):**
```bash
export PAYPAL_CLIENT_ID="xxxxxxxxxxxx"
export PAYPAL_CLIENT_SECRET="xxxxxxxxxxxx"
```

**Sicurezza:**
```bash
# Genera secret forte (min 32 caratteri)
export CRON_SECRET=$(openssl rand -base64 32)
```

### 2. Tool Richiesti

- ✅ `gcloud` CLI (authenticated)
- ✅ `firebase` CLI (logged in)
- ✅ `flutter` SDK 3.35.4
- ✅ `jq` per JSON parsing

### 3. Permessi GCP

Account deve avere ruoli:
- Cloud Run Admin
- Cloud Scheduler Admin
- Firebase Admin
- Service Account User

---

## 🚀 Deployment Automatico

### Step 1: Configurazione Variabili

```bash
cd /home/user/flutter_app

# Configura tutte le variabili ambiente
export GCP_PROJECT_ID="pet-care-9790d"
export GCP_REGION="europe-west1"

# Payment providers (LIVE)
export STRIPE_SECRET="sk_live_xxx"
export STRIPE_WEBHOOK_SECRET="whsec_live_xxx"
export PAYPAL_CLIENT_ID="live_xxx"
export PAYPAL_CLIENT_SECRET="live_xxx"

# Security
export CRON_SECRET="your-strong-secret-32-chars"
```

### Step 2: Esegui Script Deployment

```bash
bash deploy_production.sh
```

**Output atteso:**
```
========================================
🚀 MyPetCare - Production Deployment
========================================

🔍 Pre-flight checks...
✅ gcloud installato
✅ firebase installato
✅ flutter installato
✅ jq installato
✅ GCP authentication OK
✅ Firebase authentication OK

📦 Step 1: Backend Build
🔨 Compilazione TypeScript...
✅ Backend compilato con successo

☁️  Step 2: Backend Deploy (Cloud Run)
🚀 Deploy backend su Cloud Run...
✅ Backend deployato con successo
🔗 Backend URL: https://mypetcare-backend-xxx.run.app

⏰ Step 3: Cloud Scheduler Configuration
✅ Job booking-reminders aggiornato
✅ Job cleanup-locks aggiornato

🔥 Step 4: Firestore Configuration
📊 Deploy Firestore indexes...
🔒 Deploy Firestore rules...
✅ Firestore configurato con successo

📱 Step 5: Flutter Web Build
🔨 Build web con API_BASE produzione...
✅ Flutter web compilato con successo

🌐 Step 6: Firebase Hosting Deploy
🚀 Deploy su Firebase Hosting...
✅ Frontend deployato con successo

🏥 Step 7: Health Checks
✅ Backend health check OK
✅ Frontend accessibile (HTTP 200)

========================================
✅ Deployment Completato!
========================================
```

---

## 🧪 QA Validation

### Esegui Checklist Automatica

```bash
export BACKEND_URL="https://mypetcare-backend-xxx.run.app"
export ADMIN_TOKEN="your-firebase-admin-id-token"
export CRON_SECRET="your-cron-secret"

bash qa_production_checklist.sh
```

**Test Automatici:**
1. ✅ Backend Health Check
2. ✅ Admin Stats API
3. ✅ CSV Export Endpoint
4. ✅ Jobs Health Check
5. ✅ Reminder Endpoint
6. ✅ Firestore Connectivity
7. ✅ Cloud Storage
8. ✅ Frontend Accessibility
9. ✅ Cloud Scheduler Jobs

**Output QA:**
```
========================================
🧪 MyPetCare - Production QA Checklist
========================================

✅ Backend Health (pass)
✅ Admin Stats API (pass)
✅ CSV Export (pass)
✅ Jobs Health (pass)
✅ Reminder Endpoint (pass)
✅ Firestore Connectivity (pass)
✅ Cloud Storage (pass)
✅ Frontend Hosting (pass)
✅ Cloud Scheduler (pass)

========================================
📊 Test Summary
========================================

✅ Passed:  9
❌ Failed:  0
⏭️  Skipped: 1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Total:   10

Pass Rate: 90%

🎉 All automated tests passed!
```

---

## 📋 Manual Test Checklist

Dopo i test automatici, validare manualmente:

### Payment Flows

**Stripe Checkout:**
```
1. Apri app web → Effettua booking
2. Scegli pagamento Stripe
3. Completa checkout
4. ✅ Verifica: PDF receipt in Cloud Storage
5. ✅ Verifica: Booking status = paid in Firestore
```

**PayPal Capture:**
```
1. Apri app web → Effettua booking  
2. Scegli pagamento PayPal
3. Completa transazione
4. ✅ Verifica: PDF receipt in Cloud Storage
5. ✅ Verifica: Payment record in Firestore
```

### Booking Reminders

```
1. Crea booking tra 24 ore
2. Attendi trigger automatico Cloud Scheduler (ogni ora)
3. ✅ Verifica: Notifica push ricevuta su mobile
4. ✅ Verifica: booking.reminderSent = true in Firestore
5. ✅ Verifica: Logs Cloud Run senza errori
```

### Chat System

```
1. Login come user → Apri chat con PRO
2. Invia messaggio
3. Login come PRO → Verifica messaggio ricevuto
4. ✅ Verifica: Messaggio in threads/{id}/messages
5. ✅ Verifica: Real-time update UI (StreamBuilder)
```

### Admin Dashboard

```
1. Login come admin
2. Naviga a /admin/analytics
3. ✅ Verifica: 4 card statistiche popolate
4. ✅ Verifica: Grafico 30 giorni con dati reali
5. ✅ Verifica: Export CSV funzionante
6. ✅ Verifica: Revenue serie coerente con payments
```

### FCM Notifications

```
1. Registra dispositivo mobile con FCM token
2. Crea booking → Attendi reminder
3. ✅ Verifica: Push notification ricevuta
4. Invia messaggio chat
5. ✅ Verifica: Chat notification ricevuta
```

### Performance & Logs

```
1. Apri Cloud Logging console
2. Filtra per service mypetcare-backend
3. ✅ Verifica: Nessun errore critico
4. ✅ Verifica: Response time < 500ms (95th percentile)
5. ✅ Verifica: Memory usage < 400MB
```

---

## 🔧 Configurazione Post-Deployment

### 1. Stripe Webhooks

**Setup webhook endpoint:**
```bash
# URL webhook
https://mypetcare-backend-xxx.run.app/webhooks/stripe

# Eventi da ascoltare:
- payment_intent.succeeded
- payment_intent.payment_failed
- charge.succeeded
- invoice.payment_succeeded
```

**Test webhook locale:**
```bash
stripe listen --forward-to https://mypetcare-backend-xxx.run.app/webhooks/stripe
stripe trigger payment_intent.succeeded
```

### 2. PayPal Webhooks

**Dashboard:**
```
https://developer.paypal.com/dashboard/webhooks
```

**Configurazione:**
```
URL: https://mypetcare-backend-xxx.run.app/webhooks/paypal

Events:
- PAYMENT.CAPTURE.COMPLETED
- PAYMENT.CAPTURE.DENIED
- CHECKOUT.ORDER.APPROVED
```

### 3. Cloud Monitoring Alerts

**Alert su Errori:**
```bash
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="MyPetCare Backend Errors" \
  --condition-display-name="Error rate > 5%" \
  --condition-threshold-value=5 \
  --condition-threshold-duration=300s
```

**Alert su Latency:**
```bash
gcloud alpha monitoring policies create \
  --display-name="MyPetCare High Latency" \
  --condition-display-name="Request latency > 1s" \
  --condition-threshold-value=1000 \
  --condition-threshold-duration=300s
```

---

## 🔄 Rollback Procedure

### Scenario 1: Deploy Fallito (Automatic Rollback)

Cloud Run mantiene le revisioni precedenti automaticamente.

**Check revisioni disponibili:**
```bash
gcloud run revisions list \
  --service=mypetcare-backend \
  --region=europe-west1
```

Output:
```
REVISION                            ACTIVE  SERVICE               DEPLOYED
mypetcare-backend-00003-abc         yes     mypetcare-backend    2025-02-11 15:30
mypetcare-backend-00002-def                 mypetcare-backend    2025-02-10 10:20
mypetcare-backend-00001-ghi                 mypetcare-backend    2025-02-09 09:15
```

### Scenario 2: Rollback Manuale

**Step 1: Identifica revisione stabile**
```bash
# Visualizza revision con traffico attuale
gcloud run services describe mypetcare-backend \
  --region=europe-west1 \
  --format="value(status.traffic.revisionName)"
```

**Step 2: Switch traffico a revisione precedente**
```bash
# Rollback completo (100% traffico su revisione precedente)
gcloud run services update-traffic mypetcare-backend \
  --region=europe-west1 \
  --to-revisions=mypetcare-backend-00002-def=100
```

**Step 3: Verifica rollback**
```bash
# Test health endpoint
curl https://mypetcare-backend-xxx.run.app/health

# Verifica logs
gcloud run logs tail mypetcare-backend --region=europe-west1
```

### Scenario 3: Rollback Graduale (Canary)

**Split traffico 50/50:**
```bash
gcloud run services update-traffic mypetcare-backend \
  --region=europe-west1 \
  --to-revisions=mypetcare-backend-00003-abc=50,mypetcare-backend-00002-def=50
```

**Monitora metriche:**
- Error rate
- Latency
- User feedback

**Completa rollback se problemi:**
```bash
gcloud run services update-traffic mypetcare-backend \
  --region=europe-west1 \
  --to-revisions=mypetcare-backend-00002-def=100
```

### Scenario 4: Rollback Frontend (Firebase Hosting)

**Visualizza deploy history:**
```bash
firebase hosting:channel:list
```

**Rollback a versione precedente:**
```bash
# Firebase mantiene ultime 10 versioni
firebase hosting:clone SOURCE_SITE_ID:SOURCE_CHANNEL_ID TARGET_CHANNEL_ID
```

**Alternative: Redeploy da Git commit precedente:**
```bash
git checkout <commit-hash>
flutter build web --dart-define=API_BASE="$BACKEND_URL"
firebase deploy --only hosting
```

---

## 📊 Monitoring & Logging

### Cloud Run Logs

**Real-time logs:**
```bash
gcloud run logs tail mypetcare-backend --region=europe-west1
```

**Filtra per errori:**
```bash
gcloud run logs read mypetcare-backend \
  --region=europe-west1 \
  --filter='severity=ERROR' \
  --limit=50
```

**Filtra per endpoint specifico:**
```bash
gcloud run logs read mypetcare-backend \
  --region=europe-west1 \
  --filter='jsonPayload.route="/admin/stats"' \
  --limit=20
```

### Cloud Scheduler Logs

**Job execution history:**
```bash
gcloud scheduler jobs describe booking-reminders \
  --location=europe-west1
```

**Execution logs:**
```bash
gcloud logging read \
  "resource.type=cloud_scheduler_job AND resource.labels.job_id=booking-reminders" \
  --limit=50
```

### Firebase Hosting Analytics

**Dashboard:**
```
https://console.firebase.google.com/project/pet-care-9790d/hosting
```

**Metriche chiave:**
- Requests per day
- Bandwidth usage
- Error rate (4xx, 5xx)

---

## 🔐 Security Best Practices

### Secret Management

**Usa Google Secret Manager (Raccomandato):**
```bash
# Crea secret
echo -n "sk_live_xxx" | gcloud secrets create stripe-secret --data-file=-

# Concedi accesso a Cloud Run
gcloud secrets add-iam-policy-binding stripe-secret \
  --member="serviceAccount:SERVICE_ACCOUNT@PROJECT.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

# Usa in Cloud Run
gcloud run services update mypetcare-backend \
  --update-secrets=STRIPE_SECRET=stripe-secret:latest
```

### Firestore Security

**Verifica rules deployment:**
```bash
firebase firestore:rules
```

**Test rules locale:**
```bash
firebase emulators:start --only firestore
# Esegui test con simulatore
```

### CORS Configuration

**Storage CORS:**
```json
[
  {
    "origin": ["https://mypetcare.web.app"],
    "method": ["GET"],
    "maxAgeSeconds": 3600
  }
]
```

```bash
gsutil cors set cors.json gs://pet-care-9790d.appspot.com
```

---

## 💰 Cost Optimization

### Cloud Run

**Imposta limiti:**
```bash
gcloud run services update mypetcare-backend \
  --region=europe-west1 \
  --min-instances=0 \
  --max-instances=10 \
  --memory=512Mi \
  --cpu=1
```

**Monitoraggio costi:**
```
https://console.cloud.google.com/billing
```

### Firestore

**Ottimizza query:**
- Usa limit() per paginazione
- Indici solo necessari
- Cache read frequenti

**Budget alert:**
```bash
gcloud alpha billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="MyPetCare Monthly Budget" \
  --budget-amount=100 \
  --threshold-rule=percent=90
```

---

## 📱 Mobile App Deployment

### Android APK Build

```bash
cd /home/user/flutter_app

# Build APK release
flutter build apk --release \
  --dart-define=API_BASE="https://mypetcare-backend-xxx.run.app"

# Output
build/app/outputs/flutter-apk/app-release.apk
```

### Google Play Store Upload

1. Crea app listing
2. Upload APK/AAB
3. Compila store listing
4. Submit per review

**Signing configuration:**
```bash
# Genera keystore
keytool -genkey -v -keystore mypetcare-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias mypetcare

# Configura in android/key.properties
storePassword=your-password
keyPassword=your-password
keyAlias=mypetcare
storeFile=../mypetcare-key.jks
```

---

## ✅ Post-Deployment Checklist

### Immediate (First Hour)

- [ ] ✅ Backend health check pass
- [ ] ✅ Frontend accessible
- [ ] ✅ Admin dashboard loading
- [ ] ✅ Logs senza errori critici
- [ ] ✅ Cloud Scheduler jobs executing
- [ ] ✅ Stripe webhooks configured
- [ ] ✅ PayPal webhooks configured

### Short-term (First Day)

- [ ] ✅ Test payment Stripe completo
- [ ] ✅ Test payment PayPal completo
- [ ] ✅ Booking reminder ricevuto
- [ ] ✅ Chat funzionante
- [ ] ✅ Admin stats accurate
- [ ] ✅ CSV export funzionante
- [ ] ✅ FCM notifications attive

### Medium-term (First Week)

- [ ] ✅ Nessun rollback necessario
- [ ] ✅ Performance metrics OK (< 500ms)
- [ ] ✅ Error rate < 1%
- [ ] ✅ User feedback positivo
- [ ] ✅ Costi entro budget
- [ ] ✅ Mobile app submitted
- [ ] ✅ Marketing materiali pronti

---

## 📞 Support & Contacts

### Emergency Contacts

**Backend Issues:**
- Cloud Run Console: https://console.cloud.google.com/run
- Logs: `gcloud run logs tail mypetcare-backend`

**Frontend Issues:**
- Firebase Console: https://console.firebase.google.com
- Hosting: `firebase hosting:channel:list`

**Database Issues:**
- Firestore Console: https://console.firebase.google.com/firestore
- Indexes: `firebase deploy --only firestore:indexes`

### Documentation Links

- Backend API: `/API_TESTING_EXAMPLES.md`
- Deployment: `/DEPLOYMENT_INSTRUCTIONS.md`
- Testing: `/FULL_SYSTEM_TEST.md`
- Validation: `/FINAL_VALIDATION_CHECKLIST.md`

---

## 🎉 Success Metrics

### Technical KPIs

- ✅ Uptime: > 99.9%
- ✅ Response Time: < 500ms (p95)
- ✅ Error Rate: < 1%
- ✅ Deployment Time: < 15 min

### Business KPIs

- Daily Active Users (DAU)
- Bookings per day
- Revenue per day
- User retention rate

---

**🚀 MyPetCare è pronto per produzione!**

Seguire questa guida per un deployment sicuro e controllato in ambiente production.

Per domande o problemi, consultare la documentazione completa nella directory del progetto.
