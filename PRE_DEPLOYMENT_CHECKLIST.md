# ✅ Pre-Deployment Checklist - MyPetCare Production

**Completa questa checklist PRIMA di eseguire il deployment in produzione.**

---

## 📋 Checklist Overview

```
┌─────────────────────────────────────────────┐
│  📊 PROGRESS TRACKER                       │
├─────────────────────────────────────────────┤
│  [ ] 1. Credenziali & Secrets (6 items)   │
│  [ ] 2. Tool & Environment (5 items)       │
│  [ ] 3. GCP Configuration (7 items)        │
│  [ ] 4. Firebase Setup (4 items)           │
│  [ ] 5. Code & Config (8 items)            │
│  [ ] 6. Backup & Safety (5 items)          │
│  [ ] 7. Team & Communication (4 items)     │
│                                             │
│  TOTAL: 0/39 items completed               │
└─────────────────────────────────────────────┘
```

---

## 1️⃣ Credenziali & Secrets (6 items)

### **Stripe LIVE Credentials**
- [ ] **Stripe Secret Key** ottenuta da dashboard
  - Format: `sk_live_51xxxxxxxxxxxxx`
  - Location: https://dashboard.stripe.com/apikeys
  - ⚠️ NON usare `sk_test_xxx` (ambiente sandbox)

- [ ] **Stripe Webhook Secret** configurata
  - Format: `whsec_xxxxxxxxxxxxx`
  - Location: https://dashboard.stripe.com/webhooks
  - ⚠️ Creare webhook DOPO deployment backend

- [ ] **Stripe API Version** verificata
  - Versione raccomandata: Latest stable
  - Check: https://stripe.com/docs/api/versioning

### **PayPal LIVE Credentials**
- [ ] **PayPal Client ID** (LIVE mode)
  - Format: `AXXXXXXXXXXXXXXXxx`
  - Location: https://developer.paypal.com/dashboard/applications
  - ⚠️ NON usare sandbox credentials

- [ ] **PayPal Client Secret** (LIVE mode)
  - Format: `EXXXXXXXXXXXXXXXxx`
  - Location: Same as Client ID
  - ⚠️ Mantenere segreto (mai committare in git)

### **CRON Secret**
- [ ] **CRON_SECRET generato** (minimum 32 chars)
  - Comando: `openssl rand -hex 24`
  - ⚠️ Salvare in password manager

---

## 2️⃣ Tool & Environment (5 items)

### **CLI Tools Installed**
- [ ] **gcloud CLI** installato e aggiornato
  - Check: `gcloud --version`
  - Required: >= 400.0.0
  - Install: https://cloud.google.com/sdk/docs/install

- [ ] **firebase CLI** installato e aggiornato
  - Check: `firebase --version`
  - Required: >= 12.0.0
  - Install: `npm install -g firebase-tools`

- [ ] **flutter SDK** installato (versione corretta)
  - Check: `flutter --version`
  - Required: 3.35.4 (match sandbox version)
  - ⚠️ NON aggiornare se diversa

- [ ] **jq** installato (JSON parsing)
  - Check: `jq --version`
  - Install: `sudo apt install jq` (Linux) o `brew install jq` (Mac)

- [ ] **openssl** disponibile (secret generation)
  - Check: `openssl version`
  - Pre-installed on most systems

---

## 3️⃣ GCP Configuration (7 items)

### **Project Setup**
- [ ] **GCP Project ID** verificato
  - Project ID: `pet-care-9790d`
  - Check: `gcloud projects list`
  - Set: `gcloud config set project pet-care-9790d`

- [ ] **Billing Account** attivo
  - Check: https://console.cloud.google.com/billing
  - ⚠️ Carta credito valida configurata

- [ ] **GCP Authentication** completata
  - Check: `gcloud auth list`
  - Login: `gcloud auth login`
  - ⚠️ Usa account con permessi Owner/Editor

### **Required APIs Enabled**
- [ ] **Cloud Run API** enabled
  - Check: `gcloud services list --enabled | grep run.googleapis.com`
  - Enable: `gcloud services enable run.googleapis.com`

- [ ] **Cloud Scheduler API** enabled
  - Check: `gcloud services list --enabled | grep cloudscheduler`
  - Enable: `gcloud services enable cloudscheduler.googleapis.com`

- [ ] **Secret Manager API** enabled (se usi v2)
  - Check: `gcloud services list --enabled | grep secretmanager`
  - Enable: `gcloud services enable secretmanager.googleapis.com`

- [ ] **Firestore API** enabled
  - Check: Firestore database già creato
  - Location: https://console.firebase.google.com/u/0/project/pet-care-9790d/firestore

---

## 4️⃣ Firebase Setup (4 items)

### **Firebase Project**
- [ ] **Firebase Authentication** completato
  - Check: `firebase projects:list`
  - Login: `firebase login`
  - ⚠️ Stesso account GCP

- [ ] **Firebase Hosting** configurato
  - Check: `firebase.json` esiste in project root
  - Domain: `mypetcare.web.app`
  - SSL: Automatic (Firebase managed)

- [ ] **Firestore Database** creato
  - Location: https://console.firebase.google.com/project/pet-care-9790d/firestore
  - Mode: Production mode
  - ⚠️ Security rules configurate

- [ ] **Firebase Storage** bucket configurato
  - Bucket: `pet-care-9790d.appspot.com`
  - Check: https://console.firebase.google.com/project/pet-care-9790d/storage
  - ⚠️ CORS rules configurate

---

## 5️⃣ Code & Config (8 items)

### **Backend Code**
- [ ] **Backend compilato senza errori**
  - Check: `cd backend && npm run build`
  - ⚠️ Zero TypeScript errors

- [ ] **Tests backend passano**
  - Check: `cd backend && npm test`
  - ⚠️ Coverage > 70% raccomandato

- [ ] **Dockerfile presente** in `/backend`
  - Check: `ls -la backend/Dockerfile`
  - ⚠️ Multi-stage build raccomandato

### **Frontend Code**
- [ ] **Flutter dependencies aggiornate**
  - Check: `cd flutter_app && flutter pub get`
  - ⚠️ No conflitti dependencies

- [ ] **Flutter app compila senza errori**
  - Check: `flutter build web --release`
  - ⚠️ No build warnings critici

- [ ] **Flutter tests passano**
  - Check: `flutter test`
  - ⚠️ Widget tests principali coperti

### **Configuration Files**
- [ ] **firebase.json** configurato correttamente
  - Hosting target: `build/web`
  - Rewrite rules: SPA routing configurato
  - Headers: CORS + security headers

- [ ] **firestore.rules** aggiornate (production mode)
  - Check: `cat firestore.rules`
  - ⚠️ NO `allow read, write: if true;` in production!

---

## 6️⃣ Backup & Safety (5 items)

### **Data Backup**
- [ ] **Firestore backup** eseguito
  - Export: `gcloud firestore export gs://backup-bucket/pre-deploy`
  - ⚠️ Keep backup per rollback

- [ ] **Cloud Storage backup** eseguito (se critical data)
  - Tool: `gsutil -m cp -r gs://source gs://backup`
  - Optional per deployment iniziale

### **Rollback Preparation**
- [ ] **Current Cloud Run revision** documentata
  - Check: `gcloud run revisions list --service=mypetcare-backend`
  - Save: Latest revision ID per rollback

- [ ] **Firebase Hosting version** documentata
  - Check: `firebase hosting:channel:list`
  - Save: Current release ID

- [ ] **Rollback procedure** compresa dal team
  - Review: [PRODUCTION_DEPLOYMENT.md](./PRODUCTION_DEPLOYMENT.md) → Section "Rollback Procedures"
  - ⚠️ Almeno 2 team members devono conoscere procedura

---

## 7️⃣ Team & Communication (4 items)

### **Team Readiness**
- [ ] **Deployment owner** identificato
  - Chi esegue deployment: _________________
  - Backup owner: _________________

- [ ] **Monitoring team** assegnato (post-deployment)
  - Chi monitora logs 24h: _________________
  - Escalation contact: _________________

### **Communication Plan**
- [ ] **Maintenance window** comunicato (se downtime atteso)
  - Start time: _________________
  - Duration: _________________ (tipicamente 5-10 min)
  - Channels: Email, Slack, App notification

- [ ] **Post-deployment validation plan** definito
  - QA checklist assegnata a: _________________
  - User acceptance test: _________________
  - Go/No-Go decision owner: _________________

---

## ⚠️ Critical Warnings

### **STOP Deployment se:**

- ❌ **Stripe credentials** ancora in test mode (`sk_test_xxx`)
- ❌ **PayPal credentials** ancora in sandbox mode
- ❌ **Firestore rules** permettono `allow read, write: if true;`
- ❌ **Backend tests** falliscono
- ❌ **Flutter build** ha errori critici
- ❌ **Billing account** non attivo o carta scaduta
- ❌ **Nessun backup** Firestore eseguito (se dati esistenti)
- ❌ **Team non disponibile** per monitoring post-deployment

---

## 🚀 Ready to Deploy?

### **Final Pre-Flight Check**

```bash
# Execute questo script per validazione automatica
cd /home/user/flutter_app

# Check 1: GCP auth
gcloud auth list --filter=status:ACTIVE

# Check 2: Firebase auth
firebase projects:list

# Check 3: Backend build
cd backend && npm run build && cd ..

# Check 4: Flutter build
flutter build web --release

# Check 5: Secrets configurati
echo "STRIPE_SECRET: ${STRIPE_SECRET:+✅ SET}${STRIPE_SECRET:-❌ MISSING}"
echo "PAYPAL_CLIENT_ID: ${PAYPAL_CLIENT_ID:+✅ SET}${PAYPAL_CLIENT_ID:-❌ MISSING}"
echo "CRON_SECRET: ${CRON_SECRET:+✅ SET}${CRON_SECRET:-❌ MISSING}"
```

**Se tutti i check passano** ✅ → Procedi con deployment!

---

## 📊 Deployment Timeline

```
┌─────────────────────────────────────────────────┐
│  TIMELINE STIMATO                              │
├─────────────────────────────────────────────────┤
│  ⏰ T-60 min:  Complete checklist (1h)         │
│  ⏰ T-30 min:  Team sync meeting               │
│  ⏰ T-15 min:  Final backups                   │
│  ⏰ T-10 min:  Start deployment script         │
│  ⏰ T-5  min:  Monitor build progress          │
│  ⏰ T+0  min:  🚀 DEPLOYMENT COMPLETE          │
│  ⏰ T+5  min:  Health checks validation        │
│  ⏰ T+15 min:  QA testing start                │
│  ⏰ T+30 min:  User acceptance test            │
│  ⏰ T+1h min:  Go/No-Go decision               │
│  ⏰ T+2h min:  Announce to users (if Go)       │
└─────────────────────────────────────────────────┘
```

---

## ✅ Checklist Completion

**Prima di eseguire deployment**, verifica:

```
SUMMARY
=======
Total items:           39
Items completed:       ___ / 39
Completion %:          ___ %

REQUIRED FOR GO:       100% (39/39)
```

**Deployment autorizzato da**:
- Name: _________________________
- Role: _________________________
- Date: _________________________
- Time: _________________________
- Signature: ____________________

---

## 📞 Emergency Contacts

**In caso di problemi durante deployment**:

```
┌─────────────────────────────────────────────┐
│  🚨 EMERGENCY ROLLBACK                     │
├─────────────────────────────────────────────┤
│  Primary:   [Your Name] - [Phone]          │
│  Backup:    [Name] - [Phone]               │
│  GCP Admin: [Name] - [Phone]               │
│  On-call:   [Name] - [Phone]               │
└─────────────────────────────────────────────┘
```

**External Support**:
- GCP Support: https://cloud.google.com/support
- Firebase Support: https://firebase.google.com/support
- Stripe Support: https://support.stripe.com
- PayPal Support: https://www.paypal.com/us/smarthelp/contact-us

---

## 🎯 Next Steps

**Dopo aver completato checklist**:

1. ✅ **Review finale** con team lead
2. ✅ **Scheduling** deployment window
3. ✅ **Execute** deployment script:
   ```bash
   # Per v2 (raccomandato produzione)
   bash deploy_production_v2.sh
   
   # Per v1 (test/staging)
   bash deploy_production.sh
   ```
4. ✅ **Monitor** logs durante deployment
5. ✅ **Execute** QA checklist post-deployment
6. ✅ **Comunicare** risultato a stakeholders

---

**Good luck with your deployment! 🚀**

---

**Document Version**: 1.0  
**Last Updated**: 2025-01-28  
**Owner**: MyPetCare DevOps Team
