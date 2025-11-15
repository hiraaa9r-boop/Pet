# 🚀 Deploy Quick Start - My Pet Care

Guida rapida per il deploy completo dell'applicazione My Pet Care (Backend + Frontend).

---

## 📋 **Prerequisiti**

Prima di iniziare, assicurati di avere:

✅ **Google Cloud SDK** installato e configurato  
✅ **Firebase CLI** installato (`npm install -g firebase-tools`)  
✅ **Flutter SDK** installato (versione 3.35.4)  
✅ **Node.js** 18+ installato  
✅ Accesso al progetto Firebase: `pet-care-9790d`  
✅ Accesso al progetto Google Cloud: `pet-care-9790d`

### **Setup Iniziale**

```bash
# Login Google Cloud
gcloud auth login
gcloud config set project pet-care-9790d

# Login Firebase
firebase login

# Verifica progetto
gcloud projects describe pet-care-9790d
```

---

## 🔧 **PARTE 1: Deploy Backend su Cloud Run**

### **Step 1: Build Docker Image**

```bash
cd backend

# Build e push immagine Docker su Google Container Registry
gcloud builds submit --tag gcr.io/pet-care-9790d/pet-care-api
```

⏱️ **Tempo stimato:** 3-5 minuti

---

### **Step 2: Deploy su Cloud Run**

```bash
gcloud run deploy pet-care-api \
  --image gcr.io/pet-care-9790d/pet-care-api \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated \
  --set-env-vars "NODE_ENV=production,FIREBASE_PROJECT_ID=pet-care-9790d" \
  --memory 512Mi \
  --timeout 60s \
  --max-instances 10
```

⏱️ **Tempo stimato:** 2-3 minuti

**Output atteso:**
```
Service [pet-care-api] revision [pet-care-api-00001-abc] has been deployed and is serving 100% of traffic.
Service URL: https://pet-care-api-XXXXX-uc.a.run.app
```

🔗 **Copia l'URL del servizio!** Ti servirà per configurare il frontend.

---

### **Step 3: Configura Variabili d'Ambiente**

**⚠️ IMPORTANTE:** Devi configurare tutte le variabili d'ambiente necessarie.

Consulta la lista completa in: [`backend/docs/CLOUD_RUN_ENV_VARS.md`](backend/docs/CLOUD_RUN_ENV_VARS.md)

**Variabili critiche da configurare:**

```bash
# Firebase
gcloud run services update pet-care-api \
  --region europe-west1 \
  --set-env-vars "FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@pet-care-9790d.iam.gserviceaccount.com"

gcloud run services update pet-care-api \
  --region europe-west1 \
  --set-env-vars "FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----..."

# Stripe Live
gcloud run services update pet-care-api \
  --region europe-west1 \
  --set-env-vars "STRIPE_SECRET_KEY=sk_live_..."

gcloud run services update pet-care-api \
  --region europe-west1 \
  --set-env-vars "STRIPE_WEBHOOK_SECRET=whsec_..."

# PayPal Live
gcloud run services update pet-care-api \
  --region europe-west1 \
  --set-env-vars "PAYPAL_CLIENT_ID=..."

gcloud run services update pet-care-api \
  --region europe-west1 \
  --set-env-vars "PAYPAL_CLIENT_SECRET=..."
```

💡 **Tip:** Puoi configurare tutte le variabili insieme con virgole:
```bash
--set-env-vars "VAR1=value1,VAR2=value2,VAR3=value3"
```

---

### **Step 4: Verifica Funzionamento Backend**

```bash
# Test healthcheck
curl https://pet-care-api-XXXXX-uc.a.run.app/health

# Output atteso:
# {"ok":true,"service":"mypetcare-backend","version":"1.0.0","timestamp":"...","env":"production"}
```

---

## 📱 **PARTE 2: Deploy Frontend Flutter**

### **Step 1: Aggiorna Backend URL nel Frontend**

**Prima del deploy, devi aggiornare l'URL del backend in Flutter.**

Modifica il file `lib/config.dart`:

```dart
class AppConfig {
  // Aggiorna con l'URL Cloud Run ottenuto nello step precedente
  static const String backendBaseUrl = 'https://pet-care-api-XXXXX-uc.a.run.app';
  
  static const String webBaseUrl = 'https://pet-care-9790d.web.app';
  
  // ... resto della configurazione
}
```

🔄 **Commit le modifiche:**

```bash
git add lib/config.dart
git commit -m "Update backend URL for Cloud Run deployment"
git push origin main
```

---

### **Step 2: Build Flutter Web**

```bash
# Torna alla root del progetto
cd ..

# Build Flutter per Web (production)
flutter build web --release
```

⏱️ **Tempo stimato:** 2-4 minuti

**Output atteso:**
```
✓ Built build/web
```

---

### **Step 3: Deploy su Firebase Hosting**

```bash
# Initialize Firebase (se non ancora fatto)
firebase init hosting
# Seleziona:
# - Use existing project: pet-care-9790d
# - Public directory: build/web
# - Single-page app: Yes
# - GitHub deployments: No

# Deploy
firebase deploy --only hosting
```

⏱️ **Tempo stimato:** 2-3 minuti

**Output atteso:**
```
✔ Deploy complete!

Hosting URL: https://pet-care-9790d.web.app
```

---

## ✅ **PARTE 3: Verifica Completa**

### **1. Test Backend**

```bash
# Healthcheck
curl https://pet-care-api-XXXXX-uc.a.run.app/health

# Test CORS (dal browser dev console)
fetch('https://pet-care-api-XXXXX-uc.a.run.app/health', {
  headers: { 'Origin': 'https://pet-care-9790d.web.app' }
})
```

### **2. Test Frontend**

1. Vai su: `https://pet-care-9790d.web.app`
2. Verifica login/registrazione funzionanti
3. Controlla connessione al backend (API calls nella console dev tools)

### **3. Test Payments**

1. Accedi come utente PRO
2. Vai su pagina abbonamento
3. Testa payment flow Stripe/PayPal (usa carte test)

---

## 🔐 **PARTE 4: Configurazione Webhook**

### **Stripe Webhook**

1. Vai su [Stripe Dashboard → Webhooks](https://dashboard.stripe.com/webhooks)
2. Click **Add endpoint**
3. **Endpoint URL:** `https://pet-care-api-XXXXX-uc.a.run.app/webhooks/stripe`
4. **Eventi da selezionare:**
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
5. Copia il **Signing secret** (whsec_...)
6. Aggiorna variabile `STRIPE_WEBHOOK_SECRET` su Cloud Run

### **PayPal Webhook**

1. Vai su [PayPal Developer Dashboard → Webhooks](https://developer.paypal.com/dashboard/webhooks)
2. Click **Create Webhook**
3. **URL:** `https://pet-care-api-XXXXX-uc.a.run.app/webhooks/paypal`
4. **Eventi da selezionare:**
   - `BILLING.SUBSCRIPTION.CREATED`
   - `BILLING.SUBSCRIPTION.ACTIVATED`
   - `BILLING.SUBSCRIPTION.CANCELLED`
   - `PAYMENT.SALE.COMPLETED`
5. Copia il **Webhook ID**
6. Aggiorna variabile `PAYPAL_WEBHOOK_ID` su Cloud Run

---

## 📊 **Monitoring & Logs**

### **Cloud Run Logs**

```bash
# Logs real-time
gcloud run services logs tail pet-care-api --region europe-west1

# Logs specifici
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=pet-care-api" --limit 50 --format json
```

### **Firebase Hosting Logs**

```bash
# Deploy history
firebase hosting:channel:list

# Rollback a versione precedente (se necessario)
firebase hosting:clone SOURCE_SITE_ID:SOURCE_CHANNEL_ID TARGET_SITE_ID:live
```

### **Monitoring Console**

- **Cloud Run:** [Google Cloud Console → Cloud Run](https://console.cloud.google.com/run)
- **Firebase:** [Firebase Console](https://console.firebase.google.com/project/pet-care-9790d)
- **Stripe:** [Stripe Dashboard](https://dashboard.stripe.com/)
- **PayPal:** [PayPal Dashboard](https://developer.paypal.com/dashboard/)

---

## 🔄 **Update e Re-Deploy**

### **Backend Update**

```bash
cd backend

# Rebuild e re-deploy in un solo comando
gcloud builds submit --tag gcr.io/pet-care-9790d/pet-care-api && \
gcloud run deploy pet-care-api \
  --image gcr.io/pet-care-9790d/pet-care-api \
  --region europe-west1 \
  --platform managed
```

### **Frontend Update**

```bash
flutter build web --release
firebase deploy --only hosting
```

---

## 🆘 **Troubleshooting**

### **Problema: Backend non risponde**

```bash
# Verifica servizio attivo
gcloud run services describe pet-care-api --region europe-west1

# Verifica logs per errori
gcloud run services logs tail pet-care-api --region europe-west1
```

### **Problema: CORS errors**

1. Verifica `CORS_ALLOWED_ORIGINS` su Cloud Run
2. Controlla `backend/src/middleware/cors.ts`
3. Assicurati che frontend URL sia in whitelist

### **Problema: Firebase Auth errors**

1. Verifica `FIREBASE_PRIVATE_KEY` su Cloud Run
2. Controlla `FIREBASE_CLIENT_EMAIL`
3. Verifica `firebase_options.dart` nel frontend

---

## 📖 **Documentazione Completa**

- **Variabili Ambiente:** [`backend/docs/CLOUD_RUN_ENV_VARS.md`](backend/docs/CLOUD_RUN_ENV_VARS.md)
- **Cloud Run Deployment:** [`backend/docs/CLOUD_RUN_DEPLOYMENT_GUIDE.md`](backend/docs/CLOUD_RUN_DEPLOYMENT_GUIDE.md)
- **CORS Security:** [`backend/docs/CORS_SECURITY_UPDATE.md`](backend/docs/CORS_SECURITY_UPDATE.md)
- **Admin System:** [`docs/ADMIN_SYSTEM_SETUP.md`](docs/ADMIN_SYSTEM_SETUP.md)
- **Local Testing:** [`backend/docs/LOCAL_TEST_GUIDE.md`](backend/docs/LOCAL_TEST_GUIDE.md)

---

## 🎯 **Quick Commands Reference**

```bash
# Backend deploy (da cartella backend)
gcloud builds submit --tag gcr.io/pet-care-9790d/pet-care-api && \
gcloud run deploy pet-care-api --image gcr.io/pet-care-9790d/pet-care-api --region europe-west1 --platform managed

# Frontend deploy (da root progetto)
flutter build web --release && firebase deploy --only hosting

# Logs backend
gcloud run services logs tail pet-care-api --region europe-west1

# Aggiorna env vars
gcloud run services update pet-care-api --region europe-west1 --set-env-vars "VAR=value"
```

---

**Ultima revisione:** 2025-11-15  
**Progetto:** My Pet Care  
**Repository:** https://github.com/petcareassistenza-eng/PET-CARE-2  
**Email supporto:** petcareassistenza@gmail.com
