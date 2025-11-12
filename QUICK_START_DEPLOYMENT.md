# ⚡ Quick Start - Deployment Produzione MyPetCare

**Deployment in produzione in 10 minuti** - Guida rapida per lancio immediato.

---

## 🎯 Prerequisiti (5 minuti)

### **1. Credenziali Stripe LIVE**
Vai su: https://dashboard.stripe.com/apikeys

```bash
export STRIPE_SECRET="sk_live_51xxxxxxxxxxxxx"
export STRIPE_WEBHOOK_SECRET="whsec_xxxxxxxxxxxxx"
```

### **2. Credenziali PayPal LIVE**
Vai su: https://developer.paypal.com/dashboard/applications

```bash
export PAYPAL_CLIENT_ID="AXXXXXXXXXXXXXXXxx"
export PAYPAL_CLIENT_SECRET="EXXXXXXXXXXXXXXXxx"
```

### **3. CRON Secret (Genera)**
```bash
export CRON_SECRET=$(openssl rand -hex 24)
echo "CRON_SECRET generato: $CRON_SECRET"
```

### **4. GCP Project ID**
```bash
export GCP_PROJECT_ID="pet-care-9790d"
export GCP_REGION="europe-west1"
```

### **5. Autenticazione**
```bash
# GCP login
gcloud auth login
gcloud config set project $GCP_PROJECT_ID

# Firebase login
firebase login
```

---

## 🚀 Deployment (4 minuti)

### **Metodo A: Script v2 (RACCOMANDATO - Secret Manager)**
```bash
cd /home/user/flutter_app
bash deploy_production_v2.sh
```

**Input richiesti** (inserisci quando richiesto):
1. Stripe Secret Key
2. Stripe Webhook Secret
3. PayPal Client ID
4. PayPal Client Secret
5. CRON Secret (Invio per auto-generare)
6. Conferma deployment: scrivi `yes`

**Output atteso**:
```
✅ Tutti i secrets salvati su Secret Manager
🏗️  Build immagine Docker...
☁️  Deploy backend con Secret Manager...
✅ Backend health OK
⏰ Scheduler configurato
🔥 Firestore configurato
📱 Flutter web compilato
🌐 Frontend deployato
✅ GO-LIVE COMPLETATO
```

---

### **Metodo B: Script v1 (Rapido - Env Vars)**
```bash
cd /home/user/flutter_app
bash deploy_production.sh
```

**Conferma**: Scrivi `yes` quando richiesto

---

## ✅ Validazione Post-Deploy (2 minuti)

### **1. Health Check Backend**
```bash
export BACKEND_URL=$(gcloud run services describe mypetcare-backend \
  --region=europe-west1 \
  --format='value(status.url)')

curl -sS "$BACKEND_URL/health" | jq .
```

**Output atteso**:
```json
{
  "status": "healthy",
  "timestamp": "2025-01-28T14:30:22.123Z",
  "services": {
    "firestore": "connected",
    "storage": "connected"
  }
}
```

---

### **2. Test Frontend**
```bash
curl -sS -o /dev/null -w "HTTP Status: %{http_code}\n" \
  https://mypetcare.web.app
```

**Output atteso**: `HTTP Status: 200`

---

### **3. Test Scheduler Endpoint**
```bash
curl -sS -X POST \
  -H "x-cron-key: $CRON_SECRET" \
  "$BACKEND_URL/jobs/send-reminders" | jq .
```

**Output atteso**:
```json
{
  "ok": true,
  "reminders_sent": 0,
  "message": "Reminders sent successfully"
}
```

---

## 🔧 Configurazione Webhook (3 minuti)

### **Stripe Webhooks**

**1. Vai su**: https://dashboard.stripe.com/webhooks

**2. Click**: "Add endpoint"

**3. Configura**:
```
Endpoint URL: https://your-backend-url.run.app/webhooks/stripe
Events:
  ✅ payment_intent.succeeded
  ✅ charge.succeeded
  ✅ invoice.payment_succeeded
```

**4. Copia Signing Secret** → Salva per update env vars

---

### **PayPal Webhooks**

**1. Vai su**: https://developer.paypal.com/dashboard/webhooks

**2. Click**: "Create Webhook"

**3. Configura**:
```
Webhook URL: https://your-backend-url.run.app/webhooks/paypal
Event types:
  ✅ PAYMENT.CAPTURE.COMPLETED
  ✅ CHECKOUT.ORDER.APPROVED
```

---

## 🧪 QA Rapido (5 minuti)

### **Script QA Automatizzato**
```bash
export BACKEND_URL="https://your-backend-url.run.app"
export ADMIN_TOKEN="your-firebase-admin-id-token"

bash qa_production_checklist.sh
```

**Output atteso**:
```
========================================
🎯 Test Automatizzati: 10
✅ Passed:  9
❌ Failed:  0
⏭️  Skipped: 1
📈 Pass Rate: 90%
========================================
```

---

### **Test Manuali Critici**

**1. Stripe Checkout Flow**
```bash
# 1. Vai su https://mypetcare.web.app
# 2. Effettua login
# 3. Crea booking
# 4. Click "Paga con Stripe"
# 5. Usa carta test: 4242 4242 4242 4242
# 6. Verifica PDF generato su Storage
```

**2. PayPal Capture Flow**
```bash
# 1. Crea nuovo booking
# 2. Click "Paga con PayPal"
# 3. Login PayPal Sandbox
# 4. Approva pagamento
# 5. Verifica PDF su Storage
```

**3. Booking Reminder**
```bash
# 1. Crea booking per domani (24h)
# 2. Attendi prossimo trigger scheduler (ogni ora)
# 3. Verifica notifica FCM ricevuta su mobile
```

---

## 🔄 Rollback Rapido (se necessario)

### **Rollback Backend (30 secondi)**
```bash
# Lista revisioni
gcloud run revisions list \
  --service=mypetcare-backend \
  --region=europe-west1

# Rollback a revisione precedente
PREVIOUS_REV="mypetcare-backend-00042-xxx"

gcloud run services update-traffic mypetcare-backend \
  --region=europe-west1 \
  --to-revisions=$PREVIOUS_REV=100

# Verifica
curl https://backend-url/health
```

---

### **Rollback Frontend (15 secondi)**
```bash
firebase hosting:rollback

# Verifica
firebase hosting:channel:list
```

---

## 📊 Monitoring Essenziale

### **Logs Backend (Realtime)**
```bash
gcloud run logs tail mypetcare-backend \
  --region=europe-west1 \
  --format=json
```

---

### **Errori Recenti (Ultimi 30 min)**
```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND \
   resource.labels.service_name=mypetcare-backend AND \
   severity>=ERROR" \
  --limit=50 \
  --format=json
```

---

### **Performance Metrics**
```bash
gcloud run services describe mypetcare-backend \
  --region=europe-west1 \
  --format=json | jq '.status.traffic'
```

---

## 🎯 Checklist Go-Live

Completa questa checklist prima di comunicare lancio:

### **Backend**
- [ ] Health check ritorna `"status": "healthy"`
- [ ] Stripe Secret configurato (chiave inizia con `sk_live_`)
- [ ] PayPal credentials LIVE (non sandbox)
- [ ] Scheduler job attivo (`gcloud scheduler jobs list`)
- [ ] Firestore rules deployate
- [ ] Cloud Storage bucket configurato

### **Frontend**
- [ ] App accessibile su `https://mypetcare.web.app`
- [ ] Login funzionante
- [ ] Dashboard admin accessibile
- [ ] Pagine booking caricate correttamente

### **Payments**
- [ ] Stripe webhook configurato e attivo
- [ ] PayPal webhook configurato e attivo
- [ ] Test payment con carta Stripe real
- [ ] Test PayPal capture flow
- [ ] PDF invoice generato su Storage

### **Notifications**
- [ ] FCM token generato su mobile
- [ ] Booking reminder inviato via FCM
- [ ] Chat message notification funzionante

### **Monitoring**
- [ ] Cloud Logging attivo
- [ ] Errori backend < 1% traffic
- [ ] Performance < 2s response time
- [ ] No errors critici in logs

---

## 🚨 Troubleshooting Rapido

### **Backend non risponde**
```bash
# Check service status
gcloud run services describe mypetcare-backend \
  --region=europe-west1 \
  --format='value(status.conditions[0].message)'

# Check logs
gcloud run logs tail mypetcare-backend --region=europe-west1

# Redeploy se necessario
bash deploy_production_v2.sh
```

---

### **Stripe webhook non funziona**
```bash
# Test endpoint locale
curl -X POST \
  -H "stripe-signature: test" \
  "$BACKEND_URL/webhooks/stripe"

# Check webhook secret configurato
gcloud run services describe mypetcare-backend \
  --region=europe-west1 \
  --format=json | grep STRIPE_WEBHOOK
```

---

### **Scheduler job non triggera**
```bash
# Check job status
gcloud scheduler jobs describe booking-reminders \
  --location=europe-west1

# Run manual trigger
gcloud scheduler jobs run booking-reminders \
  --location=europe-west1

# Check logs
gcloud logging read "resource.type=cloud_scheduler_job" --limit=20
```

---

### **Frontend mostra errori CORS**
```bash
# Check FRONT_URL env var
gcloud run services describe mypetcare-backend \
  --region=europe-west1 \
  --format=json | grep FRONT_URL

# Update se necessario
gcloud run services update mypetcare-backend \
  --region=europe-west1 \
  --update-env-vars FRONT_URL=https://mypetcare.web.app
```

---

## 📞 Support Contacts

### **GCP Issues**
- Console: https://console.cloud.google.com/
- Support: https://cloud.google.com/support

### **Firebase Issues**
- Console: https://console.firebase.google.com/
- Support: https://firebase.google.com/support

### **Stripe Issues**
- Dashboard: https://dashboard.stripe.com/
- Support: https://support.stripe.com/

### **PayPal Issues**
- Developer: https://developer.paypal.com/
- Support: https://www.paypal.com/us/smarthelp/contact-us

---

## 🎉 Successo!

Se hai completato tutti i step sopra:

✅ **Backend deployed** su Cloud Run  
✅ **Frontend live** su Firebase Hosting  
✅ **Payments LIVE** (Stripe + PayPal)  
✅ **Scheduler attivo** (reminders ogni ora)  
✅ **Webhooks configurati**  
✅ **QA validation passata**  

**🚀 MyPetCare è LIVE in produzione!**

---

## 📚 Next Steps

Dopo go-live:

1. **Monitor logs** per prime 24h
2. **Test all features** con dati reali
3. **Setup Cloud Monitoring alerts**
4. **Backup Firestore** (pianifica schedule)
5. **Update documentation** con production URLs
6. **Train team** su monitoring e rollback procedures

---

## 🔗 Risorse Utili

- [📖 PRODUCTION_DEPLOYMENT.md](./PRODUCTION_DEPLOYMENT.md) - Guida completa deployment
- [🔄 DEPLOYMENT_COMPARISON.md](./DEPLOYMENT_COMPARISON.md) - Confronto script v1 vs v2
- [✅ qa_production_checklist.sh](./qa_production_checklist.sh) - Script QA automatizzato
- [🚀 deploy_production_v2.sh](./deploy_production_v2.sh) - Script deployment con Secret Manager

---

**Tempo totale**: ~10-15 minuti per deployment completo  
**Difficoltà**: 🟢 Bassa (con script automatizzati)  
**Success rate**: 95%+ (con pre-flight checks)

**Buon lancio! 🎉**
