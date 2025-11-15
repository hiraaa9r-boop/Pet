# 🚀 Deploy Backend su Google Cloud Run - Guida Manuale

**Progetto:** MyPetCare Backend  
**Service Name:** mypetcare-backend  
**Region:** europe-west1  
**Data:** 14 Novembre 2024

---

## 📋 Prerequisiti

### 1. Google Cloud CLI Installato

**Verifica installazione:**
```bash
gcloud --version
```

**Se non installato, scarica da:**
- https://cloud.google.com/sdk/docs/install

### 2. Autenticazione Google Cloud

```bash
# Login
gcloud auth login

# Verifica account attivo
gcloud auth list
```

### 3. Imposta Progetto Firebase

```bash
gcloud config set project pet-care-9790d

# Verifica progetto
gcloud config get-value project
```

### 4. Abilita API Necessarie

```bash
# Cloud Run API
gcloud services enable run.googleapis.com

# Cloud Build API (per build da source)
gcloud services enable cloudbuild.googleapis.com

# Container Registry API
gcloud services enable containerregistry.googleapis.com
```

---

## 🚀 Metodo 1: Deploy Automatico con Script

**Il modo più semplice:**

```bash
cd /home/user/flutter_app/backend
./deploy-cloudrun.sh
```

Lo script:
- ✅ Verifica prerequisiti
- ✅ Configura progetto
- ✅ Abilita API necessarie
- ✅ Deploya su Cloud Run
- ✅ Mostra URL del servizio
- ✅ Fornisce next steps

---

## 🚀 Metodo 2: Deploy Manuale Step-by-Step

### Step 1: Build e Deploy da Source

```bash
cd /home/user/flutter_app/backend

gcloud run deploy mypetcare-backend \
  --source . \
  --region=europe-west1 \
  --platform=managed \
  --allow-unauthenticated \
  --min-instances=0 \
  --max-instances=10 \
  --memory=512Mi \
  --cpu=1 \
  --timeout=300s \
  --set-env-vars="NODE_ENV=production,PORT=8080"
```

**Cosa succede:**
1. Cloud Build crea un container dal Dockerfile
2. Il container viene caricato su Container Registry
3. Cloud Run deploya il servizio
4. Viene generato un URL pubblico (https://mypetcare-backend-xxxxx-ew.a.run.app)

**Tempo stimato:** 3-5 minuti

### Step 2: Configura Environment Variables

**⚠️ CRITICO: Il servizio NON funzionerà senza queste variabili!**

**Metodo A: Via Console (CONSIGLIATO)**

1. Vai su: https://console.cloud.google.com/run/detail/europe-west1/mypetcare-backend/variables?project=pet-care-9790d

2. Clicca "Edit & Deploy New Revision"

3. Tab "Variables & Secrets" → "Add Variable"

4. Aggiungi TUTTE queste variabili:

```
BACKEND_BASE_URL=https://api.mypetcareapp.org
WEB_BASE_URL=https://app.mypetcareapp.org

STRIPE_SECRET_KEY=sk_live_YOUR_ACTUAL_KEY_HERE
STRIPE_WEBHOOK_SECRET=whsec_YOUR_ACTUAL_SECRET_HERE

PAYPAL_CLIENT_ID=YOUR_PAYPAL_CLIENT_ID
PAYPAL_SECRET=YOUR_PAYPAL_SECRET
PAYPAL_WEBHOOK_ID=YOUR_PAYPAL_WEBHOOK_ID
PAYPAL_API=https://api-m.paypal.com
```

5. Clicca "Deploy" per applicare le modifiche

**Metodo B: Via gcloud CLI**

```bash
gcloud run services update mypetcare-backend \
  --region=europe-west1 \
  --update-env-vars="BACKEND_BASE_URL=https://api.mypetcareapp.org" \
  --update-env-vars="WEB_BASE_URL=https://app.mypetcareapp.org" \
  --update-env-vars="STRIPE_SECRET_KEY=sk_live_XXX" \
  --update-env-vars="STRIPE_WEBHOOK_SECRET=whsec_XXX" \
  --update-env-vars="PAYPAL_CLIENT_ID=XXX" \
  --update-env-vars="PAYPAL_SECRET=XXX" \
  --update-env-vars="PAYPAL_WEBHOOK_ID=XXX" \
  --update-env-vars="PAYPAL_API=https://api-m.paypal.com"
```

### Step 3: Verifica Deployment

**Test Health Endpoint:**

```bash
# Ottieni URL servizio
SERVICE_URL=$(gcloud run services describe mypetcare-backend \
  --region=europe-west1 \
  --format='value(status.url)')

echo "Service URL: $SERVICE_URL"

# Test health
curl $SERVICE_URL/health
```

**Output atteso:**
```json
{
  "ok": true,
  "service": "mypetcare-backend",
  "version": "1.0.0",
  "timestamp": "2024-11-14T17:30:00.000Z",
  "env": "production"
}
```

### Step 4: Test Registration Endpoint

```bash
curl -X POST $SERVICE_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "uid": "test-uid-123",
    "role": "owner",
    "fullName": "Test User",
    "phone": "+39 333 1234567",
    "notifications": {
      "push": true,
      "email": true,
      "marketing": false
    }
  }'
```

**Output atteso:**
```json
{
  "success": true,
  "message": "User profile created successfully",
  "uid": "test-uid-123",
  "role": "owner"
}
```

---

## 🌐 Step 5: Configura Custom Domain

### Domain Mapping: api.mypetcareapp.org

**Metodo A: Via Console (CONSIGLIATO)**

1. Vai su: https://console.cloud.google.com/run/domains?project=pet-care-9790d

2. Clicca "Add Mapping"

3. Configura:
   - **Service:** mypetcare-backend
   - **Region:** europe-west1
   - **Domain:** api.mypetcareapp.org

4. Clicca "Continue" e copia i record DNS mostrati

**Metodo B: Via gcloud CLI**

```bash
gcloud run domain-mappings create \
  --service=mypetcare-backend \
  --domain=api.mypetcareapp.org \
  --region=europe-west1
```

### Configurazione DNS (Cloudflare)

**Record DNS da creare:**

```
Type    Name    Content                 Proxy   TTL
CNAME   api     ghs.googlehosted.com    Off     Auto
```

**⚠️ IMPORTANTE:** 
- Proxy deve essere **OFF** (DNS only)
- TTL può essere Auto o 300 secondi

**Verifica propagazione DNS:**
```bash
dig api.mypetcareapp.org
nslookup api.mypetcareapp.org
```

**Tempo propagazione:** 5-15 minuti

**Verifica SSL Certificate:**
- Google genera automaticamente certificato SSL
- Tempo: 15-30 minuti dopo configurazione DNS
- Verifica: https://api.mypetcareapp.org/health

---

## 🔒 Configurazione Firebase Admin SDK

### Opzione 1: Service Account Key File

**Download Service Account Key:**

1. Vai su: https://console.firebase.google.com/project/pet-care-9790d/settings/serviceaccounts/adminsdk

2. Clicca "Generate new private key"

3. Salva il file JSON scaricato

**Upload su Cloud Run:**

Il modo più semplice è usare Secret Manager:

```bash
# Crea secret
gcloud secrets create firebase-admin-sdk \
  --data-file=/path/to/firebase-admin-sdk.json

# Dai accesso al service account Cloud Run
gcloud secrets add-iam-policy-binding firebase-admin-sdk \
  --member="serviceAccount:$(gcloud iam service-accounts list --filter='displayName:Compute Engine default service account' --format='value(email)')" \
  --role="roles/secretmanager.secretAccessor"

# Monta secret come env var in Cloud Run
gcloud run services update mypetcare-backend \
  --region=europe-west1 \
  --update-secrets="GOOGLE_APPLICATION_CREDENTIALS=/secrets/firebase-admin-sdk:latest"
```

### Opzione 2: Default Credentials (Più Semplice)

Cloud Run usa automaticamente le credenziali del progetto. Assicurati che:

1. Il progetto Cloud Run sia lo stesso di Firebase (pet-care-9790d)
2. Il service account abbia i permessi Firestore

**Verifica permessi:**
```bash
# Service account Cloud Run
gcloud run services describe mypetcare-backend \
  --region=europe-west1 \
  --format='value(spec.template.spec.serviceAccountName)'

# Se usa default, dai permessi Firestore
gcloud projects add-iam-policy-binding pet-care-9790d \
  --member="serviceAccount:PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --role="roles/datastore.user"
```

---

## 📊 Monitoring & Logs

### Visualizza Logs

**Via Console:**
https://console.cloud.google.com/run/detail/europe-west1/mypetcare-backend/logs?project=pet-care-9790d

**Via gcloud CLI:**
```bash
# Logs in real-time
gcloud run services logs tail mypetcare-backend --region=europe-west1

# Ultimi 50 logs
gcloud run services logs read mypetcare-backend --region=europe-west1 --limit=50
```

### Monitoring Metrics

**Via Console:**
https://console.cloud.google.com/run/detail/europe-west1/mypetcare-backend/metrics?project=pet-care-9790d

**Metriche disponibili:**
- Request count
- Request latency
- CPU utilization
- Memory utilization
- Container instance count

### Alerting (Opzionale)

**Setup alerting per errori:**

1. Vai su Cloud Monitoring: https://console.cloud.google.com/monitoring?project=pet-care-9790d

2. Crea Policy:
   - Metric: Cloud Run → Request Count (5xx)
   - Condition: > 10 errors in 5 minutes
   - Notification: Email

---

## 🔧 Troubleshooting

### Problema 1: Deploy Fallisce con "Permission Denied"

**Causa:** Account non ha permessi Cloud Run Admin

**Soluzione:**
```bash
# Ottieni il tuo account
ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")

# Dai permessi necessari
gcloud projects add-iam-policy-binding pet-care-9790d \
  --member="user:$ACCOUNT" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding pet-care-9790d \
  --member="user:$ACCOUNT" \
  --role="roles/cloudbuild.builds.builder"
```

### Problema 2: Container Build Fallisce

**Verifica build logs:**
```bash
gcloud builds list --limit=5
gcloud builds log BUILD_ID
```

**Soluzioni comuni:**
- Verifica Dockerfile syntax
- Verifica package.json dependencies
- Verifica tsconfig.json esiste

### Problema 3: Service Starts ma Health Check Fails

**Causa:** Environment variables mancanti

**Verifica env vars:**
```bash
gcloud run services describe mypetcare-backend \
  --region=europe-west1 \
  --format='value(spec.template.spec.containers[0].env)'
```

**Soluzione:** Aggiungi tutte le env vars richieste (vedi Step 2)

### Problema 4: 500 Internal Server Error

**Controlla logs:**
```bash
gcloud run services logs tail mypetcare-backend --region=europe-west1
```

**Cause comuni:**
- Firebase Admin SDK non configurato
- Firestore permissions mancanti
- Environment variables incorrect

---

## 📋 Checklist Post-Deploy

### Backend Verification

- [ ] **Health endpoint risponde:**
  ```bash
  curl https://api.mypetcareapp.org/health
  ```

- [ ] **Registration endpoint funziona:**
  ```bash
  curl -X POST https://api.mypetcareapp.org/api/auth/register \
    -H "Content-Type: application/json" \
    -d '{"uid":"test","role":"owner","fullName":"Test","phone":"123","notifications":{"push":true,"email":true,"marketing":false}}'
  ```

- [ ] **Logs non mostrano errori:**
  ```bash
  gcloud run services logs read mypetcare-backend --region=europe-west1 --limit=20
  ```

- [ ] **Environment variables configurate:**
  - BACKEND_BASE_URL
  - WEB_BASE_URL
  - STRIPE_SECRET_KEY
  - STRIPE_WEBHOOK_SECRET
  - PAYPAL_CLIENT_ID
  - PAYPAL_SECRET
  - PAYPAL_WEBHOOK_ID

- [ ] **Custom domain funziona:**
  ```bash
  curl https://api.mypetcareapp.org/health
  ```

- [ ] **SSL certificate attivo** (https://api.mypetcareapp.org)

### Firebase Integration

- [ ] **Firestore permissions OK:**
  - Test write su collection users
  - Test write su collection pros

- [ ] **Firebase Admin SDK funziona:**
  - Nessun errore nei logs relativi a Firebase

### Frontend Integration

- [ ] **Flutter app chiama backend correttamente:**
  - Network tab mostra chiamata a https://api.mypetcareapp.org
  - Registrazione completa il flusso

- [ ] **CORS configurato correttamente:**
  - Nessun errore CORS in console browser

---

## 🎯 Comandi Utili Rapidi

```bash
# Deploy/Update servizio
gcloud run deploy mypetcare-backend --source . --region=europe-west1

# Get service URL
gcloud run services describe mypetcare-backend --region=europe-west1 --format='value(status.url)'

# Tail logs
gcloud run services logs tail mypetcare-backend --region=europe-west1

# Update env var
gcloud run services update mypetcare-backend --region=europe-west1 --update-env-vars="KEY=VALUE"

# Delete service (careful!)
gcloud run services delete mypetcare-backend --region=europe-west1

# List all services
gcloud run services list --region=europe-west1
```

---

## 📚 Riferimenti

- **Cloud Run Documentation:** https://cloud.google.com/run/docs
- **gcloud CLI Reference:** https://cloud.google.com/sdk/gcloud/reference/run
- **Custom Domains:** https://cloud.google.com/run/docs/mapping-custom-domains
- **Environment Variables:** https://cloud.google.com/run/docs/configuring/environment-variables
- **Secret Manager:** https://cloud.google.com/run/docs/configuring/secrets

---

**Status:** ✅ GUIDA COMPLETA DEPLOY CLOUD RUN

**Supporto:** petcareassistenza@gmail.com  
**Documentazione:** SECURITY_REGISTRATION_UPDATE.md + API_KEYS_CONFIG.md
