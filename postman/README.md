# 🔌 MyPetCare - Postman API Collection

**Complete API testing collection for MyPetCare backend**

---

## 📦 Files Included

```
postman/
├── MyPetCare_API.postman_collection.json      # Complete API collection
├── MyPetCare_Sandbox.postman_environment.json # Sandbox testing environment
├── MyPetCare_Production.postman_environment.json # Production environment
└── README.md                                  # This file
```

---

## 🚀 Quick Start

### **Step 1: Import Collection**

1. Open Postman
2. Click **Import** button (top left)
3. Select `MyPetCare_API.postman_collection.json`
4. Collection imported ✅

### **Step 2: Import Environment**

1. Click **Environments** (left sidebar)
2. Click **Import**
3. Select `MyPetCare_Sandbox.postman_environment.json` (for testing)
4. Environment imported ✅

### **Step 3: Get Firebase ID Token**

**Option A: Via Firebase REST API**

```bash
# Use test credentials
curl -X POST "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=YOUR_FIREBASE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "owner.test+1@mypetcare.it",
    "password": "Test!2345",
    "returnSecureToken": true
  }'

# Copy "idToken" from response
```

**Option B: Via Flutter App**

```dart
import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser;
final idToken = await user?.getIdToken();
print('ID Token: $idToken');
```

### **Step 4: Configure Environment**

1. Select **MyPetCare - Sandbox** environment (top right dropdown)
2. Click **Eye icon** → **Edit**
3. Paste your Firebase ID Token in `FIREBASE_ID_TOKEN` variable
4. Save ✅

### **Step 5: Test API**

1. Open **Professionisti (PRO)** folder
2. Run **Get All PROs** request
3. Should return `200 OK` with PRO list ✅

---

## 🔑 Test Credentials (Sandbox)

### **Firebase Authentication**

```yaml
Owner:
  Email: owner.test+1@mypetcare.it
  Password: Test!2345

PRO:
  Email: pro.test+1@mypetcare.it
  Password: Test!2345

Admin:
  Email: admin.test@mypetcare.it
  Password: Test!2345
```

### **Payment Testing**

```yaml
Stripe Test Cards:
  Success: 4242 4242 4242 4242 | 12/34 | 123
  3DS Required: 4000 0027 6000 3184 | 12/34 | 123
  Declined: 4000 0000 0000 9995 | 12/34 | 123

PayPal Sandbox:
  Buyer: buyer-sbx@mypetcare.it | Sbxtest123!
  Business: merchant-sbx@mypetcare.it | Sbxtest123!

Coupons:
  FREE-1M: 1 mese gratis (100% discount)
  FREE-3M: 3 mesi gratis (100% discount)
  FREE-12M: 12 mesi gratis (100% discount)
```

---

## 📂 API Endpoints Overview

### **1. Auth**
```
GET /auth/login - Info su come ottenere Firebase ID Token
```

### **2. Professionisti (PRO)**
```
GET    /pros           - Lista PRO attivi
GET    /pros/:id       - Dettaglio PRO
POST   /pros           - Crea PRO (Admin only)
PUT    /pros/:id       - Aggiorna PRO (Owner/Admin)
```

### **3. Calendari**
```
GET    /calendars/:proId        - Calendario PRO
POST   /calendars/:proId/slots  - Crea slot disponibilità
```

### **4. Bookings**
```
POST   /bookings                - Crea prenotazione
GET    /bookings/:id            - Dettaglio prenotazione
POST   /bookings/:id/cancel     - Cancella prenotazione
POST   /bookings/:id/refund     - Rimborso (Admin only)
```

### **5. Payments**
```
POST   /payments/stripe/subscribe  - Sottoscrizione Stripe
POST   /payments/paypal/subscribe  - Sottoscrizione PayPal
POST   /coupons/apply              - Applica coupon
```

### **6. Webhooks (Local Testing)**
```
POST   /webhooks/stripe   - Test Stripe webhook
POST   /webhooks/paypal   - Test PayPal webhook
```

---

## 🧪 Testing Workflow

### **Scenario 1: Owner Books Service**

1. **Login as Owner**
   - Use "Get Firebase ID Token" with owner credentials
   - Copy token to `FIREBASE_ID_TOKEN` variable

2. **Find PRO**
   ```
   GET /pros
   → Copy proId from response
   ```

3. **Check Availability**
   ```
   GET /calendars/:proId
   → Verify available slots
   ```

4. **Create Booking**
   ```
   POST /bookings
   Body: {
     "proId": "pro-test-1",
     "serviceId": "service-1",
     "date": "2025-12-15",
     "startTime": "09:00"
   }
   → Returns booking ID
   ```

5. **Verify Booking**
   ```
   GET /bookings/:bookingId
   → Status should be "confirmed"
   ```

---

### **Scenario 2: PRO Creates Availability**

1. **Login as PRO**
   - Use PRO credentials to get ID token

2. **Create Calendar Slots**
   ```
   POST /calendars/:proId/slots
   Body: {
     "slots": [
       {
         "date": "2025-12-15",
         "start": "09:00",
         "end": "13:00",
         "step": 30,
         "capacity": 4
       }
     ]
   }
   → Creates 8 slots (09:00, 09:30, 10:00, ..., 12:30)
   ```

---

### **Scenario 3: Admin Refund**

1. **Login as Admin**
   - Use admin credentials to get ID token

2. **Refund Booking**
   ```
   POST /bookings/:bookingId/refund
   Body: {
     "amount": 35,
     "reason": "Customer request"
   }
   → Triggers Stripe refund webhook
   ```

---

## ⚙️ Environment Variables Reference

### **Common Variables**

| Variable | Description | Example |
|----------|-------------|---------|
| `BASE_URL` | API base URL | `https://api.mypetcare.it` |
| `FIREBASE_ID_TOKEN` | Firebase auth token | `eyJhbGciOiJSUzI1Ni...` |
| `FIREBASE_API_KEY` | Firebase project API key | `AIzaSyExample...` |

### **Test User Variables**

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `OWNER_EMAIL` | Test owner email | `owner.test+1@mypetcare.it` |
| `OWNER_PASSWORD` | Test owner password | `Test!2345` |
| `PRO_EMAIL` | Test PRO email | `pro.test+1@mypetcare.it` |
| `PRO_PASSWORD` | Test PRO password | `Test!2345` |
| `ADMIN_EMAIL` | Test admin email | `admin.test@mypetcare.it` |
| `ADMIN_PASSWORD` | Test admin password | `Test!2345` |

### **Payment Test Variables**

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `STRIPE_TEST_CARD` | Stripe success card | `4242424242424242` |
| `STRIPE_TEST_CARD_3DS` | Stripe 3DS card | `4000002760003184` |
| `PAYPAL_SANDBOX_BUYER` | PayPal test buyer | `buyer-sbx@mypetcare.it` |
| `COUPON` | Test coupon code | `FREE-1M` |

---

## 🔒 Security Best Practices

### **Never Commit Sensitive Data**

```bash
# Add to .gitignore
postman/*.env
postman/*secrets*
*.postman_environment.json
```

### **Use Environment Variables**

```
✅ GOOD: {{FIREBASE_ID_TOKEN}}
❌ BAD:  Hardcoded token in request body
```

### **Rotate Tokens Regularly**

```
Firebase ID tokens expire after 1 hour.
Get fresh token before testing session.
```

---

## 🐛 Troubleshooting

### **Issue: 401 Unauthorized**

**Solution:**
```
1. Verify FIREBASE_ID_TOKEN is set in environment
2. Check token hasn't expired (1h validity)
3. Get fresh token via Firebase Auth
4. Ensure user has correct role (owner/pro/admin)
```

### **Issue: 403 Forbidden**

**Solution:**
```
1. Check Firestore security rules
2. Verify user role matches endpoint requirements
3. Confirm user owns the resource (for owner-only endpoints)
```

### **Issue: 404 Not Found**

**Solution:**
```
1. Verify BASE_URL is correct for environment
2. Check endpoint path matches backend routes
3. Confirm resource ID exists in Firestore
```

### **Issue: 500 Internal Server Error**

**Solution:**
```
1. Check Cloud Functions logs:
   firebase functions:log --project mypetcare-prod
2. Verify backend .env.production is configured
3. Check webhook secrets are correct
```

---

## 📊 Response Examples

### **GET /pros - Success**
```json
{
  "pros": [
    {
      "id": "pro-test-1",
      "displayName": "Toelettatore Test",
      "bio": "10 anni di esperienza",
      "services": [
        {
          "name": "Visita base",
          "minutes": 30,
          "price": 35
        }
      ],
      "geo": {
        "lat": 40.7274,
        "lng": 8.5606,
        "address": "Sassari, Italia"
      },
      "rating": 4.8,
      "reviewCount": 24,
      "active": true
    }
  ]
}
```

### **POST /bookings - Success**
```json
{
  "bookingId": "booking-abc123",
  "status": "confirmed",
  "proId": "pro-test-1",
  "userId": "user-xyz789",
  "date": "2025-12-15",
  "startTime": "09:00",
  "duration": 30,
  "price": 35,
  "paymentStatus": "paid",
  "createdAt": "2025-01-12T10:00:00.000Z"
}
```

### **Error Response - 403**
```json
{
  "error": "Forbidden",
  "message": "User does not have permission to access this resource",
  "code": "PERMISSION_DENIED"
}
```

---

## 🔄 Webhook Testing (Local)

### **Test Stripe Webhook Locally**

```bash
# Terminal 1: Start backend locally
cd backend
npm run dev

# Terminal 2: Start Stripe CLI listener
stripe listen --forward-to localhost:8080/webhooks/stripe

# Terminal 3: Trigger test event
stripe trigger invoice.payment_succeeded
```

### **Test PayPal Webhook Locally**

```bash
# Use PayPal Developer Dashboard webhook simulator
# URL: https://developer.paypal.com/dashboard/webhooks

# Or use Postman request:
POST http://localhost:8080/webhooks/paypal
Body: {
  "event_type": "BILLING.SUBSCRIPTION.ACTIVATED",
  "resource": { "id": "I-TEST123", "custom_id": "user-test-1" }
}
```

---

## 📚 Additional Resources

- **Firebase Auth REST API**: https://firebase.google.com/docs/reference/rest/auth
- **Stripe Test Cards**: https://stripe.com/docs/testing
- **PayPal Sandbox**: https://developer.paypal.com/developer/accounts/
- **Postman Docs**: https://learning.postman.com/docs/getting-started/introduction/

---

## 🆘 Support

**Issues or Questions?**

- 📧 Email: tech@mypetcare.it
- 💬 GitHub: [mypetcare/issues](https://github.com/mypetcare/issues)
- 📚 Docs: https://docs.mypetcare.it

---

**🎉 Happy Testing with MyPetCare API! 🐾**
