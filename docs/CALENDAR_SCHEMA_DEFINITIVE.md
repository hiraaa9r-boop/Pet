# 📅 Calendar Schema - Definitive Structure

## Overview

This document defines the **definitive calendar structure** used by MY PET CARE for managing PRO availability, exceptions, locks, and bookings.

---

## 🗂️ Firestore Collections

### 1. `calendars/{proId}` (Document)

Main calendar configuration for each PRO.

```typescript
{
  stepMin: number,              // Slot duration in minutes (e.g., 15, 30, 60)
  timezone: string,             // IANA timezone (e.g., "Europe/Rome")
  weeklySchedule: {             // Default weekly availability
    mon: IntervalStr[],         // Array of { start: "HH:mm", end: "HH:mm" }
    tue: IntervalStr[],
    wed: IntervalStr[],
    thu: IntervalStr[],
    fri: IntervalStr[],
    sat: IntervalStr[],
    sun: IntervalStr[]
  }
}
```

**Example**:
```json
{
  "stepMin": 30,
  "timezone": "Europe/Rome",
  "weeklySchedule": {
    "mon": [
      { "start": "09:00", "end": "13:00" },
      { "start": "15:00", "end": "19:00" }
    ],
    "tue": [
      { "start": "09:00", "end": "13:00" },
      { "start": "15:00", "end": "19:00" }
    ],
    "wed": [],
    "thu": [
      { "start": "09:00", "end": "13:00" },
      { "start": "15:00", "end": "19:00" }
    ],
    "fri": [
      { "start": "09:00", "end": "13:00" },
      { "start": "15:00", "end": "19:00" }
    ],
    "sat": [
      { "start": "10:00", "end": "14:00" }
    ],
    "sun": []
  }
}
```

---

### 2. `calendars/{proId}/exceptions/{YYYY-MM-DD}` (Document)

Overrides for specific dates (holidays, special hours, closures).

```typescript
{
  closed?: boolean,             // If true, PRO is closed this day
  intervals?: IntervalStr[]     // If present, replaces weeklySchedule for this day
}
```

**Example - Closed Day**:
```json
{
  "closed": true
}
```

**Example - Custom Hours**:
```json
{
  "closed": false,
  "intervals": [
    { "start": "10:00", "end": "12:30" },
    { "start": "16:00", "end": "20:00" }
  ]
}
```

---

### 3. `calendars/{proId}/locks/{lockId}` (Document)

Temporary slot reservations (5-minute TTL) to prevent double booking.

```typescript
{
  slotStart: Timestamp,         // Slot start time (UTC)
  slotEnd: Timestamp,           // Slot end time (UTC)
  userId: string,               // User who holds the lock
  bookingId?: string,           // Optional booking reference
  ttl: Timestamp,               // Expiration time (auto-cleanup)
  proId: string,                // PRO ID (redundant for filtering)
  dateISO: string,              // Date in YYYY-MM-DD format
  createdAt: Timestamp          // Lock creation time
}
```

**Lock ID Format**: `{YYYY-MM-DD}_{HH:mm}`  
**Example**: `2025-11-20_10:00`

**TTL Policy**: Enable Firestore TTL on `ttl` field for automatic cleanup.

---

### 4. `bookings/{bookingId}` (Global Collection)

Confirmed or pending bookings.

```typescript
{
  proId: string,                // PRO providing the service
  userId: string,               // User who booked
  start: Timestamp,             // Booking start time (UTC)
  end: Timestamp,               // Booking end time (UTC)
  status: "pending" | "confirmed" | "cancelled",
  serviceName: string,
  price: number,
  appFee: number,
  totalPaid: number,
  paymentIntentId?: string,
  createdAt: Timestamp
}
```

---

## 🔄 Availability Algorithm

### Steps

1. **Load Calendar**: Fetch `calendars/{proId}` for `stepMin`, `timezone`, and `weeklySchedule`
2. **Load Exceptions**: Query `calendars/{proId}/exceptions/{date}` for the date range
3. **Generate Base Slots**:
   - For each day in range:
     - If exception exists with `closed=true` → No slots
     - If exception has `intervals` → Use those instead of weekly
     - Otherwise → Use `weeklySchedule[dayOfWeek]`
   - Generate slots using `stepMin` within each interval
4. **Load Active Bookings**: Query `bookings` where:
   - `proId == {proId}`
   - `status IN ['pending', 'confirmed']`
   - `start <= rangeEnd` AND `end >= rangeStart`
5. **Load Active Locks**: Query `calendars/*/locks` where:
   - `ttl > now()`
   - `slotStart <= rangeEnd`
   - Filter by `proId` match
6. **Filter Conflicts**: Remove slots that overlap with bookings or locks

---

## 🛠️ API Endpoints

### GET `/api/pros/:id/availability`

**Query Parameters**:
- `from`: YYYY-MM-DD (default: today)
- `to`: YYYY-MM-DD (default: today + 7 days)
- Max range: 14 days

**Response**:
```json
{
  "ok": true,
  "proId": "pro123",
  "from": "2025-11-20",
  "to": "2025-11-27",
  "timezone": "Europe/Rome",
  "days": [
    {
      "date": "2025-11-20",
      "stepMin": 30,
      "slots": [
        { "start": "2025-11-20T08:00:00.000Z", "end": "2025-11-20T08:30:00.000Z" },
        { "start": "2025-11-20T08:30:00.000Z", "end": "2025-11-20T09:00:00.000Z" }
      ]
    }
  ]
}
```

---

## 🔒 Slot Locking Flow

### 1. User Selects Slot

```http
POST /api/bookings/hold
Authorization: Bearer {token}

{
  "proId": "pro123",
  "dateISO": "2025-11-20",
  "start": "10:00",
  "end": "10:30"
}
```

**Response**:
- `200 OK` - Slot locked for 5 minutes
- `409 Conflict` - Slot already held by another user

### 2. User Completes Booking

```http
POST /api/bookings

{
  "proId": "pro123",
  "date": "2025-11-20",
  "timeStart": "10:00",
  "timeEnd": "10:30",
  ...
}
```

### 3. Payment Confirmation

Stripe webhook → Booking status: `confirmed` → Lock automatically expires

### 4. Lock Cleanup

- **Automatic**: Firestore TTL policy on `ttl` field
- **Manual**: `POST /api/admin/cleanup-locks` (admin only)
- **Scheduled**: Cloud Function every 5 minutes

---

## 📊 Firestore Indexes Required

```json
{
  "indexes": [
    {
      "collectionGroup": "bookings",
      "fields": [
        { "fieldPath": "proId", "order": "ASCENDING" },
        { "fieldPath": "start", "order": "ASCENDING" },
        { "fieldPath": "end", "order": "ASCENDING" }
      ]
    },
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

---

## 🎯 Best Practices

### For PROs

1. **Set Realistic `stepMin`**: 15-60 minutes depending on service type
2. **Use Exceptions Sparingly**: Only for holidays or special events
3. **Monitor Locks**: Check admin dashboard for stuck locks

### For Developers

1. **Always Use UTC**: Convert to PRO timezone only for display
2. **Handle Timezone Edge Cases**: DST transitions, international clients
3. **Implement Retry Logic**: For lock conflicts (409 errors)
4. **Enable TTL Policy**: Set Firestore TTL on `locks.ttl` field

### For System Admins

1. **Monitor Lock Count**: Alert if > 1000 active locks
2. **Scheduled Cleanup**: Run cleanup job every 5-10 minutes
3. **Index Monitoring**: Watch for "missing index" errors in logs

---

## 🚀 Migration from Old Schema

If migrating from an older calendar structure:

1. Rename `weekly` → `weeklySchedule`
2. Move exceptions to subcollection: `calendars/{proId}/exceptions/{date}`
3. Update lock documents to use `slotStart`/`slotEnd` (Timestamp)
4. Enable Firestore TTL policy on `locks.ttl`
5. Update all API clients to use new `/api/pros/:id/availability` endpoint

---

## 📝 Notes

- **Slot Contiguity**: Two slots are NOT considered overlapping if one ends exactly when another starts
- **Timezone Handling**: All calculations use Luxon library with explicit timezone conversion
- **Performance**: Availability endpoint optimized for <500ms response time
- **Scalability**: Supports 1000+ PROs with 10000+ bookings/day

---

## 📞 Support

For questions about calendar implementation:
- Backend: `backend/src/routes/availability.routes.ts`
- Service: `backend/src/services/booking.service.ts`
- Cleanup: `backend/src/services/cleanup.service.ts`
