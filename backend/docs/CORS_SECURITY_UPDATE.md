# 🔒 CORS e Security Update - Backend My Pet Care

Aggiornamento configurazione backend con CORS professionale, rate limiting e security best practices.

---

## ✅ Modifiche Implementate

### 1️⃣ Nuovo Middleware CORS Professionale

**File:** `src/middleware/cors.ts`

**Features:**
- ✅ **Whitelist origini** configurable via environment variable
- ✅ **Default origins** per Firebase Hosting e localhost
- ✅ **Server-to-server** requests permessi (origin null)
- ✅ **Logging** origini non autorizzate
- ✅ **Credentials support** per cookie/session
- ✅ **Preflight cache** 24h per ottimizzare performance

**Configurazione Default:**
```typescript
const defaultOrigins = [
  'https://pet-care-9790d.web.app',
  'https://pet-care-9790d.firebaseapp.com',
  'http://localhost:5060',
];
```

**Configurazione Custom (Opzionale):**
```bash
# Aggiungi origini extra via environment variable
CORS_ALLOWED_ORIGINS=https://app.mypetcareapp.org,https://api.mypetcareapp.org
```

---

### 2️⃣ Index.ts Aggiornato con Security Best Practices

**File:** `src/index.ts`

**Nuove Features:**

#### 🛡️ Security Headers (Helmet)
```typescript
app.use(
  helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' },
  })
);
```

#### 📊 Request Logging (Morgan)
```typescript
app.use(morgan('combined'));
```
Logs formato Apache combinato per monitoring e debugging.

#### ⏱️ Rate Limiting Globale
```typescript
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minuti
  max: 100,                  // 100 richieste per IP
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api', apiLimiter);
```

**Protezione contro:**
- Brute force attacks
- DDoS attacks
- API abuse

---

### 3️⃣ Nuove Dipendenze Installate

```json
{
  "dependencies": {
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0",
    "express-rate-limit": "^7.0.0"
  },
  "devDependencies": {
    "@types/cors": "^2.8.17",
    "@types/morgan": "^1.9.9"
  }
}
```

---

## 🚀 Testing Locale

### 1. Build del Progetto

```bash
cd backend
npm run build
```

**Output atteso:**
```
> mypetcare-backend@1.0.0 build
> tsc
```

### 2. Avvio Server Locale

#### Opzione A: Con .env File

Crea `.env` nella root del backend:
```bash
# .env
NODE_ENV=development
PORT=8080
BACKEND_BASE_URL=http://localhost:8080
WEB_BASE_URL=http://localhost:5060

# Firebase
FIREBASE_PROJECT_ID=pet-care-9790d
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxx@pet-care-9790d.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"

# Stripe
STRIPE_SECRET_KEY=sk_test_xxx...
STRIPE_WEBHOOK_SECRET=whsec_test_xxx...

# PayPal
PAYPAL_CLIENT_ID=test_xxx...
PAYPAL_SECRET=test_xxx...
PAYPAL_WEBHOOK_ID=test_xxx...

# CORS (opzionale)
CORS_ALLOWED_ORIGINS=https://custom-domain.com
```

Poi avvia:
```bash
npm start
```

#### Opzione B: Con Environment Variables Inline

```bash
PORT=8080 \
NODE_ENV=development \
BACKEND_BASE_URL=http://localhost:8080 \
WEB_BASE_URL=http://localhost:5060 \
FIREBASE_PROJECT_ID=pet-care-9790d \
FIREBASE_CLIENT_EMAIL=test@test.com \
FIREBASE_PRIVATE_KEY="test" \
STRIPE_SECRET_KEY=sk_test \
STRIPE_WEBHOOK_SECRET=whsec_test \
PAYPAL_CLIENT_ID=test \
PAYPAL_SECRET=test \
PAYPAL_WEBHOOK_ID=test \
npm start
```

### 3. Test Health Endpoint

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

### 4. Test CORS

#### Test Origin Autorizzata
```bash
curl -H "Origin: https://pet-care-9790d.web.app" \
     -H "Access-Control-Request-Method: POST" \
     -H "Access-Control-Request-Headers: Content-Type,Authorization" \
     -X OPTIONS \
     http://localhost:8080/api/auth/register
```

**Headers attesi nella response:**
```
Access-Control-Allow-Origin: https://pet-care-9790d.web.app
Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Allow-Credentials: true
```

#### Test Origin NON Autorizzata
```bash
curl -H "Origin: https://evil-site.com" \
     http://localhost:8080/api/auth/register
```

**Response attesa:**
```
Error: Not allowed by CORS
```

**Log server:**
```
[CORS] Origin NON consentita: https://evil-site.com
```

### 5. Test Rate Limiting

```bash
# Esegui 101 richieste in rapida successione
for i in {1..101}; do
  curl http://localhost:8080/api/auth/register
done
```

**Dopo la 100esima richiesta:**
```
HTTP/1.1 429 Too Many Requests
{
  "error": "Too many requests, please try again later."
}
```

---

## 🌐 Deployment su Cloud Run

### Variabili d'Ambiente Aggiuntive

Oltre alle variabili base, aggiungi (opzionale):

```bash
# Console Cloud Run o CLI
CORS_ALLOWED_ORIGINS=https://app.mypetcareapp.org,https://custom-domain.com
```

### Verifica Post-Deployment

```bash
# 1. Health check
curl https://pet-care-api-xxxxx-ew.a.run.app/health

# 2. Test CORS da browser
# Apri DevTools Console su https://pet-care-9790d.web.app
fetch('https://pet-care-api-xxxxx-ew.a.run.app/api/admin/stats', {
  method: 'GET',
  headers: {
    'Authorization': 'Bearer YOUR_TOKEN'
  }
})
.then(r => r.json())
.then(console.log)
.catch(console.error);
```

---

## 🔧 Configurazione Avanzata

### Aggiungere Nuove Origini CORS

#### Metodo A: Environment Variable (Raccomandato)
```bash
# Cloud Run Console
CORS_ALLOWED_ORIGINS=https://new-domain.com,https://another-domain.com
```

#### Metodo B: Modifica Codice
File: `src/middleware/cors.ts`
```typescript
const defaultOrigins = [
  'https://pet-care-9790d.web.app',
  'https://pet-care-9790d.firebaseapp.com',
  'http://localhost:5060',
  'https://app.mypetcareapp.org',  // ← Aggiungi qui
];
```

### Personalizzare Rate Limiting

File: `src/index.ts`
```typescript
// Rate limiting più aggressivo per admin API
const adminLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minuti
  max: 50,                   // Solo 50 richieste per IP
  standardHeaders: true,
});
app.use('/api/admin', adminLimiter);

// Rate limiting più permissivo per letture pubbliche
const publicLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  standardHeaders: true,
});
app.use('/api/pros', publicLimiter);
```

### Disabilitare Logging in Produzione

File: `src/index.ts`
```typescript
// Request logging solo in development
if (config.env === 'development') {
  app.use(morgan('combined'));
}
```

---

## 📊 Monitoring e Debugging

### Visualizza Logs CORS

I logs CORS warnings appariranno nei logs Cloud Run:
```bash
gcloud run services logs tail pet-care-api --region europe-west1
```

**Output esempio:**
```
2024-11-15 09:00:00 [CORS] Origin NON consentita: https://unauthorized-site.com
```

### Monitorare Rate Limiting

```bash
# Logs Cloud Run filtrando per 429 Too Many Requests
gcloud run services logs read pet-care-api \
  --region europe-west1 \
  --filter="httpRequest.status=429" \
  --limit 50
```

### Dashboard Cloud Run

Console: https://console.cloud.google.com/run

Metriche disponibili:
- Request count
- Request latency
- Error rate (4xx, 5xx)
- CPU utilization
- Memory utilization

---

## ⚠️ Troubleshooting

### CORS Error: "No 'Access-Control-Allow-Origin' header"

**Causa:** Origin non nella whitelist

**Soluzione:**
1. Verifica origin nel log: `[CORS] Origin NON consentita: ...`
2. Aggiungi origin a `CORS_ALLOWED_ORIGINS` environment variable
3. Rideploy servizio

### Rate Limit: "Too many requests"

**Causa:** Superato limite di 100 richieste in 15 minuti

**Soluzione:**
- **Development:** Aumenta `max` in apiLimiter
- **Production:** Normale protezione, user deve attendere

### Morgan Logging Non Appare

**Causa:** Morgan logs potrebbero essere bufferizzati

**Soluzione:**
```typescript
app.use(morgan('combined', {
  stream: {
    write: (message) => console.log(message.trim())
  }
}));
```

---

## ✅ Checklist Security

- [x] **CORS** configurato con whitelist esplicita
- [x] **Helmet** attivo per security headers
- [x] **Rate limiting** su tutte le API
- [x] **Request logging** per audit trail
- [x] **Environment variables** validation
- [x] **Error handling** senza leak di informazioni sensibili
- [ ] **HTTPS only** (gestito da Cloud Run)
- [ ] **Firebase Auth** validation su endpoint protetti
- [ ] **Input validation** con Zod schemas
- [ ] **SQL injection** protection (non applicabile, usa Firestore)
- [ ] **XSS protection** (gestito da Helmet)

---

## 📚 Risorse

- [Express Rate Limit](https://www.npmjs.com/package/express-rate-limit)
- [Helmet Security](https://helmetjs.github.io/)
- [Morgan Logging](https://github.com/expressjs/morgan)
- [CORS Documentation](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)

---

**Autore:** My Pet Care Backend Security Update  
**Versione:** 1.0.0  
**Data:** 2024-11-15  
**Status:** ✅ Pronto per deployment
