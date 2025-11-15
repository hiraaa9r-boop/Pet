# 🔐 Variabili d'Ambiente per Cloud Run

Questa è la lista **completa e aggiornata** delle variabili d'ambiente da configurare su Cloud Run per il backend My Pet Care.

---

## 📋 **Variabili Obbligatorie**

### **1. NODE_ENV**
```bash
NODE_ENV=production
```
- **Descrizione:** Ambiente di esecuzione (production / development / test)
- **Valore Production:** `production`
- **Nota:** Cloud Run DEVE avere `production`

---

### **2. PORT**
```bash
PORT=8080
```
- **Descrizione:** Porta HTTP per il server Express
- **Valore Cloud Run:** `8080` (default Cloud Run)
- **Nota:** Cloud Run passa automaticamente questa variabile

---

### **3. BACKEND_BASE_URL**
```bash
BACKEND_BASE_URL=https://pet-care-api-XXXXX-uc.a.run.app
```
- **Descrizione:** URL pubblico del backend Cloud Run
- **Come ottenerlo:** Dopo il deploy con `gcloud run services describe pet-care-api`
- **Esempio:** `https://pet-care-api-123456789-uc.a.run.app`

---

### **4. FRONTEND_BASE_URL**
```bash
FRONTEND_BASE_URL=https://pet-care-9790d.web.app
```
- **Descrizione:** URL pubblico del frontend Flutter (Firebase Hosting)
- **Valore Production:** `https://pet-care-9790d.web.app`
- **Nota:** Usato per CORS e redirect

---

## 🔥 **Firebase Configuration**

### **5. FIREBASE_PROJECT_ID**
```bash
FIREBASE_PROJECT_ID=pet-care-9790d
```
- **Dove trovarlo:** Firebase Console → Project Settings → General
- **Valore:** `pet-care-9790d`

---

### **6. FIREBASE_CLIENT_EMAIL**
```bash
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@pet-care-9790d.iam.gserviceaccount.com
```
- **Dove trovarlo:** File `firebase-admin-sdk.json` → campo `client_email`
- **Formato:** `firebase-adminsdk-xxxxx@PROJECT_ID.iam.gserviceaccount.com`

---

### **7. FIREBASE_PRIVATE_KEY**
```bash
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIE...LONG_KEY_HERE...=\n-----END PRIVATE KEY-----\n"
```
- **Dove trovarlo:** File `firebase-admin-sdk.json` → campo `private_key`
- **⚠️ IMPORTANTE:** 
  - Mantenere gli `\n` per i newline
  - Racchiudere tra virgolette doppie
  - Non committare MAI nel codice!

---

### **8. FIREBASE_DATABASE_URL** (opzionale)
```bash
FIREBASE_DATABASE_URL=https://pet-care-9790d.firebaseio.com
```
- **Descrizione:** URL Realtime Database (se usato)
- **Formato:** `https://PROJECT_ID.firebaseio.com`
- **Nota:** Opzionale se usi solo Firestore

---

## 💳 **Stripe Live Configuration**

### **9. STRIPE_PUBLISHABLE_KEY**
```bash
STRIPE_PUBLISHABLE_KEY=YOUR_STRIPE_PUBLISHABLE_KEY_HERE
```
- **Dove trovarlo:** Stripe Dashboard → Developers → API Keys → Publishable key
- **Formato:** Inizia con `pk_live_` seguito da caratteri alfanumerici
- **Nota:** Chiave PUBBLICA (safe per client-side)

---

### **10. STRIPE_SECRET_KEY**
```bash
STRIPE_SECRET_KEY=YOUR_STRIPE_SECRET_KEY_HERE
```
- **Dove trovarlo:** Stripe Dashboard → Developers → API Keys → Secret key
- **Formato:** Inizia con `sk_live_` seguito da caratteri alfanumerici
- **⚠️ CRITICO:** 
  - Chiave SEGRETA - MAI committare!
  - Solo su Cloud Run
  - Sostituisci YOUR_STRIPE_SECRET_KEY_HERE con la tua chiave effettiva

---

### **11. STRIPE_WEBHOOK_SECRET**
```bash
STRIPE_WEBHOOK_SECRET=YOUR_STRIPE_WEBHOOK_SECRET_HERE
```
- **Dove trovarlo:** Stripe Dashboard → Developers → Webhooks → Create endpoint
- **Formato:** Inizia con `whsec_` seguito da caratteri alfanumerici
- **Endpoint URL:** `https://BACKEND_URL/webhooks/stripe`
- **Eventi da ascoltare:**
  - `checkout.session.completed`
  - `customer.subscription.created`
  - `customer.subscription.updated`
  - `customer.subscription.deleted`
  - `invoice.payment_succeeded`
  - `invoice.payment_failed`

---

## 💰 **PayPal Live Configuration**

### **12. PAYPAL_CLIENT_ID**
```bash
PAYPAL_CLIENT_ID=YOUR_PAYPAL_LIVE_CLIENT_ID
```
- **Dove trovarlo:** PayPal Developer Dashboard → My Apps & Credentials → Live → REST API apps
- **Modalità:** LIVE (non sandbox)

---

### **13. PAYPAL_CLIENT_SECRET**
```bash
PAYPAL_CLIENT_SECRET=YOUR_PAYPAL_LIVE_CLIENT_SECRET
```
- **Dove trovarlo:** PayPal Developer Dashboard → My Apps & Credentials → Live → Show Secret
- **⚠️ CRITICO:** Chiave SEGRETA - solo su Cloud Run

---

### **14. PAYPAL_WEBHOOK_ID**
```bash
PAYPAL_WEBHOOK_ID=YOUR_PAYPAL_WEBHOOK_ID
```
- **Dove trovarlo:** PayPal Developer Dashboard → Webhooks → Create webhook
- **Webhook URL:** `https://BACKEND_URL/webhooks/paypal`
- **Eventi da ascoltare:**
  - `BILLING.SUBSCRIPTION.CREATED`
  - `BILLING.SUBSCRIPTION.ACTIVATED`
  - `BILLING.SUBSCRIPTION.CANCELLED`
  - `PAYMENT.SALE.COMPLETED`

---

### **15. PAYPAL_MODE**
```bash
PAYPAL_MODE=live
```
- **Valori possibili:** `sandbox` | `live`
- **Production:** `live`

---

## 🔒 **Security & CORS**

### **16. CORS_ALLOWED_ORIGINS**
```bash
CORS_ALLOWED_ORIGINS=https://pet-care-9790d.web.app,https://pet-care-9790d.firebaseapp.com
```
- **Descrizione:** Origini aggiuntive per CORS (comma-separated)
- **Default già in codice:**
  - `https://pet-care-9790d.web.app`
  - `https://pet-care-9790d.firebaseapp.com`
  - `http://localhost:5060`
- **Nota:** Puoi aggiungere domini custom qui

---

### **17. LOG_LEVEL** (opzionale)
```bash
LOG_LEVEL=info
```
- **Valori possibili:** `debug` | `info` | `warn` | `error`
- **Production:** `info` o `warn`
- **Development:** `debug`

---

## 🚀 **Come Configurare su Cloud Run**

### **Metodo 1: Durante Deploy**
```bash
gcloud run deploy pet-care-api \
  --image gcr.io/pet-care-9790d/pet-care-api \
  --region europe-west1 \
  --platform managed \
  --set-env-vars "NODE_ENV=production" \
  --set-env-vars "FIREBASE_PROJECT_ID=pet-care-9790d" \
  --set-env-vars "STRIPE_SECRET_KEY=sk_live_..." \
  --allow-unauthenticated
```

### **Metodo 2: Aggiorna Servizio Esistente**
```bash
gcloud run services update pet-care-api \
  --region europe-west1 \
  --set-env-vars "VARIABILE=valore"
```

### **Metodo 3: Console Google Cloud**
1. Vai su **Cloud Run** → Seleziona servizio `pet-care-api`
2. Click **Edit & Deploy New Revision**
3. Tab **Variables & Secrets** → **Add Variable**
4. Inserisci nome e valore

---

## ✅ **Checklist Pre-Deploy**

Prima di fare deploy su Cloud Run, verifica:

- [ ] Tutte le variabili Firebase configurate
- [ ] Stripe Live Keys configurate (pk_live_ e sk_live_)
- [ ] Stripe Webhook Secret configurato (whsec_)
- [ ] PayPal Live Credentials configurate
- [ ] CORS_ALLOWED_ORIGINS include frontend URL
- [ ] NODE_ENV=production
- [ ] PORT=8080

---

## 📖 **Riferimenti**

- **Firebase Admin SDK:** [Console Firebase → Project Settings → Service Accounts](https://console.firebase.google.com/)
- **Stripe Keys:** [Stripe Dashboard → Developers → API Keys](https://dashboard.stripe.com/apikeys)
- **Stripe Webhooks:** [Stripe Dashboard → Developers → Webhooks](https://dashboard.stripe.com/webhooks)
- **PayPal Credentials:** [PayPal Developer Dashboard](https://developer.paypal.com/dashboard/)

---

**Ultima revisione:** 2025-11-15  
**Progetto:** My Pet Care Backend  
**Email supporto:** petcareassistenza@gmail.com
