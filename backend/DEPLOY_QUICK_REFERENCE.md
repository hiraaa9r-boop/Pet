# 🚀 Cloud Run Deployment - Quick Reference

Comandi rapidi per deployment backend My Pet Care su Google Cloud Run.

---

## ⚡ Deployment Rapido (3 Comandi)

### Windows PowerShell

```powershell
cd C:\path\to\mypetcare\backend

# 1. Configura progetto
gcloud config set project pet-care-9790d

# 2. Build + Push immagine
gcloud builds submit --tag gcr.io/pet-care-9790d/pet-care-api

# 3. Deploy su Cloud Run
gcloud run deploy pet-care-api `
  --image gcr.io/pet-care-9790d/pet-care-api `
  --region europe-west1 `
  --platform managed `
  --allow-unauthenticated
```

### Linux / macOS / Git Bash

```bash
cd /path/to/mypetcare/backend

# 1. Configura progetto
gcloud config set project pet-care-9790d

# 2. Build + Push immagine
gcloud builds submit --tag gcr.io/pet-care-9790d/pet-care-api

# 3. Deploy su Cloud Run
gcloud run deploy pet-care-api \
  --image gcr.io/pet-care-9790d/pet-care-api \
  --region europe-west1 \
  --platform managed \
  --allow-unauthenticated
```

---

## 📜 Script Automatizzati

### Opzione A: Script PowerShell (Windows)

```powershell
# Deploy completo (build + deploy)
.\deploy-cloudrun.ps1

# Solo build (senza deploy)
.\deploy-cloudrun.ps1 -BuildOnly

# Solo deploy (immagine già buildrata)
.\deploy-cloudrun.ps1 -DeployOnly
```

### Opzione B: Script Bash (Linux/macOS)

```bash
# Deploy completo
./deploy-cloudrun-simple.sh
```

---

## 🔧 Variabili d'Ambiente Essenziali

**Metodo Console (Raccomandato):**
1. https://console.cloud.google.com/run
2. Click su `pet-care-api`
3. "Modifica e distribuisci nuova revisione"
4. Tab "Variabili e secrets"
5. Aggiungi:

```
NODE_ENV=production
PORT=8080
FIREBASE_PROJECT_ID=pet-care-9790d
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxx@pet-care-9790d.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n
STRIPE_SECRET_KEY=sk_live_xxx...
STRIPE_WEBHOOK_SECRET=whsec_xxx...
PAYPAL_CLIENT_ID=xxx...
PAYPAL_SECRET=xxx...
```

**Metodo CLI:**
```bash
gcloud run services update pet-care-api \
  --region europe-west1 \
  --set-env-vars "NODE_ENV=production,PORT=8080,FIREBASE_PROJECT_ID=pet-care-9790d"
```

---

## ✅ Verifica Deployment

### 1. Health Check
```bash
# Sostituisci con il tuo URL
curl https://pet-care-api-xxxxx-ew.a.run.app/health
```

**Risposta attesa:**
```json
{
  "ok": true,
  "service": "mypetcare-backend",
  "version": "1.0.0",
  "env": "production"
}
```

### 2. Visualizza Logs
```bash
gcloud run services logs tail pet-care-api --region europe-west1
```

### 3. Ottieni URL Servizio
```bash
gcloud run services describe pet-care-api \
  --region europe-west1 \
  --format="value(status.url)"
```

---

## 🔄 Rideploy (Dopo Modifiche Codice)

```bash
# 1. Rebuild immagine
gcloud builds submit --tag gcr.io/pet-care-9790d/pet-care-api

# 2. Deploy nuova versione (usa automaticamente l'immagine più recente)
gcloud run deploy pet-care-api \
  --image gcr.io/pet-care-9790d/pet-care-api \
  --region europe-west1
```

**Nota:** Cloud Run mantiene le variabili d'ambiente tra i deploy.

---

## 📱 Aggiorna Flutter Config

Dopo il primo deploy, aggiorna `lib/config.dart`:

```dart
class AppConfig {
  // ✅ Aggiorna con il tuo URL Cloud Run
  static const String backendBaseUrl = 'https://pet-care-api-xxxxx-ew.a.run.app';
  // ...
}
```

Poi rebuild Flutter:
```bash
cd flutter_app
flutter build web --release
flutter build apk --release
```

---

## ⚠️ Troubleshooting Rapido

### Errore: "Cannot find module 'firebase-admin'"
```bash
# Verifica package.json
cat package.json | grep firebase-admin
# Deve essere in "dependencies", non "devDependencies"
```

### Errore 500: Internal Server Error
```bash
# Controlla logs
gcloud run services logs tail pet-care-api --region europe-west1

# Verifica variabili ambiente
gcloud run services describe pet-care-api --region europe-west1 --format="value(spec.template.spec.containers[0].env)"
```

### Errore: "Service account does not have permission"
```bash
# Aggiungi ruolo Cloud Run Admin
gcloud projects add-iam-policy-binding pet-care-9790d \
  --member="user:tuo@email.com" \
  --role="roles/run.admin"
```

---

## 🌐 Dominio Personalizzato (Opzionale)

### Mappatura Dominio

1. **Cloud Run Console:**
   - https://console.cloud.google.com/run
   - "Mappature di domini" → "Aggiungi mapping"

2. **Configura:**
   - Servizio: `pet-care-api`
   - Dominio: `api.mypetcareapp.org`

3. **DNS Record:**
   - Tipo: `CNAME`
   - Nome: `api`
   - Valore: `ghs.googlehosted.com`

4. **Aggiorna Flutter:**
   ```dart
   static const String backendBaseUrl = 'https://api.mypetcareapp.org';
   ```

---

## 📊 Comandi Utili

```bash
# Info servizio
gcloud run services describe pet-care-api --region europe-west1

# Lista revisioni
gcloud run revisions list --service pet-care-api --region europe-west1

# Rollback a revisione precedente
gcloud run services update-traffic pet-care-api \
  --region europe-west1 \
  --to-revisions REVISION_NAME=100

# Configura scaling
gcloud run services update pet-care-api \
  --region europe-west1 \
  --min-instances 0 \
  --max-instances 10

# Configura risorse
gcloud run services update pet-care-api \
  --region europe-west1 \
  --memory 512Mi \
  --cpu 1
```

---

## ✅ Checklist

- [ ] gcloud CLI installato e autenticato
- [ ] Progetto configurato: `pet-care-9790d`
- [ ] Build completato senza errori
- [ ] Deploy completato e URL ottenuto
- [ ] Variabili d'ambiente configurate
- [ ] Health endpoint risponde
- [ ] Flutter config aggiornato con nuovo URL
- [ ] App testata con nuovo backend

---

**📚 Documentazione Completa:** `CLOUD_RUN_DEPLOYMENT_GUIDE.md`

**🛠️ Supporto:** Consulta logs con `gcloud run services logs tail`
