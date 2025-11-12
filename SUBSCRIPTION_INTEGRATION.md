# 🎫 MY PET CARE - Subscription Integration Guide

Guida completa all'integrazione del sistema di sottoscrizioni PRO con Stripe Checkout, Webhook e Promotion Codes.

---

## 📋 Panoramica Sistema

Il sistema di sottoscrizioni PRO include:

- **3 Piani di Abbonamento**: Mensile (€29), Trimestrale (€79), Annuale (€299)
- **3 Promotion Codes**: FREE-1M, FREE-3M, FREE-12M (100% sconto per 1/3/12 mesi)
- **Stripe Checkout**: Pagamento sicuro con redirect
- **Webhook Automatico**: Aggiornamento stato subscription + visibilità profilo PRO
- **ProBlockedPage Flutter**: UI con CTA per attivazione abbonamenti e coupon

---

## 🔧 Setup Completo (15 minuti)

### Fase 1: Stripe Setup Script (3 minuti)

Lo script automatico `stripe_setup.ts` crea tutti i prodotti, prezzi e promotion code necessari.

```bash
# 1. Vai nella directory ops_scripts
cd ops_scripts/

# 2. Crea file .env con la tua Stripe Secret Key
echo "STRIPE_KEY=sk_test_..." > .env

# O per produzione:
echo "STRIPE_KEY=sk_live_..." > .env

# 3. Esegui lo script di setup
node --env-file=.env stripe_setup.ts
```

**Output atteso:**
```
✅ Product creato: PRO Monthly - price_1ABC123...
✅ Product creato: PRO Quarterly - price_1DEF456...
✅ Product creato: PRO Annual - price_1GHI789...
✅ Coupon creato: FREE-1M (duration: 1 month)
✅ Coupon creato: FREE-3M (duration: 3 months)
✅ Coupon creato: FREE-12M (duration: 12 months)
✅ Promotion Code creato: FREE-1M - promo_1JKL012...
✅ Promotion Code creato: FREE-3M - promo_1MNO345...
✅ Promotion Code creato: FREE-12M - promo_1PQR678...

🎉 Setup completato! Copia gli ID sopra nel file backend/.env
```

**IMPORTANTE**: Salva tutti gli ID generati (price_xxx e promo_xxx) - li userai nel prossimo step.

---

### Fase 2: Backend Configuration (5 minuti)

Aggiungi le variabili d'ambiente al backend.

```bash
cd backend/

# Crea .env se non esiste
cp .env.example .env

# Aggiungi le variabili con gli ID generati dallo script
nano .env
```

**Aggiungi queste variabili con gli ID effettivi:**

```env
# Stripe Subscription Prices (SOSTITUISCI con i price_xxx generati)
STRIPE_PRICE_PRO_MONTHLY=price_1ABC123...
STRIPE_PRICE_PRO_QUARTERLY=price_1DEF456...
STRIPE_PRICE_PRO_ANNUAL=price_1GHI789...

# Stripe Promotion Codes (OPZIONALE - SOSTITUISCI con i promo_xxx generati)
STRIPE_PROMO_FREE_1M=promo_1JKL012...
STRIPE_PROMO_FREE_3M=promo_1MNO345...
STRIPE_PROMO_FREE_12M=promo_1PQR678...

# Altre variabili richieste
STRIPE_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
APP_URL=https://app.mypetcare.it
APP_FEE_PCT=5
```

**Test Backend Locale:**
```bash
npm install
npm run dev

# Test endpoint subscribe (richiede auth token Firebase)
curl -X POST http://localhost:8080/pro/subscribe \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"plan":"monthly","free":0}'
```

---

### Fase 3: Stripe Webhook Setup (5 minuti)

Il webhook gestisce automaticamente:
- ✅ Aggiornamento stato subscription in Firestore (`subscriptions/{proId}`)
- ✅ Toggle visibilità profilo PRO (`pros.visible = true/false`)
- ✅ Gestione eventi: subscription.created, updated, deleted

**Setup su Stripe Dashboard:**

1. **Vai su**: https://dashboard.stripe.com/webhooks
2. **Click**: "Add endpoint"
3. **Endpoint URL**: `https://YOUR_CLOUD_RUN_URL/stripe/webhook`
4. **Eventi da ascoltare**:
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `payment_intent.succeeded` (opzionale, per booking payments)
   - `payment_intent.payment_failed` (opzionale)

5. **Copia Webhook Signing Secret**: `whsec_...`
6. **Aggiungi al backend .env**: `STRIPE_WEBHOOK_SECRET=whsec_...`

**Test Webhook (Stripe CLI):**
```bash
# Installa Stripe CLI: https://stripe.com/docs/stripe-cli
stripe login

# Forward webhook a localhost per test
stripe listen --forward-to localhost:8080/stripe/webhook

# In altra finestra, trigger evento test
stripe trigger customer.subscription.created
```

---

### Fase 4: Flutter App Configuration (2 minuti)

La `ProBlockedPage` è già integrata e pronta all'uso. Devi solo configurare l'URL backend.

**Opzione A: Dart Define (Raccomandato)**

```bash
# Durante flutter run, passa l'URL backend
flutter run -d chrome --dart-define=BACKEND_URL=https://your-run-url.run.app

# O aggiungi a launch.json per VS Code:
{
  "name": "Flutter (Chrome)",
  "request": "launch",
  "type": "dart",
  "args": [
    "--dart-define=BACKEND_URL=https://your-run-url.run.app"
  ]
}
```

**Opzione B: File di Configurazione**

Crea `lib/config.dart`:
```dart
class AppConfig {
  static const backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:8080', // Per dev locale
  );
}
```

Usa in `ProBlockedPage`:
```dart
import 'package:my_pet_care/config.dart';

// ...
final backendUrl = AppConfig.backendUrl;
final resp = await http.post(
  Uri.parse('$backendUrl/pro/subscribe'),
  // ...
);
```

---

## 🎯 Come Funziona: Flusso Completo

### Scenario 1: PRO attiva abbonamento mensile

**1. Utente PRO non ha subscription attiva**
- Navigando nell'app viene reindirizzato a `/pro-blocked`
- Vede `ProBlockedPage` con CTA piani disponibili

**2. Utente clicca "Abbonamento Mensile - €29/mese"**
```dart
_subscribeStripe(plan: 'monthly', free: 0)
```

**3. Flutter chiama backend `/pro/subscribe`**
```typescript
// Backend crea Stripe Customer se non esiste
const customer = await stripe.customers.create({
  email: req.auth.email,
  metadata: { proId: req.auth.uid }
});

// Crea Checkout Session
const session = await stripe.checkout.sessions.create({
  mode: 'subscription',
  customer: customerId,
  line_items: [{ price: 'price_1ABC123...', quantity: 1 }],
  success_url: 'https://app.mypetcare.it/pro/sub-success',
  cancel_url: 'https://app.mypetcare.it/pro/sub-cancel',
});

// Ritorna URL Checkout
res.json({ ok: true, url: session.url });
```

**4. Flutter apre Stripe Checkout in browser**
```dart
final uri = Uri.parse(checkoutUrl);
await launchUrl(uri, mode: LaunchMode.externalApplication);
```

**5. Utente completa pagamento su Stripe**

**6. Stripe invia webhook `customer.subscription.created` al backend**
```typescript
// Backend riceve evento
const sub = event.data.object; // Stripe Subscription
const customerId = sub.customer;

// Trova proId da customerId
const pros = await db.collection('pros')
  .where('payout.stripeCustomerId', '==', customerId)
  .get();
const proId = pros.docs[0].id;

// Aggiorna Firestore
await db.collection('subscriptions').doc(proId).set({
  provider: 'stripe',
  status: 'active',
  currentPeriodEnd: Timestamp.fromMillis(sub.current_period_end * 1000),
  lastUpdated: FieldValue.serverTimestamp()
}, { merge: true });

// Rendi profilo visibile
await db.collection('pros').doc(proId).set({ 
  visible: true 
}, { merge: true });
```

**7. Utente ritorna all'app**
- Riverpod rileva `subscriptions.isActive = true`
- Router non reindirizza più a `/pro-blocked`
- Profilo PRO ora visibile nella mappa

---

### Scenario 2: Admin assegna coupon FREE-3M

**1. Admin applica coupon da pannello admin**
```dart
// Admin page
await http.post(
  '$backendUrl/admin/pro-coupons/apply',
  headers: {'Authorization': 'Bearer $adminToken'},
  body: jsonEncode({
    'proId': 'target_pro_uid',
    'code': 'FREE-3M'
  })
);
```

**2. Backend applica coupon**
```typescript
// Backend endpoint /admin/pro-coupons/apply
const freeUntil = new Date();
freeUntil.setMonth(freeUntil.getMonth() + 3); // +3 mesi

await db.collection('subscriptions').doc(proId).set({
  status: 'in_trial',
  freeUntil: Timestamp.fromDate(freeUntil),
  lastUpdated: FieldValue.serverTimestamp()
}, { merge: true });

await db.collection('pros').doc(proId).set({ 
  visible: true 
}, { merge: true });
```

**3. PRO può ora operare per 3 mesi gratuitamente**

---

### Scenario 3: PRO usa Promotion Code FREE-1M direttamente

**1. Admin crea promotion code "FREE-1M" su Stripe** (già fatto da `stripe_setup.ts`)

**2. PRO clicca bottone "FREE-1M" su `ProBlockedPage`**
```dart
_subscribeStripe(plan: 'monthly', free: 1)
```

**3. Backend crea Checkout con promotion code automatico**
```typescript
let promotion_code: string | undefined;
if (free === 1) promotion_code = process.env.STRIPE_PROMO_FREE_1M;

const session = await stripe.checkout.sessions.create({
  mode: 'subscription',
  customer: customerId,
  line_items: [{ price: monthlyPriceId, quantity: 1 }],
  allow_promotion_codes: false, // Disabilita input manuale
  discounts: [{ promotion_code }], // Applica automaticamente
  // ...
});
```

**4. Stripe Checkout mostra prezzo €0 per il primo mese**

**5. Dopo 1 mese, subscription rinnova a €29/mese**

**6. Webhook aggiorna automaticamente lo stato ad ogni rinnovo**

---

## 🧪 Testing Completo

### Test 1: Activation Flow (Owner → PRO)

```bash
# 1. Registra nuovo utente con ruolo "pro"
# 2. Crea profilo PRO
# 3. Prova ad accedere a feature riservate PRO
# 4. Verifica redirect a /pro-blocked
# 5. Clicca "Abbonamento Mensile"
# 6. Completa checkout Stripe (usa test card 4242 4242 4242 4242)
# 7. Verifica redirect a /pro/sub-success
# 8. Controlla Firestore: subscriptions/{proId}.status = 'active'
# 9. Controlla pros/{proId}.visible = true
# 10. Verifica profilo PRO ora visibile nella mappa home
```

### Test 2: Coupon Application (Admin)

```bash
# 1. Login come admin
# 2. Vai a pannello admin coupons
# 3. Seleziona PRO target
# 4. Applica coupon "FREE-3M"
# 5. Verifica subscriptions/{proId}.freeUntil = +3 mesi
# 6. Verifica pros/{proId}.visible = true
# 7. Login come PRO target
# 8. Verifica accesso senza redirect a /pro-blocked
```

### Test 3: Promotion Code Direct Use

```bash
# 1. Login come PRO non attivo
# 2. Navigare a /pro-blocked
# 3. Cliccare bottone "FREE-1M"
# 4. Stripe Checkout mostra €0 per primo mese
# 5. Completa checkout
# 6. Verifica subscription creata con coupon applicato
# 7. Dopo 1 mese: verifica addebito €29 automatico
```

### Test 4: Webhook Events

```bash
# Usa Stripe CLI per simulare eventi

# Test subscription created
stripe trigger customer.subscription.created
# Verifica: subscriptions/{proId} creato con status 'active'

# Test subscription deleted (cancellazione)
stripe trigger customer.subscription.deleted
# Verifica: subscriptions/{proId}.status = 'canceled'
# Verifica: pros/{proId}.visible = false

# Test subscription updated (rinnovo)
stripe trigger customer.subscription.updated
# Verifica: currentPeriodEnd aggiornato
```

### Test 5: Subscription Expiration

```bash
# 1. Crea subscription di test
# 2. Usa Stripe Dashboard per impostare scadenza immediata
# 3. Esegui job schedulato /jobs/subscription-sweeper
# 4. Verifica: subscriptions/{proId}.status = 'none'
# 5. Verifica: pros/{proId}.visible = false
# 6. Login come PRO
# 7. Verifica redirect a /pro-blocked
```

---

## 🔒 Security Notes

### Backend Endpoint Protection

**`/pro/subscribe`** - Protected by `requireAuth` middleware
```typescript
// Solo utenti autenticati possono creare subscription
app.post('/pro/subscribe', requireAuth, async (req, res) => {
  // req.auth.uid garantito da middleware
});
```

**`/admin/pro-coupons/apply`** - Protected by `requireAdmin` middleware
```typescript
// Solo admin possono applicare coupon
app.post('/admin/pro-coupons/apply', requireAdmin, async (req, res) => {
  // Verifica role = 'admin' in Firestore
});
```

**`/stripe/webhook`** - Protected by Stripe signature verification
```typescript
// Solo richieste autentiche da Stripe accettate
const event = stripe.webhooks.constructEvent(
  req.body, 
  req.headers['stripe-signature'], 
  process.env.STRIPE_WEBHOOK_SECRET
);
// Se signature non valida → 400 Bad signature
```

### Firestore Security Rules

```javascript
// Solo backend può scrivere subscriptions
match /subscriptions/{proId} {
  allow read: if request.auth != null && request.auth.uid == proId;
  allow write: if false; // Solo backend via Admin SDK
}

// PRO visibility controllata da subscription
match /pros/{proId} {
  allow read: if true; // Public read per mappa
  allow update: if request.auth.uid == proId 
                && (!request.resource.data.diff(resource.data).affectedKeys().hasAny(['visible']));
  // visible può essere modificato solo da backend
}
```

---

## 📊 Monitoring & Analytics

### Stripe Dashboard Metrics

Monitora su https://dashboard.stripe.com/:

- **MRR (Monthly Recurring Revenue)**: Entrate mensili ricorrenti
- **Active Subscriptions**: Numero subscription attive
- **Churn Rate**: Tasso cancellazione mensile
- **Coupon Usage**: Utilizzo promotion codes

### Firebase Analytics Events

Traccia eventi personalizzati:

```dart
// Quando PRO attiva subscription
FirebaseAnalytics.instance.logEvent(
  name: 'subscription_activated',
  parameters: {
    'plan': plan, // monthly/quarterly/annual
    'price': price,
    'method': 'stripe_checkout',
  },
);

// Quando PRO usa coupon
FirebaseAnalytics.instance.logEvent(
  name: 'coupon_redeemed',
  parameters: {
    'code': code, // FREE-1M/3M/12M
    'months': months,
  },
);
```

### Cloud Run Logs

Monitora backend su Cloud Console:

```bash
# View logs
gcloud logging read "resource.type=cloud_run_revision" \
  --limit 50 \
  --format json

# Filter webhook events
gcloud logging read "resource.type=cloud_run_revision AND jsonPayload.message:webhook" \
  --limit 20
```

---

## 🚨 Troubleshooting

### Problema: Checkout non si apre

**Sintomo**: Clicking "Abbonamento Mensile" non apre Stripe Checkout

**Cause possibili**:
1. ❌ Backend URL non configurato correttamente
2. ❌ Firebase Auth token scaduto
3. ❌ STRIPE_PRICE_PRO_MONTHLY non impostato nel backend .env

**Fix**:
```bash
# Verifica backend URL
flutter run --dart-define=BACKEND_URL=https://your-url.run.app

# Test backend endpoint
curl -X POST https://your-url.run.app/pro/subscribe \
  -H "Authorization: Bearer $(firebase auth:token)" \
  -H "Content-Type: application/json" \
  -d '{"plan":"monthly","free":0}'

# Verifica .env backend
cat backend/.env | grep STRIPE_PRICE_PRO
```

---

### Problema: Webhook non aggiorna Firestore

**Sintomo**: Dopo checkout, subscription Firestore non viene creata

**Cause possibili**:
1. ❌ Webhook non configurato su Stripe
2. ❌ STRIPE_WEBHOOK_SECRET errato
3. ❌ Endpoint webhook non raggiungibile

**Fix**:
```bash
# Verifica webhook settings su Stripe Dashboard
# https://dashboard.stripe.com/webhooks

# Test webhook con Stripe CLI
stripe listen --forward-to https://your-url.run.app/stripe/webhook

# Trigger evento test
stripe trigger customer.subscription.created

# Check backend logs
gcloud logging read "resource.type=cloud_run_revision" \
  --filter "jsonPayload.message:webhook" \
  --limit 10
```

---

### Problema: ProBlockedPage continua a mostrare dopo pagamento

**Sintomo**: Dopo checkout success, utente ancora reindirizzato a /pro-blocked

**Cause possibili**:
1. ❌ Webhook non ha aggiornato subscriptions/{proId}
2. ❌ Riverpod provider non ha ricaricato dati
3. ❌ Routing guard non controlla correttamente subscription.isActive

**Fix**:
```dart
// Verifica subscription state in Firestore manualmente
// Firebase Console → Firestore → subscriptions/{proId}

// Force refresh subscription in app
final subscriptionProvider = Provider<Stream<Subscription>>((ref) {
  final uid = ref.watch(authProvider).value?.uid;
  if (uid == null) return Stream.value(Subscription.empty());
  
  return FirebaseFirestore.instance
    .collection('subscriptions')
    .doc(uid)
    .snapshots()
    .map((snap) => Subscription.fromFirestore(snap));
});

// In routing guard
redirect: (context, state) {
  final subscription = ref.read(subscriptionProvider).value;
  if (subscription == null || !subscription.isActive) {
    return '/pro-blocked';
  }
  return null;
}
```

---

### Problema: Promotion Code non applicato

**Sintomo**: Clicking "FREE-1M" apre checkout ma prezzo pieno €29

**Cause possibili**:
1. ❌ STRIPE_PROMO_FREE_1M non impostato nel backend .env
2. ❌ Promotion Code non creato su Stripe (script stripe_setup.ts non eseguito)
3. ❌ Promotion Code scaduto o disabilitato

**Fix**:
```bash
# Verifica promotion codes su Stripe Dashboard
# https://dashboard.stripe.com/coupons

# Re-esegui script setup se necessario
cd ops_scripts/
node --env-file=.env stripe_setup.ts

# Verifica backend .env
cat backend/.env | grep STRIPE_PROMO_FREE

# Test endpoint con coupon
curl -X POST https://your-url.run.app/pro/subscribe \
  -H "Authorization: Bearer $(firebase auth:token)" \
  -H "Content-Type: application/json" \
  -d '{"plan":"monthly","free":1}'
```

---

## 📚 Riferimenti

### Documentazione Esterna
- **Stripe Checkout**: https://stripe.com/docs/payments/checkout
- **Stripe Subscriptions**: https://stripe.com/docs/billing/subscriptions/overview
- **Stripe Webhooks**: https://stripe.com/docs/webhooks
- **Stripe Coupons**: https://stripe.com/docs/billing/subscriptions/coupons
- **Firebase Auth**: https://firebase.google.com/docs/auth
- **Firestore Security**: https://firebase.google.com/docs/firestore/security/get-started

### File del Progetto
- **Backend API**: `backend/src/index.ts`
- **Flutter ProBlockedPage**: `lib/screens/pro/pro_blocked_page.dart`
- **Subscription Model**: `lib/models/subscription_model.dart`
- **Stripe Setup Script**: `ops_scripts/stripe_setup.ts`
- **Backend .env Template**: `backend/.env.example`
- **Postman Collection**: `postman_collection.json`

### Documentazione Interna
- **QUICK_START.md**: Setup iniziale 30 minuti
- **DOCUMENTAZIONE_COMPLETA.md**: Architettura completa sistema
- **SETUP_CHECKLIST.md**: Checklist deployment produzione
- **TEST_DATA.md**: Script popolamento database test

---

## ✅ Checklist Integrazione

### Pre-Deploy
- [ ] Script `stripe_setup.ts` eseguito con successo
- [ ] Price ID copiati in backend/.env
- [ ] Promo Code ID copiati in backend/.env (opzionale)
- [ ] Webhook configurato su Stripe Dashboard
- [ ] STRIPE_WEBHOOK_SECRET aggiunto a backend/.env
- [ ] Backend .env completo di tutte le variabili richieste
- [ ] Flutter app configurata con BACKEND_URL
- [ ] Test locale backend funzionante (npm run dev)
- [ ] Test checkout Stripe con test card funzionante

### Post-Deploy
- [ ] Backend deployato su Cloud Run
- [ ] Webhook endpoint raggiungibile da Stripe
- [ ] Test end-to-end: registrazione → checkout → webhook → visibilità
- [ ] Test coupon application da admin panel
- [ ] Test promotion code direct use
- [ ] Monitoring configurato (Stripe Dashboard + Cloud Run logs)
- [ ] Documentation aggiornata con URL produzione
- [ ] Backup configuration file (.env, webhook secrets)

---

**Guida completata! 🎉**

Per supporto: petcareassistenza@gmail.com
