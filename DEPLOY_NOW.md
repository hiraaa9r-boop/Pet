# 🚀 Deploy Now - Guida Pratica Immediata

**Progetto:** My Pet Care  
**Data:** 15 Novembre 2024  
**Repository:** https://github.com/petcareassistenza-eng/PET-CARE-2

---

## ⚡ **Deploy Rapido in 5 Step**

### **📋 Prerequisiti**

Prima di iniziare, assicurati di avere:

✅ **Google Cloud SDK** installato → https://cloud.google.com/sdk/docs/install  
✅ **Firebase CLI** installato → `npm install -g firebase-tools`  
✅ **Flutter SDK** installato (3.35.4)  
✅ Accesso al progetto `pet-care-9790d`

---

## **STEP 1️⃣: Setup Iniziale**

```bash
# Clone repository (se non l'hai già)
git clone https://github.com/petcareassistenza-eng/PET-CARE-2.git
cd PET-CARE-2

# Login Google Cloud
gcloud auth login
gcloud config set project pet-care-9790d

# Verifica
gcloud config get-value project
# Output atteso: pet-care-9790d

# Login Firebase
firebase login
```

---

## **STEP 2️⃣: Deploy Backend su Cloud Run**

### **Opzione A: Script Automatico (Raccomandato)**

```bash
# Esegui script deploy automatico
./DEPLOY_COMMANDS.sh
```

Lo script farà automaticamente:
- ✅ Build Docker image su Cloud Build
- ✅ Deploy su Cloud Run
- ✅ Recupero Service URL
- ✅ Health check

### **Opzione B: Comandi Manuali**

```bash
cd backend

# Build Docker image
gcloud builds submit --tag gcr.io/pet-care-9790d/pet-care-api

# Deploy su Cloud Run
gcloud run deploy pet-care-api \
  --image gcr.io/pet-care-9790d/pet-care-api \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated \
  --memory 512Mi \
  --timeout 60s \
  --max-instances 10

# Recupera URL
gcloud run services describe pet-care-api \
  --region europe-west1 \
  --format 'value(status.url)'
```

**⏱️ Tempo stimato:** 5-7 minuti

**📝 IMPORTANTE:** Salva l'URL del servizio! Ti servirà per il prossimo step.

**Esempio URL:**
```
https://pet-care-api-123456789-uc.a.run.app
```

---

## **STEP 3️⃣: Configura Variabili d'Ambiente**

### **Opzione A: Script Interattivo (Raccomandato)**

```bash
# Esegui script configurazione guidata
./CONFIGURE_ENV_VARS.sh
```

Lo script ti chiederà:
- Firebase Admin SDK credentials
- Stripe Live Keys
- PayPal Live Keys
- Backend/Frontend URLs
- CORS origins

### **Opzione B: Configurazione Manuale**

Consulta la lista completa variabili in: **`backend/docs/CLOUD_RUN_ENV_VARS.md`**

**Comando esempio:**
```bash
gcloud run services update pet-care-api \
  --region europe-west1 \
  --set-env-vars "\
NODE_ENV=production,\
FIREBASE_PROJECT_ID=pet-care-9790d,\
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@pet-care-9790d.iam.gserviceaccount.com,\
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----...,\
STRIPE_SECRET_KEY=sk_live_...,\
STRIPE_WEBHOOK_SECRET=whsec_...,\
PAYPAL_CLIENT_ID=...,\
PAYPAL_CLIENT_SECRET=...,\
BACKEND_BASE_URL=https://pet-care-api-XXXXX-uc.a.run.app,\
FRONTEND_BASE_URL=https://pet-care-9790d.web.app,\
CORS_ALLOWED_ORIGINS=https://pet-care-9790d.web.app,https://pet-care-9790d.firebaseapp.com"
```

**⏱️ Tempo stimato:** 5-10 minuti

**✅ Verifica configurazione:**
```bash
curl https://pet-care-api-XXXXX-uc.a.run.app/health
```

---

## **STEP 4️⃣: Aggiorna Flutter Config**

**Modifica il file `lib/config.dart`:**

```dart
class AppConfig {
  // ⚠️ AGGIORNA CON L'URL OTTENUTO DALLO STEP 2
  static const String backendBaseUrl = 'https://pet-care-api-XXXXX-uc.a.run.app';
  
  static const String webBaseUrl = 'https://pet-care-9790d.web.app';
  
  // ... resto della configurazione
}
```

**Commit le modifiche:**

```bash
git add lib/config.dart
git commit -m "Update backend URL for Cloud Run deployment"
git push origin main
```

---

## **STEP 5️⃣: Deploy Frontend su Firebase Hosting**

```bash
# Build Flutter Web
flutter build web --release

# Deploy su Firebase Hosting
firebase deploy --only hosting
```

**⏱️ Tempo stimato:** 3-5 minuti

**✅ Output atteso:**
```
✔ Deploy complete!

Hosting URL: https://pet-care-9790d.web.app
```

---

## ✅ **Verifica Deploy Completato**

### **1. Test Backend**

```bash
# Health check
curl https://pet-care-api-XXXXX-uc.a.run.app/health

# Output atteso:
# {
#   "ok": true,
#   "service": "mypetcare-backend",
#   "version": "1.0.0",
#   "timestamp": "...",
#   "env": "production"
# }
```

### **2. Test Frontend**

1. Apri browser: **https://pet-care-9790d.web.app**
2. Verifica caricamento app
3. Testa login/registrazione
4. Controlla console browser per errori API

### **3. Test CORS**

Apri Console Browser (F12) e esegui:

```javascript
fetch('https://pet-care-api-XXXXX-uc.a.run.app/health', {
  headers: { 'Origin': 'https://pet-care-9790d.web.app' }
}).then(r => r.json()).then(console.log)
```

**Output atteso:** Nessun errore CORS, risposta JSON health check.

---

## 🔐 **STEP BONUS: Setup Webhook (Post-Deploy)**

### **Stripe Webhook**

1. Vai su: https://dashboard.stripe.com/webhooks
2. Click **Add endpoint**
3. **Endpoint URL:** `https://pet-care-api-XXXXX-uc.a.run.app/webhooks/stripe`
4. **Eventi:**
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
5. Copia **Signing secret** (whsec_...)
6. Aggiorna variabile `STRIPE_WEBHOOK_SECRET` su Cloud Run:
   ```bash
   gcloud run services update pet-care-api \
     --region europe-west1 \
     --set-env-vars "STRIPE_WEBHOOK_SECRET=whsec_..."
   ```

### **PayPal Webhook**

1. Vai su: https://developer.paypal.com/dashboard/webhooks
2. Click **Create Webhook**
3. **URL:** `https://pet-care-api-XXXXX-uc.a.run.app/webhooks/paypal`
4. **Eventi:**
   - `BILLING.SUBSCRIPTION.CREATED`
   - `BILLING.SUBSCRIPTION.ACTIVATED`
   - `BILLING.SUBSCRIPTION.CANCELLED`
   - `PAYMENT.SALE.COMPLETED`
5. Copia **Webhook ID**
6. Aggiorna variabile `PAYPAL_WEBHOOK_ID` su Cloud Run:
   ```bash
   gcloud run services update pet-care-api \
     --region europe-west1 \
     --set-env-vars "PAYPAL_WEBHOOK_ID=YOUR_WEBHOOK_ID"
   ```

---

## 📊 **Monitoring**

### **Cloud Run Logs**

```bash
# Logs in tempo reale
gcloud run services logs tail pet-care-api --region europe-west1

# Ultimi 50 log
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=pet-care-api" \
  --limit 50 \
  --format json
```

### **Firebase Hosting**

- **Console:** https://console.firebase.google.com/project/pet-care-9790d/hosting
- **Deploy history:** `firebase hosting:channel:list`

---

## 🆘 **Troubleshooting**

### **Problema: Backend non risponde**

```bash
# Verifica servizio
gcloud run services describe pet-care-api --region europe-west1

# Check logs
gcloud run services logs tail pet-care-api --region europe-west1
```

### **Problema: CORS errors nel browser**

1. Verifica `CORS_ALLOWED_ORIGINS` include URL frontend
2. Check `backend/src/middleware/cors.ts`
3. Verifica whitelist:
   ```bash
   gcloud run services describe pet-care-api \
     --region europe-west1 \
     --format 'value(spec.template.spec.containers[0].env)'
   ```

### **Problema: Firebase Auth errors**

1. Verifica `FIREBASE_PRIVATE_KEY` su Cloud Run (mantieni `\n`)
2. Check `FIREBASE_CLIENT_EMAIL`
3. Verifica `firebase_options.dart` nel frontend

---

## 📖 **Documentazione Completa**

- 📘 **Deploy Dettagliato:** [`DEPLOY_QUICK_START.md`](DEPLOY_QUICK_START.md)
- 🔑 **Variabili Ambiente:** [`backend/docs/CLOUD_RUN_ENV_VARS.md`](backend/docs/CLOUD_RUN_ENV_VARS.md)
- 🛡️ **CORS & Security:** [`backend/docs/CORS_SECURITY_UPDATE.md`](backend/docs/CORS_SECURITY_UPDATE.md)
- 👑 **Admin System:** [`docs/ADMIN_SYSTEM_SETUP.md`](docs/ADMIN_SYSTEM_SETUP.md)

---

## ✅ **Checklist Deploy**

**Pre-Deploy:**
- [ ] Google Cloud SDK installato e configurato
- [ ] Firebase CLI installato
- [ ] Accesso progetto `pet-care-9790d` verificato
- [ ] Repository clonato localmente

**Backend:**
- [ ] Docker image buildato su Cloud Build
- [ ] Backend deployed su Cloud Run
- [ ] Variabili d'ambiente configurate (17 variabili)
- [ ] Health check funzionante
- [ ] URL backend salvato

**Frontend:**
- [ ] `lib/config.dart` aggiornato con URL backend
- [ ] Flutter web buildato (`flutter build web --release`)
- [ ] Deploy su Firebase Hosting completato
- [ ] App accessibile su https://pet-care-9790d.web.app

**Post-Deploy:**
- [ ] Login/registrazione testati
- [ ] API calls funzionanti
- [ ] CORS verificato (no errors in console)
- [ ] Webhook Stripe configurato
- [ ] Webhook PayPal configurato

---

## 🎯 **Tempo Totale Stimato**

- ⏱️ **Setup Iniziale:** 2-3 minuti
- ⏱️ **Backend Deploy:** 5-7 minuti
- ⏱️ **Env Vars Config:** 5-10 minuti
- ⏱️ **Frontend Update:** 2-3 minuti
- ⏱️ **Frontend Deploy:** 3-5 minuti
- ⏱️ **Webhook Setup:** 5-10 minuti (opzionale)

**⚡ TOTALE: 25-40 minuti circa**

---

## 📞 **Supporto**

- **Repository:** https://github.com/petcareassistenza-eng/PET-CARE-2
- **Email:** petcareassistenza@gmail.com
- **Firebase Console:** https://console.firebase.google.com/project/pet-care-9790d
- **Google Cloud Console:** https://console.cloud.google.com/run?project=pet-care-9790d

---

**Ultima revisione:** 15 Novembre 2024  
**Versione:** 1.0.0

🚀 **Buon Deploy!**
