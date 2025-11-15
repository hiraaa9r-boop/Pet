# 🔑 API Keys Configuration - MyPetCare

**Data Configurazione:** 14 Novembre 2024  
**Progetto Firebase:** pet-care-9790d  
**Status:** ✅ CONFIGURATO

---

## 📱 Firebase API Keys

### 🌐 Web Platform
```dart
// lib/firebase_options.dart - Web Configuration
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyAYmHD9bdyek_sg-DBAJH25eWRGOuWIF6k',
  appId: '1:72431103725:web:4ee4fb4a04f1ec39e326e4',
  messagingSenderId: '72431103725',
  projectId: 'pet-care-9790d',
  authDomain: 'pet-care-9790d.firebaseapp.com',
  storageBucket: 'pet-care-9790d.firebasestorage.app',
);
```

**✅ Status:** Configurato in `lib/firebase_options.dart`

---

### 🤖 Android Platform
```dart
// lib/firebase_options.dart - Android Configuration
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyCKAKCjJb2_utnE7GVKYoRJL54TkKRzxKs',
  appId: '1:72431103725:android:a2bbea591780a9d7e326e4',
  messagingSenderId: '72431103725',
  projectId: 'pet-care-9790d',
  storageBucket: 'pet-care-9790d.firebasestorage.app',
);
```

**Google Maps API Key (Android):**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyCKAKCjJb2_utnE7GVKYoRJL54TkKRzxKs" />
```

**✅ Status:** 
- Configurato in `lib/firebase_options.dart`
- Configurato in `android/app/src/main/AndroidManifest.xml`

---

### 🍏 iOS Platform
```dart
// lib/firebase_options.dart - iOS Configuration
static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'AIzaSyCAzxhOpTqgrbhyEcWsAlMNN6k8FtkcSkU',
  appId: '1:72431103725:ios:b8e4fb4a04f1ec39e326e4',
  messagingSenderId: '72431103725',
  projectId: 'pet-care-9790d',
  storageBucket: 'pet-care-9790d.firebasestorage.app',
  iosBundleId: 'it.mypetcare.myPetCare',
);
```

**File da configurare manualmente (iOS):**
```xml
<!-- ios/Runner/GoogleService-Info.plist -->
<key>API_KEY</key>
<string>AIzaSyCAzxhOpTqgrbhyEcWsAlMNN6k8FtkcSkU</string>
```

**✅ Status:** 
- Configurato in `lib/firebase_options.dart`
- ⚠️ **TODO:** Configurare manualmente `ios/Runner/GoogleService-Info.plist` quando si compila per iOS

---

## 💳 Stripe Configuration

### Publishable Key (Client-Side)
```dart
// lib/config.dart
static const String stripePublishableKey = 
    'pk_live_51SPfsqLXZ73CzUdPBUMKZOvJxfaFbduP95vzLOjtdG8S00EtbhrpKJ1cwxuRlxjJtrY4dCQ2ZMEmLMPVK2xAkfq900itoo0iGY';
```

**✅ Status:** Configurato in `lib/config.dart`

**⚠️ IMPORTANTE:** Questa è la **Publishable Key** (pk_live_) che è sicura per il client-side.

---

### Secret Key (Server-Side)
**🔒 NON configurare nel Flutter app - Solo backend!**

```bash
# backend/.env (PRODUCTION)
STRIPE_SECRET_KEY=sk_live_****************
STRIPE_WEBHOOK_SECRET=whsec_**************
```

**Configurazione Cloud Run:**
```bash
# Quando deploya il backend su Cloud Run:
gcloud run services update mypetcare-backend \
  --set-env-vars="STRIPE_SECRET_KEY=sk_live_YOUR_SECRET_KEY" \
  --set-env-vars="STRIPE_WEBHOOK_SECRET=whsec_YOUR_WEBHOOK_SECRET"
```

**⚠️ Status:** Da configurare quando si deploya il backend

---

### Price IDs (Da Creare in Stripe Dashboard)
```dart
// lib/config.dart - Da aggiornare dopo creazione prodotti Stripe
static const String stripeMonthlyPriceId = 'price_STRIPE_MENSILE_LIVE'; // 👈 TODO
static const String stripeYearlyPriceId  = 'price_STRIPE_ANNUALE_LIVE'; // 👈 TODO
```

**📋 Prossimi Step Stripe:**
1. Vai su Stripe Dashboard (LIVE mode): https://dashboard.stripe.com
2. Crea prodotto "MyPetCare PRO - Mensile" (€29.99/mese ricorrente)
3. Crea prodotto "MyPetCare PRO - Annuale" (€299.99/anno ricorrente)
4. Copia i Price IDs generati (formato: `price_xxxxx`)
5. Aggiorna `lib/config.dart` con i Price IDs reali
6. Configura webhook: `https://api.mypetcareapp.org/webhooks/stripe`

**Guida completa:** `docs/STRIPE-LIVE-SETUP.md`

---

## 🅿️ PayPal Configuration

### Plan IDs (Da Creare in PayPal Dashboard)
```dart
// lib/config.dart - Da aggiornare dopo creazione piani PayPal
static const String paypalMonthlyPlanId = 'P_PAYPAL_MENSILE_LIVE'; // 👈 TODO
```

**📋 Prossimi Step PayPal:**
1. Vai su PayPal Developer (LIVE mode): https://developer.paypal.com
2. Crea REST API App (LIVE credentials)
3. Crea Billing Plan "MyPetCare PRO - Mensile" (€29.99/mese)
4. Copia il Plan ID (formato: `P-xxxxx`)
5. Aggiorna `lib/config.dart` con il Plan ID reale
6. Configura webhook: `https://api.mypetcareapp.org/webhooks/paypal`

**Guida completa:** `docs/PAYPAL-LIVE-SETUP.md`

---

### Client ID e Secret (Server-Side)
**🔒 NON configurare nel Flutter app - Solo backend!**

```bash
# backend/.env (PRODUCTION)
PAYPAL_CLIENT_ID=YOUR_LIVE_CLIENT_ID
PAYPAL_SECRET=YOUR_LIVE_SECRET
PAYPAL_WEBHOOK_ID=YOUR_WEBHOOK_ID
PAYPAL_API=https://api-m.paypal.com
```

**⚠️ Status:** Da configurare quando si deploya il backend

---

## 📋 Checklist Configurazione

### Frontend Flutter
- [x] Firebase Web API Key configurato
- [x] Firebase Android API Key configurato
- [x] Firebase iOS API Key configurato (in firebase_options.dart)
- [x] Google Maps Android API Key configurato
- [x] Stripe Publishable Key configurato
- [ ] **TODO:** Configurare GoogleService-Info.plist manualmente per iOS
- [ ] **TODO:** Aggiornare Stripe Price IDs dopo creazione prodotti
- [ ] **TODO:** Aggiornare PayPal Plan ID dopo creazione billing plan

### Backend (Da Configurare su Cloud Run)
- [ ] Stripe Secret Key (environment variable)
- [ ] Stripe Webhook Secret (environment variable)
- [ ] PayPal Client ID (environment variable)
- [ ] PayPal Secret (environment variable)
- [ ] PayPal Webhook ID (environment variable)

---

## 🚀 Deploy Aggiornato

### Archivio con Nuove API Keys
**File disponibili:**
- `mypetcare_UPDATED_KEYS.tar.gz` (11 MB)
- `mypetcare_UPDATED_KEYS.zip` (11 MB)

**Contengono:**
- ✅ Firebase API Keys aggiornate (Web, Android, iOS)
- ✅ Google Maps Android API Key aggiornata
- ✅ Stripe Publishable Key configurata
- ✅ Build Flutter web ottimizzato (release mode)

### Deploy su Firebase Hosting

**Opzione 1: Firebase CLI (veloce)**
```bash
cd C:\Users\pinca\Downloads
Expand-Archive -Path mypetcare_UPDATED_KEYS.zip -DestinationPath .
cd mypetcare_deploy_fix
firebase deploy --only hosting
```

**Opzione 2: Aggiornamento Quick (se hai già deployato)**
```bash
# Nella cartella dove hai già fatto il primo deploy
cd C:\Users\pinca\Downloads\mypetcare_deploy_FIXED\mypetcare_deploy_fix

# Sovrascrivi con nuova build
# (Scarica e estrai mypetcare_UPDATED_KEYS.zip)
# Copia il contenuto della cartella web/ nella tua cartella esistente

# Redeploy
firebase deploy --only hosting
```

---

## 🔒 Sicurezza

### ✅ Chiavi Pubbliche (Safe per Client-Side)
Queste chiavi sono configurate nel Flutter app e sono sicure:
- Firebase API Keys (tutte le piattaforme)
- Google Maps API Key (con restrizioni su Firebase Console)
- Stripe Publishable Key (pk_live_)

### 🔒 Chiavi Segrete (SOLO Backend)
Queste chiavi NON devono MAI essere nel codice Flutter:
- Stripe Secret Key (sk_live_)
- Stripe Webhook Secret (whsec_)
- PayPal Client ID e Secret
- Firebase Admin SDK Service Account

**Configurazione corretta:**
- Backend: Environment variables su Cloud Run
- Local Development: File `.env` (gitignored)

---

## 📚 Documentazione di Riferimento

- **Stripe Setup:** `docs/STRIPE-LIVE-SETUP.md`
- **PayPal Setup:** `docs/PAYPAL-LIVE-SETUP.md`
- **Backend Deploy:** `backend/DEPLOY-CLOUDRUN.md`
- **Firebase Deploy:** `FIREBASE_DEPLOY_MANUAL.md`
- **Project Overview:** `DEPLOY_SUMMARY.md`

---

## 📞 Support

Per problemi di configurazione:
1. Verifica che tutti i file siano stati aggiornati correttamente
2. Controlla i log di Firebase Hosting dopo il deploy
3. Testa l'autenticazione Firebase dalla web app
4. Verifica che le API Keys abbiano le restrizioni corrette su Firebase Console

---

**Last Updated:** 14 Novembre 2024  
**Version:** 1.0 - Initial Configuration
