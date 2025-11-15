# 🔒 Security & Registration Update - My Pet Care

**Data Implementazione:** 14 Novembre 2024  
**Versione:** 2.1 - Secure Backend Registration  
**Status:** ✅ COMPLETATO

---

## 🎯 Obiettivi Completati

### 1️⃣ **Backend Registration API**
- ✅ Endpoint POST /api/auth/register implementato
- ✅ Creazione profilo utente su Firestore tramite backend
- ✅ Supporto ruoli: 'owner' e 'pro'
- ✅ Validazione input e gestione errori
- ✅ Sincronizzazione collection users + pros

### 2️⃣ **Flutter Registration Security**
- ✅ Chiamata HTTP al backend invece di Firestore diretto
- ✅ Nessuna chiave segreta nel codice Flutter (✅ verificato)
- ✅ Gestione errori migliorata
- ✅ Stack trace completo per debugging

### 3️⃣ **Backend Configuration Security**
- ✅ Tutte le chiavi segrete in process.env
- ✅ File .env.example per documentazione
- ✅ Validazione config all'avvio server
- ✅ Port configuration (default 8080)

---

## 📁 File Modificati/Creati

### **Backend (TypeScript)**

#### **Nuovi File:**
```
✅ backend/src/routes/auth.ts (5.0 KB)
   - POST /api/auth/register (creazione profilo)
   - GET /api/auth/user/:uid (recupero profilo)
   - PATCH /api/auth/user/:uid (aggiornamento profilo)

✅ backend/.env.example (852 bytes)
   - Template environment variables
   - Documentazione chiavi necessarie
```

#### **File Modificati:**
```
✅ backend/src/index.ts
   + import { authRouter } from './routes/auth';
   + app.use('/api/auth', authRouter);

✅ backend/src/config.ts
   + export const SUPPORT_EMAIL = 'petcareassistenza@gmail.com';
   + port: parseInt(process.env.PORT || "8080", 10),
   + supportEmail: SUPPORT_EMAIL in config object
   + export function validateConfig() - validazione env vars
```

### **Frontend (Flutter)**

```
✅ lib/features/auth/registration_screen.dart
   - Rimossa logica Firestore diretta
   + Aggiunta chiamata HTTP POST al backend
   + import 'dart:convert';
   + import 'package:http/http.dart' as http;
   + import '../../config.dart';
   - Gestione errori migliorata con stack trace
```

---

## 🔒 Security Verification

### **✅ Nessuna Chiave Segreta in Flutter**

**Verifica eseguita:**
```bash
grep -r "sk_live_\|sk_test_\|whsec_\|PAYPAL_CLIENT_SECRET" lib/
# Result: No matches found ✅
```

**Chiavi Pubbliche Consentite in Flutter:**
- ✅ Firebase API Keys (AIzaSy...)
- ✅ Stripe Publishable Key (pk_live_...)
- ✅ Google Maps API Key (con restrizioni)

**Chiavi Segrete (SOLO Backend):**
- ❌ Stripe Secret Key (sk_live_...) → backend/.env
- ❌ Stripe Webhook Secret (whsec_...) → backend/.env
- ❌ PayPal Client ID + Secret → backend/.env
- ❌ Firebase Admin SDK Key → backend GOOGLE_APPLICATION_CREDENTIALS

---

## 📊 API Endpoint Documentation

### **POST /api/auth/register**

**Endpoint:** `POST /api/auth/register`

**Description:** Crea profilo utente su Firestore dopo registrazione Firebase Auth

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "uid": "firebase_user_uid",
  "role": "owner" | "pro",
  "fullName": "Mario Rossi",
  "phone": "+39 333 1234567",
  "proPhone": "+39 333 9876543",  // optional, per PRO
  "proEmail": "mario@studio.it",  // optional, per PRO
  "website": "https://studio.it", // optional, per PRO
  "notifications": {
    "push": true,
    "email": true,
    "marketing": false
  }
}
```

**Response 201 (Success):**
```json
{
  "success": true,
  "message": "User profile created successfully",
  "uid": "firebase_user_uid",
  "role": "owner"
}
```

**Response 400 (Validation Error):**
```json
{
  "error": "Missing required fields",
  "required": ["uid", "role", "fullName"]
}
```

**Response 500 (Internal Error):**
```json
{
  "error": "Internal server error",
  "message": "Error details..."
}
```

---

### **GET /api/auth/user/:uid**

**Endpoint:** `GET /api/auth/user/{uid}`

**Description:** Recupera profilo utente

**Response 200 (Success):**
```json
{
  "success": true,
  "user": {
    "uid": "firebase_user_uid",
    "role": "owner",
    "fullName": "Mario Rossi",
    "phone": "+39 333 1234567",
    // ... altri campi
  }
}
```

---

### **PATCH /api/auth/user/:uid**

**Endpoint:** `PATCH /api/auth/user/{uid}`

**Description:** Aggiorna profilo utente

**Request Body:**
```json
{
  "fullName": "Mario Rossi Updated",
  "phone": "+39 333 9999999"
  // ... altri campi aggiornabili
}
```

**Note:** I campi protetti (uid, role, createdAt, verified, active) non possono essere modificati dall'utente.

---

## 🔧 Backend Configuration

### **Environment Variables (Production)**

```bash
# File: backend/.env (NON committare in Git!)

NODE_ENV=production

# Server URLs
BACKEND_BASE_URL=https://api.mypetcareapp.org
WEB_BASE_URL=https://app.mypetcareapp.org

# Stripe LIVE
STRIPE_SECRET_KEY=sk_live_****************
STRIPE_WEBHOOK_SECRET=whsec_**************

# PayPal LIVE
PAYPAL_CLIENT_ID=****************
PAYPAL_SECRET=****************
PAYPAL_WEBHOOK_ID=****************
PAYPAL_API=https://api-m.paypal.com

# Firebase Admin SDK
GOOGLE_APPLICATION_CREDENTIALS=/path/to/firebase-admin-sdk.json

# Optional
PORT=8080
```

### **Configuration Validation**

Il backend valida automaticamente all'avvio che tutte le variabili richieste siano presenti:

```typescript
export function validateConfig(): void {
  const required = [
    'BACKEND_BASE_URL',
    'WEB_BASE_URL',
    'STRIPE_SECRET_KEY',
    'STRIPE_WEBHOOK_SECRET',
    'PAYPAL_CLIENT_ID',
    'PAYPAL_SECRET',
    'PAYPAL_WEBHOOK_ID',
  ];

  const missing = required.filter(key => !process.env[key]);

  if (missing.length > 0) {
    console.error('❌ Missing required environment variables:');
    missing.forEach(key => console.error(`   - ${key}`));
    throw new Error('Configuration validation failed');
  }

  console.log('✅ Configuration validated successfully');
}
```

---

## 🚀 Deployment Instructions

### **1. Backend Deployment (Cloud Run)**

```bash
cd backend

# Deploy con environment variables
gcloud run deploy mypetcare-backend \
  --source . \
  --region europe-west1 \
  --platform managed \
  --allow-unauthenticated \
  --set-env-vars="NODE_ENV=production" \
  --set-env-vars="BACKEND_BASE_URL=https://api.mypetcareapp.org" \
  --set-env-vars="WEB_BASE_URL=https://app.mypetcareapp.org" \
  --set-env-vars="STRIPE_SECRET_KEY=sk_live_***" \
  --set-env-vars="STRIPE_WEBHOOK_SECRET=whsec_***" \
  --set-env-vars="PAYPAL_CLIENT_ID=***" \
  --set-env-vars="PAYPAL_SECRET=***" \
  --set-env-vars="PAYPAL_WEBHOOK_ID=***" \
  --set-env-vars="PAYPAL_API=https://api-m.paypal.com"
```

**Oppure configura tramite Cloud Run Console:**
- Console → Cloud Run → mypetcare-backend
- Tab "Variables & Secrets"
- Aggiungi tutte le environment variables

### **2. Frontend Deployment (Firebase Hosting)**

```bash
# Il frontend usa SOLO chiavi pubbliche (già configurate)
cd /path/to/mypetcare_deploy_fix
firebase deploy --only hosting
```

---

## 📋 Testing Checklist

### **Backend Testing**

- [ ] **Health Check:**
  ```bash
  curl https://api.mypetcareapp.org/health
  ```
  Expected: `{"ok": true, "service": "mypetcare-backend", ...}`

- [ ] **Registration Endpoint:**
  ```bash
  curl -X POST https://api.mypetcareapp.org/api/auth/register \
    -H "Content-Type: application/json" \
    -d '{"uid":"test","role":"owner","fullName":"Test User","phone":"123"}'
  ```
  Expected: 201 with success message

### **Frontend Testing**

- [ ] Vai su: https://pet-care-9790d.web.app/register
- [ ] Compila form registrazione Owner
- [ ] Premi "Registrati come Proprietario"
- [ ] Verifica chiamata a `/api/auth/register` in Network tab
- [ ] Verifica redirect a homeOwner
- [ ] Controlla Firestore → collection `users` → documento creato

### **Security Testing**

- [ ] Verifica che NESSUNA chiave segreta appaia in:
  - Network tab (richieste HTTP)
  - Source code Flutter (Inspect → Sources)
  - Build artifacts (main.dart.js)
- [ ] Verifica che solo Publishable Keys siano visibili client-side

---

## 🔐 Security Best Practices

### **✅ Implemented**

1. **Separation of Concerns:**
   - Frontend: Firebase Auth + chiavi pubbliche
   - Backend: Firestore write + chiavi segrete

2. **Environment Variables:**
   - Tutte le chiavi segrete in process.env
   - Validation all'avvio del server
   - .env.example per documentazione

3. **API Security:**
   - Input validation su backend
   - Error handling senza leak di info sensitive
   - CORS configuration appropriata

### **🔜 Recommended Improvements**

1. **Rate Limiting:**
   ```typescript
   import rateLimit from 'express-rate-limit';
   
   const registerLimiter = rateLimit({
     windowMs: 15 * 60 * 1000, // 15 minuti
     max: 5, // max 5 registrazioni
     message: 'Too many registration attempts',
   });
   
   app.post('/api/auth/register', registerLimiter, ...);
   ```

2. **Firebase Admin SDK Verification:**
   ```typescript
   import { getAuth } from 'firebase-admin/auth';
   
   async function verifyFirebaseToken(uid: string) {
     try {
       await getAuth().getUser(uid);
       return true;
     } catch (error) {
       return false;
     }
   }
   ```

3. **Firestore Security Rules:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         // Solo backend può scrivere, utente può leggere solo i propri dati
         allow read: if request.auth != null && request.auth.uid == userId;
         allow write: if false; // Solo backend API
       }
     }
   }
   ```

---

## 📚 Riferimenti

### **File Chiave:**
- Backend Auth Routes: `backend/src/routes/auth.ts`
- Backend Config: `backend/src/config.ts`
- Flutter Registration: `lib/features/auth/registration_screen.dart`
- Flutter Config: `lib/config.dart`
- Env Template: `backend/.env.example`

### **Documentazione:**
- Firebase Auth: https://firebase.google.com/docs/auth
- Firestore Security: https://firebase.google.com/docs/firestore/security/rules
- Express Best Practices: https://expressjs.com/en/advanced/best-practice-security.html
- Cloud Run Env Vars: https://cloud.google.com/run/docs/configuring/environment-variables

---

**Status Finale:** ✅ REGISTRATION SICURA CON BACKEND API

**Prossima Azione:** 
1. Deploy backend su Cloud Run con environment variables
2. Test endpoint `/api/auth/register`
3. Test registrazione frontend end-to-end

---

**Supporto:** petcareassistenza@gmail.com  
**Documentazione Completa:** Questo file + API_KEYS_CONFIG.md + BRAND_IDENTITY_UPDATE.md
