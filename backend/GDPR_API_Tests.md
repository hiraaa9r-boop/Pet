# 🧪 GDPR API Tests - MyPetCare Backend

Test collection per endpoint GDPR usando Postman, Insomnia o curl.

---

## 📋 **Prerequisiti**

1. **Backend attivo**: `https://api.mypetcareapp.org`
2. **Firebase ID Token**: Ottieni token autenticato tramite Firebase Auth
3. **Account test**: Crea account dedicato per test cancellazione

---

## 🔐 **Autenticazione**

Tutti gli endpoint GDPR richiedono autenticazione Firebase:

```
Authorization: Bearer YOUR_FIREBASE_ID_TOKEN
Content-Type: application/json
```

**Come ottenere il token:**

```javascript
// JavaScript (Firebase Web SDK)
const user = firebase.auth().currentUser;
const token = await user.getIdToken();
```

```dart
// Flutter
final user = FirebaseAuth.instance.currentUser;
final token = await user?.getIdToken();
```

---

## 📥 **1. Export Dati Utente (GET /api/gdpr/me)**

### **Descrizione:**
Esporta tutti i dati personali dell'utente (GDPR Art. 15, 20)

### **Request:**
```http
GET https://api.mypetcareapp.org/api/gdpr/me
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json
```

### **Response Attesa (200 OK):**
```json
{
  "ok": true,
  "data": {
    "uid": "abc123xyz",
    "user": {
      "id": "abc123xyz",
      "fullName": "Mario Rossi",
      "role": "owner",
      "notifications": {
        "push": true,
        "email": true,
        "marketing": false
      },
      "createdAt": "2024-11-14T10:00:00Z",
      "updatedAt": "2024-11-14T10:00:00Z"
    },
    "pro": null,
    "bookingsAsOwner": [
      {
        "id": "booking123",
        "proId": "pro456",
        "serviceId": "service789",
        "status": "confirmed",
        "date": "2024-11-20",
        "createdAt": "2024-11-14T10:00:00Z"
      }
    ],
    "bookingsAsPro": [],
    "reviews": [],
    "exportedAt": "2024-11-14T12:30:00Z"
  }
}
```

### **Errori Comuni:**

**401 Unauthorized:**
```json
{
  "ok": false,
  "error": "UNAUTHORIZED",
  "message": "Token non valido o scaduto"
}
```

**500 Internal Server Error:**
```json
{
  "ok": false,
  "error": "GDPR_EXPORT_FAILED",
  "message": "Errore durante export dati"
}
```

---

## 🗑️ **2. Cancellazione Account (DELETE /api/gdpr/me)**

### **Descrizione:**
Soft-delete account + anonimizzazione dati (GDPR Art. 17)

⚠️ **ATTENZIONE**: Operazione irreversibile!

### **Request:**
```http
DELETE https://api.mypetcareapp.org/api/gdpr/me
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json
```

### **Response Attesa (200 OK):**
```json
{
  "ok": true,
  "status": "DELETED",
  "deletedAt": "2024-11-14T12:35:00Z",
  "message": "Account disabilitato e dati anonimizzati con successo",
  "affectedDocuments": 15
}
```

### **Operazioni Effettuate:**
1. ✅ Soft-delete profili `users` e `pros` (campo `deletedAt` + `active: false`)
2. ✅ Anonimizzazione bookings (marca `ownerDeleted`/`proDeleted`)
3. ✅ Anonimizzazione reviews (marca `ownerDeleted`)
4. ✅ Disabilitazione Firebase Auth (`disabled: true`)

### **Errori Comuni:**

**401 Unauthorized:**
```json
{
  "ok": false,
  "error": "UNAUTHORIZED",
  "message": "Token non valido o scaduto"
}
```

**400 Bad Request (Troppi documenti):**
```json
{
  "ok": false,
  "error": "TOO_MANY_DOCUMENTS",
  "message": "Troppi documenti da elaborare. Contatta il supporto."
}
```

**500 Internal Server Error:**
```json
{
  "ok": false,
  "error": "GDPR_DELETE_FAILED",
  "message": "Errore durante cancellazione account"
}
```

---

## 🔍 **Rate Limiting**

Gli endpoint GDPR sono protetti da rate limiting (`gdprLimiter`):

- **Limite**: 10 richieste per IP ogni 15 minuti
- **Response quando superato**:
```json
{
  "error": "TOO_MANY_REQUESTS",
  "message": "Rate limit exceeded. Riprova tra 15 minuti."
}
```

---

## 🧪 **Test con curl**

### **Export Dati:**
```bash
curl -X GET https://api.mypetcareapp.org/api/gdpr/me \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  | jq '.'
```

### **Cancellazione Account:**
```bash
# ⚠️ ATTENZIONE: Operazione irreversibile!
curl -X DELETE https://api.mypetcareapp.org/api/gdpr/me \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  | jq '.'
```

---

## 📊 **Postman Collection**

### **Collection Structure:**

```
MyPetCare GDPR API
├── 🔐 Get Firebase Token (Pre-request)
├── 📥 Export User Data (GET /api/gdpr/me)
└── 🗑️ Delete Account (DELETE /api/gdpr/me)
```

### **Environment Variables:**

```
base_url: https://api.mypetcareapp.org
firebase_token: {{firebase_id_token}}
```

---

## ✅ **Checklist Test Completi**

- [ ] **Export dati**: Verifica JSON contiene tutti i campi
- [ ] **Export dati**: Controlla formato `exportedAt` (ISO 8601)
- [ ] **Export dati**: Verifica inclusione bookings/reviews
- [ ] **Cancellazione**: Verifica soft-delete (campo `deletedAt`)
- [ ] **Cancellazione**: Verifica Firebase Auth disabilitato
- [ ] **Cancellazione**: Verifica bookings anonimizzati
- [ ] **Cancellazione**: Verifica impossibilità login post-cancellazione
- [ ] **Rate Limiting**: Supera 10 richieste, verifica blocco 429
- [ ] **Auth**: Testa con token scaduto (401)
- [ ] **Auth**: Testa senza token (401)

---

## 🚨 **Best Practices Testing**

### **Ambiente Test:**
- Usa **account dedicati** per test cancellazione
- **NON testare** su account produzione
- **Backend staging** preferibile per test distruttivi

### **Dati Test:**
- Crea bookings/reviews prima di testare export
- Verifica anonimizzazione su documenti reali
- Controlla Firebase Console dopo cancellazione

### **Sicurezza:**
- **Mai condividere** Firebase ID Token
- Token scadono dopo 1 ora (richiedi nuovo)
- Testa rate limiting per prevenire abusi

---

## 📞 **Supporto**

Per problemi con endpoint GDPR:
- **Email**: petcareassistenza@gmail.com
- **Backend logs**: Controlla Cloud Run logs per errori dettagliati
- **Firestore**: Verifica collection `users`, `pros`, `bookings`

---

**🎉 Test completati con successo!**
