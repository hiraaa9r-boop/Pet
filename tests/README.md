# 🧪 MyPetCare API Tests

Collezione completa di test API per MyPetCare con supporto per **VS Code REST Client** e **Postman**.

## 🔧 Strumenti Disponibili

### Opzione A: VS Code REST Client (Raccomandato per sviluppatori)
- ✅ Test rapidi direttamente da VS Code
- ✅ Environment variables con `.env`
- ✅ Sintassi semplice e leggibile
- 📄 **File**: `admin.http`, `payments.http`

### Opzione B: Postman (Raccomandato per QA/Product Manager)
- ✅ Interfaccia grafica user-friendly
- ✅ Gestione environment multipli (dev/staging/production)
- ✅ Collection sharing con team
- ✅ Test automation e monitoring
- 📄 **File**: `postman_admin_collection.json`
- 📖 **Guida Setup**: Vedi `POSTMAN_SETUP.md`

**👉 Se usi Postman, vai direttamente alla [Guida Postman Setup](POSTMAN_SETUP.md)**

---

## 📦 File Disponibili

| File | Tipo | Descrizione |
|------|------|-------------|
| `admin.http` | REST Client | Test endpoint admin (stats, refund) |
| `payments.http` | REST Client | Test endpoint pagamenti (Stripe, PayPal, coupon) |
| `postman_admin_collection.json` | Postman | Collection Postman per admin API |
| `POSTMAN_SETUP.md` | Documentazione | Guida completa setup Postman |
| `README.md` | Documentazione | Questa guida (REST Client focus) |

---

## 📋 Prerequisiti

### 1. Installa VS Code REST Client Extension

```bash
# Da VS Code
# Cerca "REST Client" di Humao nella marketplace
# Oppure installa da: https://marketplace.visualstudio.com/items?itemName=humao.rest-client
```

### 2. Configura Environment Variables

Crea file `.env` nella root del progetto:

```bash
# /home/user/flutter_app/.env
FIREBASE_ADMIN_ID_TOKEN=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
FIREBASE_USER_ID_TOKEN=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 3. Ottieni Firebase ID Token

**Metodo 1 - Da Flutter App (Debug Mode):**
```dart
// In main.dart o dovunque dopo login
import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final token = await user.getIdToken();
  print('🔑 ID Token: $token');
}
```

**Metodo 2 - Da Firebase Console:**
1. Vai a Firebase Console → Authentication → Users
2. Seleziona un utente con ruolo admin
3. Copia UID
4. Usa Firebase REST API:
```bash
curl 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=YOUR_API_KEY' \
-H 'Content-Type: application/json' \
-d '{"email":"admin@mypetcare.app","password":"yourpassword","returnSecureToken":true}'
```

**Metodo 3 - Da Browser DevTools:**
1. Apri Flutter Web app
2. F12 → Console
3. Esegui:
```javascript
firebase.auth().currentUser.getIdToken().then(t => console.log(t))
```

---

## 🚀 File di Test Disponibili

### 1. `admin.http` - Admin API Tests

**Endpoint testati:**
- ✅ Health check
- ✅ Admin stats (PRO attivi, users, revenue 30d, bookings 30d)
- ✅ Refund totale (Stripe/PayPal)
- ✅ Refund parziale con amount specifico
- ✅ Test con Stripe invoice ID
- ✅ Test con PayPal capture ID

**Come usare:**
1. Apri `tests/admin.http` in VS Code
2. Aggiorna `@token` con tuo Firebase Admin ID Token
3. Click su "Send Request" sopra ogni blocco `###`
4. Verifica response in pannello laterale

**Esempio sostituzione Payment ID:**
```http
# PRIMA
POST {{baseUrl}}/admin/refund/PAYMENT_ID_HERE

# DOPO (Stripe invoice)
POST {{baseUrl}}/admin/refund/in_1PQzEL2eZvKYlo2C8KKfQjXt

# DOPO (PayPal capture)
POST {{baseUrl}}/admin/refund/8LW12345X6789012K
```

### 2. `payments.http` - Payments API Tests

**Endpoint testati:**
- ✅ Health check
- ✅ Create Stripe Checkout Session (con/senza coupon)
- ✅ Create Stripe Billing Portal
- ✅ Create PayPal Order (mensile/annuale)
- ✅ Capture PayPal Order
- ✅ Validate Coupon (valido/invalido/vuoto)

**Come usare:**
1. Apri `tests/payments.http` in VS Code
2. Aggiorna `@token` con tuo Firebase User ID Token
3. Sostituisci `price_ABC123` con tuo Price ID Stripe reale
4. Click "Send Request" per testare

**Esempio sostituzioni:**
```http
# Stripe Price ID (da Stripe Dashboard → Products)
"planId": "price_1PQzEL2eZvKYlo2C8KKfQjXt"

# PayPal Order ID (da response create-order)
POST {{baseUrl}}/payments/paypal/capture/8LW12345X6789012K

# Stripe Customer ID (da Firestore users/{uid}.subscription.customerId)
"customerId": "cus_PQzEL2eZvKYlo2C"
```

---

## 📊 Expected Responses

### Admin Stats Success
```json
{
  "usersTotal": 523,
  "activePros": 47,
  "revenue30d": "12847.50",
  "bookings30d": 234,
  "generatedAt": "2025-01-15T10:30:00.000Z"
}
```

### Refund Success (Stripe)
```json
{
  "ok": true,
  "refund": {
    "provider": "stripe",
    "refundId": "re_1PQzEL2eZvKYlo2C8KKfQjXt",
    "amountCents": 499,
    "status": "succeeded"
  }
}
```

### Refund Success (PayPal)
```json
{
  "ok": true,
  "refund": {
    "provider": "paypal",
    "refundId": "8LW12345X6789012K",
    "amountCents": 499,
    "status": "COMPLETED"
  }
}
```

### Stripe Checkout Session Success
```json
{
  "url": "https://checkout.stripe.com/c/pay/cs_test_a1b2c3d4e5f6g7h8i9j0#fidkdWxOYHwnPyd1blpxYHZxWjA0T3JscmpGN19QdWM2VWdyX0FWQmBzYjZGcXdmZ3FxfXRhUTU3bmtiR0huXXJTXUptcGlfYVBsZWBLVkdOZjZHcj1vN3xHdXFwdElJUE9zMHZsQ1JSa0FNbGFiY35KXSc"
}
```

### Coupon Validation Success
```json
{
  "valid": true,
  "type": "free_months",
  "months": 1
}
```

### Coupon Validation Failure
```json
{
  "valid": false,
  "reason": "Not found"
}
```

---

## 🔒 Sicurezza e Best Practices

### 1. Token Scadenza
I Firebase ID Token scadono dopo **1 ora**. Se ricevi `401 Unauthorized`:
```http
HTTP/1.1 401 Unauthorized
{
  "error": "Invalid or expired token"
}
```
**Soluzione**: Rigenera token da app o console.

### 2. Admin Role Verification
Se ricevi `403 Forbidden` su endpoint admin:
```http
HTTP/1.1 403 Forbidden
{
  "error": "Forbidden"
}
```
**Soluzione**: Verifica che l'utente abbia ruolo admin in Firestore:
```javascript
// Firestore users/{uid}
{
  "role": "admin"  // ⚠️ Deve essere "admin", non "owner" o "pro"
}
```

### 3. Payment ID Format
**Stripe:**
- Invoice: `in_1234567890`
- Charge: `ch_1234567890`
- Payment Intent: `pi_1234567890`

**PayPal:**
- Order: `8LW12345X6789012K` (17 chars alfanumerici uppercase)
- Capture: Same format as Order ID

### 4. Environment URLs

**Development:**
```http
@baseUrl = http://localhost:8080
```

**Staging:**
```http
@baseUrl = https://api-staging.mypetcare.app
```

**Production:**
```http
@baseUrl = https://api.mypetcare.app
```

---

## 🧪 Test Workflow Consigliato

### 1. Test Pre-Deploy (Staging)

```bash
# Step 1: Health check
GET /health

# Step 2: Admin stats (verifica RBAC)
GET /admin/stats

# Step 3: Create Stripe session (verifica redirect URL)
POST /payments/stripe/create-session

# Step 4: Create PayPal order (verifica approval link)
POST /payments/paypal/create-order

# Step 5: Validate coupon (verifica logica sconto)
POST /payments/coupon/validate
```

### 2. Test Post-Deploy (Production)

```bash
# Step 1: Health check production
GET https://api.mypetcare.app/health

# Step 2: Stats con dati reali
GET https://api.mypetcare.app/admin/stats

# Step 3: Test refund su pagamento dummy
POST https://api.mypetcare.app/admin/refund/DUMMY_PAYMENT_ID
```

### 3. Test E2E Completo

1. **Create Stripe Session** → Copia `url` → Apri in browser → Completa checkout
2. **Webhook Stripe** → Verifica evento in Stripe Dashboard → Check Firestore `/payments`
3. **Admin Stats** → Verifica `revenue30d` aggiornato
4. **Refund** → Esegui rimborso → Verifica `refunded: true` in Firestore
5. **Validate Receipt** → Check Firebase Storage `/receipts/{userId}/stripe_{paymentId}.pdf`

---

## 📝 Customization Tips

### Aggiungere Nuovo Endpoint

```http
###
# 11) Get User Bookings
GET {{baseUrl}}/bookings?userId=USER_ID_HERE
Authorization: Bearer {{token}}
Accept: application/json
```

### Aggiungere Variabili Custom

```http
@baseUrl = https://api.mypetcare.app
@token = {{$processEnv FIREBASE_ADMIN_ID_TOKEN}}
@proId = pro-test-1
@userId = user-test-1

###
GET {{baseUrl}}/pros/{{proId}}
Authorization: Bearer {{token}}
```

### Test con File Upload (Multipart)

```http
###
POST {{baseUrl}}/upload/receipt
Authorization: Bearer {{token}}
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW

------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="file"; filename="receipt.pdf"
Content-Type: application/pdf

< ./test-files/receipt.pdf
------WebKitFormBoundary7MA4YWxkTrZu0gW--
```

---

## 🔍 Troubleshooting

### Errore: "Cannot connect to server"
```
Error: connect ECONNREFUSED 127.0.0.1:8080
```
**Soluzione**: Verifica che backend sia running:
```bash
cd backend
npm run dev
```

### Errore: "Invalid JSON"
```
SyntaxError: Unexpected token < in JSON at position 0
```
**Soluzione**: Server ritorna HTML invece di JSON. Check URL corretto.

### Errore: "CORS error"
```
Access to fetch has been blocked by CORS policy
```
**Soluzione**: Verifica CORS config in `backend/src/index.ts`:
```typescript
app.use(cors({
  origin: process.env.FRONTEND_URL || 'https://mypetcare.it',
  credentials: true,
}));
```

---

## 📖 Risorse Aggiuntive

### Documentazione Test
- **Postman Setup Guide**: `tests/POSTMAN_SETUP.md` - Guida completa per Postman
- **Admin Tests**: `tests/admin.http` - Test REST Client per endpoint admin
- **Payments Tests**: `tests/payments.http` - Test REST Client per pagamenti

### API Documentation
- **Stripe API Docs**: https://stripe.com/docs/api
- **PayPal API Docs**: https://developer.paypal.com/api/rest/
- **Firebase Auth Tokens**: https://firebase.google.com/docs/auth/admin/verify-id-tokens

### Tools
- **VS Code REST Client**: https://marketplace.visualstudio.com/items?itemName=humao.rest-client
- **Postman Download**: https://www.postman.com/downloads/

---

## 🎯 Quick Start

### Per Utenti VS Code
```bash
# 1. Installa estensione REST Client
# 2. Apri tests/admin.http in VS Code
# 3. Aggiorna @token con tuo Firebase Admin ID Token
# 4. Click "Send Request" sopra ogni blocco ###
```

### Per Utenti Postman
```bash
# 1. Scarica Postman da https://www.postman.com/downloads/
# 2. Importa tests/postman_admin_collection.json
# 3. Configura Environment Variables (baseUrl, adminToken, paymentId)
# 4. Segui guida completa in tests/POSTMAN_SETUP.md
```

---

**Last Updated**: 2025-01-15
**Version**: 2.0.0
**Status**: ✅ Ready for Testing (VS Code REST Client + Postman)
