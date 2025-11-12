# 💳 MY PET CARE - Integrazione PayPal Subscribe

Guida completa all'integrazione del sistema di sottoscrizioni PRO con PayPal, parallelo a Stripe.

---

## 📋 Panoramica

Il sistema ora supporta **due provider di pagamento** per gli abbonamenti PRO:

- ✅ **Stripe** (primario): Checkout Session con carte di credito
- ✅ **PayPal** (alternativo): Subscription con approvazione PayPal

Entrambi i provider supportano:
- 3 piani di abbonamento (Mensile €29, Trimestrale €79, Annuale €299)
- Coupon gratuiti (FREE-1M/3M/12M) per bypass pagamento
- Webhook automatici per aggiornamento stato subscription

---

## 🔧 Setup PayPal (15 minuti)

### Step 1: Account PayPal Developer (5 minuti)

1. **Registrati** su: https://developer.paypal.com/
2. **Login** e vai su **Dashboard** → **Apps & Credentials**
3. **Crea App**:
   - Click "Create App"
   - Nome: "MY PET CARE PRO Subscriptions"
   - App Type: **Merchant**
   - Click "Create App"

4. **Ottieni Credenziali**:
   - **Sandbox** (per test):
     - Client ID: `xxx-sandbox`
     - Secret: `xxx-sandbox-secret`
   - **Live** (per produzione):
     - Client ID: `xxx-live`
     - Secret: `xxx-live-secret`

5. **Copia credenziali** → Le userai nel backend `.env`

---

### Step 2: Crea Subscription Plans su PayPal (10 minuti)

**Vai su**: https://www.paypal.com/billing/plans

**Crea 3 piani**:

#### Plan 1: PRO Monthly
1. Click "Create Plan"
2. **Product**:
   - Name: `PRO Monthly - MY PET CARE`
   - Type: `Service`
   - Category: `Professional Services`
3. **Pricing**:
   - Billing cycle: `Monthly`
   - Price: `€29.00`
   - Setup fee: None
4. **Settings**:
   - Auto-renewal: Yes
   - Trial: None (usiamo coupon invece)
5. **Save Plan** → Copia **Plan ID**: `P-XXXXXXXXXXXXXX`

#### Plan 2: PRO Quarterly
1. Click "Create Plan"
2. **Product**:
   - Name: `PRO Quarterly - MY PET CARE`
   - Type: `Service`
   - Category: `Professional Services`
3. **Pricing**:
   - Billing cycle: `Every 3 months`
   - Price: `€79.00`
4. **Save Plan** → Copia **Plan ID**: `P-YYYYYYYYYYYYYY`

#### Plan 3: PRO Annual
1. Click "Create Plan"
2. **Product**:
   - Name: `PRO Annual - MY PET CARE`
   - Type: `Service`
   - Category: `Professional Services`
3. **Pricing**:
   - Billing cycle: `Yearly`
   - Price: `€299.00`
4. **Save Plan** → Copia **Plan ID**: `P-ZZZZZZZZZZZZZZ`

**IMPORTANTE**: Salva tutti i Plan ID - li userai nel backend `.env`

---

### Step 3: Backend Configuration (3 minuti)

Aggiungi al file `backend/.env`:

```env
# PayPal Configuration
PAYPAL_CLIENT_ID=YOUR_PAYPAL_CLIENT_ID
PAYPAL_SECRET=YOUR_PAYPAL_SECRET
PAYPAL_MODE=sandbox  # O "live" per produzione

# PayPal Subscription Plan IDs
PAYPAL_PLAN_MONTHLY=P-XXXXXXXXXXXXXX
PAYPAL_PLAN_QUARTERLY=P-YYYYYYYYYYYYYY
PAYPAL_PLAN_ANNUAL=P-ZZZZZZZZZZZZZZ
```

**Esempio completo `.env`**:
```env
# Server
PORT=8080

# Firebase
FIREBASE_PROJECT_ID=mypetcare-prod
GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json

# Stripe (esistente)
STRIPE_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PRICE_PRO_MONTHLY=price_xxx
STRIPE_PRICE_PRO_QUARTERLY=price_xxx
STRIPE_PRICE_PRO_ANNUAL=price_xxx
STRIPE_PROMO_FREE_1M=promo_xxx
STRIPE_PROMO_FREE_3M=promo_xxx
STRIPE_PROMO_FREE_12M=promo_xxx

# PayPal (nuovo)
PAYPAL_CLIENT_ID=AaAaBbCc123...
PAYPAL_SECRET=EeEeFfGg456...
PAYPAL_MODE=live
PAYPAL_PLAN_MONTHLY=P-XXXXXXXXXXXXXX
PAYPAL_PLAN_QUARTERLY=P-YYYYYYYYYYYYYY
PAYPAL_PLAN_ANNUAL=P-ZZZZZZZZZZZZZZ

# Application Settings
APP_FEE_PCT=5
APP_URL=https://app.mypetcare.it

# SendGrid
SENDGRID_API_KEY=SG...
EMAIL_FROM=no-reply@mypetcare.it
EMAIL_REPLY_TO=petcareassistenza@gmail.com
```

---

### Step 4: PayPal Webhook Setup (5 minuti)

I webhook PayPal notificano il backend quando lo stato della subscription cambia.

**Setup su PayPal Dashboard**:

1. **Vai su**: https://developer.paypal.com/dashboard/
2. **Click**: Apps & Credentials → (tua app) → Webhooks
3. **Add Webhook**:
   - **Webhook URL**: `https://YOUR_CLOUD_RUN_URL/paypal/webhook`
   - **Event types** da selezionare:
     - `BILLING.SUBSCRIPTION.ACTIVATED`
     - `BILLING.SUBSCRIPTION.UPDATED`
     - `BILLING.SUBSCRIPTION.CANCELLED`
     - `BILLING.SUBSCRIPTION.SUSPENDED`
     - `BILLING.SUBSCRIPTION.EXPIRED`
4. **Save**

**Per test locale** (usando ngrok):
```bash
# Installa ngrok: https://ngrok.com/
ngrok http 8080

# Usa l'URL generato per webhook:
# https://abc123.ngrok.io/paypal/webhook
```

---

## 🔄 Come Funziona: Flusso PayPal Subscribe

### Scenario 1: PRO attiva abbonamento mensile PayPal

**1. Utente PRO clicca "Mensile €29/mese (PayPal)"**
```dart
// Flutter chiama
_subscribePayPal('monthly', 0)
```

**2. Backend crea PayPal Subscription**
```typescript
// Backend /pro/subscribe/paypal
const request = new paypal.subscriptions.SubscriptionsCreateRequest();
request.requestBody({
  plan_id: process.env.PAYPAL_PLAN_MONTHLY, // P-XXXXXXXXXXXXXX
  application_context: {
    brand_name: 'MY PET CARE',
    user_action: 'SUBSCRIBE_NOW',
    return_url: 'https://app.mypetcare.it/pro/sub-success',
    cancel_url: 'https://app.mypetcare.it/pro/sub-cancel'
  },
  subscriber: {
    email_address: proEmail
  },
  custom_id: proId // Per webhook lookup
});

const subscription = await paypalClient.execute(request);
const approvalLink = subscription.result.links.find(l => l.rel === 'approve').href;

res.json({ ok: true, approvalUrl: approvalLink });
```

**3. Flutter apre PayPal Approval URL**
```dart
final uri = Uri.parse(approvalUrl);
await launchUrl(uri, mode: LaunchMode.externalApplication);
```

**4. Utente approva su PayPal**
- Login PayPal account
- Review subscription details
- Click "Subscribe Now"

**5. PayPal redirect a success_url**
- URL: `https://app.mypetcare.it/pro/sub-success`
- Flutter mostra schermata successo

**6. PayPal invia webhook `BILLING.SUBSCRIPTION.ACTIVATED`**
```typescript
// Backend /paypal/webhook
const subscription = event.resource;
const proId = subscription.custom_id;

await db.collection('subscriptions').doc(proId).set({
  provider: 'paypal',
  status: 'active',
  paypalSubscriptionId: subscription.id,
  lastUpdated: FieldValue.serverTimestamp()
}, { merge: true });

await db.collection('pros').doc(proId).set({ 
  visible: true 
}, { merge: true });
```

**7. PRO profilo ora visibile**
- Firestore: `subscriptions/{proId}.status = 'active'`
- Firestore: `pros/{proId}.visible = true`
- Mappa home mostra il PRO

---

### Scenario 2: PRO usa coupon FREE-3M (PayPal)

**1. PRO clicca "FREE-3M (PayPal)"**
```dart
_subscribePayPal('monthly', 3)
```

**2. Backend bypassa PayPal e imposta freeUntil**
```typescript
// Backend /pro/subscribe/paypal
if (free > 0) {
  const months = Number(free);
  const freeUntil = new Date();
  freeUntil.setMonth(freeUntil.getMonth() + months);
  
  await db.collection('subscriptions').doc(proId).set({
    provider: 'paypal',
    status: 'in_trial',
    freeUntil: Timestamp.fromDate(freeUntil),
    lastUpdated: FieldValue.serverTimestamp()
  }, { merge: true });
  
  await db.collection('pros').doc(proId).set({ 
    visible: true 
  }, { merge: true });
  
  return res.json({ ok: true, message: 'Trial 3 mesi attivo' });
}
```

**3. Flutter mostra success message**
```dart
// No URL redirect, mostra snackbar
_showSnackBar('Abbonamento attivo! Profilo ora visibile.');
Navigator.pop(context);
```

**4. PRO può operare per 3 mesi gratuitamente**
- Dopo 3 mesi: Job sweeper disabilita profilo
- PRO deve sottoscrivere piano regolare

---

### Scenario 3: Cancellazione Subscription PayPal

**1. PRO cancella abbonamento da PayPal Dashboard**

**2. PayPal invia webhook `BILLING.SUBSCRIPTION.CANCELLED`**
```typescript
// Backend /paypal/webhook
const subscription = event.resource;
const proId = subscription.custom_id;

await db.collection('subscriptions').doc(proId).set({
  status: 'canceled',
  lastUpdated: FieldValue.serverTimestamp()
}, { merge: true });

await db.collection('pros').doc(proId).set({ 
  visible: false 
}, { merge: true });
```

**3. PRO profilo diventa invisibile**
- Firestore: `subscriptions/{proId}.status = 'canceled'`
- Firestore: `pros/{proId}.visible = false`
- Mappa home rimuove il PRO

---

## 🧪 Testing

### Test 1: PayPal Monthly Subscription

```bash
# 1. Registra nuovo PRO
# 2. Vai a /pro-blocked
# 3. Click "Mensile €29/mese (PayPal)"
# 4. Verifica apertura PayPal approval page
# 5. Login con PayPal Sandbox account (crea uno su developer.paypal.com)
# 6. Approva subscription
# 7. Verifica redirect a /pro/sub-success
# 8. Check Firestore: subscriptions/{proId}.status = 'active'
# 9. Check Firestore: pros/{proId}.visible = true
# 10. Verifica PRO visibile nella mappa home
```

### Test 2: PayPal FREE-3M Coupon

```bash
# 1. Login come PRO non attivo
# 2. Vai a /pro-blocked
# 3. Click "FREE-3M (PayPal)"
# 4. Verifica NO redirect (bypass PayPal)
# 5. Verifica snackbar "Abbonamento attivo!"
# 6. Check Firestore: subscriptions/{proId}.freeUntil = +3 mesi
# 7. Check Firestore: pros/{proId}.visible = true
# 8. Verifica accesso completo per 3 mesi
```

### Test 3: PayPal Webhook

```bash
# Usa PayPal Sandbox Dashboard per trigger eventi

# Test subscription activated
# Dashboard → Subscriptions → (tua subscription) → Cancel
# Verifica webhook ricevuto dal backend
# Check logs: gcloud logging read "resource.type=cloud_run_revision"

# Test subscription cancelled
# Dashboard → Subscriptions → (tua subscription) → Cancel
# Verifica pros.visible = false in Firestore
```

### Test 4: Confronto Stripe vs PayPal

```bash
# 1. Crea 2 PRO test accounts
# 2. PRO_A: Attiva con Stripe Monthly
# 3. PRO_B: Attiva con PayPal Monthly
# 4. Verifica entrambi visibili nella mappa
# 5. Check Firestore: 
#    - PRO_A: subscriptions.provider = 'stripe'
#    - PRO_B: subscriptions.provider = 'paypal'
# 6. Verifica payment provider diverso ma risultato identico
```

---

## 🔒 Security & Best Practices

### Webhook Signature Verification

**IMPORTANTE**: Il codice attuale non verifica la firma PayPal. Implementa prima del deploy produzione:

```typescript
// Backend /paypal/webhook
import crypto from 'crypto';

function verifyPayPalSignature(headers: any, body: string): boolean {
  const transmissionId = headers['paypal-transmission-id'];
  const timestamp = headers['paypal-transmission-time'];
  const webhookId = process.env.PAYPAL_WEBHOOK_ID; // Aggiungi a .env
  const certUrl = headers['paypal-cert-url'];
  const signature = headers['paypal-transmission-sig'];
  const algorithm = headers['paypal-auth-algo'];

  // Verifica signature secondo PayPal docs
  // https://developer.paypal.com/api/rest/webhooks/rest/
  
  // TODO: Implementa verifica completa
  return true; // PLACEHOLDER
}

app.post('/paypal/webhook', bodyParser.raw({ type: 'application/json' }), async (req, res) => {
  // Verifica signature prima di processare
  if (!verifyPayPalSignature(req.headers, req.body.toString())) {
    return res.status(400).send('Invalid signature');
  }
  
  // ... resto del codice webhook
});
```

### Custom ID per Lookup PRO

Il `custom_id` nella subscription PayPal contiene il `proId` Firebase:

```typescript
// Quando crei subscription
custom_id: (req as any).auth.uid // proId Firebase

// Nel webhook
const proId = event.resource.custom_id; // Recupera proId
```

**Best Practice**: Valida che `custom_id` sia un UID Firebase valido prima di aggiornare Firestore.

### Error Handling

```typescript
// Backend /pro/subscribe/paypal
try {
  const subscription = await paypalClient.execute(request);
  // ...
} catch (err: any) {
  console.error('PayPal subscription error:', err);
  
  // Log dettagliato per debug
  if (err.response) {
    console.error('PayPal API Error:', {
      status: err.response.status,
      body: err.response.body
    });
  }
  
  res.status(500).send('PAYPAL_ERROR');
}
```

---

## 📊 Monitoring

### PayPal Dashboard Metrics

**Monitora su**: https://www.paypal.com/billing/subscriptions

- Active subscriptions count
- Monthly recurring revenue (MRR)
- Cancellation rate
- Failed payment rate

### Backend Logs

```bash
# Cloud Run logs
gcloud logging read "resource.type=cloud_run_revision AND jsonPayload.message:paypal" \
  --limit 50

# Filter webhook events
gcloud logging read "resource.type=cloud_run_revision AND jsonPayload.endpoint:/paypal/webhook" \
  --limit 20

# Error logs
gcloud logging read "resource.type=cloud_run_revision AND severity>=ERROR AND jsonPayload.message:PayPal" \
  --limit 10
```

### Firebase Analytics Events

```dart
// Flutter - Track PayPal subscriptions
FirebaseAnalytics.instance.logEvent(
  name: 'subscription_activated',
  parameters: {
    'provider': 'paypal',
    'plan': plan, // monthly/quarterly/annual
    'price': price,
  },
);
```

---

## 🚨 Troubleshooting

### Problema: PayPal approval link non si apre

**Sintomo**: Click "Mensile (PayPal)" ma nessuna finestra PayPal

**Cause**:
1. ❌ `PAYPAL_PLAN_MONTHLY` non configurato in .env
2. ❌ PayPal credentials errate
3. ❌ Flutter `url_launcher` non funziona

**Fix**:
```bash
# Verifica .env
cat backend/.env | grep PAYPAL

# Test backend endpoint
curl -X POST https://your-url.run.app/pro/subscribe/paypal \
  -H "Authorization: Bearer $(firebase auth:token)" \
  -H "Content-Type: application/json" \
  -d '{"plan":"monthly","free":0}'

# Verifica response: dovrebbe contenere "approvalUrl"
```

---

### Problema: Webhook non aggiorna Firestore

**Sintomo**: Subscription attiva su PayPal ma profilo PRO non visibile

**Cause**:
1. ❌ Webhook non configurato su PayPal Dashboard
2. ❌ Webhook URL errato
3. ❌ `custom_id` non salvato nella subscription

**Fix**:
```bash
# Verifica webhook configurato
# PayPal Dashboard → Apps → Webhooks → Check endpoint

# Verifica webhook URL raggiungibile
curl -X POST https://your-url.run.app/paypal/webhook \
  -H "Content-Type: application/json" \
  -d '{"event_type":"BILLING.SUBSCRIPTION.ACTIVATED"}'

# Check backend logs
gcloud logging read "resource.type=cloud_run_revision AND jsonPayload.endpoint:/paypal/webhook"

# Verifica custom_id nella subscription PayPal
# Dashboard → Subscriptions → (tua subscription) → Details
```

---

### Problema: Coupon FREE-xM non attiva subscription

**Sintomo**: Click "FREE-3M (PayPal)" ma nessun effetto

**Cause**:
1. ❌ Backend non gestisce `free > 0` correttamente
2. ❌ Firestore permission denied

**Fix**:
```bash
# Test backend endpoint con free=3
curl -X POST https://your-url.run.app/pro/subscribe/paypal \
  -H "Authorization: Bearer $(firebase auth:token)" \
  -H "Content-Type: application/json" \
  -d '{"plan":"monthly","free":3}'

# Response attesa: {"ok":true,"message":"Trial 3 mesi attivo"}

# Verifica Firestore manualmente
# Firebase Console → Firestore → subscriptions/{proId}
# Dovrebbe avere: freeUntil = +3 mesi da ora
```

---

## 📚 Riferimenti

### Documentazione PayPal
- **Subscriptions API**: https://developer.paypal.com/docs/subscriptions/
- **Webhooks**: https://developer.paypal.com/api/rest/webhooks/
- **SDK Node.js**: https://github.com/paypal/Checkout-NodeJS-SDK
- **Sandbox Testing**: https://developer.paypal.com/tools/sandbox/

### Documentazione MY PET CARE
- **Subscription Integration**: `SUBSCRIPTION_INTEGRATION.md`
- **Backend API**: `backend/src/index.ts`
- **ProBlockedPage**: `lib/screens/pro/pro_blocked_page.dart`
- **Quick Start**: `QUICK_START.md`

---

## ✅ Checklist Integrazione PayPal

### Pre-Deploy
- [ ] Account PayPal Developer creato
- [ ] App PayPal creata (Client ID + Secret ottenuti)
- [ ] 3 Subscription Plans creati su PayPal Dashboard
- [ ] Plan IDs copiati in backend/.env
- [ ] PayPal credentials aggiunte a backend/.env
- [ ] PAYPAL_MODE impostato correttamente (sandbox/live)
- [ ] Webhook configurato su PayPal Dashboard
- [ ] Backend deployato con nuove variabili
- [ ] Flutter app testata con entrambi i provider

### Post-Deploy
- [ ] Test subscription PayPal Monthly funzionante
- [ ] Test subscription PayPal Annual funzionante
- [ ] Test coupon FREE-1M/3M/12M (PayPal) funzionanti
- [ ] Webhook events ricevuti e processati correttamente
- [ ] Firestore aggiornato automaticamente dopo approval
- [ ] PRO profilo visibility toggle funzionante
- [ ] Logs backend puliti senza errori PayPal
- [ ] Monitoring configurato (PayPal Dashboard + Cloud Run)
- [ ] Documentazione aggiornata con URL produzione

---

**Integrazione PayPal completata! 🎉**

Ora gli utenti PRO possono scegliere tra:
- ✅ Stripe (carte di credito)
- ✅ PayPal (account PayPal)
- ✅ Coupon gratuiti per entrambi i provider

**Per supporto**: petcareassistenza@gmail.com
