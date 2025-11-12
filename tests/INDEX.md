# 📇 Indice File Test API - MyPetCare

Questa directory contiene tutti i file necessari per testare le API di MyPetCare usando VS Code REST Client o Postman.

---

## 📂 Struttura Directory

```
tests/
├── INDEX.md                              ← Questo file (navigazione rapida)
├── README.md                             ← Documentazione principale (focus REST Client)
├── POSTMAN_SETUP.md                      ← Guida completa setup Postman
├── admin.http                            ← Test REST Client per Admin API
├── payments.http                         ← Test REST Client per Payments API
├── postman_admin_collection.json         ← Collection Postman Admin API
└── postman_environment_example.json      ← Template environment Postman
```

---

## 🚀 Quick Start per Tool

### 🔵 VS Code REST Client

**Prerequisiti:**
- ✅ VS Code installato
- ✅ Estensione REST Client ([Install](https://marketplace.visualstudio.com/items?itemName=humao.rest-client))

**Workflow:**
1. Apri `admin.http` o `payments.http` in VS Code
2. Configura token in variabili `@token`
3. Click "Send Request" sopra ogni blocco `###`
4. Visualizza response nel pannello laterale

**File da usare:**
- [`admin.http`](admin.http) - 6 scenari test admin
- [`payments.http`](payments.http) - 10 scenari test pagamenti

**Documentazione:**
- [`README.md`](README.md) - Guida completa REST Client

---

### 🟠 Postman

**Prerequisiti:**
- ✅ Postman installato ([Download](https://www.postman.com/downloads/))

**Workflow:**
1. Importa `postman_admin_collection.json` in Postman
2. Configura Environment Variables (baseUrl, adminToken, paymentId)
3. Esegui requests dalla collection
4. Visualizza responses e salva test cases

**File da usare:**
- [`postman_admin_collection.json`](postman_admin_collection.json) - Collection principale
- [`postman_environment_example.json`](postman_environment_example.json) - Template environment

**Documentazione:**
- [`POSTMAN_SETUP.md`](POSTMAN_SETUP.md) - Guida completa Postman (13,967 caratteri)

---

## 📊 Confronto Tool

| Feature | VS Code REST Client | Postman |
|---------|-------------------|---------|
| **Setup Speed** | ⚡ Veloce (solo estensione) | 🐢 Medio (download app) |
| **Learning Curve** | 📈 Basso (sintassi semplice) | 📊 Medio (UI complessa) |
| **Environment Management** | 🟡 File `.env` locale | 🟢 UI dedicata (dev/staging/prod) |
| **Collaboration** | 🟡 File versioning (Git) | 🟢 Cloud sync + team sharing |
| **Test Automation** | 🔴 Limitato | 🟢 Avanzato (CI/CD integration) |
| **Response Visualization** | 🟡 Pannello VS Code | 🟢 UI ricca con history |
| **Ideale per** | Sviluppatori | QA Engineers + Product Managers |

---

## 📋 Endpoint Testati

### Admin API (`admin.http` / Postman Collection)

| Endpoint | Metodo | Descrizione |
|----------|--------|-------------|
| `/health` | GET | Health check server |
| `/admin/stats` | GET | Statistiche aggregate (users, PROs, revenue, bookings) |
| `/admin/refund/:paymentId` | POST | Rimborso totale/parziale (Stripe/PayPal) |

**Test Cases:**
1. ✅ Health check
2. ✅ Admin stats con token valido
3. ✅ Refund totale (body vuoto)
4. ✅ Refund parziale (con `amountCents`)
5. ✅ Refund Stripe Invoice (ID `in_...`)
6. ✅ Refund PayPal Capture (ID alfanumerico 17 chars)

---

### Payments API (`payments.http`)

| Endpoint | Metodo | Descrizione |
|----------|--------|-------------|
| `/payments/stripe/create-session` | POST | Crea Checkout Session Stripe |
| `/payments/stripe/portal` | POST | Crea link Billing Portal |
| `/payments/stripe/webhook` | POST | Handler webhook Stripe |
| `/payments/paypal/create-order` | POST | Crea ordine PayPal |
| `/payments/paypal/capture/:orderId` | POST | Cattura pagamento PayPal |
| `/payments/coupon/validate` | POST | Valida codice coupon |

**Test Cases:**
1. ✅ Health check
2. ✅ Stripe Checkout con coupon
3. ✅ Stripe Checkout senza coupon
4. ✅ Stripe Billing Portal
5. ✅ PayPal Order mensile (€29.99)
6. ✅ PayPal Order annuale (€299.99)
7. ✅ PayPal Capture
8. ✅ Coupon valido ("FREE-1M")
9. ✅ Coupon invalido
10. ✅ Coupon vuoto

---

## 🔑 Configurazione Token Firebase

Tutti i test richiedono un **Firebase ID Token** valido. Ecco i metodi supportati:

### Metodo 1: Flutter Debug Mode
```dart
final token = await FirebaseAuth.instance.currentUser!.getIdToken();
debugPrint('🔑 Token: $token');
```

### Metodo 2: Firebase REST API
```bash
curl 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=API_KEY' \
-d '{"email":"admin@mypetcare.app","password":"pass","returnSecureToken":true}'
```

### Metodo 3: Browser DevTools
```javascript
firebase.auth().currentUser.getIdToken().then(t => console.log(t))
```

**⏱️ IMPORTANTE**: I token scadono dopo **1 ora**. Rigenera se ricevi errori `401` o `403`.

---

## 🛠️ Configurazione Environment

### VS Code REST Client (`.env` file)

Crea `.env` nella root del progetto:

```bash
# /home/user/flutter_app/.env
FIREBASE_ADMIN_ID_TOKEN=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
FIREBASE_USER_ID_TOKEN=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Postman (Environment Variables)

**Opzione A - Variables in Collection:**
1. Click su collection → Tab **Variables**
2. Modifica valori: `baseUrl`, `adminToken`, `paymentId`
3. Save (Ctrl+S)

**Opzione B - Environment Separato:**
1. Importa `postman_environment_example.json`
2. Modifica valori per tuo ambiente
3. Duplica per creare `Production`, `Staging`, `Local`

---

## 📖 Documentazione Completa

### Per Utenti VS Code
👉 **Leggi**: [`README.md`](README.md)

**Include:**
- Setup completo estensione REST Client
- Generazione token Firebase (3 metodi)
- Esempi response per ogni endpoint
- Troubleshooting comune
- Best practices sicurezza

### Per Utenti Postman
👉 **Leggi**: [`POSTMAN_SETUP.md`](POSTMAN_SETUP.md)

**Include:**
- Importazione collection passo-passo
- Configurazione environment variables
- Esempi request/response
- Troubleshooting dettagliato
- Workflow testing raccomandato

---

## ✅ Checklist Setup Completo

### VS Code REST Client
- [ ] Estensione REST Client installata
- [ ] File `.env` creato nella root progetto
- [ ] Token Firebase ID generato e inserito in `.env`
- [ ] File `admin.http` aperto in VS Code
- [ ] Primo test "Health Check" eseguito con successo

### Postman
- [ ] Postman installato
- [ ] Collection `postman_admin_collection.json` importata
- [ ] Environment variables configurate (baseUrl, adminToken, paymentId)
- [ ] Token Firebase ID generato e inserito
- [ ] Primo test "Health Check" eseguito con successo

---

## 🔍 Troubleshooting Comune

### Errore: 401 Unauthorized
**Causa**: Token Firebase ID scaduto o invalido  
**Soluzione**: Rigenera token (valido 1 ora)

### Errore: 403 Forbidden
**Causa**: Utente non ha ruolo admin  
**Soluzione**: Verifica `users/{uid}.role = "admin"` in Firestore

### Errore: 404 Not Found (Payment)
**Causa**: Payment ID invalido  
**Soluzione**: Verifica ID documento in Firestore `payments` collection

### Errore: ECONNREFUSED
**Causa**: Backend non raggiungibile  
**Soluzione**: Verifica `baseUrl` corretto e server online

---

## 📝 Prossimi Passi

1. **Scegli il tuo tool** (VS Code REST Client o Postman)
2. **Segui la guida setup** corrispondente
3. **Genera token Firebase ID** usando uno dei 3 metodi
4. **Esegui primo test** (Health Check)
5. **Continua con test admin/payments** secondo necessità

---

## 📞 Supporto

**Domande frequenti risolte in:**
- [`README.md`](README.md#troubleshooting) - Sezione Troubleshooting REST Client
- [`POSTMAN_SETUP.md`](POSTMAN_SETUP.md#6-troubleshooting) - Sezione Troubleshooting Postman

**File correlati backend:**
- `/backend/src/routes/admin.ts` - Implementazione endpoint admin
- `/backend/src/routes/payments.ts` - Implementazione endpoint payments

---

**Versione**: 2.0.0  
**Ultimo aggiornamento**: 2025-01-15  
**Status**: ✅ Production Ready
