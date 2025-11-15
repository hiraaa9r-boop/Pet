# 🔑 Configurazione Completa API Keys - MY PET CARE

Guida dettagliata per configurare **TUTTE** le chiavi API necessarie per il funzionamento completo dell'applicazione.

---

## 📋 Indice

1. [Firebase Configuration](#1-firebase-configuration)
2. [Stripe Payment Keys](#2-stripe-payment-keys)
3. [PayPal Payment Keys](#3-paypal-payment-keys)
4. [Google Maps API Keys](#4-google-maps-api-keys)
5. [Variabili d'Ambiente Backend](#5-variabili-dambiente-backend)
6. [Variabili d'Ambiente Frontend](#6-variabili-dambiente-frontend)
7. [Security Best Practices](#7-security-best-practices)
8. [Testing delle Configurazioni](#8-testing-delle-configurazioni)

---

## 1. Firebase Configuration

### 1.1 Firebase Admin SDK (Backend)

**Dove ottenerlo:**
1. Firebase Console → https://console.firebase.google.com/
2. Seleziona progetto: **pet-care-9790d**
3. ⚙️ **Project settings** → **Service accounts**
4. **Genera nuova chiave privata** (Python)
5. Scarica file JSON

**Dove configurarlo:**

**Backend:**
```bash
# Posiziona il file in:
backend/firebase-admin-sdk.json

# Oppure su Cloud Run:
# Usa Secret Manager e monta come volume
```

**File `.env`:**
```bash
GOOGLE_APPLICATION_CREDENTIALS=./firebase-admin-sdk.json
FIREBASE_PROJECT_ID=pet-care-9790d
FIREBASE_STORAGE_BUCKET=pet-care-9790d.appspot.com
```

### 1.2 google-services.json (Android)

**Dove ottenerlo:**
1. Firebase Console → Project settings
2. **Android app** → Download `google-services.json`

**Dove posizionarlo:**
```
android/app/google-services.json
```

### 1.3 GoogleService-Info.plist (iOS)

**Dove ottenerlo:**
1. Firebase Console → Project settings
2. **iOS app** → Download `GoogleService-Info.plist`

**Dove posizionarlo:**
```
ios/Runner/GoogleService-Info.plist
```

### 1.4 Firebase Options (Flutter)

**File:** `lib/firebase_options.dart`

Già presente e configurato con:
- Web configuration
- Android configuration
- iOS configuration

---

## 2. Stripe Payment Keys

### 2.1 Ottieni le Chiavi

**Stripe Dashboard:** https://dashboard.stripe.com/apikeys

**Chiavi Necessarie:**
1. **Publishable Key** (`pk_test_...` o `pk_live_...`)
   - Usato nel **frontend Flutter**
   - Sicuro da committare pubblicamente
   - Usato per creare Checkout Session

2. **Secret Key** (`sk_test_...` o `sk_live_...`)
   - Usato nel **backend Node.js**
   - **MAI committare su Git**
   - Usato per operazioni server-side

3. **Webhook Secret** (`whsec_...`)
   - Validazione webhook Stripe
   - Ottieni creando endpoint webhook

### 2.2 Configurazione Backend

**File:** `backend/.env`

```bash
STRIPE_SECRET_KEY=sk_test_51QG1U8DqQmWzLvPh...
STRIPE_WEBHOOK_SECRET=whsec_abc123...
STRIPE_MONTHLY_PRICE_ID=price_1ABC...
STRIPE_YEARLY_PRICE_ID=price_1DEF...
```

### 2.3 Configurazione Frontend

**File:** `lib/config.dart`

```dart
class AppConfig {
  static const String stripePublishableKey = 'pk_test_51QG1U8DqQmWzLvPh...';
  static const String stripeMonthlyPriceId = 'price_1ABC...';
}
```

### 2.4 Setup Webhook Stripe

**Endpoint da configurare:**
```
https://your-backend-url/api/payments/stripe/webhook
```

**Events da ascoltare:**
- `checkout.session.completed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `invoice.payment_succeeded`
- `invoice.payment_failed`

---

## 3. PayPal Payment Keys

### 3.1 Ottieni le Credenziali

**PayPal Developer Dashboard:** https://developer.paypal.com/dashboard/

**Chiavi Necessarie:**
1. **Client ID** (`YOUR_CLIENT_ID`)
2. **Secret** (`YOUR_SECRET`)
3. **Webhook ID** (dopo aver creato webhook)

**Ambienti:**
- **Sandbox:** `https://api-m.sandbox.paypal.com` (development)
- **Live:** `https://api-m.paypal.com` (production)

### 3.2 Configurazione Backend

**File:** `backend/.env`

```bash
PAYPAL_CLIENT_ID=YOUR_PAYPAL_CLIENT_ID_HERE
PAYPAL_SECRET=YOUR_PAYPAL_SECRET_HERE
PAYPAL_API=https://api-m.sandbox.paypal.com
PAYPAL_WEBHOOK_ID=YOUR_WEBHOOK_ID
```

### 3.3 Setup Webhook PayPal

**Endpoint da configurare:**
```
https://your-backend-url/api/payments/paypal/webhook
```

**Events da ascoltare:**
- `PAYMENT.CAPTURE.COMPLETED`
- `PAYMENT.CAPTURE.DENIED`
- `BILLING.SUBSCRIPTION.CREATED`
- `BILLING.SUBSCRIPTION.ACTIVATED`
- `BILLING.SUBSCRIPTION.CANCELLED`

---

## 4. Google Maps API Keys

**Guida dettagliata:** Vedi `GOOGLE_MAPS_API_SETUP.md`

### 4.1 Crea Chiavi su Google Cloud Console

https://console.cloud.google.com/apis/credentials

**3 Chiavi Separate:**

#### A) Android API Key
- **Restrizione:** App Android
- **Package Name:** `com.spark.orange`
- **SHA-1 Fingerprint:** (ottieni con keytool)

#### B) iOS API Key
- **Restrizione:** App iOS
- **Bundle ID:** `com.example.myPetCare`

#### C) Web API Key
- **Restrizione:** Referrer HTTP
- **Domini autorizzati:**
  - `https://pet-care-9790d.web.app/*`
  - `http://localhost:*/*`

### 4.2 Configurazione

**Android:** `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyCKAKCjJb2_utnE7GVKYoRJL54TkKRzxKs" />
```

**iOS:** `ios/Runner/AppDelegate.swift`
```swift
GMSServices.provideAPIKey("YOUR_IOS_KEY_HERE")
```

**Web:** `web/index.html`
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_WEB_KEY_HERE"></script>
```

---

## 5. Variabili d'Ambiente Backend

**File:** `backend/.env` (crea da `.env.example`)

```bash
# Firebase
GOOGLE_APPLICATION_CREDENTIALS=./firebase-admin-sdk.json
FIREBASE_PROJECT_ID=pet-care-9790d

# Stripe
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# PayPal
PAYPAL_CLIENT_ID=...
PAYPAL_SECRET=...
PAYPAL_API=https://api-m.sandbox.paypal.com

# Google Maps
GOOGLE_MAPS_ANDROID_KEY=AIzaSy...
GOOGLE_MAPS_IOS_KEY=AIzaSy...
GOOGLE_MAPS_WEB_KEY=AIzaSy...

# CORS
CORS_ALLOWED_ORIGINS=https://pet-care-9790d.web.app,http://localhost:5060

# URLs
BACKEND_BASE_URL=http://localhost:8080
WEB_URL=https://pet-care-9790d.web.app

# Environment
NODE_ENV=development
PORT=8080
```

---

## 6. Variabili d'Ambiente Frontend

**File:** `lib/config.dart`

```dart
class AppConfig {
  // Backend URLs
  static const String backendBaseUrl = 
      String.fromEnvironment('BACKEND_URL', 
          defaultValue: 'http://localhost:8080');
  
  // Stripe
  static const String stripePublishableKey = 'pk_test_...';
  static const String stripeMonthlyPriceId = 'price_...';
  
  // Web URL
  static const String webUrl = 'https://pet-care-9790d.web.app';
  
  // Firebase Project
  static const String firebaseProjectId = 'pet-care-9790d';
}
```

---

## 7. Security Best Practices

### 7.1 File da NON Committare

**.gitignore** deve includere:
```gitignore
# Environment files
.env
.env.*
!.env.example

# Firebase
firebase-admin-sdk.json
google-services.json
GoogleService-Info.plist

# iOS
ios/Runner/GoogleService-Info.plist

# Keystores
*.jks
*.keystore
key.properties
```

### 7.2 Restrizioni API Keys

**✅ DA FARE:**
- Limita Android keys con SHA-1 e package name
- Limita iOS keys con Bundle ID
- Limita Web keys con HTTP referrer
- Usa chiavi separate per ogni piattaforma
- Abilita solo le API necessarie
- Configura alert su superamento quote

**❌ DA NON FARE:**
- Non usare chiavi senza restrizioni
- Non committare chiavi su Git
- Non condividere chiavi via email/chat
- Non usare la stessa chiave per tutte le piattaforme

### 7.3 Gestione Secrets su Cloud Run

**Opzione A: Variabili d'ambiente**
```bash
gcloud run deploy mypetcare-backend \
  --set-env-vars="STRIPE_SECRET_KEY=sk_..." \
  --set-env-vars="PAYPAL_CLIENT_ID=..."
```

**Opzione B: Secret Manager (Raccomandato)**
```bash
# Crea secret
gcloud secrets create stripe-secret-key \
  --data-file=- <<< "sk_..."

# Usa nel deploy
gcloud run deploy mypetcare-backend \
  --set-secrets="STRIPE_SECRET_KEY=stripe-secret-key:latest"
```

---

## 8. Testing delle Configurazioni

### 8.1 Test Stripe

**Test Cards:**
```
Successo: 4242 4242 4242 4242
Decline: 4000 0000 0000 0002
3D Secure: 4000 0025 0000 3155
```

**Test Checkout:**
```bash
curl -X POST http://localhost:8080/api/payments/stripe/checkout \
  -H "Content-Type: application/json" \
  -d '{
    "proId": "test_pro_id",
    "priceId": "price_...",
    "successUrl": "http://localhost:5060/success",
    "cancelUrl": "http://localhost:5060/cancel"
  }'
```

### 8.2 Test PayPal

**Sandbox Accounts:**
- Buyer: test@personal.example.com
- Merchant: test@business.example.com

**Test API:**
```bash
curl -X POST http://localhost:8080/api/payments/paypal/create-order \
  -H "Content-Type: application/json" \
  -d '{
    "proId": "test_pro_id",
    "planType": "MONTHLY",
    "returnUrl": "http://localhost:5060/success",
    "cancelUrl": "http://localhost:5060/cancel"
  }'
```

### 8.3 Test Google Maps

**Verifica Android:**
```bash
# Installa APK
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk

# Check logs
adb logcat | grep -i "maps\|google"
```

**Verifica Web:**
```bash
# Build e serve
flutter build web --release
python3 -m http.server 5060 --directory build/web

# Apri browser e controlla console
open http://localhost:5060
```

### 8.4 Test Firebase

**Verifica Backend:**
```bash
# Test Firestore connection
node -e "
const admin = require('firebase-admin');
const serviceAccount = require('./firebase-admin-sdk.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
const db = admin.firestore();
db.collection('test').add({timestamp: new Date()})
  .then(() => console.log('✅ Firestore OK'))
  .catch(err => console.error('❌ Error:', err));
"
```

---

## 🔗 Link Utili

### Documentation
- **Firebase:** https://firebase.google.com/docs
- **Stripe:** https://stripe.com/docs
- **PayPal:** https://developer.paypal.com/docs
- **Google Maps:** https://developers.google.com/maps/documentation

### Dashboards
- **Firebase Console:** https://console.firebase.google.com/
- **Stripe Dashboard:** https://dashboard.stripe.com/
- **PayPal Developer:** https://developer.paypal.com/dashboard/
- **Google Cloud Console:** https://console.cloud.google.com/

### Security
- **Stripe Security:** https://stripe.com/docs/security
- **PayPal Security:** https://developer.paypal.com/docs/api/overview/#security
- **Google API Security:** https://developers.google.com/maps/api-security-best-practices

---

## ✅ Checklist Configurazione Completa

### Backend
- [ ] File `.env` creato da `.env.example`
- [ ] Firebase Admin SDK JSON presente
- [ ] Stripe Secret Key configurata
- [ ] Stripe Webhook Secret configurata
- [ ] PayPal Client ID e Secret configurati
- [ ] Google Maps keys configurate
- [ ] CORS origins configurati
- [ ] Backend URLs configurati

### Frontend
- [ ] `config.dart` con valori corretti
- [ ] `firebase_options.dart` presente
- [ ] Android `google-services.json` presente
- [ ] iOS `GoogleService-Info.plist` presente
- [ ] AndroidManifest.xml con Google Maps key
- [ ] iOS AppDelegate con Google Maps key
- [ ] Web index.html con Google Maps script

### Security
- [ ] `.gitignore` configurato correttamente
- [ ] Nessuna chiave committata su Git
- [ ] API keys con restrizioni appropriate
- [ ] Webhook secrets configurati
- [ ] Test mode attivo per Stripe e PayPal

### Testing
- [ ] Test Stripe checkout funzionante
- [ ] Test PayPal checkout funzionante
- [ ] Test Google Maps su Android
- [ ] Test Google Maps su iOS
- [ ] Test Google Maps su Web
- [ ] Test Firebase Firestore connection
- [ ] Webhook testati localmente (ngrok/localtunnel)

---

**Ultima revisione:** 15 Novembre 2024  
**Progetto:** MY PET CARE  
**Versione:** 1.0.0
