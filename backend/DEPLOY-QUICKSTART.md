# ⚡ Deploy Backend Cloud Run - Quick Start (5 Minuti)

**Progetto:** pet-care-9790d  
**Service:** mypetcare-backend  
**Region:** europe-west1

---

## 🚀 Deploy in 3 Comandi

### 1. Prepara Ambiente

```bash
# Login Google Cloud
gcloud auth login

# Imposta progetto
gcloud config set project pet-care-9790d

# Abilita API
gcloud services enable run.googleapis.com cloudbuild.googleapis.com
```

### 2. Deploy Backend

```bash
cd /home/user/flutter_app/backend

gcloud run deploy mypetcare-backend \
  --source . \
  --region=europe-west1 \
  --allow-unauthenticated \
  --memory=512Mi \
  --cpu=1 \
  --set-env-vars="NODE_ENV=production,PORT=8080"
```

**Tempo:** 3-5 minuti ⏱️

### 3. Configura Environment Variables

**Via Console (più facile):**

1. Vai su: https://console.cloud.google.com/run/detail/europe-west1/mypetcare-backend/variables?project=pet-care-9790d

2. Clicca "Edit & Deploy New Revision"

3. Aggiungi queste variabili:

```
BACKEND_BASE_URL=https://api.mypetcareapp.org
WEB_BASE_URL=https://app.mypetcareapp.org
STRIPE_SECRET_KEY=sk_live_YOUR_KEY
STRIPE_WEBHOOK_SECRET=whsec_YOUR_SECRET
PAYPAL_CLIENT_ID=YOUR_CLIENT_ID
PAYPAL_SECRET=YOUR_SECRET
PAYPAL_WEBHOOK_ID=YOUR_WEBHOOK_ID
PAYPAL_API=https://api-m.paypal.com
```

4. Clicca "Deploy"

---

## ✅ Verifica Deploy

```bash
# Ottieni URL
SERVICE_URL=$(gcloud run services describe mypetcare-backend \
  --region=europe-west1 \
  --format='value(status.url)')

# Test health
curl $SERVICE_URL/health

# Test registration
curl -X POST $SERVICE_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"uid":"test","role":"owner","fullName":"Test User","phone":"123","notifications":{"push":true,"email":true,"marketing":false}}'
```

**Output atteso:** `{"success": true, ...}`

---

## 🌐 Configura Custom Domain (Opzionale)

**1. Via Console:**
- Vai su: https://console.cloud.google.com/run/domains?project=pet-care-9790d
- Add Mapping → api.mypetcareapp.org

**2. DNS (Cloudflare):**
```
CNAME   api   ghs.googlehosted.com   (Proxy: OFF)
```

**3. Verifica:**
```bash
curl https://api.mypetcareapp.org/health
```

---

## 📊 Comandi Utili

```bash
# Logs real-time
gcloud run services logs tail mypetcare-backend --region=europe-west1

# Update env var
gcloud run services update mypetcare-backend \
  --region=europe-west1 \
  --update-env-vars="KEY=VALUE"

# Redeploy
gcloud run deploy mypetcare-backend --source . --region=europe-west1
```

---

## ❓ Problemi?

**Deploy Fails:**
- Verifica Dockerfile esiste
- Verifica package.json corretto
- Controlla build logs: `gcloud builds list --limit=5`

**500 Error:**
- Verifica environment variables configurate
- Controlla logs: `gcloud run services logs tail mypetcare-backend --region=europe-west1`

**Permission Denied:**
```bash
ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
gcloud projects add-iam-policy-binding pet-care-9790d \
  --member="user:$ACCOUNT" \
  --role="roles/run.admin"
```

---

## 📚 Guide Complete

- **Guida Dettagliata:** `DEPLOY-MANUAL-CLOUDRUN.md`
- **Script Automatico:** `./deploy-cloudrun.sh`
- **Security:** `SECURITY_REGISTRATION_UPDATE.md`

---

**✅ Deploy Completato in ~5 minuti!**
