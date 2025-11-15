# 🛡️ Sistema Amministrativo My Pet Care

Guida completa per la configurazione e utilizzo del sistema di amministrazione con ruoli Firebase Auth.

## 📋 Indice

1. [Architettura del Sistema](#architettura)
2. [Setup Backend](#setup-backend)
3. [Promozione Utenti Admin](#promozione-admin)
4. [API Admin Endpoints](#api-endpoints)
5. [Frontend Flutter](#frontend-flutter)
6. [Testing](#testing)
7. [Security Best Practices](#security)

---

## 🏗️ Architettura del Sistema {#architettura}

### Componenti Principali

**Backend (Node.js/TypeScript):**
- `backend/src/auth/setAdmin.ts` - Script per promuovere utenti ad admin
- `backend/src/middleware/auth.ts` - Middleware autenticazione con supporto admin claims
- `backend/src/routes/admin.ts` - Endpoints API amministrativi

**Frontend (Flutter):**
- `lib/models/app_user.dart` - Modello utente con flag isAdmin
- `lib/services/auth_service.dart` - Servizio auth con supporto custom claims
- `lib/admin/admin_home_screen.dart` - Pannello amministrativo

### Flusso di Autenticazione Admin

```
1. Utente fa login → Firebase Auth
2. Backend verifica token → Legge custom claim admin=true
3. Se admin=true → Accesso a rotte /api/admin/*
4. Flutter legge claim → Mostra menu "Pannello amministrativo"
```

---

## 🔧 Setup Backend {#setup-backend}

### 1. Middleware Auth (Già Configurato)

File: `backend/src/middleware/auth.ts`

```typescript
// Controlla custom claim admin PRIMA del role
const isAdmin = decoded.admin === true;

// Se ha custom claim admin=true, imposta role='admin'
if (isAdmin && role !== 'admin') {
  role = 'admin';
}
```

**Funzionalità:**
- ✅ Legge custom claim `admin` da Firebase Auth token
- ✅ Supporta doppio controllo: `role='admin'` OR `admin=true`
- ✅ Middleware `requireAdmin` blocca accesso non autorizzato

### 2. Router Admin (Già Montato)

File: `backend/src/index.ts`

```typescript
import adminRouter from './routes/admin';
app.use('/api/admin', adminRouter);
```

**Endpoints Disponibili:**
- `GET /api/admin/stats` - Statistiche generali
- `GET /api/admin/pros/pending` - PRO in attesa di approvazione
- `POST /api/admin/pros/:id/status` - Cambia stato PRO (approved/disabled/pending)
- `POST /api/admin/pros/:id/approve` - Approva PRO (legacy)
- `GET /api/admin/coupons` - Lista coupons
- `POST /api/admin/coupons` - Crea nuovo coupon

---

## 👑 Promozione Utenti Admin {#promozione-admin}

### Script setAdmin.ts

File: `backend/src/auth/setAdmin.ts`

#### Uso Step-by-Step:

**1. Trova l'UID dell'utente da promuovere:**

```bash
# Opzione A: Firebase Console
https://console.firebase.google.com/
→ Authentication → Users → Copia UID

# Opzione B: Query Firestore (se hai l'email)
firebase firestore:query users --where "email == user@example.com"
```

**2. Modifica lo script:**

```typescript
const UID_DA_PROMUOVERE = 'ABC123xyz456...'; // ← Inserisci UID reale
const SET_AS_ADMIN = true; // true = promuovi, false = rimuovi
```

**3. Esegui lo script:**

```bash
cd backend
npx ts-node src/auth/setAdmin.ts
```

**Output Atteso:**

```
🚀 Impostazione admin per UID: ABC123xyz456...
🎯 Admin: ATTIVA

📋 Utente trovato: user@example.com
✅ Utente ABC123xyz456... ora ha admin=true
📧 Email: user@example.com
⚠️  L'utente deve fare logout/login per ricaricare i claims
🔍 Claims verificati: { admin: true }

✨ Operazione completata con successo!
```

**4. Ricarica claims (opzioni):**

**Opzione A - Logout/Login:** L'utente deve fare logout e login per ricaricare i token con i nuovi claims.

**Opzione B - Refresh Programmatico (Flutter):**
```dart
final authService = AuthService();
await authService.refreshClaims();
final user = await authService.getCurrentUser();
print('Admin: ${user?.isAdmin}'); // true
```

---

## 🔌 API Admin Endpoints {#api-endpoints}

### Authentication Headers

Tutte le API admin richiedono header Authorization:

```
Authorization: Bearer <firebase-id-token>
```

### GET /api/admin/stats

**Descrizione:** Statistiche generali della piattaforma

**Response:**
```json
{
  "totalPros": 45,
  "activePros": 38,
  "totalBookings": 127
}
```

### GET /api/admin/pros/pending

**Descrizione:** Lista PRO in attesa di approvazione

**Response:**
```json
[
  {
    "id": "pro_123",
    "displayName": "Studio Veterinario Milano",
    "businessName": "Vet Care SRL",
    "email": "info@vetcare.it",
    "status": "pending",
    "createdAt": "2024-01-15T10:30:00Z"
  }
]
```

### POST /api/admin/pros/:id/status

**Descrizione:** Cambia stato di un professionista

**Body:**
```json
{
  "status": "approved" // o "disabled" o "pending"
}
```

**Response:**
```json
{
  "ok": true,
  "status": "approved"
}
```

**Stati Validi:**
- `approved` - Professionista approvato e visibile
- `disabled` - Professionista disabilitato/rifiutato
- `pending` - In attesa di approvazione

### Errori Comuni

**401 Unauthorized:**
```json
{
  "error": "Missing Authorization header"
}
```
→ Token Firebase mancante o non valido

**403 Forbidden:**
```json
{
  "error": "Admin only"
}
```
→ Utente non ha privilegi admin

---

## 📱 Frontend Flutter {#frontend-flutter}

### 1. Modello AppUser

File: `lib/models/app_user.dart`

```dart
class AppUser {
  final String uid;
  final String email;
  final bool isAdmin; // Custom claim
  final String role;  // 'owner' | 'pro' | 'admin'
  
  // Verifica admin
  bool get isAdmin => isAdmin == true;
}
```

### 2. Auth Service

File: `lib/services/auth_service.dart`

```dart
// Carica utente con claims
final user = await authService.getCurrentUser();
print('Admin: ${user?.isAdmin}');

// Ricarica claims (dopo promozione)
await authService.refreshClaims();
```

### 3. Routing

File: `lib/router/app_router.dart`

```dart
GoRoute(
  path: '/admin',
  builder: (_, __) => const AdminHomeScreen(),
),
```

### 4. Menu Condizionale

File: `lib/screens/home/home_owner_screen.dart` e `home_pro_screen.dart`

```dart
// Mostra solo se admin
if (_currentUser?.isAdmin == true)
  ListTile(
    leading: const Icon(Icons.admin_panel_settings),
    title: const Text('Pannello amministrativo'),
    onTap: () => context.go('/admin'),
  ),
```

### 5. AdminHomeScreen

File: `lib/admin/admin_home_screen.dart`

**Funzionalità:**
- ✅ Dashboard con statistiche (PRO, owner, prenotazioni)
- ✅ Lista PRO in attesa di approvazione
- ✅ Approva/Rifiuta professionisti con un tap
- ✅ Pull-to-refresh per aggiornare dati
- ✅ Error handling con retry

**Azioni Disponibili:**
- ✅ Approva PRO (icona verde)
- ✅ Rifiuta PRO (icona rossa)
- 🔄 Refresh dati

---

## 🧪 Testing {#testing}

### Test Backend

**1. Test Promozione Admin:**

```bash
# Esegui script setAdmin.ts
cd backend
npx ts-node src/auth/setAdmin.ts
```

**2. Test API Stats:**

```bash
# Ottieni token (da Firebase Console o app)
TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."

# Test endpoint stats
curl -H "Authorization: Bearer $TOKEN" \
  https://api.mypetcareapp.org/api/admin/stats
```

**3. Test API Pros Pending:**

```bash
curl -H "Authorization: Bearer $TOKEN" \
  https://api.mypetcareapp.org/api/admin/pros/pending
```

**4. Test Cambio Stato PRO:**

```bash
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"approved"}' \
  https://api.mypetcareapp.org/api/admin/pros/PRO_ID/status
```

### Test Flutter

**1. Test Caricamento Claims:**

```dart
void testAdminClaims() async {
  final authService = AuthService();
  await authService.signInWithEmailAndPassword(
    email: 'admin@example.com',
    password: 'password',
  );
  
  final user = await authService.getCurrentUser();
  print('Is Admin: ${user?.isAdmin}'); // true
  print('Role: ${user?.role}');       // admin
}
```

**2. Test Navigation:**

```dart
// Dopo login come admin
context.go('/admin');
// Deve aprire AdminHomeScreen
```

---

## 🔒 Security Best Practices {#security}

### 1. Custom Claims vs Firestore

**✅ RACCOMANDATO: Custom Claims**
- Più sicuri (non modificabili da client)
- Inclusi nel token JWT
- Validati dal backend automaticamente

**❌ SCONSIGLIATO: Firestore `isAdmin` field**
- Modificabili da client con security rules deboli
- Richiedono query extra
- Possibile race condition

### 2. Backend Authorization

```typescript
// ✅ CORRETTO: Doppio controllo
if (req.user?.role !== 'admin' && req.user?.admin !== true) {
  return res.status(403).json({ error: 'Admin only' });
}

// ❌ SBAGLIATO: Solo Firestore role
if (req.user?.role !== 'admin') { ... }
```

### 3. Frontend UI

```dart
// ✅ CORRETTO: Nascondere UI basato su claims
if (_currentUser?.isAdmin == true) {
  // Mostra admin panel
}

// ⚠️ NOTA: La sicurezza vera è sul backend!
// Nascondere UI è solo UX, non security
```

### 4. Rate Limiting

Le rotte admin dovrebbero avere rate limiting aggressivo:

```typescript
import rateLimit from 'express-rate-limit';

const adminLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minuti
  max: 100, // Max 100 richieste per IP
});

router.use(requireAuth, requireAdmin, adminLimiter);
```

### 5. Audit Logging

Considera di loggare tutte le azioni admin:

```typescript
router.post('/pros/:id/status', async (req, res) => {
  const adminUid = req.user!.uid;
  const action = `Changed pro ${req.params.id} status to ${req.body.status}`;
  
  // Log to Firestore
  await db.collection('audit_logs').add({
    adminUid,
    action,
    timestamp: new Date(),
  });
  
  // ... resto della logica
});
```

---

## 📝 Checklist Pre-Produzione

- [ ] **Script setAdmin.ts testato** con almeno 1 utente reale
- [ ] **Backend middleware auth** supporta custom claim admin=true
- [ ] **Router admin montato** su /api/admin
- [ ] **Firestore Security Rules** impediscono modifiche dirette ai claims
- [ ] **Flutter AdminHomeScreen** accessibile solo se isAdmin=true
- [ ] **Rate limiting configurato** per API admin
- [ ] **Audit logging implementato** (opzionale ma raccomandato)
- [ ] **Documentazione utente** per amministratori creata

---

## 🆘 Troubleshooting

### Problema: "Admin only" errore 403

**Causa:** Custom claim admin non impostato o non ricaricato

**Soluzione:**
1. Verifica che lo script setAdmin.ts sia stato eseguito
2. Utente deve fare logout/login per ricaricare token
3. Oppure chiama `authService.refreshClaims()` in Flutter

### Problema: Menu admin non appare

**Causa:** Claims non caricati o user null

**Soluzione:**
1. Verifica che `_loadUser()` venga chiamato in `initState()`
2. Controlla console Flutter per errori
3. Verifica che `getCurrentUser()` ritorni user con isAdmin=true

### Problema: API admin ritornano 401

**Causa:** Token Firebase mancante o scaduto

**Soluzione:**
1. Verifica header Authorization con Bearer token
2. Ottieni nuovo token con `user.getIdToken()`
3. Controlla scadenza token (1 ora di default)

---

## 📚 Risorse

- [Firebase Custom Claims](https://firebase.google.com/docs/auth/admin/custom-claims)
- [GoRouter Navigation](https://pub.dev/packages/go_router)
- [Express Rate Limiting](https://www.npmjs.com/package/express-rate-limit)

---

**Autore:** Sistema Amministrativo My Pet Care  
**Versione:** 1.0.0  
**Data:** 2024
