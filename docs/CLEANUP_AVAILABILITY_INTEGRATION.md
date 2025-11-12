# 🚀 Cleanup → Availability → Flutter Integration Guide

## Overview

Complete implementation of the stabilization pack:
1. ✅ Cleanup expired locks (Cloud Functions)
2. ✅ Availability endpoint (millisecond-based)
3. ✅ Flutter integration (SlotGrid widget)
4. ✅ Testing & Monitoring

---

## 1️⃣ Cleanup Locks - Cloud Functions

### Files Created
```
backend/functions/
├── package.json                     # Dependencies
├── tsconfig.json                    # TypeScript config
└── src/
    ├── index.ts                     # Main export
    └── cron/
        └── cleanupLocks.ts          # Scheduled function
```

### Deployment

```bash
cd backend/functions
npm install
npm run deploy:cron
```

### Schedule
- **Frequency**: Every 5 minutes
- **Timezone**: Europe/Rome
- **Operation**: Delete locks where `ttl < now`
- **Batch size**: 500 locks max per run

### Monitoring

```bash
# View function logs
firebase functions:log --only cleanupExpiredLocks

# Check last execution
firebase functions:log --only cleanupExpiredLocks --limit 1
```

---

## 2️⃣ Availability Endpoint

### API Specification

**Endpoint**: `GET /api/pros/:id/availability`

**Query Parameters**:
- `date` (required): ISO date "YYYY-MM-DD"
- `tz` (optional): IANA timezone (default: "Europe/Rome")
- `durationMin` (optional): Minutes per slot (default: stepMin from calendar meta)

**Response**:
```json
{
  "proId": "test-pro-001",
  "date": "2025-11-20",
  "tz": "Europe/Rome",
  "stepMin": 30,
  "windows": [
    { "start": "09:00", "end": "12:00" },
    { "start": "15:00", "end": "18:00" }
  ],
  "locks": [
    { "slotStart": 1732096800000, "slotEnd": 1732098600000 }
  ],
  "slots": [
    { "start": 1732089600000, "end": 1732091400000 },
    { "start": 1732091400000, "end": 1732093200000 }
  ]
}
```

### Calendar Schema

```typescript
// calendars/{proId}/meta/config
{
  stepMin: 30,
  weeklySchedule: {
    "0": [],  // Sunday (dow 0-6)
    "1": [{ start: "09:00", end: "12:00" }],  // Monday
    // ... other days
  },
  exceptions: {
    "2025-12-25": [],  // Christmas - closed
    "2025-11-15": [{ start: "10:00", end: "14:00" }]  // Special hours
  }
}

// calendars/{proId}/locks/{lockId}
{
  slotStart: 1732089600000,  // milliseconds
  slotEnd: 1732091400000,    // milliseconds
  ttl: 1732092000000,        // expiration time
  userId: "user123",
  bookingId: "booking456"    // optional
}
```

### Algorithm

1. Load calendar meta (stepMin, weeklySchedule, exceptions)
2. Get daily windows (exceptions override weeklySchedule)
3. Generate candidate slots based on stepMin
4. Load active locks (ttl > now)
5. Filter out slots that overlap with locks
6. Return free slots

---

## 3️⃣ Flutter Integration

### Files Created

```
lib/
├── services/
│   └── availability_service.dart    # HTTP client
└── widgets/
    └── slot_grid_ms.dart            # Slot grid widget
```

### Usage Example

```dart
import 'package:my_pet_care/services/availability_service.dart';
import 'package:my_pet_care/widgets/slot_grid_ms.dart';

final service = AvailabilityService('http://localhost:8080');

SlotGridMs(
  proId: 'pro_123',
  date: DateTime(2025, 11, 20),
  service: service,
  durationMin: 30,
  crossAxisCount: 3,
  onSelect: (start, end) {
    // Handle slot selection
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confermi questo orario?'),
        content: Text('${DateFormat.Hm().format(start)} - ${DateFormat.Hm().format(end)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Create booking/lock
            },
            child: const Text('Continua'),
          ),
        ],
      ),
    );
  },
)
```

### Widget States

1. **Loading**: Shows CircularProgressIndicator
2. **Error**: Shows error message with retry button
3. **Empty**: Shows "Nessuna disponibilità" message
4. **Success**: Shows grid of available slots

---

## 4️⃣ Testing

### Backend Tests

```bash
# Create test calendar data
cd backend
node scripts/create-test-calendar.js

# Run availability tests
bash test-availability.sh http://localhost:8080

# Manual test
curl "http://localhost:8080/api/pros/test-pro-001/availability?date=2025-11-20" | jq .
```

### Expected Results

**Test Calendar**:
- PRO ID: `test-pro-001`
- Monday-Friday: 09:00-12:00, 15:00-18:00 (stepMin: 30)
- Saturday: 10:00-14:00
- Sunday: Closed
- Test lock: 10:00-10:30

**Expected Slots** (Monday 2025-11-20):
- Morning: 09:00, 09:30, 11:00, 11:30 (10:00-10:30 locked)
- Afternoon: 15:00, 15:30, 16:00, 16:30, 17:00, 17:30

### Unit Tests (Jest - TODO)

```typescript
describe('Availability Algorithm', () => {
  it('should generate correct slots with 30min stepMin', () => {
    const windows = [{ start: '09:00', end: '12:00' }];
    const slots = generateSlots(windows, 30);
    expect(slots.length).toBe(6); // 09:00, 09:30, 10:00, 10:30, 11:00, 11:30
  });

  it('should filter out locked slots', () => {
    const slots = [...]; // 12 slots
    const locks = [
      { slotStart: 1000, slotEnd: 1800 }, // 2 locked
    ];
    const free = filterLocks(slots, locks);
    expect(free.length).toBe(10);
  });
});
```

---

## 5️⃣ Monitoring & Hardening

### Firestore Indexes

```json
{
  "indexes": [
    {
      "collectionGroup": "locks",
      "fields": [
        { "fieldPath": "ttl", "order": "ASCENDING" },
        { "fieldPath": "slotStart", "order": "ASCENDING" }
      ]
    }
  ]
}
```

### Rate Limiting

Backend already has rate limiting configured:
- 300 requests per 15 minutes per IP
- Applied to `/api/*` routes

### Safe Window (TODO)

Discard slots with `start < now + X minutes` to avoid last-second bookings:

```typescript
// Filter slots starting in the next 15 minutes
const safeWindowMs = 15 * 60 * 1000;
const freeSlots = candidateSlots.filter(slot => {
  const isFuture = slot.start > (nowMs + safeWindowMs);
  const noLockCollision = !activeLocks.some(...);
  return isFuture && noLockCollision;
});
```

### Idempotency (TODO)

Use `bookingId` as idempotent key when creating locks:

```typescript
// Check if lock already exists with same bookingId
const existingLock = await locksRef
  .where('bookingId', '==', bookingId)
  .limit(1)
  .get();

if (!existingLock.empty) {
  return { ok: true, message: 'Lock already exists' };
}
```

---

## 📊 Production Checklist

### Backend
- [x] Cleanup function deployed
- [x] Availability endpoint tested
- [x] Firestore rules configured
- [x] Firestore indexes created
- [ ] Rate limiting verified
- [ ] Safe window implemented
- [ ] Idempotency implemented

### Frontend
- [x] AvailabilityService created
- [x] SlotGridMs widget created
- [x] Loading/error/empty states
- [ ] Integration with booking flow
- [ ] Lock creation on selection
- [ ] Conflict handling (409 error)

### Monitoring
- [ ] Cloud Functions alerts
- [ ] Backend API monitoring
- [ ] Firestore usage tracking
- [ ] Lock count alerts (>1000)

---

## 🚀 Next Steps

1. **Test End-to-End Flow**
   - Create test calendar
   - Test availability API
   - Test Flutter widget

2. **Implement Lock Creation**
   - Add endpoint to create lock on slot selection
   - Add TTL validation (5 minutes)
   - Handle conflicts (409 response)

3. **Add Monitoring**
   - Cloud Functions alerts
   - Lock count monitoring
   - API response time tracking

4. **Hardening**
   - Safe window implementation
   - Idempotency keys
   - Double-lock prevention

---

## 📞 Support

For questions about implementation:
- **Cleanup**: `backend/functions/src/cron/cleanupLocks.ts`
- **Availability**: `backend/src/routes/availability_ms.routes.ts`
- **Flutter Service**: `lib/services/availability_service.dart`
- **Flutter Widget**: `lib/widgets/slot_grid_ms.dart`
- **Testing**: `backend/test-availability.sh`
