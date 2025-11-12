# 📬 Guida Setup Postman Collection - MyPetCare Admin API

## 📋 Indice

1. [Importazione Collection](#1-importazione-collection)
2. [Configurazione Environment Variables](#2-configurazione-environment-variables)
3. [Generazione Token Firebase ID](#3-generazione-token-firebase-id)
4. [Esecuzione Test](#4-esecuzione-test)
5. [Esempi Risposte](#5-esempi-risposte)
6. [Troubleshooting](#6-troubleshooting)

---

## 1. Importazione Collection

### Passo 1: Scarica il File
Il file della collection si trova in:
```
tests/postman_admin_collection.json
```

### Passo 2: Importa in Postman

**Metodo A - Import da File:**
1. Apri **Postman**
2. Clicca su **Import** (in alto a sinistra)
3. Seleziona tab **File**
4. Trascina `postman_admin_collection.json` o clicca **Choose Files**
5. Clicca **Import**

**Metodo B - Import da Raw JSON:**
1. Apri **Postman**
2. Clicca su **Import**
3. Seleziona tab **Raw text**
4. Incolla il contenuto JSON completo del file
5. Clicca **Continue** → **Import**

### Passo 3: Verifica Importazione
Dovresti vedere una nuova collection chiamata:
```
📁 MyPetCare Admin API
  ├── Health Check
  ├── GET /admin/stats
  ├── POST /admin/refund/:paymentId (Totale)
  ├── POST /admin/refund/:paymentId (Parziale)
  ├── POST /admin/refund - Stripe Invoice Example
  └── POST /admin/refund - PayPal Capture Example
```

---

## 2. Configurazione Environment Variables

### Opzione A - Environment Predefinito (Raccomandato)

**Le variabili sono già incluse nella collection con valori di default!**

Per personalizzarle:

1. Clicca sulla collection **MyPetCare Admin API**
2. Vai al tab **Variables**
3. Modifica i valori:

| Variable | Initial Value | Current Value | Description |
|----------|---------------|---------------|-------------|
| `baseUrl` | `https://api.mypetcare.app` | (uguale) | URL base API backend |
| `adminToken` | `YOUR_FIREBASE_ADMIN_ID_TOKEN_HERE` | *Inserisci token reale* | Token Firebase ID utente admin |
| `paymentId` | `PAYMENT_DOC_ID_FROM_FIRESTORE` | *Inserisci payment ID reale* | ID documento pagamento Firestore |

4. Clicca **Save** (Ctrl+S / Cmd+S)

### Opzione B - Environment Separato

Per gestire più ambienti (dev, staging, production):

1. Clicca su **Environments** (a sinistra)
2. Clicca **+** per creare nuovo environment
3. Nomina l'environment: `MyPetCare - Production`
4. Aggiungi le variabili:

```
baseUrl         → https://api.mypetcare.app
adminToken      → (token Firebase ID)
paymentId       → (ID documento Firestore)
```

5. Seleziona l'environment dal dropdown in alto a destra
6. Clicca **Save**

**Ripeti per altri ambienti:**
- `MyPetCare - Staging` → `https://staging-api.mypetcare.app`
- `MyPetCare - Local` → `http://localhost:3000`

---

## 3. Generazione Token Firebase ID

Il token Firebase ID è richiesto per autenticazione admin. Ecco 3 metodi per ottenerlo:

### Metodo 1: Flutter Debug Mode (Più Semplice)

**Aggiungi codice temporaneo nella tua app Flutter:**

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Inserisci questo codice dopo il login admin
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final token = await user.getIdToken();
  if (kDebugMode) {
    debugPrint('🔑 Firebase ID Token:');
    debugPrint(token);
  }
}
```

**Copia il token dall'output della console Flutter.**

---

### Metodo 2: Firebase REST API

**Usa `curl` per autenticarti e ottenere il token:**

```bash
curl -X POST 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=YOUR_FIREBASE_API_KEY' \
-H 'Content-Type: application/json' \
-d '{
  "email": "admin@mypetcare.app",
  "password": "your-admin-password",
  "returnSecureToken": true
}'
```

**Risposta:**
```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "AGEhc0...",
  "expiresIn": "3600"
}
```

**Copia il valore di `idToken`.**

---

### Metodo 3: Browser DevTools (Se hai Web App)

1. Apri la tua app web Flutter nel browser
2. Effettua login come admin
3. Apri **DevTools** (F12)
4. Vai alla tab **Console**
5. Esegui:

```javascript
firebase.auth().currentUser.getIdToken().then(token => {
  console.log('🔑 Firebase ID Token:');
  console.log(token);
});
```

6. **Copia il token** dalla console

---

### ⏱️ Scadenza Token

**IMPORTANTE**: I token Firebase ID scadono dopo **1 ora**.

Se ricevi errore `401 Unauthorized` o `403 Forbidden`, **rigenera il token** usando uno dei metodi sopra.

---

## 4. Esecuzione Test

### Test 1: Health Check

**Scopo**: Verificare che il backend sia online

1. Seleziona request **Health Check**
2. Clicca **Send**
3. Verifica risposta `200 OK`:

```json
{
  "status": "ok",
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

---

### Test 2: GET /admin/stats

**Scopo**: Ottenere statistiche aggregate

1. **Prerequisito**: Imposta variabile `adminToken` con token valido
2. Seleziona request **GET /admin/stats**
3. Verifica header `Authorization: Bearer {{adminToken}}`
4. Clicca **Send**
5. Verifica risposta `200 OK`:

```json
{
  "usersTotal": 523,
  "activePros": 47,
  "revenue30d": 12450.00,
  "bookings30d": 189
}
```

**Errori Comuni:**
- `401 Unauthorized` → Token scaduto o mancante
- `403 Forbidden` → Utente non ha ruolo admin
- `500 Internal Server Error` → Errore Firestore o query

---

### Test 3: POST /admin/refund (Totale)

**Scopo**: Rimborso completo di un pagamento

1. **Prerequisito**: Imposta `adminToken` e `paymentId` con ID reale da Firestore
2. Seleziona request **POST /admin/refund/:paymentId (Totale)**
3. Verifica che Body sia **vuoto** (per rimborso totale)
4. Clicca **Send**
5. Verifica risposta `200 OK`:

```json
{
  "success": true,
  "refund": {
    "id": "re_1PQzEL2eZvKYlo2C0D5C9mVj",
    "amount": 2999,
    "status": "succeeded",
    "created": 1704724800
  },
  "message": "Rimborso completato"
}
```

---

### Test 4: POST /admin/refund (Parziale)

**Scopo**: Rimborso parziale specificando importo

1. Seleziona request **POST /admin/refund/:paymentId (Parziale)**
2. Verifica Body JSON:

```json
{
  "amountCents": 499
}
```

3. **Modifica `amountCents`** con l'importo desiderato (es: `1500` per €15.00)
4. Clicca **Send**
5. Verifica risposta `200 OK`:

```json
{
  "success": true,
  "refund": {
    "id": "re_1PQzEL2eZvKYlo2C0D5C9mVj",
    "amount": 499,
    "status": "succeeded",
    "created": 1704724800
  },
  "message": "Rimborso parziale completato (€4.99)"
}
```

---

### Test 5: Esempi Specifici (Stripe Invoice, PayPal Capture)

**Questi test includono ID di esempio - sostituiscili con ID reali:**

#### Stripe Invoice Example:
```
URL: {{baseUrl}}/admin/refund/in_1PQzEL2eZvKYlo2C8KKfQjXt
                                  ↑
                    Sostituisci con invoice ID reale
```

#### PayPal Capture Example:
```
URL: {{baseUrl}}/admin/refund/8LW12345X6789012K
                                  ↑
                    Sostituisci con capture ID reale
```

---

## 5. Esempi Risposte

### Success Response - Stats

```json
{
  "usersTotal": 523,
  "activePros": 47,
  "revenue30d": 12450.00,
  "bookings30d": 189
}
```

**Headers:**
```
Status: 200 OK
Content-Type: application/json
```

---

### Success Response - Refund (Stripe)

```json
{
  "success": true,
  "refund": {
    "id": "re_1PQzEL2eZvKYlo2C0D5C9mVj",
    "amount": 2999,
    "currency": "eur",
    "status": "succeeded",
    "created": 1704724800,
    "payment_intent": "pi_3PQzEL2eZvKYlo2C0D5C9mVj"
  },
  "message": "Rimborso completato"
}
```

---

### Success Response - Refund (PayPal)

```json
{
  "success": true,
  "refund": {
    "id": "1JU08902781691411",
    "status": "COMPLETED",
    "amount": {
      "value": "29.99",
      "currency_code": "EUR"
    },
    "create_time": "2025-01-15T10:30:00Z"
  },
  "message": "Rimborso PayPal completato"
}
```

---

### Error Response - 401 Unauthorized

```json
{
  "error": "Token non valido o scaduto"
}
```

**Causa**: Token Firebase ID mancante, scaduto (>1h), o malformato  
**Soluzione**: Rigenera token e aggiorna variabile `adminToken`

---

### Error Response - 403 Forbidden

```json
{
  "error": "Utente non autorizzato - ruolo admin richiesto"
}
```

**Causa**: Utente autenticato ma senza ruolo admin in Firestore  
**Soluzione**: Verifica che il documento `users/{uid}` abbia `role: "admin"`

---

### Error Response - 404 Not Found

```json
{
  "error": "Pagamento non trovato"
}
```

**Causa**: `paymentId` non esiste nella collection Firestore `payments`  
**Soluzione**: Verifica ID documento in Firestore Console

---

### Error Response - 500 Internal Server Error

```json
{
  "error": "Errore durante il rimborso Stripe",
  "details": "No such charge: 'ch_invalid'"
}
```

**Causa**: Errore API Stripe/PayPal (charge/capture ID invalido)  
**Soluzione**: Verifica che il pagamento contenga `raw` metadata validi

---

## 6. Troubleshooting

### ❌ Problema: "Could not send request"

**Causa**: Backend non raggiungibile

**Soluzioni:**
1. Verifica che `baseUrl` sia corretto nell'environment
2. Testa con Health Check prima di altri endpoint
3. Verifica che il backend sia online:
   ```bash
   curl https://api.mypetcare.app/health
   ```
4. Controlla CORS se stai testando da browser
5. Verifica firewall/VPN non blocchino le richieste

---

### ❌ Problema: "401 Unauthorized"

**Causa**: Token Firebase ID mancante, scaduto, o invalido

**Soluzioni:**
1. **Verifica token esista**: Vai a Variables → controlla `adminToken`
2. **Rigenera token** (scade dopo 1 ora):
   - Usa uno dei 3 metodi nella sezione **Generazione Token**
3. **Verifica header Authorization**:
   ```
   Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
   ```
4. **Copia/incolla attentamente** il token (no spazi extra)

---

### ❌ Problema: "403 Forbidden"

**Causa**: Utente autenticato ma non admin

**Soluzioni:**
1. **Verifica ruolo in Firestore**:
   - Apri Firebase Console → Firestore
   - Collection: `users`
   - Documento: UID dell'utente autenticato
   - Verifica campo: `role: "admin"`

2. **Aggiungi ruolo admin se mancante**:
   ```javascript
   // Script Firebase Admin SDK
   const admin = require('firebase-admin');
   const db = admin.firestore();
   
   await db.collection('users').doc('USER_UID_HERE').set({
     role: 'admin'
   }, { merge: true });
   ```

---

### ❌ Problema: "404 Not Found - Payment not found"

**Causa**: `paymentId` invalido o inesistente

**Soluzioni:**
1. **Verifica ID in Firestore Console**:
   - Collection: `payments`
   - Copia ID documento esatto (case-sensitive)

2. **Aggiorna variabile `paymentId`**:
   - Variables → `paymentId` → Incolla ID reale
   - Save (Ctrl+S / Cmd+S)

3. **Formato ID corretto**:
   - Stripe: `ch_...`, `pi_...`, `in_...`
   - PayPal: 17 caratteri alfanumerici

---

### ❌ Problema: "500 Internal Server Error - No such charge"

**Causa**: Metadata `payment.raw` non contiene charge/capture ID validi

**Soluzioni:**
1. **Verifica struttura documento Firestore**:
   ```json
   {
     "provider": "stripe",
     "raw": {
       "charge": "ch_3PQzEL2eZvKYlo2C0D5C9mVj",
       "payment_intent": "pi_...",
       "status": "succeeded"
     }
   }
   ```

2. **Per PayPal, verifica capture ID**:
   ```json
   {
     "provider": "paypal",
     "raw": {
       "purchase_units": [
         {
           "payments": {
             "captures": [
               { "id": "8LW12345X6789012K" }
             ]
           }
         }
       ]
     }
   }
   ```

3. **Testa in Stripe/PayPal Dashboard**:
   - Cerca il payment ID nella dashboard
   - Verifica che sia rimborsabile (stato `succeeded`/`completed`)

---

### ❌ Problema: "CORS Error" (da browser)

**Causa**: Postman web version con restrizioni CORS

**Soluzioni:**
1. **Usa Postman Desktop App** (raccomandato)
2. **Disabilita CORS in Postman**:
   - Settings → General → "Request validation" → OFF
3. **Verifica backend CORS headers**:
   ```javascript
   res.header('Access-Control-Allow-Origin', '*');
   res.header('Access-Control-Allow-Methods', 'GET, POST');
   res.header('Access-Control-Allow-Headers', 'Authorization, Content-Type');
   ```

---

### ❌ Problema: Variables non sostituite ({{baseUrl}} visibile in URL)

**Causa**: Environment non selezionato o variabili non salvate

**Soluzioni:**
1. **Verifica environment attivo**:
   - Dropdown in alto a destra → Seleziona environment
2. **Salva modifiche variabili**:
   - Dopo aver modificato Variables → Ctrl+S / Cmd+S
3. **Verifica sintassi**:
   - Doppio parentesi graffe: `{{baseUrl}}` ✅
   - Singole parentesi: `{baseUrl}` ❌

---

## 📚 Risorse Aggiuntive

### File Correlati
- `tests/postman_admin_collection.json` - Collection Postman
- `tests/admin.http` - Versione REST Client VS Code
- `tests/payments.http` - Test endpoints pagamenti
- `tests/README.md` - Documentazione REST Client

### Link Utili
- [Postman Documentation](https://learning.postman.com/docs/)
- [Firebase Auth REST API](https://firebase.google.com/docs/reference/rest/auth)
- [Stripe API Reference](https://stripe.com/docs/api/refunds)
- [PayPal API Reference](https://developer.paypal.com/docs/api/payments/v2/)

---

## ✅ Checklist Setup Completo

Usa questa checklist per verificare che tutto sia configurato correttamente:

- [ ] **Collection importata** in Postman
- [ ] **Variabile `baseUrl`** impostata correttamente
- [ ] **Token Firebase ID generato** con uno dei 3 metodi
- [ ] **Variabile `adminToken`** aggiornata con token valido
- [ ] **Payment ID reale** ottenuto da Firestore
- [ ] **Variabile `paymentId`** aggiornata con ID reale
- [ ] **Health Check test** eseguito con successo (200 OK)
- [ ] **GET /admin/stats test** eseguito con successo
- [ ] **POST /admin/refund test** eseguito con successo
- [ ] **Variabili salvate** (Ctrl+S / Cmd+S)

---

**Tutto pronto! 🚀**

Ora puoi testare facilmente gli endpoint Admin API di MyPetCare con Postman.

Se incontri problemi, consulta la sezione **Troubleshooting** o i file di test correlati nella cartella `tests/`.
