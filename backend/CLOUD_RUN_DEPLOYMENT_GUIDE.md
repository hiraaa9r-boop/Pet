# 🚀 Guida Deployment Backend su Google Cloud Run

Guida passo-passo per deployare il backend My Pet Care su Google Cloud Run.

---

## 📋 Prerequisiti

### Software Necessario
- ✅ **gcloud CLI** installato ([Download](https://cloud.google.com/sdk/docs/install))
- ✅ **Git Bash o PowerShell** (Windows)
- ✅ **Account Google Cloud** attivo
- ✅ **Progetto Firebase**: `pet-care-9790d`

### Verifica gcloud
```bash
gcloud --version
# Deve mostrare: Google Cloud SDK xxx.x.x
```

---

## 🟢 STEP 1: Configurazione Progetto

### 1.1 Autentica con Google Cloud

```bash
# Login con account Google
gcloud auth login

# Configura progetto
gcloud config set project pet-care-9790d

# Verifica configurazione
gcloud config list
```

**Output atteso:**
```
[core]
account = tuo@email.com
project = pet-care-9790d
```

### 1.2 Abilita API Necessarie

```bash
# Cloud Run API
gcloud services enable run.googleapis.com

# Cloud Build API
gcloud services enable cloudbuild.googleapis.com

# Container Registry API
gcloud services enable containerregistry.googleapis.com
```

---

## 🟢 STEP 2: Build Immagine Docker con Cloud Build

### 2.1 Naviga alla Directory Backend

```bash
# Windows PowerShell
cd C:\path\to\mypetcare\backend

# macOS/Linux
cd /path/to/mypetcare/backend

# Git Bash (Windows)
cd /c/path/to/mypetcare/backend
```

### 2.2 Submit Build a Cloud Build

```bash
# Build e push immagine Docker
gcloud builds submit --tag gcr.io/pet-care-9790d/pet-care-api
```

**Cosa fa questo comando:**
1. Comprime il codice locale (esclusi file in `.dockerignore`)
2. Invia a Google Cloud Build
3. Esegue il Dockerfile
4. Crea immagine: `gcr.io/pet-care-9790d/pet-care-api`
5. Pusha nel Container Registry

**Tempo stimato:** 3-5 minuti

**Output finale:**
```
BUILD SUCCESS
ID: abc123-def456-ghi789
IMAGES: gcr.io/pet-care-9790d/pet-care-api
```

---

## 🟢 STEP 3: Deploy su Cloud Run

### 3.1 Deploy Servizio

```bash
# Deploy con impostazioni base
gcloud run deploy pet-care-api \
  --image gcr.io/pet-care-9790d/pet-care-api \
  --region europe-west1 \
  --platform managed \
  --allow-unauthenticated
```

**Parametri:**
- `--image`: Immagine Docker da usare
- `--region`: Datacenter Europa (Milano)
- `--platform managed`: Cloud Run fully managed
- `--allow-unauthenticated`: API pubbliche (richieste senza auth Google)

**Durante il deploy ti chiederà:**
```
Allow unauthenticated invocations to [pet-care-api] (y/N)?
```
→ **Rispondi: `y`**

### 3.2 Salva l'URL del Servizio

**Output finale:**
```
Service [pet-care-api] revision [pet-care-api-00001-abc] has been deployed 
and is serving 100 percent of traffic.
Service URL: https://pet-care-api-xxxxx-ew.a.run.app
```

**💾 IMPORTANTE: Salva questo URL!**
```
https://pet-care-api-xxxxx-ew.a.run.app
```

Questo è il tuo nuovo **BACKEND_BASE_URL**.

---

## 🟢 STEP 4: Configurazione Variabili d'Ambiente

### 4.1 Variabili Obbligatorie

Le seguenti variabili DEVONO essere configurate per il funzionamento:

| Variabile | Descrizione | Dove Trovarlo |
|-----------|-------------|---------------|
| `FIREBASE_PROJECT_ID` | ID progetto Firebase | `pet-care-9790d` |
| `FIREBASE_CLIENT_EMAIL` | Email service account | Firebase Console → Project Settings → Service Accounts |
| `FIREBASE_PRIVATE_KEY` | Chiave privata (formato: `-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n`) | Firebase service account JSON |
| `STRIPE_SECRET_KEY` | Chiave segreta Stripe | Stripe Dashboard → Developers → API Keys (sk_live_...) |
| `STRIPE_WEBHOOK_SECRET` | Webhook signing secret | Stripe Dashboard → Webhooks (whsec_...) |
| `PAYPAL_CLIENT_ID` | Client ID PayPal | PayPal Developer Dashboard |
| `PAYPAL_SECRET` | Secret PayPal | PayPal Developer Dashboard |
| `PAYPAL_WEBHOOK_ID` | Webhook ID PayPal | PayPal Webhooks configuration |

### 4.2 Metodo A: Configurazione via Console (Consigliato)

1. **Vai in Cloud Run Console:**
   - https://console.cloud.google.com/run
   - Seleziona `pet-care-api`

2. **Modifica servizio:**
   - Click su **"Modifica e distribuisci nuova revisione"**

3. **Aggiungi variabili:**
   - Tab **"Variabili e secrets"**
   - Click **"Aggiungi variabile"**
   - Inserisci nome e valore
   - Ripeti per ogni variabile

4. **Salva e ridistribuisci:**
   - Click **"Distribuisci"**
   - Attendi completamento (1-2 minuti)

### 4.3 Metodo B: Configurazione via CLI

```bash
# Imposta singola variabile
gcloud run services update pet-care-api \
  --region europe-west1 \
  --set-env-vars "NODE_ENV=production"

# Imposta multiple variabili (una per riga)
gcloud run services update pet-care-api \
  --region europe-west1 \
  --set-env-vars "NODE_ENV=production,PORT=8080,FIREBASE_PROJECT_ID=pet-care-9790d"
```

### 4.4 Formato FIREBASE_PRIVATE_KEY

**⚠️ CRITICO:** La private key deve essere in formato singola linea:

```bash
# Input (dal JSON):
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...
...multiline...
-----END PRIVATE KEY-----

# Output (per Cloud Run):
-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n...multiline...\n-----END PRIVATE KEY-----\n
```

**Script di conversione:**
```bash
# Unix/Linux/macOS
cat firebase-admin-sdk.json | jq -r '.private_key' | awk '{printf "%s\\n", $0}'

# Windows PowerShell
(Get-Content firebase-admin-sdk.json | ConvertFrom-Json).private_key -replace "`n", "\n"
```

---

## 🟢 STEP 5: Verifica Deployment

### 5.1 Test Health Endpoint

```bash
# Sostituisci con il tuo URL
curl https://pet-care-api-xxxxx-ew.a.run.app/health
```

**Response attesa:**
```json
{
  "ok": true,
  "service": "mypetcare-backend",
  "version": "1.0.0",
  "timestamp": "2024-11-15T10:30:00.000Z",
  "env": "production"
}
```

### 5.2 Test Admin Endpoint (richiede token)

```bash
# Ottieni token Firebase da Flutter app
TOKEN="eyJhbGciOiJSUzI1NiIs..."

curl https://pet-care-api-xxxxx-ew.a.run.app/api/admin/stats \
  -H "Authorization: Bearer $TOKEN"
```

### 5.3 Controlla Logs

```bash
# Visualizza logs in tempo reale
gcloud run services logs tail pet-care-api --region europe-west1

# Visualizza ultimi 50 log
gcloud run services logs read pet-care-api --region europe-west1 --limit 50
```

---

## 🟢 STEP 6: Configurazione Flutter App

### 6.1 Aggiorna config.dart

File: `lib/config.dart`

```dart
class AppConfig {
  // ✅ AGGIORNA con il tuo URL Cloud Run
  static const String backendBaseUrl = 'https://pet-care-api-xxxxx-ew.a.run.app';
  
  // Mantieni invariati
  static const String webBaseUrl = 'https://app.mypetcareapp.org';
  static const String stripePublishableKey = 'pk_live_51SPfsq...';
  // ...
}
```

### 6.2 Rebuild Flutter App

```bash
cd flutter_app

# Web
flutter build web --release

# Android
flutter build apk --release
```

### 6.3 Test Registrazione

1. Apri Flutter app
2. Vai a registrazione
3. Compila form e registra
4. Verifica che la richiesta vada a `https://pet-care-api-xxxxx-ew.a.run.app/api/auth/register`
5. Controlla logs Cloud Run per vedere la richiesta

---

## 🟢 STEP 7: Configurazione CORS (Opzionale)

Se hai problemi CORS da Flutter Web, configura origini permesse.

### 7.1 Aggiorna Middleware CORS

File: `backend/src/index.ts`

```typescript
const allowedOrigins = [
  'https://pet-care-9790d.web.app',
  'https://pet-care-9790d.firebaseapp.com',
  'https://app.mypetcareapp.org',
  'http://localhost:5060' // Development
];

app.use(cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));
```

### 7.2 Rideploy

```bash
# Rebuild
npm run build

# Submit new build
gcloud builds submit --tag gcr.io/pet-care-9790d/pet-care-api

# Deploy updated service
gcloud run deploy pet-care-api \
  --image gcr.io/pet-care-9790d/pet-care-api \
  --region europe-west1
```

---

## 🟢 STEP 8: Mappatura Dominio Personalizzato (Opzionale)

### 8.1 Aggiungi Mapping in Cloud Run

1. **Cloud Run Console:**
   - https://console.cloud.google.com/run

2. **Mappature di domini:**
   - Click **"Aggiungi mapping"**

3. **Configura:**
   - Servizio: `pet-care-api`
   - Dominio: `api.mypetcareapp.org`
   - Click **"Continua"**

4. **Aggiungi record DNS:**
   - Tipo: `CNAME`
   - Nome: `api`
   - Valore: `ghs.googlehosted.com`
   - TTL: 3600

5. **Verifica mapping:**
   - Attendi propagazione DNS (5-30 minuti)
   - Test: `curl https://api.mypetcareapp.org/health`

### 8.2 Aggiorna Flutter Config

```dart
static const String backendBaseUrl = 'https://api.mypetcareapp.org';
```

---

## 📊 Comandi Utili Cloud Run

### Informazioni Servizio
```bash
# Dettagli servizio
gcloud run services describe pet-care-api --region europe-west1

# URL servizio
gcloud run services describe pet-care-api --region europe-west1 --format="value(status.url)"
```

### Gestione Revisioni
```bash
# Lista revisioni
gcloud run revisions list --service pet-care-api --region europe-west1

# Rollback a revisione precedente
gcloud run services update-traffic pet-care-api \
  --region europe-west1 \
  --to-revisions REVISION_NAME=100
```

### Scaling e Performance
```bash
# Configura auto-scaling
gcloud run services update pet-care-api \
  --region europe-west1 \
  --min-instances 0 \
  --max-instances 10 \
  --concurrency 80

# Configura risorse
gcloud run services update pet-care-api \
  --region europe-west1 \
  --memory 512Mi \
  --cpu 1
```

### Logs e Monitoring
```bash
# Logs realtime
gcloud run services logs tail pet-care-api --region europe-west1

# Logs con filtri
gcloud run services logs read pet-care-api \
  --region europe-west1 \
  --filter="severity>=ERROR" \
  --limit 100
```

---

## ⚠️ Troubleshooting

### Errore: "Service account does not have permission"

**Soluzione:**
```bash
# Aggiungi ruolo Cloud Run Admin
gcloud projects add-iam-policy-binding pet-care-9790d \
  --member="user:tuo@email.com" \
  --role="roles/run.admin"
```

### Errore: "Cannot find module 'firebase-admin'"

**Causa:** Dipendenze non installate nel container

**Soluzione:** Verifica `package.json` includa `firebase-admin` in `dependencies` (non `devDependencies`)

### Errore 500: "Internal Server Error"

**Debug:**
```bash
# Controlla logs
gcloud run services logs tail pet-care-api --region europe-west1
```

**Cause comuni:**
- Variabili ambiente mancanti
- FIREBASE_PRIVATE_KEY mal formattata
- Service account senza permessi Firestore

### Timeout durante deploy

**Soluzione:**
```bash
# Aumenta timeout
gcloud run deploy pet-care-api \
  --image gcr.io/pet-care-9790d/pet-care-api \
  --region europe-west1 \
  --timeout 300
```

---

## ✅ Checklist Post-Deployment

- [ ] Health endpoint risponde con `{"ok": true}`
- [ ] Variabili ambiente configurate (verifica logs non mostrano "undefined")
- [ ] API admin protette (401/403 senza token valido)
- [ ] Registrazione utenti funziona da Flutter app
- [ ] Stripe webhooks configurati con nuovo URL
- [ ] PayPal webhooks configurati con nuovo URL
- [ ] CORS permette richieste da Flutter Web
- [ ] Logs Cloud Run non mostrano errori critici
- [ ] Firestore Security Rules deployate
- [ ] Flutter config aggiornato con nuovo backend URL

---

## 📚 Risorse

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [gcloud CLI Reference](https://cloud.google.com/sdk/gcloud/reference/run)
- [Container Registry](https://cloud.google.com/container-registry/docs)
- [Environment Variables](https://cloud.google.com/run/docs/configuring/environment-variables)
- [Custom Domains](https://cloud.google.com/run/docs/mapping-custom-domains)

---

**Autore:** My Pet Care Backend Deployment Guide  
**Versione:** 1.0.0  
**Data:** 2024-11-15  
**Status:** ✅ Ready for production deployment
