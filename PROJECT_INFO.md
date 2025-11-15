# 🐾 MyPetCare - Project Information

## 📊 Project Overview

**Nome Progetto:** MyPetCare  
**Descrizione:** Piattaforma per connettere proprietari di animali con professionisti del settore pet care  
**Piattaforme:** Web (Flutter), Android (Flutter), Backend (Node.js + TypeScript)  
**Status:** ✅ Production-Ready

---

## 🔑 Firebase Project

**Project ID:** `pet-care-9790d`  
**Firebase Console:** https://console.firebase.google.com/project/pet-care-9790d  
**Google Cloud Console:** https://console.cloud.google.com/?project=pet-care-9790d

### **Services Enabled:**
- ✅ Firebase Hosting
- ✅ Cloud Firestore
- ✅ Firebase Authentication
- ✅ Firebase Storage
- ✅ Firebase Cloud Messaging (FCM)
- ⏳ Cloud Run (backend deployment pending)

---

## 🌐 URLs & Domains

### **Production URLs (Target):**
```
Frontend:  https://app.mypetcareapp.org
Backend:   https://api.mypetcareapp.org
```

### **Firebase URLs (Default):**
```
Frontend:  https://pet-care-9790d.web.app
           https://pet-care-9790d.firebaseapp.com
```

### **API Endpoints:**
```
Health Check:     /health
Stripe Checkout:  /api/payments/stripe/checkout
PayPal Checkout:  /api/payments/paypal/checkout
Stripe Webhook:   /webhooks/stripe
PayPal Webhook:   /webhooks/paypal
Notifications:    /api/notifications/*
Admin Dashboard:  /api/admin/*
Pros:             /api/pros/*
Bookings:         /api/bookings/*
```

---

## 📂 Repository Structure

```
flutter_app/
├── lib/                          # Flutter app source
│   ├── main.dart
│   ├── config.dart              # App configuration
│   ├── ui/                      # UI components
│   │   ├── screens/             # 11 schermate complete
│   │   └── widgets/             # Reusable widgets
│   ├── features/                # Feature modules
│   ├── services/                # Firebase, HTTP services
│   └── router/                  # go_router configuration
│
├── backend/                      # Node.js backend
│   ├── src/
│   │   ├── index.ts             # Express server entry
│   │   ├── config.ts            # Environment config
│   │   ├── routes/              # API routes
│   │   └── payments/            # Stripe + PayPal
│   ├── .env.development.example
│   ├── .env.production.example
│   └── DEPLOY-CLOUDRUN.md       # Backend deploy guide
│
├── build/web/                    # Flutter web build (31 MB)
├── assets/                       # Images, fonts
├── docs/                         # Documentation (360 KB)
│   ├── STRIPE-LIVE-SETUP.md
│   ├── PAYPAL-LIVE-SETUP.md
│   ├── UI_IMPLEMENTATION_SUMMARY.md
│   └── UI_INTEGRATION_GUIDE.md
│
├── firebase.json                 # Firebase Hosting config
├── .firebaserc                   # Firebase project ID
├── pubspec.yaml                  # Flutter dependencies
├── FIREBASE_DEPLOY_MANUAL.md     # Frontend deploy guide
├── DEPLOY_SUMMARY.md             # Complete deploy overview
├── OPERATIONS-GOLIVE.md          # Go-live checklist
└── README_DEPLOY_NOW.md          # Quick start deploy
```

---

## 🔐 Configuration Files

### **Flutter App (`lib/config.dart`):**
```dart
class AppConfig {
  static const String backendBaseUrl = 'https://api.mypetcareapp.org';
  static const String webBaseUrl = 'https://app.mypetcareapp.org';
  
  // Stripe Price IDs (LIVE)
  static const String stripeMonthlyPriceId = 'price_XXXXXXXXX';
  static const String stripeYearlyPriceId = 'price_YYYYYYYY';
  
  // PayPal Plan ID (LIVE)
  static const String paypalMonthlyPlanId = 'P-XXXXXXXXXXXX';
}
```

**⚠️ IMPORTANT:** Aggiornare con ID reali dopo setup Stripe/PayPal

### **Backend Environment Variables:**

**Development (`backend/.env.development.example`):**
```bash
NODE_ENV=development
BACKEND_BASE_URL=http://localhost:3000
WEB_BASE_URL=http://localhost:52000
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_test_xxxxxxxxx
PAYPAL_CLIENT_ID=PAYPAL-CLIENT-ID-TEST
PAYPAL_SECRET=PAYPAL-SECRET-TEST
PAYPAL_API=https://api-m.sandbox.paypal.com
```

**Production (`backend/.env.production.example`):**
```bash
NODE_ENV=production
BACKEND_BASE_URL=https://api.mypetcareapp.org
WEB_BASE_URL=https://app.mypetcareapp.org
STRIPE_SECRET_KEY=sk_live_xxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx
PAYPAL_CLIENT_ID=XXXXXXXXXXXXXX
PAYPAL_SECRET=YYYYYYYYYYYYYYYY
PAYPAL_API=https://api-m.paypal.com
```

**⚠️ SECURITY:** Mai committare file `.env` con chiavi reali nel repository!

---

## 🗄️ Database Schema

### **Firestore Collections:**

**users/{uid}:**
```json
{
  "uid": "string",
  "email": "string",
  "name": "string",
  "phone": "string?",
  "role": "owner|pro",
  "notificationsEnabled": "boolean",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

**pros/{uid}:**
```json
{
  "uid": "string",
  "name": "string",
  "email": "string",
  "phone": "string?",
  "subscriptionStatus": "active|inactive",
  "subscriptionProvider": "stripe|paypal|null",
  "subscriptionPlan": "string?",
  "services": ["array"],
  "bio": "string",
  "address": "string",
  "city": "string",
  "latitude": "number?",
  "longitude": "number?",
  "rating": "number",
  "reviewsCount": "number",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

**bookings/{bookingId}:**
```json
{
  "bookingId": "string",
  "ownerId": "string",
  "proId": "string",
  "petId": "string",
  "serviceType": "string",
  "date": "Timestamp",
  "startTime": "string",
  "endTime": "string",
  "status": "pending|confirmed|completed|cancelled",
  "price": "number",
  "notes": "string?",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

**calendars/{uid}/slots/{slotId}:**
```json
{
  "slotId": "string",
  "proId": "string",
  "date": "string (YYYY-MM-DD)",
  "startTime": "string (HH:mm)",
  "endTime": "string (HH:mm)",
  "isAvailable": "boolean",
  "isBooked": "boolean",
  "bookingId": "string?",
  "createdAt": "Timestamp"
}
```

---

## 💳 Payment Integration

### **Stripe:**
- **API Version:** 2024-06-20
- **Subscription Mode:** Checkout Sessions
- **Webhook Events:** `customer.subscription.*`
- **Signature Verification:** Required (raw body parser)

### **PayPal:**
- **API:** REST API v2
- **Auth:** OAuth2 client credentials
- **Subscription:** Billing Plans
- **Webhook Events:** `BILLING.SUBSCRIPTION.*`

---

## 📱 App Features

### **Owner (Proprietari):**
- 🔍 Ricerca professionisti su mappa
- 📋 Lista professionisti con filtri
- 📅 Prenotazione servizi
- 🐾 Gestione animali domestici
- ⭐ Sistema recensioni
- 🔔 Notifiche push

### **Pro (Professionisti):**
- 📆 Gestione calendario disponibilità
- 📝 Gestione prenotazioni ricevute
- 💼 Profilo studio completo
- 💳 Abbonamento PRO (€29.99/mese)
- 📊 Statistiche e analytics
- 🔔 Notifiche prenotazioni

---

## 🔧 Development Environment

### **Flutter:**
- **Version:** 3.35.4 (LOCKED)
- **Dart:** 3.9.2 (LOCKED)
- **Packages:** See `pubspec.yaml`
- **Platform:** Web primary, Android target

### **Backend:**
- **Node.js:** 18+ required
- **TypeScript:** 5.x
- **Framework:** Express.js
- **Database:** Cloud Firestore
- **Hosting:** Google Cloud Run

### **Tools:**
- Firebase CLI
- Google Cloud SDK (gcloud)
- Flutter SDK
- Git

---

## 📊 Build Information

### **Current Build:**
- **Date:** November 14, 2024
- **Size:** 31 MB (uncompressed), 11 MB (compressed)
- **Flutter Version:** 3.35.4
- **Dart Version:** 3.9.2
- **Build Mode:** Release (--release)
- **PWA:** Enabled (service worker + manifest)

### **Build Artifacts:**
```
mypetcare_web_build.tar.gz    11 MB
mypetcare_web_build.zip        11 MB
build/web/                     31 MB
```

---

## 📚 Documentation Index

| File | Purpose | Size |
|------|---------|------|
| `README_DEPLOY_NOW.md` | Quick deploy guide | 5.4 KB |
| `FIREBASE_DEPLOY_MANUAL.md` | Firebase deploy detailed | 9.0 KB |
| `DEPLOY_SUMMARY.md` | Complete project summary | 13 KB |
| `OPERATIONS-GOLIVE.md` | Go-live checklist | 3.4 KB |
| `backend/DEPLOY-CLOUDRUN.md` | Backend deployment | 13 KB |
| `docs/STRIPE-LIVE-SETUP.md` | Stripe configuration | 5.6 KB |
| `docs/PAYPAL-LIVE-SETUP.md` | PayPal configuration | 8.3 KB |
| `docs/UI_IMPLEMENTATION_SUMMARY.md` | UI documentation | 12 KB |
| `docs/UI_INTEGRATION_GUIDE.md` | Integration guide | 8.6 KB |

**Total:** 78+ KB documentation

---

## 🚀 Deployment Sequence

1. ✅ **Build completato** (FATTO)
2. ⏳ **Frontend deploy** → Firebase Hosting (~10 min)
3. ⏳ **Firebase Auth setup** → Enable email/password (~5 min)
4. ⏳ **Stripe LIVE config** → Products + webhooks (~20 min)
5. ⏳ **PayPal LIVE config** → Plans + webhooks (~20 min)
6. ⏳ **Backend deploy** → Cloud Run + env vars (~30 min)
7. ⏳ **Custom domains** → DNS configuration (~30 min + propagation)
8. ⏳ **End-to-end testing** → All flows (~1 hour)

**Total Time:** ~3 hours active work + 24h DNS propagation

---

## 🔗 Important Links

### **Development:**
- Firebase Console: https://console.firebase.google.com/project/pet-care-9790d
- Firebase Hosting: https://console.firebase.google.com/project/pet-care-9790d/hosting
- Firestore Database: https://console.firebase.google.com/project/pet-care-9790d/firestore
- Authentication: https://console.firebase.google.com/project/pet-care-9790d/authentication
- Google Cloud Console: https://console.cloud.google.com/?project=pet-care-9790d

### **Payment Providers:**
- Stripe Dashboard: https://dashboard.stripe.com/
- Stripe Webhooks: https://dashboard.stripe.com/webhooks
- PayPal Developer: https://developer.paypal.com/dashboard/
- PayPal Apps: https://developer.paypal.com/dashboard/applications/live

---

## ✅ Pre-Launch Checklist

- [x] Flutter web build completed
- [x] Backend code complete
- [x] Firebase project configured
- [x] Documentation complete
- [ ] Frontend deployed on Firebase Hosting
- [ ] Firebase Auth enabled
- [ ] Stripe LIVE configured
- [ ] PayPal LIVE configured
- [ ] Backend deployed on Cloud Run
- [ ] Custom domains configured
- [ ] End-to-end testing passed
- [ ] Firestore security rules updated for production

---

**📅 Last Updated:** November 14, 2024  
**📍 Project Status:** Ready for Deployment  
**👥 Team:** MyPetCare Development Team

---

**💙 MyPetCare - Tutti i servizi per il tuo pet! 🐾**
