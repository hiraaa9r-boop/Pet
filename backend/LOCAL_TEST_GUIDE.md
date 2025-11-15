# 🧪 Local Testing Guide - Backend My Pet Care

Guida rapida per testare il backend localmente prima del deployment.

---

## ⚡ Quick Start (3 Comandi)

```bash
# 1. Install dependencies
npm install

# 2. Build TypeScript
npm run build

# 3. Start server
npm start
```

---

## 📋 Preparazione Environment Variables

### Opzione A: File .env (Raccomandato)

Crea file `.env` nella root del backend:

```bash
# .env
NODE_ENV=development
PORT=8080
BACKEND_BASE_URL=http://localhost:8080
WEB_BASE_URL=http://localhost:5060

# Firebase (ottieni da Firebase Console → Project Settings → Service Accounts)
FIREBASE_PROJECT_ID=pet-care-9790d
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxx@pet-care-9790d.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvQI...\n-----END PRIVATE KEY-----\n"

# Stripe Test Keys (Stripe Dashboard → Developers → API Keys)
STRIPE_SECRET_KEY=sk_test_51SPfsqLXZ...
STRIPE_WEBHOOK_SECRET=whsec_xxx...

# PayPal Sandbox (PayPal Developer Dashboard)
PAYPAL_CLIENT_ID=AXxxx...
PAYPAL_SECRET=EPxxx...
PAYPAL_WEBHOOK_ID=xxx...

# CORS - Origini extra (opzionale)
CORS_ALLOWED_ORIGINS=https://custom-domain.com
```

### Opzione B: Environment Variables Inline

```bash
PORT=8080 \
NODE_ENV=development \
BACKEND_BASE_URL=http://localhost:8080 \
WEB_BASE_URL=http://localhost:5060 \
FIREBASE_PROJECT_ID=pet-care-9790d \
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@pet-care-9790d.iam.gserviceaccount.com \
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n" \
STRIPE_SECRET_KEY=sk_test_xxx \
STRIPE_WEBHOOK_SECRET=whsec_test_xxx \
PAYPAL_CLIENT_ID=test \
PAYPAL_SECRET=test \
PAYPAL_WEBHOOK_ID=test \
npm start
```

---

## 🧪 Test Endpoints

### 1. Health Check

```bash
curl http://localhost:8080/health
```

**Response attesa:**
```json
{
  "ok": true,
  "service": "mypetcare-backend",
  "version": "1.0.0",
  "timestamp": "2024-11-15T09:00:00.000Z",
  "env": "development"
}
```

### 2. Test CORS Headers

```bash
curl -i -H "Origin: https://pet-care-9790d.web.app" \
     http://localhost:8080/health
```

**Headers attesi:**
```
Access-Control-Allow-Origin: https://pet-care-9790d.web.app
Access-Control-Allow-Credentials: true
```

### 3. Test Rate Limiting

```bash
# Esegui 101 richieste rapide
for i in {1..101}; do
  echo "Request $i"
  curl -s http://localhost:8080/health | grep -o '"ok":true' || echo "Rate limited!"
done
```

**Dopo 100 richieste:**
```
Rate limited!
```

### 4. Test Admin Stats (Richiede Token)

```bash
# Ottieni token da Flutter app DevTools
TOKEN="eyJhbGciOiJSUzI1NiIs..."

curl -H "Authorization: Bearer $TOKEN" \
     http://localhost:8080/api/admin/stats
```

**Response attesa:**
```json
{
  "totalPros": 45,
  "activePros": 38,
  "totalBookings": 127
}
```

---

## 🔍 Debugging

### Visualizza Logs Realtime

Il server usa **morgan** per logging automatico:

```
::1 - - [15/Nov/2024:09:00:00 +0000] "GET /health HTTP/1.1" 200 123 "-" "curl/7.68.0"
::1 - - [15/Nov/2024:09:00:01 +0000] "POST /api/auth/register HTTP/1.1" 201 456 "-" "Mozilla/5.0"
```

### Logs CORS Warnings

```
[CORS] Origin NON consentita: https://unauthorized-site.com
```

### Verifica Middleware Caricati

Aggiungi in `index.ts` (temporaneo):
```typescript
console.log('📋 Middleware loaded:');
console.log('  ✅ CORS');
console.log('  ✅ Helmet');
console.log('  ✅ Morgan');
console.log('  ✅ Rate Limiter');
```

---

## 🚀 Deploy Workflow

### 1. Test Locale
```bash
npm run build
npm start
# Testa tutti gli endpoint
```

### 2. Commit Changes
```bash
git add .
git commit -m "Add CORS and security middleware"
git push origin main
```

### 3. Deploy Cloud Run
```bash
gcloud builds submit --tag gcr.io/pet-care-9790d/pet-care-api
gcloud run deploy pet-care-api \
  --image gcr.io/pet-care-9790d/pet-care-api \
  --region europe-west1
```

### 4. Configura Environment Variables
```
https://console.cloud.google.com/run
→ pet-care-api → Modifica → Variabili e secrets
```

### 5. Test Produzione
```bash
curl https://pet-care-api-xxxxx-ew.a.run.app/health
```

---

## ⚠️ Common Issues

### Errore: "Missing required environment variable"

**Causa:** File .env mancante o incompleto

**Soluzione:**
```bash
# Verifica variabili richieste
node -e "require('dotenv').config(); console.log(process.env)"
```

### Errore: "Cannot find module 'morgan'"

**Causa:** Dipendenze non installate

**Soluzione:**
```bash
npm install
```

### Port Already in Use

**Causa:** Porta 8080 già occupata

**Soluzione:**
```bash
# Cambia porta in .env
PORT=3000

# O trova processo che usa porta
lsof -ti:8080 | xargs kill -9
```

### CORS Error in Browser

**Causa:** Origin non whitelistata

**Soluzione:** Aggiungi origin in `CORS_ALLOWED_ORIGINS` o in `defaultOrigins`

---

## ✅ Pre-Deploy Checklist

- [ ] `npm install` completato senza errori
- [ ] `npm run build` completato senza errori
- [ ] `.env` file configurato con valori reali
- [ ] `npm start` avvia server senza errori
- [ ] `/health` endpoint risponde con 200
- [ ] CORS headers presenti in response
- [ ] Rate limiting funziona (test 101 richieste)
- [ ] Morgan logs appaiono in console
- [ ] Admin endpoints protetti (401 senza token)
- [ ] Firebase connection funziona (test registrazione)

---

## 📚 Scripts Disponibili

```json
{
  "scripts": {
    "build": "tsc",                  // Compila TypeScript
    "start": "node dist/index.js",   // Avvia server compilato
    "dev": "ts-node-dev --respawn --transpile-only src/index.ts"  // Dev mode con hot reload
  }
}
```

---

**🎯 Ready for Local Testing!**

Segui questi step e il tuo backend sarà pronto per il deployment su Cloud Run.
