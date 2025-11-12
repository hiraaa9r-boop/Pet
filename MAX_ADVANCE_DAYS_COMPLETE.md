# ✅ maxAdvanceDays Feature - Implementazione Completa

## 🎯 Feature Implementata

**maxAdvanceDays** - Limita quanto lontano nel futuro gli utenti possono prenotare servizi.

---

## 📝 Cosa È Stato Implementato

### 1. **Backend Filter Logic** ✅

**File**: `backend/src/routes/availability_iso.routes.ts`

**Modifiche applicate:**
```typescript
// Read from calendar meta
const maxAdvanceDays = meta.maxAdvanceDays ?? 60; // Default 60 days

// Calculate max booking date
const nowMs = Date.now();
const maxBookingDateMs = nowMs + (maxAdvanceDays * 86400000);

// Filter candidate slots
const filteredSlots = candidateSlots.filter(slot => {
  const slotFromMs = new Date(slot.from).getTime();
  return slotFromMs <= maxBookingDateMs;
});

// Log filtering
logger.info({ 
  candidateSlots: candidateSlots.length,
  filteredSlots: filteredSlots.length,
  maxAdvanceDays,
}, 'Slots filtered by maxAdvanceDays');

// Use filtered slots for overlap detection
const freeSlots = filteredSlots.filter(slot => { ... });
```

**Posizione nel flow:**
```
1. Generate candidate slots (weeklySchedule + exceptions)
2. Apply maxAdvanceDays filter  ← AGGIUNTO QUI
3. Load bookings and locks
4. Filter overlaps
5. Return free slots
```

---

### 2. **Documentazione Completa** ✅

**File**: `backend/MAX_ADVANCE_DAYS_FEATURE.md` (8 KB)

**Sezioni documentate:**
- ✅ Obiettivo e use case
- ✅ Schema Firestore config
- ✅ Implementazione backend dettagliata
- ✅ Esempi pratici (30, 60, 90, 365 giorni)
- ✅ Testing guide con curl commands
- ✅ Flutter UI integration examples
- ✅ Monitoring & logs
- ✅ Best practices per tipo servizio
- ✅ Deployment strategy
- ✅ Checklist implementazione

---

### 3. **Test Script** ✅

**File**: `backend/test-max-advance-days.sh` (3.8 KB)

**Test cases inclusi:**
- ✅ Test 1: Within horizon (today + 20 days, max 60)
- ✅ Test 2: Beyond horizon (today + 80 days, max 60)
- ✅ Test 3: Edge case - exactly at horizon (today + 60 days)
- ✅ Test 4: Very far future (today + 365 days)
- ✅ Test 5: Today (should always work)

**Usage:**
```bash
cd backend
./test-max-advance-days.sh http://localhost:8080 test-pro-001
```

---

## 📊 Schema Firestore

### Calendar Meta Config

**Path**: `calendars/{proId}/meta/config`

```json
{
  "stepMin": 60,
  "timezone": "Europe/Rome",
  "maxAdvanceDays": 60,  // ← NUOVO CAMPO
  "weeklySchedule": {
    "0": [],
    "1": [{ "start": "09:00", "end": "18:00" }]
  },
  "exceptions": {}
}
```

**Campo Details:**
- **Type**: `number`
- **Default**: `60` (se non specificato nel backend)
- **Unit**: giorni
- **Validazione**: Opzionale (può essere undefined)

---

## 🔧 Come Funziona

### Flow Step-by-Step

```
User richiede: GET /api/pros/pro_123/availability?date=2025-12-25
                                                       ↓
Backend calcola: 
  today = 2025-11-10
  maxAdvanceDays = 60 (from calendar meta)
  maxBookingDate = 2025-11-10 + 60 days = 2026-01-09
  requestedDate = 2025-12-25
                                                       ↓
Verifica: 2025-12-25 <= 2026-01-09 ? 
  → YES ✅ → Genera slots per 2025-12-25
  → NO  ❌ → Ritorna slots: []
```

### Esempi Concreti

#### Esempio 1: Data Valida
```
Today: 2025-11-10
maxAdvanceDays: 60
Request date: 2025-12-15 (35 giorni futuri)
Result: ✅ Slots ritornati normalmente
```

#### Esempio 2: Data Troppo Lontana
```
Today: 2025-11-10
maxAdvanceDays: 60
Request date: 2026-02-01 (83 giorni futuri)
Result: ❌ slots: [] (oltre horizon)
```

#### Esempio 3: Esattamente al Limite
```
Today: 2025-11-10
maxAdvanceDays: 60
Request date: 2026-01-09 (60 giorni esatti)
Result: ✅ Slots ritornati (boundary inclusivo)
```

---

## 🧪 Testing

### Quick Test

```bash
# 1. Configure PRO calendar
# Firebase Console → calendars/pro_123/meta/config
# Set: maxAdvanceDays = 30

# 2. Test within horizon (today + 20 days)
curl "http://localhost:8080/api/pros/pro_123/availability?date=$(date -d '+20 days' +%Y-%m-%d)" | jq

# Expected: slots array with available slots

# 3. Test beyond horizon (today + 40 days)
curl "http://localhost:8080/api/pros/pro_123/availability?date=$(date -d '+40 days' +%Y-%m-%d)" | jq

# Expected: { "slots": [] }
```

### Automated Test Suite

```bash
cd backend
./test-max-advance-days.sh http://localhost:8080 pro_123
```

---

## 📱 Flutter Integration Example

### Date Picker Constraint

```dart
class BookingDatePicker extends StatelessWidget {
  final Pro pro;

  Future<DateTime?> pickDate(BuildContext context) async {
    final maxDays = pro.calendar?.maxAdvanceDays ?? 60;
    final now = DateTime.now();
    final maxDate = now.add(Duration(days: maxDays));

    return showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: maxDate,  // ✅ Constrained by maxAdvanceDays
      helpText: 'Prenota fino a $maxDays giorni avanti',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final date = await pickDate(context);
        if (date != null) {
          // Proceed with availability request
        }
      },
      child: Text('Scegli Data'),
    );
  }
}
```

### Display Booking Horizon

```dart
Widget buildBookingInfo(Pro pro) {
  final maxDays = pro.calendar?.maxAdvanceDays ?? 60;
  final maxDate = DateTime.now().add(Duration(days: maxDays));
  final formatter = DateFormat('dd MMMM yyyy', 'it_IT');

  return Card(
    child: ListTile(
      leading: Icon(Icons.calendar_month, color: Colors.blue),
      title: Text('Prenotabile fino a'),
      subtitle: Text(formatter.format(maxDate)),
      trailing: Chip(
        label: Text('$maxDays gg'),
        backgroundColor: Colors.blue.shade100,
      ),
    ),
  );
}
```

---

## 📊 Valori Raccomandati per Settore

| Tipo Servizio | maxAdvanceDays | Ragione |
|---------------|----------------|---------|
| **Veterinario** | 30-60 | Urgenze frequenti, pianificazione breve |
| **Pet Sitting** | 60-90 | Viaggi pianificati con anticipo |
| **Grooming** | 30-45 | Servizio regolare, breve pianificazione |
| **Pet Hotel** | 90-180 | Vacanze pianificate molto in anticipo |
| **Training** | 60-90 | Corsi programmati con settimane di anticipo |

---

## 🔍 Logs & Monitoring

### Log Output Example

```json
{
  "level": "info",
  "message": "Slots filtered by maxAdvanceDays",
  "proId": "pro_123",
  "date": "2025-12-25",
  "candidateSlots": 18,
  "filteredSlots": 12,
  "maxAdvanceDays": 60,
  "timestamp": "2025-11-10T10:30:00.000Z"
}
```

**Interpretazione:**
- 18 slots generati da weeklySchedule
- 12 slots entro horizon (60 giorni)
- 6 slots filtrati (oltre horizon)

---

## 🚀 Deployment

### Step 1: Deploy Backend

```bash
# Backend già aggiornato con maxAdvanceDays logic
cd backend
npm run dev  # Test locale

# Deploy to production
gcloud run deploy my-pet-care-api --source .
```

### Step 2: Configure Calendar Meta

```javascript
// Via Firebase Console o script
const db = admin.firestore();
const calendarRef = db
  .collection('calendars')
  .doc('pro_123')
  .collection('meta')
  .doc('config');

await calendarRef.update({
  maxAdvanceDays: 60  // Set desired value
});
```

### Step 3: Test in Production

```bash
# Test with real PRO ID
curl "https://api.mypetcare.it/api/pros/REAL_PRO_ID/availability?date=2025-12-25" | jq
```

---

## ✅ Checklist

- [x] **Backend logic** implementata in availability endpoint
- [x] **Default value** (60 giorni) configurato
- [x] **Logging** con dettagli filtro (candidateSlots, filteredSlots)
- [x] **Documentazione** completa con esempi
- [x] **Test script** automatizzato
- [ ] **Firestore Rules** validation (optional - può essere undefined)
- [ ] **Flutter UI** per display horizon (esempio fornito)
- [ ] **Admin panel** per configurare maxAdvanceDays
- [ ] **Production testing** con PRO reali

---

## 🎯 Summary

**Feature Status**: ✅ IMPLEMENTED  
**Default Value**: 60 days  
**Backend Changes**: 1 file modified  
**New Files**: 2 (documentation + test script)  
**LOC Added**: ~30 lines  

**Ready for:**
- ✅ Local testing
- ✅ Production deployment
- ✅ Flutter integration

---

## 📞 Support

**Implementation Questions**: Consulta `MAX_ADVANCE_DAYS_FEATURE.md`  
**Testing Issues**: Run `./test-max-advance-days.sh`  
**Config Help**: Firebase Console → `calendars/{proId}/meta/config`

---

**Version**: 1.0  
**Date**: 2025-11-10  
**Developer**: Full-Stack Mobile Developer  
**Feature**: maxAdvanceDays (booking horizon limit)  
**Status**: ✅ COMPLETE & DOCUMENTED
