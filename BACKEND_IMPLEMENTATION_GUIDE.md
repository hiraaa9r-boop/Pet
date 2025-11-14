# 🚀 MyPetCare Backend - Guida all'Implementazione

## 📋 Panoramica

Questa guida documenta l'implementazione completa del backend MyPetCare basato su Node.js + TypeScript + Express + Firebase.

### Struttura del Progetto

```
backend/
├── src/
│   ├── index.ts                          # Entry point Express server
│   ├── config.ts                         # Configurazione centralizzata
│   ├── firebase.ts                       # Inizializzazione Firebase Admin SDK
│   ├── middleware/
│   │   └── auth.ts                       # Middleware autenticazione (requireAuth, requireAdmin)
│   └── routes/
│       ├── payments.ts                   # Checkout Stripe + PayPal
│       ├── payments.stripe.webhook.ts    # Webhook Stripe per eventi subscription
│       ├── payments.paypal.webhook.ts    # Webhook PayPal per eventi subscription
│       ├── notifications.ts              # Sistema notifiche FCM + Firestore
│       ├── admin.ts                      # Dashboard admin (stats, PRO approval, coupons)
│       ├── pros.ts                       # Gestione profili PRO
│       └── bookings.ts                   # Gestione prenotazioni con notifiche
├── package.json
├── tsconfig.json
├── Dockerfile
└── .env.example
```

---

## 🔧 Setup Iniziale

### 1. Installazione Dipendenze

```bash
cd backend
npm install
```

### 2. Configurazione Environment Variables

Copia `.env.example` in `.env` e compila i valori:

```bash
cp .env.example .env
```

**Variabili richieste:**

- `STRIPE_SECRET_KEY` - Chiave segreta Stripe da dashboard
- `STRIPE_WEBHOOK_SECRET` - Secret webhook Stripe
- `PAYPAL_CLIENT_ID` - Client ID PayPal
- `PAYPAL_SECRET` - Secret PayPal
- `PAYPAL_API` - URL API PayPal (sandbox o production)
- `PAYPAL_WEBHOOK_ID` - ID webhook PayPal
- `GOOGLE_APPLICATION_CREDENTIALS` - Path al file JSON Firebase Admin SDK

### 3. Firebase Admin SDK

1. Vai su Firebase Console → Project Settings → Service Accounts
2. Clicca "Generate new private key"
3. Salva il file JSON e imposta il path in `GOOGLE_APPLICATION_CREDENTIALS`

---

## 🚦 Avvio Server

### Development Mode (con hot-reload)

```bash
npm run dev
```

Server attivo su `http://localhost:8080`

### Production Build

```bash
npm run build
npm start
```

### Docker

```bash
# Build immagine
docker build -t mypetcare-backend .

# Run container
docker run -p 8080:8080 --env-file .env mypetcare-backend
```

---

## 📡 API Endpoints

### 🔐 Autenticazione

Tutti gli endpoint richiedono header `Authorization: Bearer <firebase_token>` (tranne webhook e healthcheck).

**Middleware disponibili:**
- `requireAuth` - Verifica token Firebase e popola `req.user`
- `requireAdmin` - Richiede ruolo admin
- `requirePro` - Richiede ruolo PRO

---

### 💳 Pagamenti

#### `POST /api/payments/stripe/checkout`
Crea sessione checkout Stripe per abbonamento PRO.

**Body:**
```json
{
  "proId": "string",
  "priceId": "string",
  "successUrl": "string (optional)",
  "cancelUrl": "string (optional)"
}
```

**Response:**
```json
{
  "url": "https://checkout.stripe.com/..."
}
```

#### `POST /api/payments/stripe/webhook`
Webhook Stripe (raw body required).

**Eventi gestiti:**
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `invoice.payment_succeeded`
- `invoice.payment_failed`

#### `POST /api/payments/paypal/create-order`
Crea ordine PayPal per pagamento.

**Body:**
```json
{
  "proId": "string",
  "amount": "string",
  "returnUrl": "string (optional)",
  "cancelUrl": "string (optional)"
}
```

**Response:**
```json
{
  "approvalLink": "https://www.paypal.com/checkoutnow?token=..."
}
```

#### `POST /api/payments/paypal/webhook`
Webhook PayPal con verifica firma.

---

### 🔔 Notifiche

#### `POST /api/notifications/register-token`
Registra token FCM per utente.

**Body:**
```json
{
  "userId": "string",
  "token": "string"
}
```

#### `GET /api/notifications/:userId`
Lista notifiche in-app dell'utente.

**Query params:**
- `limit` (default: 50)
- `unreadOnly` (default: false)

#### `POST /api/notifications/:userId/:notificationId/mark-read`
Marca notifica come letta.

#### `POST /api/notifications/test`
Endpoint di test (rimuovere in produzione).

**Funzione helper esportata:**
```typescript
import { sendNotificationToUser } from './routes/notifications';

await sendNotificationToUser(userId, {
  type: 'booking_created',
  title: 'Nuova prenotazione',
  body: 'Hai ricevuto una nuova prenotazione',
  data: { bookingId: '123' }
});
```

---

### 👨‍💼 Admin

**Tutti gli endpoint richiedono `requireAuth` + `requireAdmin`**

#### `GET /api/admin/stats`
Statistiche piattaforma.

**Response:**
```json
{
  "totalPros": 150,
  "activePros": 42,
  "approvedPros": 38,
  "pendingPros": 12,
  "totalBookings": 1250
}
```

#### `GET /api/admin/pros/pending`
Lista PRO in attesa di approvazione.

#### `POST /api/admin/pros/:id/approve`
Approva profilo PRO.

#### `POST /api/admin/pros/:id/reject`
Rifiuta profilo PRO (con notifica).

#### `GET /api/admin/coupons`
Lista tutti i coupon.

#### `POST /api/admin/coupons`
Crea nuovo coupon.

**Body:**
```json
{
  "code": "string",
  "monthsFree": "number",
  "description": "string (optional)",
  "maxUses": "number (optional)"
}
```

#### `PATCH /api/admin/coupons/:id`
Attiva/disattiva coupon.

---

### 🦸 PRO

#### `POST /api/pros/me` (requireAuth)
Crea/aggiorna profilo PRO del current user.

**Body:**
```json
{
  "displayName": "string",
  "city": "string",
  "services": ["string"],
  "categories": ["string"],
  "description": "string",
  "phone": "string"
}
```

#### `GET /api/pros`
Lista PRO visibili (approved + abbonati attivi).

#### `GET /api/pros/:id`
Dettaglio singolo PRO.

---

### 📅 Prenotazioni

#### `POST /api/bookings` (requireAuth)
Crea nuova prenotazione e invia notifiche.

**Body:**
```json
{
  "proId": "string",
  "serviceId": "string",
  "serviceName": "string",
  "startTime": "ISO 8601 string",
  "endTime": "ISO 8601 string",
  "notes": "string (optional)"
}
```

#### `GET /api/bookings/my` (requireAuth)
Lista prenotazioni dell'utente autenticato.

#### `GET /api/bookings/:id` (requireAuth)
Dettaglio prenotazione (solo owner o PRO).

---

## ⚙️ Configurazione Webhook

### Stripe Webhook

1. Vai su [Stripe Dashboard → Webhooks](https://dashboard.stripe.com/webhooks)
2. Clicca "Add endpoint"
3. URL: `https://your-backend.com/api/payments/stripe/webhook`
4. Seleziona eventi:
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
5. Copia il "Signing secret" e aggiungi a `.env` come `STRIPE_WEBHOOK_SECRET`

### PayPal Webhook

1. Vai su [PayPal Developer Dashboard → Webhooks](https://developer.paypal.com/dashboard/webhooks)
2. Crea nuovo webhook
3. URL: `https://your-backend.com/api/payments/paypal/webhook`
4. Seleziona eventi:
   - `BILLING.SUBSCRIPTION.*`
   - `PAYMENT.SALE.COMPLETED`
5. Copia il "Webhook ID" e aggiungi a `.env` come `PAYPAL_WEBHOOK_ID`

---

## 🗄️ Schema Firestore

### Collection: `pros`
```typescript
{
  uid: string,
  displayName: string,
  city: string,
  services: string[],
  categories: string[],
  description: string,
  phone: string,
  status: 'pending' | 'approved' | 'rejected',
  subscriptionStatus: 'active' | 'inactive' | 'trial' | 'past_due',
  subscriptionProvider: 'stripe' | 'paypal' | null,
  subscriptionPlan: string | null,
  currentPeriodStart: Timestamp | null,
  currentPeriodEnd: Timestamp | null,
  lastPaymentAt: Timestamp | null,
  cancelAtPeriodEnd: boolean,
  stripeCustomerId: string | null,
  stripeSubscriptionId: string | null,
  paypalOrderId: string | null,
  approvedAt: Timestamp | null,
  updatedAt: Timestamp
}
```

### Collection: `userPushTokens`
```typescript
{
  userId: string, // Document ID
  tokens: string[], // Array di FCM tokens
  updatedAt: Timestamp
}
```

### Collection: `notifications/{userId}/items`
```typescript
{
  type: 'booking' | 'payment' | 'approval' | 'generic',
  title: string,
  body: string,
  data: Record<string, any>,
  read: boolean,
  createdAt: Timestamp,
  readAt: Timestamp (optional)
}
```

### Collection: `coupons`
```typescript
{
  code: string, // UPPERCASE
  type: 'FREE_MONTHS',
  monthsFree: number,
  description: string | null,
  active: boolean,
  maxUses: number | null,
  currentUses: number,
  createdAt: Timestamp
}
```

### Collection: `bookings`
```typescript
{
  ownerId: string,
  proId: string,
  serviceId: string,
  serviceName: string,
  startTime: Timestamp,
  endTime: Timestamp,
  notes: string | null,
  status: 'booked' | 'completed' | 'cancelled',
  createdAt: Timestamp
}
```

---

## 🔒 Sicurezza

### Verifica Firma Webhook

**Stripe:**
- Usa `express.raw()` per raw body
- Verifica firma con `stripe.webhooks.constructEvent()`
- DEVE essere registrato PRIMA di `express.json()`

**PayPal:**
- Usa `/v1/notifications/verify-webhook-signature`
- Verifica tramite API PayPal con access token

### Token Firebase

- Tutti gli endpoint protetti verificano token Firebase
- Ruoli gestiti tramite custom claims o Firestore collection `users`
- Middleware `requireAdmin` verifica ruolo admin

---

## 🧪 Testing

```bash
# Test endpoint healthcheck
curl http://localhost:8080/health

# Test con token Firebase
curl -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
     http://localhost:8080/api/pros/me
```

---

## 🚀 Deploy

### Cloud Run (Google Cloud)

```bash
# Build e push immagine
gcloud builds submit --tag gcr.io/PROJECT_ID/mypetcare-backend

# Deploy
gcloud run deploy mypetcare-backend \
  --image gcr.io/PROJECT_ID/mypetcare-backend \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated \
  --set-env-vars "NODE_ENV=production" \
  --set-secrets="STRIPE_SECRET_KEY=stripe_secret:latest"
```

### Heroku

```bash
heroku container:push web -a mypetcare-backend
heroku container:release web -a mypetcare-backend
```

---

## 📝 Note Importanti

1. **Webhook Stripe**: DEVE usare `express.raw()` body parser
2. **PayPal Token**: Implementato caching automatico per performance
3. **FCM Token Cleanup**: Rimozione automatica token invalidi
4. **Admin Access**: Primo admin da configurare manualmente su Firestore
5. **Environment Variables**: Mai committare `.env` su git

---

## 🆘 Troubleshooting

### Stripe webhook fallisce con 400

- Verifica che `STRIPE_WEBHOOK_SECRET` sia corretto
- Assicurati che webhook sia registrato PRIMA di `express.json()`
- Controlla che il raw body arrivi correttamente

### PayPal token error

- Verifica credenziali `PAYPAL_CLIENT_ID` e `PAYPAL_SECRET`
- Controlla URL API corretto (sandbox vs production)

### Firebase Admin SDK error

- Verifica path file JSON in `GOOGLE_APPLICATION_CREDENTIALS`
- Controlla permessi file JSON (readable)
- Verifica che service account abbia ruoli corretti su Firebase

---

## 📚 Risorse

- [Stripe API Docs](https://stripe.com/docs/api)
- [PayPal API Docs](https://developer.paypal.com/api/rest/)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
