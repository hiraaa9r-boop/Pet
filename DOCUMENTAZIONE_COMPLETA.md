# MY PET CARE - Documentazione Completa del Progetto

## 📋 Indice
1. [Panoramica del Progetto](#panoramica)
2. [Architettura del Sistema](#architettura)
3. [Stack Tecnologico](#stack)
4. [Schema Dati Firestore](#schema-dati)
5. [Regole di Sicurezza](#regole-sicurezza)
6. [Sistema di Abbonamenti PRO](#abbonamenti-pro)
7. [Sistema di Pagamenti](#pagamenti)
8. [Backend API](#backend-api)
9. [Job Schedulati](#job-schedulati)
10. [UI/UX Flow](#ui-flow)
11. [Pannello Admin](#pannello-admin)
12. [Deploy e CI/CD](#deploy)
13. [Checklist di Lancio](#checklist)

---

## 📱 Panoramica del Progetto

**MY PET CARE** è una piattaforma completa per la gestione di servizi veterinari e pet care che connette proprietari di animali con professionisti del settore.

### Caratteristiche Principali

- **Ruoli Utente**: Proprietario / Professionista (veterinario, toelettatore, pet sitter, educatore, allevatore, taxi, pensione)
- **Autenticazione**: Registrazione con verifica email obbligatoria
- **Abbonamenti PRO**: Richiesti per visibilità e operatività dei professionisti
  - €29/mese
  - €79/3 mesi
  - €299/anno
- **Coupon PRO**: FREE-1M, FREE-3M, FREE-12M (solo admin)
- **Prenotazioni**: Sistema di slot (15/30/60 minuti) con richiesta → accettazione
- **Pagamenti**: Capture T-24h con fee piattaforma 3-5%
- **Penale Cancellazione**: <24h → 50% di penale
- **Mappa Interattiva**: Visualizzazione professionisti con icone per categoria
- **Sistema Recensioni**: Post-servizio
- **Notifiche**: Push e email per ogni fase del processo

---

## 🏗️ Architettura del Sistema

```
┌─────────────────┐
│  Flutter App    │ ← Web/Android/iOS
│  (Material 3)   │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│   Firebase      │
│   - Auth        │
│   - Firestore   │
│   - Storage     │
│   - FCM         │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Cloud Run      │ ← Node.js/TypeScript Backend
│  - Pagamenti    │
│  - Webhook      │
│  - Coupon       │
│  - Job T-24h    │
└────────┬────────┘
         │
         ↓
┌─────────────────────────────┐
│  Stripe Connect Express     │
│  PayPal Commerce Platform   │
└─────────────────────────────┘
```

---

## 🛠️ Stack Tecnologico

### Frontend (Flutter)
- **Framework**: Flutter 3.35.4 (Material Design 3)
- **State Management**: Riverpod 2.5.1
- **Routing**: GoRouter 14.2.0
- **Maps**: Google Maps Flutter 2.7.0
- **Location**: Geolocator 12.0.0
- **Firebase**: 
  - firebase_core: 3.6.0
  - firebase_auth: 5.3.1
  - cloud_firestore: 5.4.3
  - firebase_storage: 12.3.2
  - firebase_messaging: 15.1.3

### Backend (Cloud Run)
- **Runtime**: Node.js/TypeScript
- **Framework**: Express
- **Database**: Firebase Firestore
- **Pagamenti**: 
  - Stripe SDK
  - PayPal Checkout SDK
- **Email**: SendGrid (con dominio personalizzato)

### Branding & Design
- **Colore Principale**: #0F6259 (Teal Green)
- **Font Titoli**: Poppins
- **Font Testo**: Inter
- **Iconografia**: Icone personalizzate per categorie professionisti

---

## 💾 Schema Dati Firestore

### 1. Collection: `users`
```typescript
{
  uid: string,
  role: 'owner' | 'pro' | 'admin',
  name: string,
  email: string,
  photoUrl?: string,
  emailVerified: boolean,
  createdAt: Timestamp
}
```

### 2. Collection: `pros`
```typescript
{
  uid: string,
  bio: string,
  categories: ProCategory[], // ['veterinario', 'toelettatore', ...]
  kyc: {
    piva?: string,
    albo?: string,
    iban?: string
  },
  payout: {
    stripeId?: string,
    paypalId?: string
  },
  location: {
    lat: number,
    lng: number,
    address: string
  },
  radiusKm: number,
  visible: boolean,
  rating?: number,
  reviewCount: number
}
```

### 3. Collection: `services`
```typescript
{
  id: string,
  proId: string,
  category: ProCategory,
  title: string,
  description: string,
  durationMin: 15 | 30 | 60,
  priceCents: number,
  type: 'online' | 'inPerson' | 'both',
  active: boolean
}
```

### 4. Collection: `bookings`
```typescript
{
  id: string,
  ownerId: string,
  proId: string,
  serviceId: string,
  petIds: string[],
  start: Timestamp,
  end: Timestamp,
  status: 'pending' | 'accepted' | 'paid' | 'completed' | 'cancelled' | 'paymentFailed',
  payment?: {
    provider: 'stripe' | 'paypal',
    intentId?: string,
    orderId?: string,
    appFeePct: number,
    couponCode?: string,
    discountCents?: number
  },
  policy: {
    cancelBeforeH: 24,
    penaltyPct: 50
  },
  createdAt: Timestamp,
  cancelledAt?: Timestamp,
  cancellationReason?: string
}
```

### 5. Collection: `pets`
```typescript
{
  id: string,
  ownerId: string,
  name: string,
  species: 'cane' | 'gatto' | 'altro',
  breed?: string,
  weight?: number,
  birthDate?: Timestamp,
  allergies?: string,
  vaccines?: string,
  notes?: string,
  photoUrl?: string,
  createdAt: Timestamp
}
```

### 6. Collection: `subscriptions`
```typescript
{
  proId: string,
  planId?: 'monthly' | 'quarterly' | 'annual',
  provider: 'stripe' | 'paypal',
  status: 'active' | 'inTrial' | 'pastDue' | 'canceled' | 'none',
  currentPeriodEnd?: Timestamp,
  freeUntil?: Timestamp, // Per coupon PRO
  lastUpdated: Timestamp,
  stripeSubscriptionId?: string,
  paypalSubscriptionId?: string
}
```

### 7. Collection: `pro_coupons`
```typescript
{
  code: string, // es. 'FREE-1M', 'FREE-3M', 'FREE-12M'
  months: 1 | 3 | 12,
  active: boolean,
  validFrom: Timestamp,
  validTo: Timestamp,
  maxRedemptions?: number,
  maxPerPro: number, // default: 1
  notes: string,
  createdBy: string, // admin uid
  createdAt: Timestamp
}
```

### 8. Collection: `reviews`
```typescript
{
  id: string,
  proId: string,
  ownerId: string,
  bookingId: string,
  rating: 1 | 2 | 3 | 4 | 5,
  text: string,
  photos: string[],
  createdAt: Timestamp
}
```

---

## 🔒 Regole di Sicurezza Firestore

Le regole di sicurezza sono definite in `firestore.rules`. Punti chiave:

- **Utenti**: Possono leggere/modificare solo i propri dati
- **Professionisti**: Visibili solo se `visible == true` o al proprietario
- **Prenotazioni**: Visibili solo a owner/pro coinvolti o admin
- **Abbonamenti**: Modificabili solo via backend
- **Coupon**: Gestione esclusiva admin via backend

---

## 💳 Sistema di Abbonamenti PRO

### Piani Disponibili
1. **PRO Mensile**: €29/mese
2. **PRO Trimestrale**: €79/3 mesi (risparmio ~11%)
3. **PRO Annuale**: €299/anno (risparmio ~16%)

### Coupon PRO (Admin Only)
- **FREE-1M**: 1 mese gratis
- **FREE-3M**: 3 mesi gratis
- **FREE-12M**: 12 mesi gratis

### Logica di Verifica Abbonamento

```typescript
async function isProActive(proId: string): Promise<boolean> {
  const sub = await firestore.collection('subscriptions').doc(proId).get();
  const data = sub.data();
  
  if (!data) return false;
  
  const now = Date.now();
  const freeUntil = data.freeUntil?.toMillis() ?? 0;
  const end = data.currentPeriodEnd?.toMillis() ?? 0;
  const status = data.status;
  
  return (freeUntil > now) || 
         ((status === 'active' || status === 'inTrial') && end > now);
}
```

### Guard PRO Bloccato

I professionisti senza abbonamento attivo:
- Non appaiono sulla mappa (`visible = false`)
- Vengono reindirizzati alla pagina `/pro/blocked`
- Non possono accettare prenotazioni

---

## 💰 Sistema di Pagamenti

### Provider Supportati
1. **Stripe Connect Express** (consigliato)
2. **PayPal Commerce Platform**

### Flusso di Pagamento

```
1. Owner crea booking (status: pending)
2. PRO accetta booking
   ↓
3. Backend crea PaymentIntent (capture_method: manual)
   - Amount: priceCents
   - Application Fee: 3-5% (configurabile)
   - Transfer to: PRO account
   ↓
4. Owner conferma pagamento (carta salvata o nuovo metodo)
   ↓
5. T-24h: Job automatico cattura il pagamento
   ↓
6. Booking status: paid → PRO riceve trasferimento
   ↓
7. Dopo servizio: Owner lascia recensione
```

### Politiche di Cancellazione

| Tempistica | Penale | Note |
|------------|--------|------|
| > 24h | 0% | Rimborso completo |
| < 24h | 50% | Penale 50% al PRO |
| No-show | 100% | Nessun rimborso |

### Coupon Checkout (Sconto Fee Piattaforma)

Opzionali, riducono la fee della piattaforma per l'owner:

```typescript
// Validazione coupon
POST /coupons/validate
{
  code: string,
  bookingId: string
}

// Response
{
  ok: true,
  discountCents: number // Sconto applicato alla app fee
}
```

---

## 🔧 Backend API (Cloud Run)

### Endpoints Principali

#### Autenticazione (Middleware)
```typescript
requireAuth(req, res, next) // Verifica JWT Firebase
requireAdmin(req, res, next) // Verifica ruolo admin
requireProActive(req, res, next) // Verifica abbonamento PRO attivo
```

#### Booking
```typescript
POST /bookings
// Crea nuova prenotazione (owner)
// Requires: proId, serviceId, start, end, petIds, policy

POST /bookings/:id/accept
// PRO accetta e crea PaymentIntent
// Requires: requireProActive
```

#### Coupon Checkout
```typescript
POST /coupons/validate
// Valida coupon e calcola sconto
// Requires: code, bookingId
```

#### Admin - Coupon PRO
```typescript
POST /admin/pro-coupons
// Crea/aggiorna coupon PRO
// Requires: requireAdmin

POST /admin/pro-coupons/apply
// Applica coupon a specifico PRO
// Requires: requireAdmin
// Body: { proId, code }
```

#### Webhook
```typescript
POST /stripe/webhook
// Gestisce eventi Stripe
// Events: payment_intent.*, subscription.*, charge.refunded
```

---

## ⏰ Job Schedulati (Cloud Scheduler)

### 1. Job Capture T-24h
**Frequenza**: Ogni ora  
**Endpoint**: `POST /jobs/capture`

```typescript
// Logica
- Trova bookings con status='accepted' e start <= now+24h
- Per ogni booking:
  - Cattura PaymentIntent (Stripe) o Order (PayPal)
  - Applica sconto coupon se presente
  - Aggiorna status a 'paid' o 'paymentFailed'
```

### 2. Job Subscription Sweeper
**Frequenza**: Ogni giorno alle 2:00 AM  
**Endpoint**: `POST /jobs/subscription-sweeper`

```typescript
// Logica
- Trova tutti i subscriptions
- Per ogni subscription:
  - Verifica se freeUntil > now O (status='active' AND currentPeriodEnd > now)
  - Se scaduto:
    - Set status='none'
    - Set pros.visible=false
```

---

## 🎨 UI/UX Flow

### 1. Mappa Interattiva (Homepage)

**Componenti**:
- GoogleMap con marker professionisti
- Filtri categoria (chip orizzontali)
- My Location button
- FAB "Prenotazioni"

**Icone Categoria** (assets/icons/):
- `veterinario.png`
- `toelettatore.png`
- `educatore-addestratore.png`
- `allevatore.png`
- `pensione-pet.png`
- `taxi.png`
- `pet-sitter.png`

### 2. Scheda Professionista (MioDottore-style)

**Sezioni**:
- Header: Foto, Nome, Rating, Badge "Consulenze online"
- CTA: "Prenota una visita"
- Tabs:
  - **Informazioni**: Bio, categorie, indirizzo
  - **Recensioni**: Lista recensioni con stelle
  - **Fotografie**: Gallery
- **Servizi**: Lista con prezzi e slot disponibili
- Mini-mappa con posizione

### 3. Flow Prenotazione

```
1. Selezione Servizio → Mostra slot disponibili
2. Selezione Pet(s) → Multi-select pet registrati
3. Conferma Dati → Review booking
4. Richiesta Inviata → Status: pending
   ↓
5. PRO Accetta → Notification + Email
   ↓
6. Checkout → Inserisci metodo pagamento
   ↓
7. T-24h → Capture automatica
   ↓
8. Post-Servizio → Richiesta recensione
```

### 4. Profilo Proprietario

**Sezioni**:
- Dati personali
- I miei Pet (card con foto, nome, specie, età)
- Le mie Prenotazioni
- Metodi di pagamento
- Impostazioni

### 5. Dashboard Professionista

**Sezioni**:
- Status Abbonamento (badge + data scadenza)
- Prenotazioni in arrivo
- Calendario disponibilità
- I miei Servizi
- Statistiche (guadagni, recensioni)
- KYC & Payout

**Guard Blocco**:
Se abbonamento scaduto → redirect `/pro/blocked` con:
- Messaggio "Abbonamento richiesto"
- Piani disponibili
- CTA "Attiva/Rinnova"

---

## 🛡️ Pannello Admin

### Dashboard
- **KPI**: Utenti totali, PRO attivi, Prenotazioni oggi, Revenue
- **Grafici**: Trend registrazioni, bookings, revenue

### Gestione Professionisti
- **Lista PRO**: Tabella con status abbonamento
- **Azioni**:
  - Verifica KYC (PIVA, Albo, IBAN)
  - Toggle visible
  - Applica Coupon PRO

### Coupon PRO

**Form Creazione**:
```
- Codice (UPPERCASE, es. PROMO-2024)
- Mesi gratuiti: [1] [3] [12]
- Attivo: [x]
- Valido dal: [date]
- Valido al: [date]
- Max usi globali: [number / unlimited]
- Max per PRO: [1] (default)
- Note: [textarea]
```

**Applica Coupon a PRO**:
```
Input:
- PRO ID (autocomplete search)
- Coupon Code (dropdown codici attivi)

Action:
POST /admin/pro-coupons/apply
→ Set freeUntil = now + months
→ Set status = 'inTrial'
→ Set visible = true
→ Log redemption
```

### Coupon Checkout (Opzionale)

**Form Creazione**:
```
- Codice
- Tipo: [percent | fixed]
- Valore: [number]
- Categorie applicabili: [multi-select]
- Valido dal/al
- Max usi
- Note
```

### Gestione Prenotazioni
- **Vista Tutte**: Filtri per status, date, PRO
- **Azioni**:
  - Rimborsi manuali
  - Applicazione penali
  - Cancellazioni admin

### Impostazioni Sistema
- **APP_FEE %**: Slider 0-10%
- **Email Templates**: Editor con variabili
- **Reply-to**: petcareassistenza@gmail.com
- **Notifiche Push**: Toggle abilitazione

---

## 🚀 Deploy e CI/CD

### Ambienti
1. **dev**: Testing interno
2. **stage**: Pre-produzione
3. **prod**: Produzione

### GitHub Actions Workflow

```yaml
name: Deploy MY PET CARE

on:
  push:
    branches: [main, dev, stage]

jobs:
  deploy-app:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.4'
      
      - name: Build Web
        run: flutter build web --release
      
      - name: Deploy to Firebase Hosting
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: YOUR_PROJECT_ID

  deploy-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build & Deploy Cloud Run
        run: |
          gcloud builds submit --tag gcr.io/$PROJECT_ID/backend
          gcloud run deploy backend \
            --image gcr.io/$PROJECT_ID/backend \
            --platform managed \
            --region europe-west1 \
            --allow-unauthenticated
```

### Cloud Run Deploy Commands

```bash
# Build
gcloud builds submit --tag gcr.io/PROJECT_ID/mypetcare-backend

# Deploy
gcloud run deploy mypetcare-backend \
  --image gcr.io/PROJECT_ID/mypetcare-backend \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated \
  --set-env-vars "
    STRIPE_KEY=sk_live_...,
    STRIPE_WEBHOOK_SECRET=whsec_...,
    APP_FEE_PCT=5,
    APP_URL=https://app.mypetcare.it,
    FIREBASE_PROJECT_ID=...,
    SENDGRID_API_KEY=...
  "
```

---

## ✅ Checklist di Lancio

### Pre-Lancio

- [ ] **Firebase Setup**
  - [ ] Progetto Firebase creato
  - [ ] Firestore database attivato
  - [ ] Authentication abilitato (Email/Password)
  - [ ] Storage configurato
  - [ ] FCM configurato

- [ ] **Stripe Setup**
  - [ ] Account Stripe Connect Express attivato
  - [ ] Prodotti creati (monthly, quarterly, annual)
  - [ ] Coupon PRO creati (FREE-1M, FREE-3M, FREE-12M)
  - [ ] Webhook configurato → Cloud Run endpoint

- [ ] **PayPal Setup**
  - [ ] Commerce Platform attivato
  - [ ] Piani configurati (opzionale)

- [ ] **Backend Deploy**
  - [ ] Cloud Run service deployato
  - [ ] Variabili ambiente configurate
  - [ ] Job schedulati (Capture T-24h, Sweeper)
  - [ ] Webhook testati

- [ ] **Email Setup**
  - [ ] SendGrid account creato
  - [ ] Dominio verificato
  - [ ] Template email creati
  - [ ] Reply-to: petcareassistenza@gmail.com

- [ ] **Flutter App**
  - [ ] Firebase configurato (google-services.json)
  - [ ] Google Maps API key attiva
  - [ ] Icone categoria presenti
  - [ ] App icon generata
  - [ ] Font Poppins/Inter installati

- [ ] **Testing**
  - [ ] Flow registrazione completo
  - [ ] Verifica email funzionante
  - [ ] Creazione PRO e abbonamento
  - [ ] Booking end-to-end
  - [ ] Pagamento Stripe/PayPal
  - [ ] Capture T-24h testata
  - [ ] Coupon PRO testati
  - [ ] Push notifications funzionanti

### Post-Lancio

- [ ] Monitoring attivo (Firebase Analytics, Cloud Monitoring)
- [ ] Backup database automatici
- [ ] Support email monitorato (petcareassistenza@gmail.com)
- [ ] Documentazione utente pubblicata
- [ ] Privacy Policy e Termini di Servizio pubblicati

---

## 📞 Supporto e Contatti

**Email Assistenza**: petcareassistenza@gmail.com  
**Ruolo**: Support e Reply-to per tutte le email automatiche

---

## 📝 Note Tecniche Aggiuntive

### Font Download Links
- **Poppins**: https://fonts.google.com/specimen/Poppins
- **Inter**: https://fonts.google.com/specimen/Inter

### Color Palette
```css
:root {
  --brand-primary: #0F6259;
  --brand-light: #14857A;
  --brand-dark: #0A4A43;
  --background: #F5F5F5;
  --card-bg: #FFFFFF;
  --text-primary: #212121;
  --text-secondary: #757575;
  --error: #D32F2F;
  --success: #388E3C;
  --warning: #FFA726;
}
```

### Firebase CLI Commands
```bash
# Deploy rules
firebase deploy --only firestore:rules

# Deploy indexes
firebase deploy --only firestore:indexes

# Deploy hosting
firebase deploy --only hosting
```

---

**Versione Documento**: 1.0  
**Data Ultimo Aggiornamento**: Novembre 2024  
**Autore**: MY PET CARE Development Team
