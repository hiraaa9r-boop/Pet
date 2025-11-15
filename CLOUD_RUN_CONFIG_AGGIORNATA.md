# ✅ CONFIGURAZIONE CLOUD RUN AGGIORNATA

**Data:** 15/11/2025  
**Status:** CONFIGURATO per Cloud Run  
**Formato URL:** `https://pet-care-api-XXXXX-ew.a.run.app`

---

## 🔄 MODIFICHE EFFETTUATE

### 1. Frontend `config.dart` ✅

**File:** `/home/user/flutter_app/lib/config.dart`

**Prima:**
```dart
static const String backendBaseUrl = 'https://api.mypetcareapp.org';
static const String webBaseUrl = 'https://app.mypetcareapp.org';
```

**Dopo:**
```dart
// ⚠️ AGGIORNA DOPO DEPLOY: Sostituisci XXXXX con l'ID servizio Cloud Run
static const String backendBaseUrl = 'https://pet-care-api-XXXXX-ew.a.run.app';
static const String webBaseUrl = 'https://pet-care-9790d.web.app';
```

---

### 2. Backend `.env` ✅

**File:** `/home/user/flutter_app/backend/.env`

**Prima:**
```bash
BACKEND_BASE_URL=http://localhost:8080
```

**Dopo:**
```bash
# ⚠️ LOCALE: http://localhost:8080
# ⚠️ CLOUD RUN: https://pet-care-api-XXXXX-ew.a.run.app (sostituisci XXXXX)
BACKEND_BASE_URL=https://pet-care-api-XXXXX-ew.a.run.app
```

---

## 📋 PROCEDURA DEPLOYMENT COMPLETA

### Step 1: Deploy Backend su Cloud Run

**Prerequisiti:**
- ✅ Google Cloud SDK installato
- ✅ Account Google con permessi Owner su `pet-care-9790d`
- ✅ Docker installato (opzionale)

**Comandi:**
```powershell
# 1. Autentica (una tantum)
gcloud auth login

# 2. Configura progetto (una tantum)
gcloud config set project pet-care-9790d

# 3. Abilita APIs (una tantum)
gcloud services enable run.googleapis.com cloudbuild.googleapis.com containerregistry.googleapis.com

# 4. Vai alla directory backend
cd backend

# 5. Deploy!
.\DEPLOY_COMMANDS.ps1  # Windows
# oppure
./deploy-cloudrun.sh   # Linux/Mac
```

**Output atteso:**
```
✅ Service deployed to: https://pet-care-api-abc123def-ew.a.run.app
```

**Tempo stimato:** 5-8 minuti

---

### Step 2: Aggiorna URL in Config Files

**Dopo il deploy, ottieni l'URL reale (esempio):**
```
https://pet-care-api-abc123def-ew.a.run.app
```

**Sostituisci in 2 file:**

#### A) Frontend `lib/config.dart`
```dart
// PRIMA
static const String backendBaseUrl = 'https://pet-care-api-XXXXX-ew.a.run.app';

// DOPO (esempio con URL reale)
static const String backendBaseUrl = 'https://pet-care-api-abc123def-ew.a.run.app';
```

#### B) Backend `.env`
```bash
# PRIMA
BACKEND_BASE_URL=https://pet-care-api-XXXXX-ew.a.run.app

# DOPO (esempio con URL reale)
BACKEND_BASE_URL=https://pet-care-api-abc123def-ew.a.run.app
```

---

### Step 3: Re-deploy Backend con URL Aggiornato

```powershell
cd backend

# Aggiorna variabile d'ambiente su Cloud Run
gcloud run services update pet-care-api \
  --region=europe-west1 \
  --set-env-vars BACKEND_BASE_URL=https://pet-care-api-abc123def-ew.a.run.app
```

**Oppure:** Re-esegui `.\DEPLOY_COMMANDS.ps1` (legge automaticamente .env aggiornato)

---

### Step 4: Rebuild e Re-deploy Frontend

```bash
cd /home/user/flutter_app

# Clean build
flutter clean
flutter pub get

# Build web release
flutter build web --release

# Deploy su Firebase Hosting
firebase deploy --only hosting
```

**Tempo stimato:** 3-5 minuti

---

### Step 5: Testa Connessione Backend

```bash
# Test health endpoint
curl https://pet-care-api-abc123def-ew.a.run.app/health

# Output atteso:
{
  "status": "ok",
  "timestamp": "2025-11-15T...",
  "environment": "production"
}
```

---

## 🔧 CONFIGURAZIONE WEBHOOK (Dopo Deploy)

### Stripe Webhook

**URL:** `https://pet-care-api-[TUO-ID]-ew.a.run.app/api/payments/webhook`

**Eventi:**
- `checkout.session.completed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `invoice.payment_succeeded`
- `invoice.payment_failed`

**Passi:**
1. Stripe Dashboard (LIVE) → Developers → Webhooks
2. Add endpoint con URL sopra
3. Seleziona eventi
4. Copia Webhook Secret (whsec_...)
5. Aggiorna `.env`: `STRIPE_WEBHOOK_SECRET=whsec_...`
6. Re-deploy backend

---

### PayPal Webhook

**URL:** `https://pet-care-api-[TUO-ID]-ew.a.run.app/webhooks/paypal`

**Eventi:**
- `PAYMENT.CAPTURE.COMPLETED`
- `PAYMENT.CAPTURE.DENIED`
- `BILLING.SUBSCRIPTION.CREATED`
- `BILLING.SUBSCRIPTION.ACTIVATED`
- `BILLING.SUBSCRIPTION.UPDATED`
- `BILLING.SUBSCRIPTION.CANCELLED`

**Passi:**
1. PayPal Developer → Webhooks
2. Create webhook con URL sopra
3. Seleziona eventi
4. Copia Webhook ID
5. Aggiorna `.env`: `PAYPAL_WEBHOOK_ID=...`
6. Re-deploy backend

---

## 📊 CORS Configuration

**Backend `.env` già configurato:**
```bash
CORS_ALLOWED_ORIGINS=https://pet-care-9790d.web.app,https://pet-care-9790d.firebaseapp.com,http://localhost:5060
```

**Aggiorna se necessario** per includere altri domini autorizzati.

---

## 🧪 TESTING POST-DEPLOYMENT

### 1. Health Check ✅
```bash
curl https://[TUO-BACKEND-URL]/health
```

### 2. API Documentation ✅
```
Browser → https://[TUO-BACKEND-URL]/api/docs
```

### 3. Frontend → Backend Connection ✅
```
1. Apri https://pet-care-9790d.web.app
2. Console Browser (F12) → Network
3. Esegui azione (login, registrazione)
4. Verifica chiamate a [TUO-BACKEND-URL]
```

### 4. Test Pagamento PayPal ✅
```
1. Seleziona abbonamento
2. Click su PayPal
3. Completa checkout
4. Verifica webhook ricevuto
```

### 5. Test Pagamento Stripe ✅
```
1. Seleziona abbonamento
2. Click su Stripe
3. Usa carta test: 4242 4242 4242 4242
4. Completa checkout
5. Verifica webhook ricevuto
```

---

## ⚠️ TROUBLESHOOTING

### Errore: CORS Policy

**Problema:** Frontend bloccato da CORS

**Soluzione:**
1. Verifica `CORS_ALLOWED_ORIGINS` in `.env`
2. Assicurati includa: `https://pet-care-9790d.web.app`
3. Re-deploy backend

---

### Errore: 503 Service Unavailable

**Problema:** Backend non risponde

**Causa Comune:**
- Firebase Admin SDK file mancante
- Variabili ambiente non configurate

**Soluzione:**
```bash
# Verifica logs
gcloud logging read "resource.type=cloud_run_revision" \
  --limit 50 \
  --project pet-care-9790d

# Verifica variabili ambiente
gcloud run services describe pet-care-api \
  --region europe-west1 \
  --format "value(spec.template.spec.containers[0].env)"
```

---

### Errore: Webhook non ricevuti

**Problema:** Stripe/PayPal non invia notifiche

**Soluzione:**
1. Verifica URL webhook corretto
2. Verifica webhook secret aggiornato in `.env`
3. Controlla logs webhook in Dashboard (Stripe/PayPal)
4. Testa con "Send test webhook" in Dashboard

---

## 📋 CHECKLIST DEPLOYMENT

### Pre-Deployment
- [ ] Google Cloud SDK installato
- [ ] Autenticato con account Owner
- [ ] Progetto configurato: `pet-care-9790d`
- [ ] APIs abilitate (Cloud Run, Cloud Build)
- [ ] Firebase Admin SDK in `backend/`
- [ ] File `.env` configurato con tutte le variabili

### Deployment
- [ ] Eseguito deploy backend: `.\DEPLOY_COMMANDS.ps1`
- [ ] Ottenuto URL Cloud Run
- [ ] Aggiornato URL in `lib/config.dart`
- [ ] Aggiornato URL in `backend/.env`
- [ ] Re-deployato backend con URL aggiornato
- [ ] Rebuild frontend: `flutter build web --release`
- [ ] Re-deployato frontend: `firebase deploy --only hosting`

### Post-Deployment
- [ ] Health check funzionante
- [ ] API docs accessibili
- [ ] Frontend → Backend connesso
- [ ] CORS configurato correttamente
- [ ] Webhook Stripe configurato e testato
- [ ] Webhook PayPal configurato e testato
- [ ] Test pagamento Stripe completato
- [ ] Test pagamento PayPal completato

---

## 🎯 RIEPILOGO URL

### Frontend (DEPLOYATO) ✅
```
https://pet-care-9790d.web.app
```

### Backend (DA DEPLOYARE) ⚠️
```
https://pet-care-api-XXXXX-ew.a.run.app

(Sostituisci XXXXX con l'ID generato dopo deployment)
```

### Firebase Console
```
https://console.firebase.google.com/project/pet-care-9790d
```

### Google Cloud Console
```
https://console.cloud.google.com/run?project=pet-care-9790d
```

---

## ⏱️ TIMELINE COMPLETA

**Con backend pronto per deploy:**

```
[T+0]  Deploy backend su Cloud Run (8 min)
[T+8]  Ottieni URL Cloud Run generato
[T+10] Aggiorna config.dart + backend/.env con URL reale
[T+12] Re-deploy backend con URL aggiornato (3 min)
[T+15] Rebuild Flutter web (3 min)
[T+18] Deploy frontend su Firebase Hosting (2 min)
[T+20] Configura webhook Stripe (5 min)
[T+25] Configura webhook PayPal (5 min)
[T+30] Re-deploy backend con webhook secrets (3 min)
[T+33] Test pagamenti Stripe (5 min)
[T+38] Test pagamenti PayPal (5 min)
[T+43] ✅ APP LIVE IN PRODUZIONE COMPLETA!
```

**TOTALE: 43 minuti**

---

## 📞 SUPPORTO

**Documentazione Dettagliata:**
- `DEPLOY_BACKEND_STATUS.md` - Status backend completo
- `PAYPAL_CONFIGURAZIONE_COMPLETA.md` - PayPal setup
- `PRODUZIONE_AUDIT_COMPLETO.md` - Audit completo

**Email:** petcareassistenza@gmail.com  
**GitHub:** https://github.com/petcareassistenza-eng/PET-CARE-2

---

**🚀 PRONTO PER DEPLOYMENT! Segui gli step sopra e avrai l'app LIVE in ~45 minuti!**
