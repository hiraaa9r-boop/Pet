# MY PET CARE 🐾

Piattaforma completa per la gestione di servizi veterinari e pet care che connette proprietari di animali con professionisti del settore.

![MY PET CARE](assets/images/app_icon.png)

## 🌟 Caratteristiche Principali

- **Ruoli Multipli**: Proprietari e Professionisti (veterinari, toelettatori, pet sitter, educatori, allevatori, taxi, pensioni)
- **Autenticazione Sicura**: Registrazione con verifica email obbligatoria
- **Abbonamenti PRO**: Sistema flessibile con piani mensili, trimestrali e annuali
- **Coupon Gratuiti**: Codici promozionali per mesi gratis (FREE-1M, FREE-3M, FREE-12M)
- **Sistema di Prenotazioni**: Slot da 15/30/60 minuti con conferma professionale
- **Pagamenti Sicuri**: Integrazione Stripe Connect e PayPal
- **Mappa Interattiva**: Visualizza professionisti nelle vicinanze con filtri categoria
- **Recensioni**: Sistema di valutazione post-servizio
- **Notifiche**: Push e email per ogni fase del processo

## 📱 Piattaforme Supportate

- ✅ Android
- ✅ iOS
- ✅ Web

## 🛠️ Stack Tecnologico

### Frontend
- **Flutter**: 3.35.4 con Material Design 3
- **State Management**: Riverpod 2.5.1
- **Routing**: GoRouter 14.2.0
- **Maps**: Google Maps Flutter 2.7.0
- **Firebase**: Auth, Firestore, Storage, FCM

### Backend
- **Runtime**: Node.js/TypeScript su Cloud Run
- **Database**: Firebase Firestore
- **Pagamenti**: Stripe Connect + PayPal
- **Email**: SendGrid

## 🚀 Quick Start

### Prerequisiti

```bash
# Flutter SDK 3.35.4
flutter --version

# Firebase CLI
npm install -g firebase-tools

# Google Cloud SDK (per Cloud Run)
gcloud --version
```

### 1. Clone del Repository

```bash
git clone https://github.com/petcareassistenza-eng/PET-CARE-2.git
cd PET-CARE-2
```

### 2. Configurazione Firebase

1. Crea un progetto su [Firebase Console](https://console.firebase.google.com/)
2. Abilita Authentication (Email/Password)
3. Crea database Firestore
4. Scarica `google-services.json` (Android) e `GoogleService-Info.plist` (iOS)
5. Posiziona i file nelle rispettive directory:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

6. Aggiorna `lib/main.dart` con le tue credenziali Firebase:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  ),
);
```

### 3. Configurazione Google Maps

1. Ottieni API Key da [Google Cloud Console](https://console.cloud.google.com/)
2. Abilita Google Maps SDK for Android/iOS/JavaScript
3. Aggiungi la chiave nei file di configurazione:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

**iOS** (`ios/Runner/AppDelegate.swift`):
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

**Web** (`web/index.html`):
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_GOOGLE_MAPS_API_KEY"></script>
```

### 4. Installazione Dipendenze

```bash
flutter pub get
```

### 5. Deploy Regole Firestore

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### 6. Avvio Applicazione

**Web** (consigliato per sviluppo):
```bash
flutter run -d chrome
```

**Android**:
```bash
flutter run -d android
```

**iOS**:
```bash
flutter run -d ios
```

## 🏗️ Struttura del Progetto

```
PET-CARE-2/
├── lib/                             # Flutter Frontend
│   ├── main.dart
│   ├── firebase_options.dart        # Firebase configuration
│   ├── config.dart                  # App configuration (backend URL, Stripe keys)
│   ├── models/                      # Data models
│   ├── providers/                   # State management
│   ├── screens/                     # UI screens
│   │   ├── home/                    # Home screens (owner/pro)
│   │   ├── auth/                    # Authentication screens
│   │   ├── booking/                 # Booking screens
│   │   ├── subscription/            # Subscription screens
│   │   └── admin/                   # Admin panel
│   ├── services/                    # Business logic
│   │   ├── auth_service.dart
│   │   └── subscription_service.dart
│   ├── widgets/                     # Reusable widgets
│   ├── theme/                       # App theme
│   ├── router/                      # Navigation (GoRouter)
│   └── utils/                       # Utilities
│
├── android/                         # Android platform configuration
│   ├── app/
│   │   ├── build.gradle.kts
│   │   └── src/main/AndroidManifest.xml
│   └── keystore/                    # Release keystore (gitignored)
│
├── ios/                             # iOS platform configuration
│   └── Runner/
│
├── web/                             # Web platform configuration
│
├── assets/                          # App assets
│   ├── branding/
│   ├── icons/
│   ├── images/
│   └── fonts/
│
├── backend/                         # Node.js/TypeScript Backend (Cloud Run)
│   ├── src/
│   │   ├── index.ts                 # Express server entry point
│   │   ├── config.ts                # Backend configuration
│   │   ├── firebase.ts              # Firebase Admin SDK
│   │   ├── auth/
│   │   │   └── setAdmin.ts          # Script for promoting users to admin
│   │   ├── routes/                  # API routes
│   │   │   ├── auth.ts              # Authentication endpoints
│   │   │   ├── payments.ts          # Payment endpoints
│   │   │   ├── admin.ts             # Admin-only endpoints
│   │   │   ├── pros.ts              # PRO management
│   │   │   ├── bookings.ts          # Booking management
│   │   │   ├── notifications.ts     # Notification system
│   │   │   └── gdpr.ts              # GDPR compliance
│   │   ├── middleware/              # Express middleware
│   │   │   ├── auth.ts              # JWT verification
│   │   │   └── cors.ts              # CORS whitelist
│   │   ├── services/                # Business logic
│   │   └── utils/                   # Utilities
│   ├── docs/                        # Backend documentation
│   │   ├── CLOUD_RUN_DEPLOYMENT_GUIDE.md
│   │   ├── CLOUD_RUN_ENV_VARS.md    # Environment variables reference
│   │   ├── CORS_SECURITY_UPDATE.md
│   │   ├── DEPLOY_QUICK_REFERENCE.md
│   │   └── LOCAL_TEST_GUIDE.md
│   ├── package.json                 # Dependencies
│   ├── tsconfig.json                # TypeScript config
│   ├── Dockerfile                   # Multi-stage Docker build
│   ├── .dockerignore
│   ├── .env.example                 # Environment variables template
│   ├── deploy-cloudrun.ps1          # PowerShell deployment script
│   └── deploy-cloudrun-simple.sh    # Bash deployment script
│
├── docs/                            # Project documentation
│   ├── ADMIN_SYSTEM_SETUP.md        # Admin system guide
│   ├── ADMIN_QUICK_START.md         # Quick admin setup
│   └── (other docs)
│
├── .gitignore                       # Git ignore rules
├── README.md                        # This file
├── DEPLOY_QUICK_START.md            # Quick deployment guide
└── pubspec.yaml                     # Flutter dependencies
```

## 🎨 Branding

- **Colore Principale**: `#0F6259` (Teal Green)
- **Font Titoli**: Poppins
- **Font Testo**: Inter
- **Icone**: Custom icons per ogni categoria di professionista

## 💳 Abbonamenti PRO

| Piano | Prezzo | Risparmio |
|-------|--------|-----------|
| Mensile | €29/mese | - |
| Trimestrale | €79/3 mesi | ~11% |
| Annuale | €299/anno | ~16% |

### Coupon PRO (Solo Admin)
- `FREE-1M`: 1 mese gratis
- `FREE-3M`: 3 mesi gratis
- `FREE-12M`: 12 mesi gratis

## 🔧 Backend Setup

### 1. Configurazione Cloud Run

```bash
cd backend
npm install

# Build Docker image
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/mypetcare-backend

# Deploy
gcloud run deploy mypetcare-backend \
  --image gcr.io/YOUR_PROJECT_ID/mypetcare-backend \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated \
  --set-env-vars "STRIPE_KEY=sk_...,STRIPE_WEBHOOK_SECRET=whsec_..."
```

### 2. Configurazione Stripe

1. Crea account su [Stripe Dashboard](https://dashboard.stripe.com/)
2. Attiva Stripe Connect Express
3. Crea prodotti:
   - PRO Mensile: €29
   - PRO Trimestrale: €79
   - PRO Annuale: €299
4. Crea coupon:
   - FREE-1M (100% off, durata 1 mese)
   - FREE-3M (100% off, durata 3 mesi)
   - FREE-12M (100% off, durata 12 mesi)
5. Configura webhook → URL Cloud Run

### 3. Job Schedulati

**Cloud Scheduler**:

```bash
# Job Capture T-24h (ogni ora)
gcloud scheduler jobs create http capture-job \
  --schedule="0 * * * *" \
  --uri="https://YOUR_CLOUD_RUN_URL/jobs/capture" \
  --http-method=POST

# Job Subscription Sweeper (ogni giorno alle 2:00)
gcloud scheduler jobs create http sweeper-job \
  --schedule="0 2 * * *" \
  --uri="https://YOUR_CLOUD_RUN_URL/jobs/subscription-sweeper" \
  --http-method=POST
```

## 📧 Email Setup

1. Crea account [SendGrid](https://sendgrid.com/)
2. Verifica dominio
3. Crea template email
4. Configura reply-to: `petcareassistenza@gmail.com`

## 🧪 Testing

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

## 📦 Build Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (Google Play)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🚢 Deploy

### Firebase Hosting (Web)
```bash
firebase deploy --only hosting
```

### Google Play Store (Android)
1. Genera keystore
2. Configura `android/key.properties`
3. Build App Bundle
4. Upload su Play Console

### App Store (iOS)
1. Apri Xcode
2. Archive
3. Upload su App Store Connect

## 📚 Documentazione

### **Guide Principali**

- 🚀 **[DEPLOY_QUICK_START.md](DEPLOY_QUICK_START.md)** - Guida rapida per il deploy completo (Backend + Frontend)
- 🔐 **[docs/ADMIN_SYSTEM_SETUP.md](docs/ADMIN_SYSTEM_SETUP.md)** - Setup sistema admin con custom claims
- ⚡ **[docs/ADMIN_QUICK_START.md](docs/ADMIN_QUICK_START.md)** - Quick start per amministratori

### **Backend Documentation**

- 📦 **[backend/docs/CLOUD_RUN_DEPLOYMENT_GUIDE.md](backend/docs/CLOUD_RUN_DEPLOYMENT_GUIDE.md)** - Deploy completo su Cloud Run
- 🔑 **[backend/docs/CLOUD_RUN_ENV_VARS.md](backend/docs/CLOUD_RUN_ENV_VARS.md)** - Variabili d'ambiente (Firebase, Stripe, PayPal)
- 🛡️ **[backend/docs/CORS_SECURITY_UPDATE.md](backend/docs/CORS_SECURITY_UPDATE.md)** - Configurazione CORS e sicurezza
- 🧪 **[backend/docs/LOCAL_TEST_GUIDE.md](backend/docs/LOCAL_TEST_GUIDE.md)** - Testing locale del backend
- 📝 **[backend/docs/DEPLOY_QUICK_REFERENCE.md](backend/docs/DEPLOY_QUICK_REFERENCE.md)** - Quick reference comandi deploy

## 🤝 Contributing

1. Fork del repository
2. Crea feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📞 Supporto

**Email Assistenza**: petcareassistenza@gmail.com

## 📄 Licenza

Questo progetto è proprietario di MY PET CARE. Tutti i diritti riservati.

## 👥 Team

- **Product Owner**: [Nome]
- **Tech Lead**: [Nome]
- **UI/UX Designer**: [Nome]
- **Backend Developer**: [Nome]
- **Mobile Developer**: [Nome]

---

**Versione**: 1.0.0  
**Ultimo Aggiornamento**: 15 Novembre 2024  
**Repository**: https://github.com/petcareassistenza-eng/PET-CARE-2

Fatto con ❤️ da MY PET CARE Team
