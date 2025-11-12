# 🚀 MyPetCare - Go-Live Pack Completo

**Production Release Guide per Play Store e App Store**

---

## 📋 Indice

1. [Versioning & Branch Management](#1️⃣-versioning--branch-management)
2. [Environment Configuration](#2️⃣-environment-configuration)
3. [Android Signing](#3️⃣-android-signing--build)
4. [iOS Build (macOS Required)](#4️⃣-ios-build-macos-required)
5. [Fastlane Automation](#5️⃣-fastlane-automation)
6. [GitHub Actions CI/CD](#6️⃣-github-actions-cicd)
7. [Backend Webhook Setup](#7️⃣-backend-webhook-setup)
8. [Firestore Security Rules](#8️⃣-firestore-security-rules)
9. [Database Seeding](#9️⃣-database-seeding)
10. [Test E2E](#🔟-test-e2e)
11. [Store Submission](#1️⃣1️⃣-store-submission)
12. [Post-Launch Monitoring](#1️⃣2️⃣-post-launch-monitoring)

---

## 1️⃣ Versioning & Branch Management

### **Version Bump (pubspec.yaml)**
```yaml
# Formato: X.Y.Z+buildNumber
version: 1.0.0+100
```

### **Git Branch & Tag**
```bash
# Crea release branch da main pulito
git checkout main
git pull origin main
git checkout -b release/1.0.0

# Commit version bump
git commit -am "chore(release): v1.0.0 - Production Release"

# Crea tag annotato
git tag -a v1.0.0 -m "MyPetCare v1.0.0 - Production Launch"

# Push branch e tag
git push origin release/1.0.0
git push origin v1.0.0
```

### **Naming Convention**
- **Major.Minor.Patch+BuildNumber**: `1.0.0+100`
- **Tags**: `v1.0.0`, `v1.0.1`, `v1.1.0`

---

## 2️⃣ Environment Configuration

### **App Environment (.env.production)**
```bash
# Location: /packages/app/.env.production
BACKEND_BASE_URL=https://api.mypetcare.it
SENTRY_DSN=https://examplePublicKey@o0.ingest.sentry.io/0
MAPS_ANDROID_KEY=AIzaSyExample_Android_Key
MAPS_IOS_KEY=AIzaSyExample_iOS_Key
FIREBASE_PROJECT_ID=pet-care-app-109bb
FIREBASE_APP_ID_ANDROID=1:123456789012:android:abc123
FIREBASE_APP_ID_IOS=1:123456789012:ios:abc123
FIREBASE_MESSAGING_SENDER_ID=123456789012
FIREBASE_API_KEY=AIzaSyExample_Firebase_API_Key
```

### **Backend Environment (.env.production)**
```bash
# Location: /packages/backend/.env.production
NODE_ENV=production
PORT=8080
FIREBASE_PROJECT_ID=pet-care-app-109bb
STRIPE_SECRET_KEY=sk_live_51Example
STRIPE_WEBHOOK_SECRET=whsec_Example
PAYPAL_CLIENT_ID=AXrQExample
PAYPAL_CLIENT_SECRET=EJExample
PAYPAL_WEBHOOK_ID=WH-Example
BASE_URL=https://api.mypetcare.it
MAINTENANCE_MODE=false
```

### **🚨 CRITICAL: GitHub Secrets**
Configura questi secrets nel repository GitHub:

```yaml
# Android Signing
ANDROID_KEYSTORE_BASE64: <base64_encoded_jks>
KS_PASS: <keystore_password>
ALIAS_PASS: <alias_password>
ALIAS: upload

# Play Console
PLAY_CONSOLE_JSON: <service_account_json>

# iOS Signing
APP_STORE_CONNECT_API_KEY: <base64_encoded_p8>
ASC_KEY_ID: <key_id>
ASC_ISSUER_ID: <issuer_id>

# Environment Variables
BACKEND_BASE_URL: https://api.mypetcare.it
SENTRY_DSN: <sentry_dsn>
```

---

## 3️⃣ Android Signing & Build

### **Step 1: Generate Keystore (One-Time)**
```bash
# Genera keystore per release signing
keytool -genkey -v -keystore android/keystore/upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Salva password in key.properties (NON committare!)
```

### **Step 2: Configure key.properties**
```properties
# Location: android/key.properties
storePassword=YourStrongPassword123!
keyPassword=YourStrongAliasPassword123!
keyAlias=upload
storeFile=../keystore/upload.jks
```

### **Step 3: Build Android App Bundle (AAB)**
```bash
# Clean build
flutter clean
flutter pub get

# Build release AAB
flutter build appbundle --release \
  --dart-define-from-file=.env.production.json

# Output: build/app/outputs/bundle/release/app-release.aab
```

### **Verify AAB**
```bash
# Check AAB size (should be < 150MB)
ls -lh build/app/outputs/bundle/release/app-release.aab

# Extract and verify contents
bundletool build-apks --bundle=app-release.aab \
  --output=app.apks --mode=universal
```

---

## 4️⃣ iOS Build (macOS Required)

### **Step 1: Configure Xcode**
```bash
# Open Xcode workspace
open ios/Runner.xcworkspace

# Verify:
# 1. Bundle ID: it.mypetcare.MyPetCare
# 2. Team: Your Apple Developer Team
# 3. Signing: Automatic or Manual
# 4. Capabilities: Push Notifications, Maps
```

### **Step 2: Build IPA**
```bash
flutter build ipa --release \
  --export-options-plist=ios/Runner/ExportOptions.plist \
  --dart-define-from-file=.env.production.json

# Output: build/ios/ipa/MyPetCare.ipa
```

### **Step 3: Verify IPA**
```bash
# Check IPA size
ls -lh build/ios/ipa/MyPetCare.ipa

# Extract and verify
unzip -l MyPetCare.ipa
```

---

## 5️⃣ Fastlane Automation

### **Install Fastlane**
```bash
# macOS (Homebrew)
brew install fastlane

# Ruby Gem
gem install fastlane
```

### **Android Deployment**
```bash
# Upload to Play Console Internal Track
cd android
fastlane beta

# Staged Rollout (10% → 50% → 100%)
fastlane rollout_10
# Wait 48h, monitor metrics
fastlane rollout_50
# Wait 24h, monitor metrics
fastlane rollout_100
```

### **iOS Deployment**
```bash
# Upload to TestFlight
cd ios
fastlane beta

# Release to App Store
fastlane release
```

---

## 6️⃣ GitHub Actions CI/CD

### **Automatic Trigger on Tag Push**
```bash
# Push tag to trigger CI/CD
git push origin v1.0.0

# GitHub Actions will:
# 1. Build Android AAB
# 2. Build iOS IPA (if macOS runner available)
# 3. Run tests and analysis
# 4. Upload to Play Console (internal track)
# 5. Upload to TestFlight
```

### **Manual Trigger (Workflow Dispatch)**
```bash
# Go to GitHub Actions tab
# Select "MyPetCare Production Release"
# Click "Run workflow"
# Choose platform: android/ios/both
```

### **Monitor Build Progress**
```
GitHub Repo → Actions → Latest workflow run
```

---

## 7️⃣ Backend Webhook Setup

### **Deploy Cloud Functions**
```bash
cd backend
npm install
npm run build
firebase deploy --only functions --project mypetcare-prod
```

### **Configure Stripe Webhooks**
```bash
# Stripe Dashboard → Developers → Webhooks
# Add endpoint: https://api.mypetcare.it/webhooks/stripe

# Events to listen:
# - invoice.payment_succeeded
# - customer.subscription.deleted
# - payment_intent.succeeded
# - charge.refunded
```

### **Configure PayPal Webhooks**
```bash
# PayPal Developer Dashboard → Webhooks
# Add webhook: https://api.mypetcare.it/webhooks/paypal

# Events to listen:
# - BILLING.SUBSCRIPTION.ACTIVATED
# - BILLING.SUBSCRIPTION.CANCELLED
# - PAYMENT.SALE.COMPLETED
# - PAYMENT.SALE.REFUNDED
```

### **Test Webhooks Locally**
```bash
# Stripe CLI
stripe listen --forward-to localhost:8080/webhooks/stripe
stripe trigger invoice.payment_succeeded

# PayPal Sandbox
# Use PayPal Developer Dashboard webhook simulator
```

---

## 8️⃣ Firestore Security Rules

### **Deploy Production Rules**
```bash
firebase deploy --only firestore:rules --project mypetcare-prod
```

### **Test Rules**
```bash
# Firebase Console → Firestore → Rules
# Click "Rules Playground"
# Test scenarios:
# - Owner reads own bookings ✓
# - Owner reads other user's bookings ✗
# - PRO updates own profile ✓
# - Guest reads PRO listings ✓
```

---

## 9️⃣ Database Seeding

### **Run Seeding Script**
```bash
cd backend
npm run seed

# Or manually:
node -r esbuild-register scripts/seed.ts
```

### **Verify Seeded Data**
```bash
# Firebase Console → Firestore
# Check collections:
# - users (3 test users)
# - pros (1 PRO profile)
# - calendars (1 calendar)
# - coupons (3 coupons: FREE-1M, FREE-3M, FREE-12M)
# - config (maintenance settings)
```

---

## 🔟 Test E2E

### **Run Test Scenarios**
Vedi **TEST_SCENARIOS.md** per la lista completa dei test.

### **Test Credentials**
```
Owner:  owner.test+1@mypetcare.it  / Test!2345
PRO:    pro.test+1@mypetcare.it    / Test!2345
Admin:  admin.test@mypetcare.it    / Test!2345

Stripe: 4242 4242 4242 4242 / 12/34 / 123
PayPal: buyer-sbx@mypetcare.it / Sbxtest123!

Coupons: FREE-1M, FREE-3M, FREE-12M
```

### **Critical Scenarios (Mandatory)**
1. ✅ Onboarding (Owner + PRO)
2. ✅ Subscription (Stripe + PayPal)
3. ✅ Booking & Payment
4. ✅ Cancellation & Refunds
5. ✅ Push Notifications
6. ✅ Security (Firestore rules)

---

## 1️⃣1️⃣ Store Submission

### **Android - Play Console**

#### **Pre-Submission Checklist**
```
[ ] AAB uploaded (build 100+)
[ ] App icon 512x512px
[ ] Screenshots (6.7" device)
[ ] Short description (80 chars)
[ ] Full description (4000 chars)
[ ] Privacy Policy URL
[ ] Terms of Service URL
[ ] Content rating completed
[ ] Pre-launch report reviewed (0 blockers)
[ ] Internal testing completed
```

#### **Rollout Strategy**
```
1. Internal Track (100 tester max)
   → Test 48-72h
   
2. Staged Rollout:
   → 10% utenti (48h monitor)
   → 50% utenti (24h monitor)
   → 100% rollout completo
```

### **iOS - App Store Connect**

#### **Pre-Submission Checklist**
```
[ ] IPA uploaded via Transporter
[ ] App icon 1024x1024px
[ ] Screenshots (6.5" & 12.9")
[ ] App description
[ ] Keywords
[ ] Privacy Policy URL
[ ] Terms of Service URL
[ ] App Review Information
[ ] TestFlight external testing approved
```

#### **Phased Release**
```
App Store Connect → Pricing and Availability
→ Enable "Phased Release for Automatic Updates"
→ 7-day automatic rollout
```

---

## 1️⃣2️⃣ Post-Launch Monitoring

### **Prime 72 Ore - Dashboard Obbligatoria**

#### **Eventi Critici**
```yaml
signup_completed:      Monitor signup flow
subscription_started:  Track PRO conversions
booking_created:       Monitor booking success rate
payment_failed:        Alert on payment issues
notification_sent:     Verify FCM delivery
```

#### **Metriche Target**
```
✅ Crash Rate:             < 0.1%
✅ Payment Success Rate:   ≥ 98%
✅ Webhook Success Rate:   ≥ 99%
✅ Notification Delivery:  < 5s
✅ API Response Time:      < 500ms
```

#### **Alert Automatici**
```yaml
HTTP Errors ≥400 > 1%:
  → Slack/Discord notification
  → Email dev team

Crashlytics New Issues:
  → Hotfix +1 build number
  → Deploy emergency update

Stripe Radar Alert:
  → Review fraud detection
  → Adjust risk parameters

Webhook Failure > 1%:
  → Check Cloud Functions logs
  → Verify webhook endpoints
```

### **Supporto Clienti**
```
📧 Email: help@mypetcare.it
💬 In-app: Pagina supporto integrata
📞 Phone: Opzionale (business plan)

SLA: 4h risposta (business hours)
```

### **Rollback Plan**

#### **Play Console Rollback**
```bash
# Console → Production → Releases
# Select previous stable version
# Click "Rollback"
# Rollout completes in ~1 hour
```

#### **App Store Rollback**
```bash
# App Store Connect → App Store → Versions
# Stop phased release
# Submit hotfix version +1
```

#### **Maintenance Mode**
```typescript
// Firestore: config/maintenance
{
  "maintenance": true,
  "message": "Manutenzione programmata. Torniamo alle 18:00."
}

// App checks this flag on startup
// Shows maintenance screen if enabled
```

---

## 🎯 Go/No-Go Decision Criteria

### **🔴 BLOCKER (NO-GO)**
- ❌ Crash blocker nelle ultime 24h
- ❌ Payment success rate < 98%
- ❌ Webhook failure rate > 1%
- ❌ Critical Firestore rules violations
- ❌ Pre-launch report critical issues

### **🟢 READY TO SHIP (GO)**
- ✅ 0 crash blocker 24h
- ✅ Payment success ≥ 98%
- ✅ Webhook success ≥ 99%
- ✅ All E2E scenarios PASSED
- ✅ Store assets complete
- ✅ Monitoring dashboard ready
- ✅ Support team available 72h

---

## 📚 Documentazione Correlata

- **TEST_SCENARIOS.md**: Scenari E2E completi
- **.env.production**: Environment variables template
- **firestore.rules**: Security rules production
- **backend/scripts/seed.ts**: Database seeding script

---

## 🆘 Troubleshooting

### **Build Failures**

#### **Android**
```bash
# Clean build cache
flutter clean
cd android && ./gradlew clean
cd ..

# Rebuild
flutter pub get
flutter build appbundle --release
```

#### **iOS**
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clean build
flutter clean
cd ios && pod install
cd ..

# Rebuild
flutter build ipa --release
```

### **Webhook Issues**
```bash
# Check Cloud Functions logs
firebase functions:log --project mypetcare-prod

# Test webhook locally
curl -X POST http://localhost:8080/webhooks/stripe \
  -H "Content-Type: application/json" \
  -d '{"test": true}'
```

### **Firestore Rules Errors**
```bash
# Test rules locally
firebase emulators:start --only firestore

# Deploy rules
firebase deploy --only firestore:rules
```

---

## ✅ Checklist Finale - READY TO SHIP

```
Phase 1: Preparation
[ ] Version bumped (1.0.0+100)
[ ] Git tag created (v1.0.0)
[ ] .env.production configured
[ ] GitHub Secrets configured
[ ] Keystore generated & secured

Phase 2: Build & Test
[ ] Android AAB built & verified
[ ] iOS IPA built & verified (if macOS)
[ ] Firestore rules deployed
[ ] Backend webhooks deployed
[ ] Database seeded
[ ] All E2E scenarios PASSED

Phase 3: Store Assets
[ ] App icons ready
[ ] Screenshots captured
[ ] Descriptions written
[ ] Privacy Policy published
[ ] Terms of Service published

Phase 4: Deployment
[ ] Play Console internal track uploaded
[ ] TestFlight external testing approved
[ ] Pre-launch report reviewed (0 blockers)
[ ] CI/CD pipeline tested

Phase 5: Monitoring
[ ] Crashlytics configured
[ ] Sentry/Analytics active
[ ] Alert webhooks configured
[ ] Support email monitored
[ ] Rollback plan documented

Phase 6: Go-Live
[ ] Staged rollout 10% (48h monitor)
[ ] Metrics within targets
[ ] 0 critical issues
[ ] READY FOR 100% ROLLOUT
```

---

**🎉 MyPetCare è production-ready! Buon lancio! 🐾**

**Per supporto tecnico:**
- 📧 tech@mypetcare.it
- 💬 GitHub Issues: [mypetcare/issues](https://github.com/mypetcare/issues)
- 📚 Docs: [docs.mypetcare.it](https://docs.mypetcare.it)
