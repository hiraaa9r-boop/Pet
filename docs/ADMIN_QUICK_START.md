# 🚀 Admin System - Quick Start

## 📝 Come Promuovere un Utente ad Admin (3 Passi)

### Passo 1: Trova l'UID utente

**Opzione A - Firebase Console:**
```
1. Vai su https://console.firebase.google.com/
2. Seleziona progetto My Pet Care
3. Authentication → Users
4. Trova utente da promuovere
5. Copia UID (es: ABC123xyz456...)
```

**Opzione B - Da email (se hai Firebase CLI):**
```bash
firebase firestore:query users --where "email == admin@example.com"
```

### Passo 2: Esegui Script Promozione

```bash
cd /home/user/flutter_app/backend

# Modifica il file con UID reale
vim src/auth/setAdmin.ts
# Cambia: const UID_DA_PROMUOVERE = 'ABC123xyz456...';

# Esegui script
npx ts-node src/auth/setAdmin.ts
```

**Output atteso:**
```
🚀 Impostazione admin per UID: ABC123xyz456...
✅ Utente ABC123xyz456... ora ha admin=true
📧 Email: admin@example.com
⚠️  L'utente deve fare logout/login per ricaricare i claims
```

### Passo 3: Ricarica Claims Utente

**L'utente deve:**
1. Fare **logout** dall'app
2. Fare **login** di nuovo
3. Aprire **Profilo**
4. Vedere nuovo menu **"Pannello amministrativo"** 🛡️

---

## 🎯 Come Accedere al Pannello Admin (Flutter Web)

### Per Utenti Admin

1. **Login** all'app Flutter Web
2. Tap su **Profilo** (icona persona in basso)
3. Scroll verso il basso
4. Tap su **"Pannello amministrativo"** 🛡️

### Dashboard Admin

Una volta dentro vedrai:

**📊 Statistiche:**
- PRO totali registrati
- PRO attivi con abbonamento
- Prenotazioni totali

**👥 PRO in Attesa:**
- Lista professionisti da approvare
- Per ogni PRO:
  - Nome studio/business
  - Email contatto
  - ✅ Pulsante APPROVA (verde)
  - ❌ Pulsante RIFIUTA (rosso)

**🔄 Refresh:**
- Pull-to-refresh per aggiornare dati

---

## 🧪 Test Veloce Sistema Admin

### Test 1: Promuovi Test User

```bash
# Nel file setAdmin.ts
const UID_DA_PROMUOVERE = 'YOUR_TEST_USER_UID';
const SET_AS_ADMIN = true;

npx ts-node src/auth/setAdmin.ts
```

### Test 2: Verifica API Backend

```bash
# Ottieni token (vedi sotto come)
TOKEN="eyJhbGciOiJSUzI1NiIs..."

# Test stats
curl -H "Authorization: Bearer $TOKEN" \
  https://api.mypetcareapp.org/api/admin/stats

# Risposta attesa: {"totalPros":45,"activePros":38,"totalBookings":127}
```

**Come ottenere token:**
1. Apri Flutter DevTools con app in debug
2. Console → Esegui:
   ```dart
   FirebaseAuth.instance.currentUser!.getIdToken().then(print);
   ```
3. Copia token stampato

### Test 3: Verifica UI Flutter

```
1. Riavvia app Flutter (dopo promozione)
2. Login con utente admin
3. Naviga a Profilo
4. Verifica presenza menu "Pannello amministrativo"
5. Tap → Deve aprire dashboard con statistiche
```

---

## ⚠️ Troubleshooting Rapido

### ❌ Menu admin NON appare

**Problema:** Claims non ricaricati

**Soluzione:**
```
1. Utente deve fare LOGOUT completo
2. Poi LOGIN di nuovo
3. Claims si ricaricano automaticamente
```

### ❌ API ritorna 403 "Admin only"

**Problema:** Token non ha claim admin=true

**Verifica:**
```bash
# Decodifica token JWT
echo "TOKEN_QUI" | cut -d'.' -f2 | base64 -d | jq .

# Deve contenere: "admin": true
```

**Soluzione:** Ri-esegui script setAdmin.ts

### ❌ Script setAdmin.ts errore

**Problema:** Firebase Admin non inizializzato

**Soluzione:**
```bash
# Verifica che Firebase sia configurato
ls -la /opt/flutter/firebase-admin-sdk.json

# Se manca, carica file da Firebase Console
```

---

## 📚 Comandi Utili

### Backend

```bash
# Avvia backend locale
cd backend
npm run dev

# Test endpoints admin
curl -H "Authorization: Bearer $TOKEN" \
  localhost:3000/api/admin/stats

# Promuovi admin
npx ts-node src/auth/setAdmin.ts
```

### Flutter

```bash
# Avvia app Flutter Web
cd flutter_app
flutter run -d chrome

# Analyze codice
flutter analyze

# Build release
flutter build web --release
```

### Firebase

```bash
# Lista utenti
firebase auth:export users.json

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Verifica progetto
firebase use
```

---

## 🔐 Note di Sicurezza

### ✅ Best Practices

1. **Promuovi solo utenti fidati** - Admin ha accesso completo
2. **Limita numero admin** - 1-3 admin consigliati per progetto piccolo
3. **Monitora azioni admin** - Implementa audit logging
4. **Usa email aziendali** - Es: admin@mypetcareapp.org

### ❌ DA NON FARE

1. ❌ **Non condividere UID pubblicamente** - Mantieni riservati
2. ❌ **Non promuovere utenti test in produzione** - Solo utenti reali
3. ❌ **Non salvare token in codice** - Sempre da variabili ambiente
4. ❌ **Non disabilitare middleware auth** - Lascia sempre attivo requireAdmin

---

## 📞 Supporto

### Documentazione Completa
- `ADMIN_SYSTEM_SETUP.md` - Guida dettagliata completa
- `ADMIN_IMPLEMENTATION_SUMMARY.md` - Riepilogo implementazione

### File Chiave
- Backend: `backend/src/auth/setAdmin.ts`
- Middleware: `backend/src/middleware/auth.ts`
- Admin Routes: `backend/src/routes/admin.ts`
- Flutter Screen: `lib/admin/admin_home_screen.dart`
- Auth Service: `lib/services/auth_service.dart`

---

## ✅ Checklist Prima di Produzione

- [ ] Almeno 1 admin promosso e testato
- [ ] Menu admin appare correttamente
- [ ] Dashboard admin carica statistiche
- [ ] Approvazione PRO funziona
- [ ] API backend protette (401/403 per non-admin)
- [ ] Token JWT contiene claim admin=true
- [ ] Firestore rules bloccano modifiche dirette
- [ ] Rate limiting configurato (opzionale)
- [ ] Audit logging attivo (opzionale)

---

**🎉 Sistema pronto all'uso! Buona amministrazione!**
