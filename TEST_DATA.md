# MY PET CARE - Test Data Setup

Dati di esempio per popolare Firestore e testare l'applicazione.

## 📊 Creazione Dati Test

### Opzione 1: Script Automatico (Consigliato)

Crea uno script Python per popolare il database:

```python
# scripts/populate_test_data.py
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta

# Inizializza Firebase Admin
cred = credentials.Certificate('path/to/serviceAccountKey.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

# 1. Crea utente PRO test
test_pro_uid = 'test_pro_001'
db.collection('users').document(test_pro_uid).set({
    'role': 'pro',
    'name': 'Dr. Mario Rossi',
    'email': 'pro@test.com',
    'emailVerified': True,
    'createdAt': firestore.SERVER_TIMESTAMP
})

# 2. Crea profilo PRO
db.collection('pros').document(test_pro_uid).set({
    'bio': 'Veterinario con 15 anni di esperienza. Specializzato in medicina interna e chirurgia.',
    'categories': ['veterinario'],
    'kyc': {
        'piva': '12345678901',
        'albo': 'OMV-12345',
        'iban': 'IT60X0542811101000000123456'
    },
    'payout': {
        'stripeId': 'acct_test_...',  # Da configurare
        'paypalId': None
    },
    'location': {
        'lat': 41.9028,
        'lng': 12.4964,
        'address': 'Via Roma 123, Roma, RM'
    },
    'radiusKm': 15.0,
    'visible': True,
    'rating': 4.8,
    'reviewCount': 127
})

# 3. Crea servizi
services = [
    {
        'proId': test_pro_uid,
        'category': 'veterinario',
        'title': 'Visita Generale',
        'description': 'Controllo completo dello stato di salute del vostro animale',
        'durationMin': 30,
        'priceCents': 5000,  # €50
        'type': 'inPerson',
        'active': True
    },
    {
        'proId': test_pro_uid,
        'category': 'veterinario',
        'title': 'Consulenza Online',
        'description': 'Videoconsulto per piccoli problemi o dubbi',
        'durationMin': 15,
        'priceCents': 2500,  # €25
        'type': 'online',
        'active': True
    },
    {
        'proId': test_pro_uid,
        'category': 'veterinario',
        'title': 'Vaccinazione',
        'description': 'Somministrazione vaccini obbligatori e facoltativi',
        'durationMin': 15,
        'priceCents': 3500,  # €35
        'type': 'inPerson',
        'active': True
    }
]

for service in services:
    db.collection('services').add(service)

# 4. Crea utente Owner test
test_owner_uid = 'test_owner_001'
db.collection('users').document(test_owner_uid).set({
    'role': 'owner',
    'name': 'Laura Bianchi',
    'email': 'owner@test.com',
    'emailVerified': True,
    'createdAt': firestore.SERVER_TIMESTAMP
})

# 5. Crea pet
db.collection('pets').add({
    'ownerId': test_owner_uid,
    'name': 'Luna',
    'species': 'cane',
    'breed': 'Golden Retriever',
    'weight': 28.5,
    'birthDate': datetime(2020, 3, 15),
    'allergies': 'Nessuna allergia nota',
    'vaccines': 'Tutti i vaccini obbligatori aggiornati',
    'notes': 'Molto socievole e giocherellona',
    'photoUrl': None,
    'createdAt': firestore.SERVER_TIMESTAMP
})

# 6. Crea subscription PRO attiva
db.collection('subscriptions').document(test_pro_uid).set({
    'planId': 'monthly',
    'provider': 'stripe',
    'status': 'active',
    'currentPeriodEnd': datetime.now() + timedelta(days=30),
    'freeUntil': None,
    'lastUpdated': firestore.SERVER_TIMESTAMP,
    'stripeSubscriptionId': 'sub_test_...'
})

# 7. Crea coupon PRO
pro_coupons = [
    {'code': 'FREE-1M', 'months': 1},
    {'code': 'FREE-3M', 'months': 3},
    {'code': 'FREE-12M', 'months': 12}
]

for coupon in pro_coupons:
    db.collection('pro_coupons').document(coupon['code']).set({
        'code': coupon['code'],
        'months': coupon['months'],
        'active': True,
        'validFrom': firestore.SERVER_TIMESTAMP,
        'validTo': datetime(2099, 12, 31),
        'maxRedemptions': None,
        'maxPerPro': 1,
        'notes': f"Coupon {coupon['months']} mesi gratis - Test",
        'createdBy': 'admin_test',
        'createdAt': firestore.SERVER_TIMESTAMP
    })

print("✅ Test data created successfully!")
```

### Opzione 2: Manuale via Firebase Console

#### 1. Utente PRO

**Collection**: `users/test_pro_001`
```json
{
  "role": "pro",
  "name": "Dr. Mario Rossi",
  "email": "pro@test.com",
  "emailVerified": true,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

**Collection**: `pros/test_pro_001`
```json
{
  "bio": "Veterinario con 15 anni di esperienza",
  "categories": ["veterinario"],
  "kyc": {
    "piva": "12345678901",
    "albo": "OMV-12345",
    "iban": "IT60X0542811101000000123456"
  },
  "payout": {
    "stripeId": "acct_test_...",
    "paypalId": null
  },
  "location": {
    "lat": 41.9028,
    "lng": 12.4964,
    "address": "Via Roma 123, Roma, RM"
  },
  "radiusKm": 15.0,
  "visible": true,
  "rating": 4.8,
  "reviewCount": 127
}
```

#### 2. Servizi

**Collection**: `services`
```json
[
  {
    "proId": "test_pro_001",
    "category": "veterinario",
    "title": "Visita Generale",
    "description": "Controllo completo dello stato di salute",
    "durationMin": 30,
    "priceCents": 5000,
    "type": "inPerson",
    "active": true
  },
  {
    "proId": "test_pro_001",
    "category": "veterinario",
    "title": "Consulenza Online",
    "description": "Videoconsulto per piccoli problemi",
    "durationMin": 15,
    "priceCents": 2500,
    "type": "online",
    "active": true
  }
]
```

#### 3. Subscription Attiva

**Collection**: `subscriptions/test_pro_001`
```json
{
  "planId": "monthly",
  "provider": "stripe",
  "status": "active",
  "currentPeriodEnd": "2024-12-31T23:59:59Z",
  "freeUntil": null,
  "lastUpdated": "2024-01-01T00:00:00Z"
}
```

#### 4. Coupon PRO

**Collection**: `pro_coupons`
```json
{
  "FREE-1M": {
    "code": "FREE-1M",
    "months": 1,
    "active": true,
    "validFrom": "2024-01-01T00:00:00Z",
    "validTo": "2099-12-31T23:59:59Z",
    "maxRedemptions": null,
    "maxPerPro": 1,
    "notes": "1 mese gratis",
    "createdBy": "admin",
    "createdAt": "2024-01-01T00:00:00Z"
  },
  "FREE-3M": {
    "code": "FREE-3M",
    "months": 3,
    "active": true,
    "validFrom": "2024-01-01T00:00:00Z",
    "validTo": "2099-12-31T23:59:59Z",
    "maxRedemptions": null,
    "maxPerPro": 1,
    "notes": "3 mesi gratis",
    "createdBy": "admin",
    "createdAt": "2024-01-01T00:00:00Z"
  },
  "FREE-12M": {
    "code": "FREE-12M",
    "months": 12,
    "active": true,
    "validFrom": "2024-01-01T00:00:00Z",
    "validTo": "2099-12-31T23:59:59Z",
    "maxRedemptions": null,
    "maxPerPro": 1,
    "notes": "12 mesi gratis",
    "createdBy": "admin",
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

---

## 🧪 Test Cards Stripe

Per testare pagamenti in modalità test:

### Carte che funzionano
- **Visa**: `4242 4242 4242 4242`
- **Mastercard**: `5555 5555 5555 4444`
- **American Express**: `3782 822463 10005`

### Dati aggiuntivi
- **Scadenza**: Qualsiasi data futura (es. 12/25)
- **CVC**: Qualsiasi 3 cifre (es. 123)
- **CAP**: Qualsiasi 5 cifre (es. 12345)

### Carte per test errori
- **Card declined**: `4000 0000 0000 0002`
- **Insufficient funds**: `4000 0000 0000 9995`
- **Expired card**: `4000 0000 0000 0069`

---

## 🎯 Coordinate Italiane di Test

Per testare la mappa con professionisti in diverse città:

```javascript
const testLocations = {
  roma: { lat: 41.9028, lng: 12.4964 },
  milano: { lat: 45.4642, lng: 9.1900 },
  napoli: { lat: 40.8518, lng: 14.2681 },
  torino: { lat: 45.0703, lng: 7.6869 },
  firenze: { lat: 43.7696, lng: 11.2558 },
  bologna: { lat: 44.4949, lng: 11.3426 },
  palermo: { lat: 38.1157, lng: 13.3615 },
  genova: { lat: 44.4056, lng: 8.9463 }
};
```

---

## 📧 Test Email Addresses

Per testare flow email:

- **Owner test**: `owner.test@mypetcare.it`
- **Pro test**: `pro.test@mypetcare.it`
- **Admin test**: `admin.test@mypetcare.it`

**Nota**: Usa servizi come [Mailtrap](https://mailtrap.io/) o [MailHog](https://github.com/mailhog/MailHog) per intercettare email in sviluppo.

---

## ✅ Checklist Test

Dopo aver creato i dati di test, verifica:

- [ ] Utente PRO appare sulla mappa
- [ ] Servizi visibili nella scheda PRO
- [ ] Subscription attiva permette operatività
- [ ] Coupon PRO possono essere applicati da admin
- [ ] Owner può creare booking
- [ ] PRO può accettare booking
- [ ] Sistema calcola correttamente fee piattaforma

---

**Tip**: Usa Firebase Emulator Suite per test locali senza toccare il database produzione!

```bash
firebase emulators:start
```
