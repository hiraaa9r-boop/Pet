# MyPetCare – Checklist Go-Live

## 🌐 Domini

- [x] **app.mypetcareapp.org** → Firebase Hosting
  - Status: Configurato in firebase.json
  - SSL: Firebase auto-gestito
  - CDN: Firebase Hosting CDN

- [ ] **api.mypetcareapp.org** → Cloud Run
  - [ ] Deploy servizio su Cloud Run
  - [ ] Domain mapping configurato
  - [ ] DNS CNAME record: `api` → `ghs.googlehosted.com`
  - [ ] SSL certificato attivo (auto-managed)

---

## 🔧 Backend

### Deploy
- [ ] **Deploy servizio `mypetcare-backend` su Cloud Run**
  ```bash
  gcloud builds submit --tag gcr.io/pet-care-9790d/mypetcare-backend
  gcloud run deploy mypetcare-backend \
    --image gcr.io/pet-care-9790d/mypetcare-backend \
    --platform managed \
    --region europe-west1 \
    --allow-unauthenticated \
    --memory 512Mi \
    --timeout 300
  ```

### Environment Variables
- [ ] **Variabili ambiente configurate** (vedi `.env.production.example`)
  - [ ] `NODE_ENV=production`
  - [ ] `BACKEND_BASE_URL=https://api.mypetcareapp.org`
  - [ ] `WEB_BASE_URL=https://app.mypetcareapp.org`
  - [ ] `STRIPE_SECRET_KEY` (LIVE key)
  - [ ] `STRIPE_WEBHOOK_SECRET`
  - [ ] `PAYPAL_CLIENT_ID` (LIVE)
  - [ ] `PAYPAL_SECRET` (LIVE)
  - [ ] `PAYPAL_WEBHOOK_ID`
  - [ ] `PAYPAL_API=https://api-m.paypal.com`

### Health Check
- [ ] **Endpoint health accessibile**
  ```bash
  curl https://api.mypetcareapp.org/health
  # Expected: {"ok": true, "timestamp": "..."}
  ```

---

## 💳 Pagamenti

### Stripe
- [ ] **Stripe LIVE mode attivato**
  - [ ] Account verificato
  - [ ] Prodotto "MyPetCare PRO Subscription" creato
  - [ ] Price ID mensile creato (price_...)
  - [ ] Price ID annuale creato (opzionale)
  - [ ] Price IDs aggiunti in `lib/config.dart`

- [ ] **Stripe webhook configurato**
  - Dashboard: https://dashboard.stripe.com/webhooks
  - URL: `https://api.mypetcareapp.org/api/payments/stripe/webhook`
  - Eventi selezionati:
    - [x] `customer.subscription.created`
    - [x] `customer.subscription.updated`
    - [x] `customer.subscription.deleted`
    - [x] `invoice.payment_succeeded`
    - [x] `invoice.payment_failed`
  - [ ] Signing secret copiato in `STRIPE_WEBHOOK_SECRET`

- [ ] **Test abbonamento Stripe con carta reale**
  - [ ] Checkout funziona
  - [ ] Redirect a success URL
  - [ ] subscriptionStatus aggiornato in Firestore
  - [ ] Webhook ricevuto e processato

### PayPal
- [ ] **PayPal LIVE mode attivato**
  - [ ] App LIVE creata in PayPal Developer Dashboard
  - [ ] Billing Plan mensile creato (P-...)
  - [ ] Billing Plan annuale creato (opzionale)
  - [ ] Plan IDs aggiunti in `lib/config.dart`

- [ ] **PayPal webhook configurato**
  - Dashboard: https://developer.paypal.com/dashboard/webhooks
  - URL: `https://api.mypetcareapp.org/api/payments/paypal/webhook`
  - Eventi selezionati:
    - [x] `BILLING.SUBSCRIPTION.ACTIVATED`
    - [x] `BILLING.SUBSCRIPTION.UPDATED`
    - [x] `BILLING.SUBSCRIPTION.CANCELLED`
    - [x] `BILLING.SUBSCRIPTION.EXPIRED`
    - [x] `PAYMENT.SALE.COMPLETED`
  - [ ] Webhook ID copiato in `PAYPAL_WEBHOOK_ID`

- [ ] **Test abbonamento PayPal con account reale**
  - [ ] Checkout funziona
  - [ ] Redirect a success URL
  - [ ] subscriptionStatus aggiornato in Firestore
  - [ ] Webhook ricevuto e processato

---

## 🔒 Sicurezza

### Code Security
- [x] **Nessuna chiave segreta hardcoded**
  - [x] Stripe keys solo in env variables
  - [x] PayPal credentials solo in env variables
  - [x] No API keys in codice committed

### API Keys
- [ ] **Google Maps API key ristretta**
  - [ ] Android app package name aggiunto
  - [ ] iOS bundle ID aggiunto
  - [ ] Web referrer aggiunto (app.mypetcareapp.org)
  - [ ] Quotas e billing alerts configurati

### Firestore
- [ ] **Regole Firestore aggiornate e testate**
  - [ ] PRO possono scrivere solo il proprio documento
  - [ ] Owner possono creare solo proprie prenotazioni
  - [ ] Admin possono leggere/scrivere tutto
  - [ ] Validazione tipi dati
  - [ ] Test coverage > 80%

### Firebase Auth
- [ ] **Email verification obbligatoria**
- [ ] **Password strength requirements**
- [ ] **Rate limiting attivato**

---

## 📱 App

### Flutter Web
- [x] **Flutter web deployata su Firebase Hosting**
  - [x] Build release ottimizzata
  - [x] Tree-shaking abilitato
  - [x] Service worker attivo
  - [x] PWA manifest configurato
  - URL: https://app.mypetcareapp.org

### Android App
- [ ] **App Android buildata (release)**
  ```bash
  cd /home/user/flutter_app
  flutter build apk --release
  ```
  - [ ] Testata contro API production
  - [ ] Google Play Console configurata
  - [ ] Signing key generato e salvato
  - [ ] App Bundle creato (opzionale)
  - [ ] Internal testing track attivo

### iOS App
- [ ] **App iOS buildata (se/quando serve)**
  ```bash
  cd /home/user/flutter_app
  flutter build ios --release
  ```
  - [ ] Testata contro API production
  - [ ] Apple Developer account attivo
  - [ ] Provisioning profiles configurati
  - [ ] TestFlight testing attivo

---

## 🔔 Notifiche

- [ ] **Firebase Cloud Messaging configurato**
  - [ ] FCM server key aggiunto in backend
  - [ ] Android app configurata (google-services.json)
  - [ ] iOS app configurata (GoogleService-Info.plist)
  - [ ] Permessi notifiche richiesti in app

- [ ] **Test notifiche push**
  - [ ] Test da Firebase Console
  - [ ] Test da backend API
  - [ ] Notifica ricevuta su Android
  - [ ] Notifica ricevuta su iOS

---

## 📊 Monitoring & Analytics

### Firebase Analytics
- [ ] **Analytics configurato**
  - [ ] Eventi custom tracciati
  - [ ] Conversioni definite
  - [ ] Dashboard configurata

### Error Tracking
- [ ] **Crashlytics attivato**
  - [ ] Android configurato
  - [ ] iOS configurato
  - [ ] Alerts configurati

### Performance Monitoring
- [ ] **Performance Monitoring attivato**
  - [ ] Custom traces definiti
  - [ ] Network requests tracciate
  - [ ] Alerts configurati

### Logging
- [ ] **Cloud Run logs configurati**
  - [ ] Log level: INFO in production
  - [ ] Log retention: 30 giorni
  - [ ] Log-based metrics creati
  - [ ] Alerts su errori critici

---

## 🧪 Testing

### End-to-End Flow
- [ ] **User journey completo testato**
  1. [ ] Registrazione Owner
  2. [ ] Login Owner
  3. [ ] Ricerca PRO nella mappa
  4. [ ] Prenotazione servizio
  5. [ ] Notifica ricevuta

- [ ] **PRO journey completo testato**
  1. [ ] Registrazione PRO
  2. [ ] Abbonamento con Stripe
  3. [ ] Setup calendario
  4. [ ] Ricezione prenotazione
  5. [ ] Conferma/Rifiuta prenotazione

### Load Testing
- [ ] **Backend load test eseguito**
  - [ ] 100 concurrent users
  - [ ] Latenza < 500ms (p95)
  - [ ] Error rate < 1%

---

## 📝 Documentation

- [x] **DEPLOY_GUIDE.md** - Guida deploy completa
- [x] **OPERATIONS-GOLIVE.md** - Questa checklist
- [ ] **API_DOCUMENTATION.md** - API endpoints documentati
- [ ] **RUNBOOK.md** - Operazioni comuni e troubleshooting
- [ ] **INCIDENT_RESPONSE.md** - Piano risposta incidenti

---

## 🚨 Rollback Plan

- [ ] **Backup pre-deploy eseguito**
  - [ ] Database Firestore export
  - [ ] Firebase Hosting version snapshot
  - [ ] Cloud Run previous revision salvata

- [ ] **Rollback procedure documentata**
  ```bash
  # Rollback Cloud Run
  gcloud run services update-traffic mypetcare-backend \
    --to-revisions=PREVIOUS_REVISION=100

  # Rollback Firebase Hosting
  firebase hosting:rollback
  ```

---

## ✅ Final Sign-Off

- [ ] **Product Owner approval**
- [ ] **Tech Lead approval**
- [ ] **QA approval**
- [ ] **Security review completed**
- [ ] **Go-Live date scheduled**: ______________
- [ ] **Post-launch monitoring plan**: 24h on-call

---

## 📞 Support Contacts

- **Product Owner**: _______________
- **Tech Lead**: _______________
- **On-call Engineer**: _______________
- **Firebase Support**: https://firebase.google.com/support
- **Stripe Support**: https://support.stripe.com
- **PayPal Support**: https://www.paypal.com/merchantsupport

---

**Last Updated**: 2024-11-14
**Next Review**: Before Go-Live
