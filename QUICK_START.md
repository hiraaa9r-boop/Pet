# MY PET CARE - Quick Start Guide 🚀

Guida rapida per far partire il progetto in 30 minuti.

## 📋 Pre-requisiti

- Flutter 3.35.4+ installato
- Node.js 18+ installato
- Account Firebase (gratuito)
- Account Stripe (gratuito in modalità test)
- Google Cloud SDK (per Cloud Run)

---

## ⚡ Setup Rapido (30 minuti)

### 1. Firebase Setup (10 min)

```bash
# 1. Vai su https://console.firebase.google.com/
# 2. Crea progetto "MY PET CARE"
# 3. Abilita:
#    - Authentication (Email/Password)
#    - Firestore Database (modalità production)
#    - Storage
#    - Cloud Messaging (FCM)

# 4. Deploy regole e indici Firestore
firebase login
firebase init
firebase use --add YOUR_PROJECT_ID
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### 2. Firebase App Configuration (5 min)

**Opzione A: FlutterFire CLI (consigliato)**
```bash
# Installa FlutterFire CLI
dart pub global activate flutterfire_cli

# Configura automaticamente
flutterfire configure
```

**Opzione B: Manuale**
```bash
# Android: Scarica google-services.json
# Posiziona in: android/app/google-services.json

# iOS: Scarica GoogleService-Info.plist
# Posiziona in: ios/Runner/GoogleService-Info.plist

# Web: Aggiorna lib/main.dart con credenziali Firebase
```

### 3. Google Maps Setup (5 min)

```bash
# 1. Vai su https://console.cloud.google.com/
# 2. Crea API Key
# 3. Abilita: Maps SDK for Android, iOS, JavaScript

# 4. Aggiungi API Key:

# Android: android/app/src/main/AndroidManifest.xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>

# iOS: ios/Runner/AppDelegate.swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")

# Web: web/index.html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
```

### 4. Assets Setup (5 min)

```bash
# 1. Scarica font da Google Fonts:
#    - Poppins: https://fonts.google.com/specimen/Poppins
#    - Inter: https://fonts.google.com/specimen/Inter

# 2. Posiziona in assets/fonts/
cp ~/Downloads/Poppins-*.ttf assets/fonts/
cp ~/Downloads/Inter-*.ttf assets/fonts/

# 3. Scarica le 8 icone generate e posizionale in assets/icons/
#    (vedi link nelle risposte precedenti)
```

### 5. Stripe Setup con Script Automatico (3 min)

```bash
# 1. Vai su https://dashboard.stripe.com/
# 2. Ottieni la tua Secret Key (sk_test_... o sk_live_...)

# 3. Esegui lo script di setup per creare Products, Prices e Promotion Codes
cd ops_scripts/
echo "STRIPE_KEY=sk_test_..." > .env
node --env-file=.env stripe_setup.ts

# Output atteso:
# ✅ Product creato: PRO Monthly - price_xxx
# ✅ Product creato: PRO Quarterly - price_xxx
# ✅ Product creato: PRO Annual - price_xxx
# ✅ Promotion Code creato: FREE-1M
# ✅ Promotion Code creato: FREE-3M
# ✅ Promotion Code creato: FREE-12M

# 4. Copia i Price ID e Promo Code ID generati
# 5. Aggiungili al backend .env (vedi sezione Backend Setup)
```

### 6. Flutter App - Prima Esecuzione (2 min)

```bash
# Installa dipendenze
flutter pub get

# Configura URL backend (sostituisci con il tuo Cloud Run URL dopo deploy)
# Opzione A: Durante flutter run
flutter run -d chrome --dart-define=BACKEND_URL=https://your-run-url.run.app

# Opzione B: Nel file di configurazione (crea lib/config.dart)
# const backendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:8080');

# Esegui su Web (più veloce per test)
flutter run -d chrome

# O su dispositivo Android/iOS
flutter run
```

### 7. Backend Setup (5 min)

```bash
cd backend

# Crea file .env
cp .env.example .env

# Modifica .env con le tue chiavi:
# - STRIPE_KEY (da Stripe Dashboard)
# - STRIPE_WEBHOOK_SECRET (da Stripe Webhook settings)
# - STRIPE_PRICE_PRO_MONTHLY=price_xxx (dall'output dello script stripe_setup.ts)
# - STRIPE_PRICE_PRO_QUARTERLY=price_xxx
# - STRIPE_PRICE_PRO_ANNUAL=price_xxx
# - STRIPE_PROMO_FREE_1M=promo_xxx (opzionale, dall'output dello script)
# - STRIPE_PROMO_FREE_3M=promo_xxx
# - STRIPE_PROMO_FREE_12M=promo_xxx
# - FIREBASE_PROJECT_ID
# - APP_FEE_PCT=5
# - APP_URL=https://app.mypetcare.it (o il tuo dominio)

# Installa dipendenze
npm install

# Test locale (opzionale)
npm run dev

# Il backend sarà disponibile su http://localhost:8080
# Test: curl http://localhost:8080/health → "ok"
```

---

## 🎯 Test Rapido dell'App

### 1. Registrazione Utente
```
1. Apri app
2. Vai a Registrazione
3. Inserisci email/password
4. Verifica email (controlla inbox)
```

### 2. Visualizza Mappa
```
1. Login
2. Vedrai mappa con professionisti (se esistono)
3. Usa filtri categoria in alto
```

### 3. Crea Professionista PRO (test)
```
1. Registrati con ruolo "pro"
2. Completa profilo PRO
3. Richiedi abbonamento (o applica coupon FREE-1M da admin)
```

---

## 🚀 Deploy Veloce (Solo quando pronto)

### Backend su Cloud Run

```bash
cd backend

# Build
npm run build

# Deploy
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/mypetcare-backend

gcloud run deploy mypetcare-backend \
  --image gcr.io/YOUR_PROJECT_ID/mypetcare-backend \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated \
  --set-env-vars "STRIPE_KEY=sk_...,APP_FEE_PCT=5"
```

### Flutter Web

```bash
# Build
flutter build web --release

# Deploy Firebase Hosting
firebase deploy --only hosting
```

### Android APK (test)

```bash
flutter build apk --release
# APK in: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔧 Troubleshooting

### Firebase Connection Error
```bash
# Verifica configurazione
flutter pub get
flutterfire configure
```

### Google Maps non si carica
```bash
# Verifica:
1. API Key corretta
2. API abilitate su Google Cloud Console
3. Billing attivo (richiesto per Maps)
```

### Backend non parte
```bash
# Verifica:
cd backend
npm install
# Controlla .env file
cat .env
```

---

## 📚 Link Utili

- **Firebase Console**: https://console.firebase.google.com/
- **Stripe Dashboard**: https://dashboard.stripe.com/
- **Google Cloud Console**: https://console.cloud.google.com/
- **Documentazione Completa**: [DOCUMENTAZIONE_COMPLETA.md](DOCUMENTAZIONE_COMPLETA.md)
- **Setup Checklist**: [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md)

---

## 🎯 Next Steps

Dopo aver completato il Quick Start:

1. ✅ **Leggi SETUP_CHECKLIST.md** per setup completo produzione
2. ✅ **Configura Stripe** per pagamenti reali
3. ✅ **Crea coupon PRO** (FREE-1M, FREE-3M, FREE-12M)
4. ✅ **Testa flow booking completo**
5. ✅ **Configura job schedulati** (Cloud Scheduler)
6. ✅ **Setup SendGrid** per email
7. ✅ **Deploy produzione**

---

## 💡 Tips

- **Sviluppo**: Usa Web per iterare velocemente (hot reload)
- **Test Pagamenti**: Usa Stripe test cards (4242 4242 4242 4242)
- **Debug**: Controlla console Firebase per errori Firestore
- **Performance**: Abilita indexing Firestore appena possibile

---

**Pronto per iniziare?** Segui i 6 passi sopra e avrai l'app funzionante in locale! 🚀
