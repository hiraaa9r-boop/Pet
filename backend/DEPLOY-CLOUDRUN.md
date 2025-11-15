# Deploy Backend MyPetCare su Google Cloud Run

## 🎯 Obiettivo
Deploy del backend Node.js/TypeScript MyPetCare su **Google Cloud Run** in produzione con configurazione completa delle variabili d'ambiente e domain mapping a `api.mypetcareapp.org`.

---

## 📋 Sezione 1 – Prerequisiti

### **1.1 Installazione Google Cloud SDK**

**macOS:**
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init
```

**Linux:**
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init
```

**Windows:**
Scarica e installa da: https://cloud.google.com/sdk/docs/install

### **1.2 Autenticazione e Configurazione Progetto**

```bash
# Autenticazione con account Google
gcloud auth login

# Imposta il progetto MyPetCare
gcloud config set project pet-care-9790d

# Verifica progetto attivo
gcloud config get-value project
# Output atteso: pet-care-9790d
```

### **1.3 Abilitare Servizi GCP Necessari**

```bash
# Abilita Cloud Run API
gcloud services enable run.googleapis.com

# Abilita Cloud Build API
gcloud services enable cloudbuild.googleapis.com

# Abilita Container Registry API
gcloud services enable containerregistry.googleapis.com

# Abilita Artifact Registry API (raccomandato per nuovi progetti)
gcloud services enable artifactregistry.googleapis.com

# Verifica servizi abilitati
gcloud services list --enabled | grep -E "(run|build|container|artifact)"
```

### **1.4 Creare Dockerfile** (se non esiste)

Assicurati che esista `backend/Dockerfile`:

```dockerfile
# backend/Dockerfile
FROM node:18-alpine

WORKDIR /app

# Copia package files
COPY package*.json ./

# Installa dipendenze
RUN npm ci --only=production

# Copia codice sorgente
COPY . .

# Compila TypeScript
RUN npm run build

# Esponi porta (Cloud Run usa PORT env var)
EXPOSE 8080

# Start server
CMD ["node", "dist/index.js"]
```

### **1.5 Creare .dockerignore** (se non esiste)

```
node_modules
dist
.env
.env.*
*.log
.git
.gitignore
README.md
```

---

## 🚀 Sezione 2 – Build & Deploy

### **Opzione A: Deploy Diretto con Source (Raccomandato)**

Cloud Run compila automaticamente il container:

```bash
# Naviga nella cartella backend
cd backend

# Deploy con build automatico
gcloud run deploy mypetcare-backend \
  --source . \
  --region europe-west1 \
  --platform managed \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --timeout 300 \
  --min-instances 0 \
  --max-instances 10 \
  --port 8080
```

### **Opzione B: Build Manuale + Deploy**

Se preferisci controllare manualmente il processo di build:

```bash
# Step 1: Build container image
gcloud builds submit --tag gcr.io/pet-care-9790d/mypetcare-backend

# Step 2: Deploy container image
gcloud run deploy mypetcare-backend \
  --image gcr.io/pet-care-9790d/mypetcare-backend \
  --region europe-west1 \
  --platform managed \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --timeout 300 \
  --min-instances 0 \
  --max-instances 10 \
  --port 8080
```

### **Parametri Deploy Spiegati:**

- `--source .` → Build automatico dal codice sorgente
- `--region europe-west1` → Region europea (buona per Italia)
- `--allow-unauthenticated` → Endpoint pubblici (API REST)
- `--memory 512Mi` → RAM allocata (aumentare se necessario)
- `--cpu 1` → 1 vCPU (sufficiente per carichi medi)
- `--timeout 300` → Timeout richiesta 5 minuti (per operazioni lunghe)
- `--min-instances 0` → Scale-to-zero per risparmiare costi
- `--max-instances 10` → Max container paralleli
- `--port 8080` → Porta esposta (Cloud Run usa PORT env var)

### **Output Atteso:**

```
✓ Building and deploying service [mypetcare-backend]...
✓ Deploying... Done.
  ✓ Creating Revision...
  ✓ Routing traffic...
Done.
Service [mypetcare-backend] revision [mypetcare-backend-00001-abc] has been deployed.
Service URL: https://mypetcare-backend-xxxxxxxxxx-ew.a.run.app
```

⚠️ **Salva la Service URL temporanea** - servirà per i test iniziali.

---

## ⚙️ Sezione 3 – Configurazione Variabili d'Ambiente

Le variabili d'ambiente **NON devono essere passate nel comando deploy**. Si configurano nella Cloud Run Console per maggiore sicurezza.

### **3.1 Configurazione via Console (Raccomandato)**

1. Vai su: https://console.cloud.google.com/run?project=pet-care-9790d
2. Clicca sul servizio **mypetcare-backend**
3. Clicca **"EDIT & DEPLOY NEW REVISION"** (in alto)
4. Scorri fino a **"Container, Variables & Secrets, Connections, Security"**
5. Clicca **"Variables & Secrets"** → **"ADD VARIABLE"**

### **3.2 Variabili da Configurare**

Aggiungi le seguenti variabili una per una:

| Nome Variabile | Valore Esempio | Note |
|---------------|---------------|------|
| `NODE_ENV` | `production` | Ambiente applicazione |
| `PORT` | `8080` | Porta Cloud Run (default) |
| `BACKEND_BASE_URL` | `https://api.mypetcareapp.org` | URL pubblico backend |
| `WEB_BASE_URL` | `https://app.mypetcareapp.org` | URL app Flutter |
| `STRIPE_SECRET_KEY` | `sk_live_xxxxxxxxxxxxx` | ⚠️ LIVE key da Stripe Dashboard |
| `STRIPE_WEBHOOK_SECRET` | `whsec_xxxxxxxxxxxxx` | Signing secret webhook Stripe |
| `PAYPAL_CLIENT_ID` | `XXXXXXXXXXXXXX` | Client ID da PayPal Developer |
| `PAYPAL_SECRET` | `YYYYYYYYYYYYYYYY` | Secret da PayPal Developer |
| `PAYPAL_WEBHOOK_ID` | `ZZZZZZZZZZZZZZ` | Webhook ID da PayPal |
| `PAYPAL_API` | `https://api-m.paypal.com` | API endpoint LIVE PayPal |

⚠️ **IMPORTANTE:**
- Non committare MAI queste chiavi nel codice
- Usa valori **LIVE** (non TEST/SANDBOX)
- Verifica che non ci siano spazi extra

### **3.3 Configurazione via CLI** (Alternativa)

```bash
gcloud run services update mypetcare-backend \
  --region europe-west1 \
  --update-env-vars NODE_ENV=production,PORT=8080,BACKEND_BASE_URL=https://api.mypetcareapp.org,WEB_BASE_URL=https://app.mypetcareapp.org

# Per variabili sensibili, usa --update-secrets (raccomandato)
# Richiede creazione secret in Secret Manager
```

### **3.4 Verificare Variabili Configurate**

```bash
gcloud run services describe mypetcare-backend \
  --region europe-west1 \
  --format="value(spec.template.spec.containers[0].env)"
```

---

## 🌐 Sezione 4 – Domain Mapping (api.mypetcareapp.org)

### **4.1 Aggiungere Domain Mapping su Cloud Run**

1. Vai su: https://console.cloud.google.com/run/domains?project=pet-care-9790d
2. Clicca **"ADD MAPPING"**
3. Compila i campi:
   - **Service:** `mypetcare-backend`
   - **Domain:** `api.mypetcareapp.org`
4. Cloud Run mostrerà i **record DNS da creare** (tipo A o CNAME)

**Output Esempio:**
```
Aggiungi i seguenti record DNS al tuo provider:

TIPO: A
NOME: api.mypetcareapp.org
VALORE: 216.239.32.21
VALORE: 216.239.34.21
VALORE: 216.239.36.21
VALORE: 216.239.38.21

OPPURE

TIPO: CNAME
NOME: api
VALORE: ghs.googlehosted.com
```

### **4.2 Configurare DNS su Cloudflare** (o altro provider)

#### **Se usi Cloudflare:**

1. Vai su: https://dash.cloudflare.com/
2. Seleziona dominio `mypetcareapp.org`
3. Vai su **DNS** → **Records**
4. Clicca **"Add record"**

**Record A (Raccomandato):**
```
Type: A
Name: api
IPv4 address: 216.239.32.21
Proxy status: DNS only (gray cloud) ⚠️ IMPORTANTE!
TTL: Auto
```

Ripeti per tutti gli IP forniti da Cloud Run (4 indirizzi).

**Record CNAME (Alternativa):**
```
Type: CNAME
Name: api
Target: ghs.googlehosted.com
Proxy status: DNS only (gray cloud) ⚠️ IMPORTANTE!
TTL: Auto
```

⚠️ **IMPORTANTE:** 
- **DISATTIVA Cloudflare Proxy** (cloud grigia, non arancione)
- Cloud Run gestisce già HTTPS con certificato automatico
- Cloudflare Proxy può causare errori di certificato SSL

### **4.3 Verifica Domain Mapping**

```bash
# Attendi propagazione DNS (5-30 minuti)
dig api.mypetcareapp.org

# Test connettività
curl https://api.mypetcareapp.org/health

# Output atteso:
# {"ok":true,"service":"mypetcare-backend","version":"1.0.0",...}
```

### **4.4 Certificato SSL Automatico**

Cloud Run genera automaticamente un certificato SSL per il dominio custom. Verifica:

1. Console Cloud Run → Servizio → **"DOMAIN MAPPINGS"**
2. Stato deve essere: ✅ **"Active"** con certificato SSL

Se il certificato non si attiva:
- Verifica che DNS sia configurato correttamente
- Attendi fino a 24 ore per propagazione DNS completa
- Verifica che Cloudflare Proxy sia disabilitato

---

## ✅ Sezione 5 – Test Post-Deploy

### **5.1 Test Health Check**

```bash
# Test endpoint health
curl https://api.mypetcareapp.org/health

# Output atteso:
{
  "ok": true,
  "service": "mypetcare-backend",
  "version": "1.0.0",
  "timestamp": "2024-11-14T...",
  "env": "production"
}
```

### **5.2 Test Endpoint Pagamenti Stripe**

```bash
# Test checkout session creation
curl -X POST https://api.mypetcareapp.org/api/payments/stripe/checkout \
  -H "Content-Type: application/json" \
  -d '{
    "priceId": "price_STRIPE_MENSILE_LIVE",
    "successUrl": "https://app.mypetcareapp.org/success",
    "cancelUrl": "https://app.mypetcareapp.org/cancel",
    "customerEmail": "test@example.com"
  }'

# Output atteso:
{
  "url": "https://checkout.stripe.com/c/pay/cs_test_..."
}
```

### **5.3 Test Webhook Stripe**

1. Vai su: https://dashboard.stripe.com/webhooks
2. Seleziona il webhook configurato
3. Clicca **"Send test webhook"**
4. Seleziona evento `customer.subscription.created`
5. Verifica risposta: **200 OK**

### **5.4 Test Endpoint Pagamenti PayPal**

```bash
# Test subscription creation
curl -X POST https://api.mypetcareapp.org/api/payments/paypal/checkout \
  -H "Content-Type: application/json" \
  -d '{
    "planId": "P_PAYPAL_MENSILE_LIVE",
    "returnUrl": "https://app.mypetcareapp.org/success",
    "cancelUrl": "https://app.mypetcareapp.org/cancel"
  }'

# Output atteso:
{
  "approveLink": "https://www.paypal.com/checkoutnow?token=..."
}
```

### **5.5 Test Webhook PayPal**

1. Vai su: https://developer.paypal.com/dashboard/webhooks
2. Seleziona il webhook configurato
3. Clicca **"Simulate event"**
4. Seleziona evento `BILLING.SUBSCRIPTION.ACTIVATED`
5. Verifica risposta: **200 OK**

### **5.6 Monitoraggio Logs**

```bash
# Visualizza logs in tempo reale
gcloud run logs tail mypetcare-backend --region europe-west1

# Filtra per errori
gcloud run logs read mypetcare-backend \
  --region europe-west1 \
  --filter="severity>=ERROR" \
  --limit 50
```

---

## 📊 Comandi Utili Post-Deploy

### **Aggiornare Servizio dopo Modifiche Codice**

```bash
cd backend
gcloud run deploy mypetcare-backend \
  --source . \
  --region europe-west1
```

### **Scalare Servizio**

```bash
# Aumentare max instances
gcloud run services update mypetcare-backend \
  --region europe-west1 \
  --max-instances 20

# Impostare min instances (sempre attivo)
gcloud run services update mypetcare-backend \
  --region europe-west1 \
  --min-instances 1
```

### **Rollback Versione Precedente**

```bash
# Lista revisioni
gcloud run revisions list --service mypetcare-backend --region europe-west1

# Rollback a revisione specifica
gcloud run services update-traffic mypetcare-backend \
  --region europe-west1 \
  --to-revisions mypetcare-backend-00001=100
```

### **Eliminare Servizio**

```bash
gcloud run services delete mypetcare-backend \
  --region europe-west1
```

---

## 🔍 Troubleshooting

### **Errore: "Container failed to start"**

Verifica:
```bash
# Check logs per errori di startup
gcloud run logs read mypetcare-backend --region europe-west1 --limit 100

# Cause comuni:
# - Variabili d'ambiente mancanti (es. STRIPE_SECRET_KEY)
# - Porta errata (deve essere 8080 o usare PORT env var)
# - Dipendenze mancanti in package.json
```

### **Errore: "503 Service Unavailable"**

Verifica:
- Servizio deployato correttamente: `gcloud run services list`
- Health check funzionante: `curl https://SERVICE_URL/health`
- Timeout non troppo basso (aumentare se necessario)

### **Errore: "Webhook signature verification failed"**

Verifica:
- `STRIPE_WEBHOOK_SECRET` configurato correttamente
- Webhook URL registrato su Stripe: `https://api.mypetcareapp.org/webhooks/stripe`
- Body parser raw per Stripe webhook (già configurato in `index.ts`)

---

## 📚 Risorse Utili

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud Run Pricing](https://cloud.google.com/run/pricing)
- [Custom Domains on Cloud Run](https://cloud.google.com/run/docs/mapping-custom-domains)
- [Environment Variables Best Practices](https://cloud.google.com/run/docs/configuring/environment-variables)

---

**✅ Deploy completato! Backend MyPetCare è live su api.mypetcareapp.org**
