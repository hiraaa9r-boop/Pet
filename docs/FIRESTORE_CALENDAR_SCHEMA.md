# Schema Firestore Calendar - MY PET CARE

## 📋 Panoramica

La collezione `calendars/{proId}` gestisce gli orari di disponibilità dei professionisti (PRO) per il sistema di prenotazione.

## 🔧 Struttura Documento

```typescript
{
  stepMin: number,           // Intervallo slot in minuti (default: 30)
  weekly: {                  // Orari settimanali
    mon: Range[],
    tue: Range[],
    wed: Range[],
    thu: Range[],
    fri: Range[],
    sat: Range[],
    sun: Range[]
  },
  exceptions: Exception[]    // Eccezioni (chiusure, override)
}

type Range = {
  start: string,  // Formato "HH:MM" (es: "09:00")
  end: string     // Formato "HH:MM" (es: "13:00")
}

type Exception = {
  date: string,         // Formato "YYYY-MM-DD" (es: "2025-12-24")
  type: 'closed' | 'override',
  ranges?: Range[]      // Solo per type='override'
}
```

---

## 📚 Esempi Pratici

### Esempio 1: Orario Standard Veterinario

```javascript
// Veterinario con orari mattino/pomeriggio, chiuso domenica
{
  "stepMin": 30,
  "weekly": {
    "mon": [
      { "start": "09:00", "end": "13:00" },
      { "start": "15:00", "end": "19:00" }
    ],
    "tue": [
      { "start": "09:00", "end": "13:00" },
      { "start": "15:00", "end": "19:00" }
    ],
    "wed": [
      { "start": "09:00", "end": "13:00" },
      { "start": "15:00", "end": "19:00" }
    ],
    "thu": [
      { "start": "09:00", "end": "13:00" },
      { "start": "15:00", "end": "19:00" }
    ],
    "fri": [
      { "start": "09:00", "end": "13:00" },
      { "start": "15:00", "end": "19:00" }
    ],
    "sat": [
      { "start": "09:00", "end": "13:00" }
    ],
    "sun": []  // Chiuso
  },
  "exceptions": []
}
```

**Slot generati per lunedì:**
- 09:00, 09:30, 10:00, 10:30, 11:00, 11:30, 12:00, 12:30
- 15:00, 15:30, 16:00, 16:30, 17:00, 17:30, 18:00, 18:30

---

### Esempio 2: Toelettatore con Slot Lunghi

```javascript
// Toelettatura con appuntamenti da 60 minuti
{
  "stepMin": 60,
  "weekly": {
    "mon": [{ "start": "10:00", "end": "18:00" }],
    "tue": [{ "start": "10:00", "end": "18:00" }],
    "wed": [{ "start": "10:00", "end": "18:00" }],
    "thu": [{ "start": "10:00", "end": "18:00" }],
    "fri": [{ "start": "10:00", "end": "18:00" }],
    "sat": [{ "start": "09:00", "end": "14:00" }],
    "sun": []
  },
  "exceptions": []
}
```

**Slot generati per martedì:**
- 10:00, 11:00, 12:00, 13:00, 14:00, 15:00, 16:00, 17:00

---

### Esempio 3: Chiusure Festive

```javascript
{
  "stepMin": 30,
  "weekly": {
    "mon": [{ "start": "09:00", "end": "18:00" }],
    "tue": [{ "start": "09:00", "end": "18:00" }],
    "wed": [{ "start": "09:00", "end": "18:00" }],
    "thu": [{ "start": "09:00", "end": "18:00" }],
    "fri": [{ "start": "09:00", "end": "18:00" }],
    "sat": [{ "start": "09:00", "end": "13:00" }],
    "sun": []
  },
  "exceptions": [
    {
      "date": "2025-12-24",
      "type": "closed"
    },
    {
      "date": "2025-12-25",
      "type": "closed"
    },
    {
      "date": "2025-12-26",
      "type": "closed"
    },
    {
      "date": "2025-12-31",
      "type": "override",
      "ranges": [{ "start": "09:00", "end": "12:00" }]
    }
  ]
}
```

**Comportamento:**
- 24, 25, 26 dicembre: **Completamente chiuso** (nessuno slot)
- 31 dicembre: **Orario ridotto** solo 09:00-12:00

---

### Esempio 4: Pet Sitter Flessibile

```javascript
// Pet sitter disponibile anche nel weekend con orari estesi
{
  "stepMin": 60,
  "weekly": {
    "mon": [{ "start": "08:00", "end": "20:00" }],
    "tue": [{ "start": "08:00", "end": "20:00" }],
    "wed": [{ "start": "08:00", "end": "20:00" }],
    "thu": [{ "start": "08:00", "end": "20:00" }],
    "fri": [{ "start": "08:00", "end": "20:00" }],
    "sat": [{ "start": "10:00", "end": "18:00" }],
    "sun": [{ "start": "10:00", "end": "16:00" }]
  },
  "exceptions": [
    {
      "date": "2025-08-15",  // Ferragosto
      "type": "closed"
    }
  ]
}
```

---

## 🔨 Operazioni CRUD su Firestore

### Creare Calendario per Nuovo PRO

```javascript
// Firebase Admin SDK (Node.js)
const admin = require('firebase-admin');
const db = admin.firestore();

async function createCalendarForNewPro(proId) {
  const defaultCalendar = {
    stepMin: 30,
    weekly: {
      mon: [
        { start: '09:00', end: '13:00' },
        { start: '15:00', end: '19:00' }
      ],
      tue: [
        { start: '09:00', end: '13:00' },
        { start: '15:00', end: '19:00' }
      ],
      wed: [
        { start: '09:00', end: '13:00' },
        { start: '15:00', end: '19:00' }
      ],
      thu: [
        { start: '09:00', end: '13:00' },
        { start: '15:00', end: '19:00' }
      ],
      fri: [
        { start: '09:00', end: '13:00' },
        { start: '15:00', end: '19:00' }
      ],
      sat: [{ start: '09:00', end: '13:00' }],
      sun: []
    },
    exceptions: []
  };

  await db.collection('calendars').doc(proId).set(defaultCalendar);
  console.log(`✅ Calendario creato per PRO: ${proId}`);
}

// Utilizzo
createCalendarForNewPro('pro_123abc');
```

---

### Aggiungere Chiusura Eccezionale

```javascript
// Aggiungere chiusura per vacanze
async function addClosedDate(proId, date) {
  const calRef = db.collection('calendars').doc(proId);
  
  await calRef.update({
    exceptions: admin.firestore.FieldValue.arrayUnion({
      date: date,  // "YYYY-MM-DD"
      type: 'closed'
    })
  });
  
  console.log(`✅ Aggiunta chiusura per ${date}`);
}

// Utilizzo
addClosedDate('pro_123abc', '2025-12-25');
```

---

### Modificare Orario Giorno Specifico

```javascript
// Override orario per un singolo giorno
async function overrideScheduleForDate(proId, date, ranges) {
  const calRef = db.collection('calendars').doc(proId);
  
  // Prima rimuovi eventuali exceptions per quella data
  const calSnap = await calRef.get();
  const calendar = calSnap.data();
  const filteredExceptions = (calendar.exceptions || [])
    .filter(ex => ex.date !== date);
  
  // Aggiungi nuovo override
  await calRef.update({
    exceptions: [
      ...filteredExceptions,
      {
        date: date,
        type: 'override',
        ranges: ranges
      }
    ]
  });
  
  console.log(`✅ Override orario per ${date}`);
}

// Utilizzo: ridurre orario per vigilia
overrideScheduleForDate('pro_123abc', '2025-12-24', [
  { start: '09:00', end: '12:00' }
]);
```

---

### Aggiornare Orari Settimanali

```javascript
// Cambiare orari standard di un giorno
async function updateWeeklySchedule(proId, dayOfWeek, ranges) {
  const calRef = db.collection('calendars').doc(proId);
  
  await calRef.update({
    [`weekly.${dayOfWeek}`]: ranges
  });
  
  console.log(`✅ Orari ${dayOfWeek} aggiornati`);
}

// Utilizzo: estendere orario venerdì
updateWeeklySchedule('pro_123abc', 'fri', [
  { start: '09:00', end: '13:00' },
  { start: '15:00', end: '21:00' }  // Fino alle 21:00
]);
```

---

### Modificare Intervallo Slot

```javascript
// Cambiare da 30min a 60min
async function updateSlotInterval(proId, stepMin) {
  const calRef = db.collection('calendars').doc(proId);
  
  await calRef.update({ stepMin: stepMin });
  
  console.log(`✅ Intervallo slot aggiornato a ${stepMin} minuti`);
}

// Utilizzo
updateSlotInterval('pro_123abc', 60);
```

---

## 🔍 Query Firestore da Flutter

### Caricare Calendario PRO

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>?> loadProCalendar(String proId) async {
  try {
    final calSnap = await FirebaseFirestore.instance
        .collection('calendars')
        .doc(proId)
        .get();
    
    if (!calSnap.exists) {
      return null;
    }
    
    return calSnap.data();
  } catch (e) {
    print('Errore caricamento calendario: $e');
    return null;
  }
}

// Utilizzo
final calendar = await loadProCalendar('pro_123abc');
if (calendar != null) {
  final stepMin = calendar['stepMin'] ?? 30;
  final mondayRanges = calendar['weekly']?['mon'] ?? [];
  print('Lunedì: $mondayRanges');
}
```

---

## 🎯 Algoritmo Availability (Backend)

L'endpoint `/pros/:id/availability?date=YYYY-MM-DD` implementa questa logica:

1. **Carica calendario** da `calendars/{proId}`
2. **Identifica giorno settimana** (sun/mon/tue/...)
3. **Carica range orari** da `weekly[dow]`
4. **Applica exceptions**:
   - Se `type='closed'` → nessuno slot
   - Se `type='override'` → usa `ranges` al posto di `weekly[dow]`
5. **Genera slot** con intervalli `stepMin`
6. **Carica prenotazioni** esistenti per quella data
7. **Filtra slot occupati** da bookings con status `pending/accepted/paid`
8. **Restituisci slot disponibili**

---

## ⚠️ Best Practices

### ✅ DO

- Usa sempre formato `HH:MM` per orari (zero-padded)
- Usa sempre formato `YYYY-MM-DD` per date
- Imposta `stepMin` in base alla durata media servizi
- Testa con diverse timezone (il backend usa UTC)
- Valida range orari: `end > start`

### ❌ DON'T

- Non usare `stepMin < 15` (troppi slot)
- Non creare range sovrapposti nello stesso giorno
- Non dimenticare di gestire `exceptions` vuoto
- Non modificare calendario durante prenotazioni attive

---

## 🧪 Testing

### Test Case 1: Slot Disponibili Giorno Normale

```bash
# Request
GET /pros/pro_123/availability?date=2025-06-16  # Lunedì

# Expected Response (con stepMin=30)
{
  "date": "2025-06-16",
  "slots": [
    "09:00", "09:30", "10:00", "10:30", 
    "11:00", "11:30", "12:00", "12:30",
    "15:00", "15:30", "16:00", "16:30", 
    "17:00", "17:30", "18:00", "18:30"
  ]
}
```

### Test Case 2: Giorno Chiuso

```bash
# Request
GET /pros/pro_123/availability?date=2025-12-25  # Natale

# Expected Response
{
  "date": "2025-12-25",
  "slots": []
}
```

### Test Case 3: Override Orario

```bash
# Request
GET /pros/pro_123/availability?date=2025-12-31  # Vigilia Capodanno

# Expected Response (solo mattina)
{
  "date": "2025-12-31",
  "slots": ["09:00", "09:30", "10:00", "10:30", "11:00", "11:30"]
}
```

---

## 📝 Checklist Setup Nuovo PRO

Quando crei un nuovo professionista, esegui:

1. ✅ Crea documento `calendars/{proId}`
2. ✅ Imposta `stepMin` appropriato per tipo servizio
3. ✅ Configura orari `weekly` per ogni giorno
4. ✅ Lascia `exceptions` array vuoto
5. ✅ Testa chiamata availability API
6. ✅ Verifica slot generati corretti

---

## 🔗 File Correlati

- **Backend**: `/backend/src/index.ts` (righe 363-422) - Endpoint availability
- **Flutter Widget**: `/lib/widgets/slot_grid.dart` - UI griglia slot
- **Config**: `/lib/config.dart` - URL backend

---

## 📞 Supporto

Per problemi con il sistema calendario:
1. Verifica che `calendars/{proId}` esista
2. Controlla formato date/orari (HH:MM, YYYY-MM-DD)
3. Testa endpoint `/pros/:id/availability` direttamente
4. Verifica log backend per errori generazione slot
