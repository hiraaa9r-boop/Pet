# MY PET CARE - Checklist Setup Completa

## ✅ Setup Completato

### 1. Struttura Progetto
- [x] Progetto Flutter creato (`my_pet_care`)
- [x] Struttura directory organizzata
- [x] Assets directory create (icons, images, fonts)
- [x] Backend directory structure

### 2. Dipendenze Flutter
- [x] `pubspec.yaml` configurato con tutte le dipendenze
- [x] Riverpod per state management
- [x] GoRouter per navigazione
- [x] Firebase packages (Auth, Firestore, Storage, FCM)
- [x] Google Maps Flutter
- [x] Geolocator per location

### 3. Modelli Dati
- [x] `user_model.dart` - Utenti (Owner/Pro/Admin)
- [x] `pro_model.dart` - Professionisti con categorie
- [x] `service_model.dart` - Servizi offerti
- [x] `booking_model.dart` - Prenotazioni con pagamenti
- [x] `pet_model.dart` - Animali domestici
- [x] `subscription_model.dart` - Abbonamenti PRO

### 4. Servizi
- [x] `auth_service.dart` - Autenticazione Firebase
- [x] `subscription_service.dart` - Gestione abbonamenti

### 5. UI/Screens
- [x] `home_map_page.dart` - Mappa interattiva
- [x] `login_page.dart` - Login con email/password
- [x] Stub screens per tutte le altre pagine

### 6. Tema & Branding
- [x] `app_theme.dart` con colori #0F6259
- [x] Font Poppins (titoli) e Inter (testo)
- [x] Material Design 3

### 7. Routing
- [x] `app_router.dart` con GoRouter
- [x] Tutte le route definite

### 8. Firebase
- [x] `firestore.rules` - Regole di sicurezza
- [x] `firestore.indexes.json` - Indici Firestore

### 9. Backend
- [x] Struttura directory backend/
- [x] `package.json` con dipendenze
- [x] `tsconfig.json` configurato
- [x] `Dockerfile` per Cloud Run
- [x] README backend

### 10. Documentazione
- [x] `DOCUMENTAZIONE_COMPLETA.md` - Guida completa
- [x] `README.md` - Quick start
- [x] `BACKEND_README.md` - Backend setup

### 11. Assets Generati
- [x] 8 icone categorie professionisti generate
- [x] Icona app principale generata

---

## 🔧 Setup Mancante (Da Completare Prima del Deploy)

### 1. Firebase Configuration

#### A. Crea Progetto Firebase
1. [ ] Vai su https://console.firebase.google.com/
2. [ ] Crea nuovo progetto "MY PET CARE"
3. [ ] Abilita Google Analytics (opzionale)

#### B. Configura Authentication
1. [ ] Vai su Authentication → Sign-in method
2. [ ] Abilita "Email/Password"
3. [ ] Configura dominio autorizzato

#### C. Crea Database Firestore
1. [ ] Vai su Firestore Database
2. [ ] Crea database in modalità production
3. [ ] Scegli location (es. europe-west1)

#### D. Configura Storage
1. [ ] Vai su Storage
2. [ ] Inizializza Storage
3. [ ] Configura regole di sicurezza

#### E. Configura Cloud Messaging (FCM)
1. [ ] Vai su Cloud Messaging
2. [ ] Abilita servizio
3. [ ] Genera Server Key

#### F. Download File Configurazione
1. [ ] Android: Scarica `google-services.json`
   - Posiziona in: `android/app/google-services.json`
2. [ ] iOS: Scarica `GoogleService-Info.plist`
   - Posiziona in: `ios/Runner/GoogleService-Info.plist`
3. [ ] Web: Copia configurazione
   - Aggiorna `lib/main.dart` con credenziali

#### G. Deploy Regole Firestore
```bash
cd /home/user/flutter_app
firebase login
firebase init
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### 2. Google Maps Configuration

#### A. Ottieni API Key
1. [ ] Vai su https://console.cloud.google.com/
2. [ ] Crea progetto o usa esistente
3. [ ] Vai su APIs & Services → Credentials
4. [ ] Crea API Key

#### B. Abilita API
1. [ ] Maps SDK for Android
2. [ ] Maps SDK for iOS
3. [ ] Maps JavaScript API
4. [ ] Geolocation API
5. [ ] Places API (opzionale)

#### C. Configura Restrizioni
1. [ ] Android: Aggiungi SHA-1 certificate fingerprint
2. [ ] iOS: Aggiungi Bundle ID
3. [ ] Web: Aggiungi domini autorizzati

#### D. Aggiungi API Key nei File
1. [ ] Android: `android/app/src/main/AndroidManifest.xml`
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```

2. [ ] iOS: `ios/Runner/AppDelegate.swift`
   ```swift
   GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
   ```

3. [ ] Web: `web/index.html`
   ```html
   <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
   ```

### 3. Font Setup

#### A. Download Font Files
1. [ ] Poppins: https://fonts.google.com/specimen/Poppins
   - Regular (400)
   - SemiBold (600)
   - Bold (700)
2. [ ] Inter: https://fonts.google.com/specimen/Inter
   - Regular (400)
   - Medium (500)
   - Bold (700)

#### B. Posiziona Font
1. [ ] Copia file in `assets/fonts/`
   - `Poppins-Regular.ttf`
   - `Poppins-SemiBold.ttf`
   - `Poppins-Bold.ttf`
   - `Inter-Regular.ttf`
   - `Inter-Medium.ttf`
   - `Inter-Bold.ttf`

### 4. Icone Categorie

Le icone sono già state generate. Devi solo scaricarle e posizionarle:

1. [ ] Scarica le 8 icone generate
2. [ ] Rinomina e posiziona in `assets/icons/`:
   - `veterinario.png`
   - `toelettatore.png`
   - `educatore-addestratore.png`
   - `allevatore.png`
   - `pensione-pet.png`
   - `taxi.png`
   - `pet-sitter.png`
   - `app_icon.png` (icona app in `assets/images/`)

### 5. Stripe Setup

#### A. Account Stripe
1. [ ] Crea account su https://dashboard.stripe.com/
2. [ ] Completa verifica account
3. [ ] Attiva modalità live

#### B. Stripe Connect Express
1. [ ] Vai su Connect → Get started
2. [ ] Scegli "Express" platform type
3. [ ] Configura onboarding flow

#### C. Crea Prodotti Abbonamento
1. [ ] Vai su Products → Add product
2. [ ] **PRO Mensile**:
   - Nome: "MY PET CARE PRO - Mensile"
   - Prezzo: €29/mese
   - Ricorrente: Mensile
3. [ ] **PRO Trimestrale**:
   - Nome: "MY PET CARE PRO - Trimestrale"
   - Prezzo: €79/3 mesi
   - Ricorrente: Trimestrale
4. [ ] **PRO Annuale**:
   - Nome: "MY PET CARE PRO - Annuale"
   - Prezzo: €299/anno
   - Ricorrente: Annuale

#### D. Crea Coupon PRO
1. [ ] Vai su Coupons → Create coupon
2. [ ] **FREE-1M**:
   - Tipo: Percent off
   - Valore: 100%
   - Durata: 1 mese
3. [ ] **FREE-3M**:
   - Tipo: Percent off
   - Valore: 100%
   - Durata: 3 mesi
4. [ ] **FREE-12M**:
   - Tipo: Percent off
   - Valore: 100%
   - Durata: 12 mesi

#### E. Configura Webhook
1. [ ] Vai su Developers → Webhooks
2. [ ] Add endpoint
3. [ ] URL: `https://YOUR_CLOUD_RUN_URL/stripe/webhook`
4. [ ] Eventi:
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
   - `charge.refunded`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
5. [ ] Copia Webhook Secret

#### F. Ottieni API Keys
1. [ ] Vai su Developers → API keys
2. [ ] Copia:
   - Publishable key (per frontend)
   - Secret key (per backend)

### 6. PayPal Setup (Opzionale)

#### A. Account PayPal
1. [ ] Crea Business Account su https://developer.paypal.com/
2. [ ] Completa verifica

#### B. Commerce Platform
1. [ ] Vai su Dashboard → My Apps & Credentials
2. [ ] Create App
3. [ ] Abilita "Accept payments"
4. [ ] Configura webhook URL

#### C. Ottieni Credenziali
1. [ ] Client ID
2. [ ] Client Secret

### 7. Backend Deploy

#### A. Configura Google Cloud
1. [ ] Installa gcloud CLI
2. [ ] `gcloud init`
3. [ ] `gcloud auth login`
4. [ ] Crea progetto o seleziona esistente

#### B. Abilita API
1. [ ] Cloud Run API
2. [ ] Cloud Build API
3. [ ] Cloud Scheduler API
4. [ ] Container Registry API

#### C. Build Backend
```bash
cd /home/user/flutter_app/backend
npm install
npm run build
```

#### D. Deploy su Cloud Run
```bash
# Build Docker image
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/mypetcare-backend

# Deploy
gcloud run deploy mypetcare-backend \
  --image gcr.io/YOUR_PROJECT_ID/mypetcare-backend \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated \
  --set-env-vars "
    PORT=8080,
    FIREBASE_PROJECT_ID=YOUR_PROJECT_ID,
    STRIPE_KEY=sk_live_...,
    STRIPE_WEBHOOK_SECRET=whsec_...,
    PAYPAL_CLIENT_ID=...,
    PAYPAL_CLIENT_SECRET=...,
    APP_FEE_PCT=5,
    APP_URL=https://app.mypetcare.it,
    SENDGRID_API_KEY=SG...,
    EMAIL_FROM=no-reply@mypetcare.it,
    EMAIL_REPLY_TO=petcareassistenza@gmail.com
  "
```

#### E. Configura Job Schedulati
```bash
# Capture T-24h (ogni ora)
gcloud scheduler jobs create http capture-payments \
  --schedule="0 * * * *" \
  --uri="https://YOUR_CLOUD_RUN_URL/jobs/capture" \
  --http-method=POST \
  --time-zone="Europe/Rome"

# Subscription Sweeper (ogni giorno alle 2:00)
gcloud scheduler jobs create http sweep-subscriptions \
  --schedule="0 2 * * *" \
  --uri="https://YOUR_CLOUD_RUN_URL/jobs/subscription-sweeper" \
  --http-method=POST \
  --time-zone="Europe/Rome"
```

### 8. SendGrid Setup

#### A. Account SendGrid
1. [ ] Crea account su https://sendgrid.com/
2. [ ] Verifica email

#### B. Domain Verification
1. [ ] Vai su Settings → Sender Authentication
2. [ ] Authenticate your domain
3. [ ] Aggiungi record DNS

#### C. Crea API Key
1. [ ] Vai su Settings → API Keys
2. [ ] Create API Key
3. [ ] Full Access
4. [ ] Copia API Key

#### D. Crea Email Templates
1. [ ] Vai su Email API → Dynamic Templates
2. [ ] Create Template per:
   - Verifica email
   - Richiesta prenotazione
   - Accettazione prenotazione
   - Reminder 48h
   - Ricevuta pagamento
   - Cancellazione
   - Richiesta recensione

#### E. Configura Reply-To
1. [ ] In ogni template
2. [ ] Reply-To: `petcareassistenza@gmail.com`

### 9. Testing

#### A. Test Locali
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/

# Integration tests
flutter drive --target=test_driver/app.dart
```

#### B. Test Manuale Flow Completo
1. [ ] Registrazione Owner
2. [ ] Verifica email
3. [ ] Aggiunta pet
4. [ ] Registrazione PRO
5. [ ] Abbonamento PRO (test Stripe)
6. [ ] Applicazione coupon PRO da Admin
7. [ ] Ricerca PRO su mappa
8. [ ] Creazione prenotazione
9. [ ] Accettazione prenotazione
10. [ ] Pagamento (test card)
11. [ ] Capture T-24h (via Cloud Scheduler test)
12. [ ] Completamento servizio
13. [ ] Recensione

### 10. Deploy Produzione

#### A. Build Flutter
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

#### B. Deploy Web (Firebase Hosting)
```bash
firebase deploy --only hosting
```

#### C. Deploy Android
1. [ ] Google Play Console
2. [ ] Upload AAB
3. [ ] Compila scheda store
4. [ ] Submit for review

#### D. Deploy iOS
1. [ ] App Store Connect
2. [ ] Archive in Xcode
3. [ ] Upload
4. [ ] Submit for review

### 11. Monitoring & Analytics

#### A. Firebase Analytics
1. [ ] Verifica eventi tracciati
2. [ ] Configura conversioni

#### B. Cloud Monitoring
1. [ ] Alert per errori backend
2. [ ] Alert per job failures
3. [ ] Dashboard KPI

#### C. Stripe Dashboard
1. [ ] Monitor transazioni
2. [ ] Alert fraud detection

---

## 📞 Support Setup

### Email Assistenza
1. [ ] Configura inbox `petcareassistenza@gmail.com`
2. [ ] Setup auto-responder
3. [ ] Documenta FAQ

---

## 🚀 Post-Launch

### Week 1
- [ ] Monitor errori in produzione
- [ ] Rispondere a feedback utenti
- [ ] Fix bug critici

### Week 2-4
- [ ] Analisi metriche utilizzo
- [ ] Ottimizzazioni performance
- [ ] Feature requests prioritizzate

---

**Note**: Questa checklist va completata prima di considerare il progetto production-ready. Ogni sezione ha istruzioni dettagliate nella DOCUMENTAZIONE_COMPLETA.md.
