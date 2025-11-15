# MyPetCare – Checklist Go-Live

## 🌐 Domini
- [x] **app.mypetcareapp.org** → Firebase Hosting (DEPLOYMENT PRONTO)
- [ ] **api.mypetcareapp.org** → Cloud Run (backend)

---

## 🖥️ Backend (Cloud Run)

**📖 Guida Completa:** `backend/DEPLOY-CLOUDRUN.md`

- [ ] **Deploy backend su Cloud Run**
  - Comando: `gcloud run deploy mypetcare-backend --source . --region europe-west1`
  - Dettagli: vedi `backend/DEPLOY-CLOUDRUN.md` Sezione 2
- [ ] **Configurare variabili d'ambiente** in Cloud Run Console
  - Elenco completo: `backend/.env.production.example`
  - Istruzioni: vedi `backend/DEPLOY-CLOUDRUN.md` Sezione 3
- [ ] **Configurare domain mapping** a `api.mypetcareapp.org`
  - DNS setup: vedi `backend/DEPLOY-CLOUDRUN.md` Sezione 4
- [ ] **Test endpoint** `/health` funzionante
  - `curl https://api.mypetcareapp.org/health`
  - Test completi: vedi `backend/DEPLOY-CLOUDRUN.md` Sezione 5

---

## 💳 Pagamenti

### Stripe
- [ ] **Creare prodotti e Price ID LIVE** in Stripe Dashboard
  - Mensile: `price_xxxxxxxxx`
  - Annuale: `price_yyyyyyyy`
- [ ] **Aggiornare `lib/config.dart`** con Price ID reali
- [ ] **Configurare webhook Stripe**
  - URL: `https://api.mypetcareapp.org/webhooks/stripe`
  - Eventi: `customer.subscription.*`
- [ ] **Test abbonamento Stripe LIVE** con carta reale

### PayPal

**📖 Guida Completa:** `docs/PAYPAL-LIVE-SETUP.md`

- [ ] **Creare Billing Plan LIVE** in PayPal Dashboard
  - Plan ID mensile: `P-xxxxxxxxxxxx`
  - Istruzioni: vedi `docs/PAYPAL-LIVE-SETUP.md` Step 3
- [ ] **Aggiornare `lib/config.dart`** con Plan ID reali
  - Istruzioni: vedi `docs/PAYPAL-LIVE-SETUP.md` Sezione "Aggiornamenti nel Codice"
- [ ] **Configurare webhook PayPal**
  - URL: `https://api.mypetcareapp.org/webhooks/paypal`
  - Eventi: `BILLING.SUBSCRIPTION.*`
  - Istruzioni: vedi `docs/PAYPAL-LIVE-SETUP.md` Step 4
- [ ] **Test abbonamento PayPal LIVE** con account reale
  - Test completi: vedi `docs/PAYPAL-LIVE-SETUP.md` Sezione "Test in Produzione"

---

## 🔒 Sicurezza
- [ ] **Nessuna chiave segreta committata** nel codice
  - Verifica con: `git log -S "sk_live" -S "PAYPAL_SECRET"`
- [ ] **Google Maps API key** ristretta per dominio
  - Console: https://console.cloud.google.com/apis/credentials
  - Restrizione: `app.mypetcareapp.org`
- [ ] **Firestore Security Rules** verificate
  - Test con Firebase Emulator: `firebase emulators:start --only firestore`

---

## 📱 App Flutter
- [ ] **Deploy Flutter Web** su Firebase Hosting
  - Build pronto: `build/web/` (11 MB compressed)
  - Manuale: Firebase Console → Hosting → Deploy
  - CLI: `firebase deploy --only hosting` (richiede autenticazione)
- [ ] **Test produzione completo**
  - [x] Login email/password
  - [ ] Google Maps caricamento mappe
  - [ ] Prenotazioni Owner → PRO
  - [ ] Calendario PRO funzionante
  - [ ] Pagamento Stripe
  - [ ] Pagamento PayPal

---

## 📊 Monitoraggio Post-Launch
- [ ] **Firebase Analytics** attivo
- [ ] **Crashlytics** configurato
- [ ] **Cloud Logging** su Cloud Run monitorato
- [ ] **Alert webhook** Stripe/PayPal attivi

---

## 🎯 Prossimi Step Immediati

1. **Deploy Flutter Web** (build pronto, carica manualmente su Firebase Hosting)
2. **Creare Stripe Price IDs** in modalità LIVE
3. **Creare PayPal Plan IDs** in modalità LIVE
4. **Deploy backend Cloud Run** con env production
5. **Configurare webhook** Stripe + PayPal
6. **Test end-to-end** con pagamenti reali
