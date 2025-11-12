# MY PET CARE - Admin Panel Specification

Specifica completa per il pannello di amministrazione.

## 🎯 Overview

Il pannello Admin permette di gestire:
- Professionisti (verifica KYC, toggle visibilità)
- Coupon PRO (CRUD + applicazione)
- Prenotazioni (view, rimborsi, penali)
- Impostazioni sistema (fee %, email templates)

---

## 🛠️ Tecnologie Consigliate

### Opzione 1: Flutter Web (Consigliato)
**Pro**: 
- Codice condiviso con app mobile
- Stesso stack tecnologico
- Deploy facile su Firebase Hosting

**Con**: 
- Richiede Firebase hosting

### Opzione 2: Next.js + React
**Pro**: 
- Ottimo per dashboard
- Vercel deploy gratuito
- Server-side rendering

**Con**: 
- Stack diverso da app principale

---

## 📊 Dashboard Home

### KPI Cards
```
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ Utenti Totali   │ │ PRO Attivi      │ │ Prenotazioni    │ │ Revenue Mensile │
│     1,234       │ │      156        │ │      89         │ │   €12,450       │
│   (+12% ↑)     │ │   (+8% ↑)      │ │   (+15% ↑)     │ │   (+22% ↑)     │
└─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘
```

### Charts
- **Registrazioni Ultimi 30 Giorni**: Line chart
- **Prenotazioni per Categoria**: Pie chart
- **Revenue Trend**: Bar chart mensile

---

## 👥 Gestione Professionisti

### Lista PRO

**Tabella Columns**:
| Nome | Email | Categorie | Status Abb. | Visible | KYC | Azioni |
|------|-------|-----------|-------------|---------|-----|--------|
| Dr. Mario Rossi | mario@email.com | Veterinario | ✅ Attivo | ✅ | ✅ | [Dettagli] [Toggle] |
| Laura Verdi | laura@email.com | Toelettatore | ⚠️ Scaduto | ❌ | ⏳ | [Dettagli] [Toggle] |

**Filtri**:
- Status abbonamento (Attivo / Scaduto / Mai attivato)
- Categoria
- KYC status (Verificato / Pending / Mancante)
- Visibilità (Visibile / Nascosto)

**Azioni Rapide**:
- ✅ **Toggle Visible**: ON/OFF con conferma
- 📧 **Invia Email**: Template predefiniti
- 🎟️ **Applica Coupon**: Modal per selezionare coupon

### Dettaglio PRO

**Tabs**:

#### 1. Info Generali
```
Nome: Dr. Mario Rossi
Email: mario.rossi@email.com
Telefono: +39 333 1234567
Bio: [text area con 500 caratteri bio]
Categorie: [x] Veterinario [ ] Toelettatore [ ] Pet Sitter
Location: Via Roma 123, Milano (MI) [Map preview]
Raggio operativo: [15] km
```

#### 2. KYC
```
P.IVA: 12345678901          [Verifica] [✅ Verificata]
Albo professionale: OMV-123 [Verifica] [⏳ In attesa]
IBAN: IT60X...123456        [Verifica] [✅ Verificato]
Documenti: [Visualizza] [Download]

[Button: Approva KYC Completo]
```

#### 3. Abbonamento
```
Status: ✅ Attivo
Piano: PRO Mensile (€29/mese)
Provider: Stripe
Prossimo Rinnovo: 15 Gen 2025
Stripe Customer ID: cus_...
Subscription ID: sub_...

Cronologia Pagamenti:
- 15 Dic 2024: €29 ✅ Pagato
- 15 Nov 2024: €29 ✅ Pagato
- 15 Ott 2024: €29 ✅ Pagato

[Button: Annulla Abbonamento]
[Button: Applica Coupon Gratis]
```

#### 4. Servizi
Lista servizi offerti dal PRO con prezzi e durate.

#### 5. Prenotazioni
Storico prenotazioni ricevute dal PRO.

#### 6. Recensioni
Recensioni ricevute con rating medio.

---

## 🎟️ Gestione Coupon PRO

### Lista Coupon

**Tabella**:
| Codice | Mesi Gratis | Attivo | Valido da | Valido a | Max Usi | Usati | Azioni |
|--------|-------------|--------|-----------|----------|---------|-------|--------|
| FREE-1M | 1 | ✅ | 01/01/24 | 31/12/99 | ∞ | 42 | [Edit] [Delete] |
| FREE-3M | 3 | ✅ | 01/01/24 | 31/12/99 | ∞ | 18 | [Edit] [Delete] |
| PROMO2024 | 3 | ✅ | 01/06/24 | 31/12/24 | 100 | 67 | [Edit] [Delete] |

**Filtri**:
- Status (Attivo / Disattivo)
- Valido (Valido ora / Scaduto / Futuro)

### Crea/Modifica Coupon

**Form**:
```
┌─────────────────────────────────────────┐
│ Codice Coupon                           │
│ [FREE-6M_______________] (UPPERCASE)    │
│                                         │
│ Mesi Gratuiti                           │
│ ( ) 1 mese                              │
│ ( ) 3 mesi                              │
│ ( ) 12 mesi                             │
│ (•) Custom: [6] mesi                    │
│                                         │
│ Stato                                   │
│ [x] Attivo                              │
│                                         │
│ Validità                                │
│ Da: [01/06/2024]  A: [31/12/2024]      │
│                                         │
│ Limiti Utilizzo                         │
│ Max usi globali: [100] (lascia vuoto = ∞)│
│ Max per PRO: [1]                        │
│                                         │
│ Note Interne                            │
│ [Coupon promozionale estate 2024___]    │
│                                         │
│         [Annulla]  [Salva Coupon]       │
└─────────────────────────────────────────┘
```

### Applica Coupon a PRO

**Modal**:
```
┌─────────────────────────────────────────┐
│  Applica Coupon PRO                     │
├─────────────────────────────────────────┤
│                                         │
│ Seleziona PRO                           │
│ [Search: Nome o Email...___________] 🔍│
│                                         │
│ Risultati:                              │
│ ┌───────────────────────────────────┐  │
│ │ • Dr. Mario Rossi                 │  │
│ │   mario.rossi@email.com           │  │
│ │   Status: ⚠️ Abbonamento scaduto  │  │
│ └───────────────────────────────────┘  │
│                                         │
│ Seleziona Coupon                        │
│ [Dropdown: FREE-1M ▼]                  │
│   - FREE-1M (1 mese)                   │
│   - FREE-3M (3 mesi)                   │
│   - FREE-12M (12 mesi)                 │
│   - PROMO2024 (3 mesi)                 │
│                                         │
│ Anteprima:                              │
│ ┌───────────────────────────────────┐  │
│ │ Mesi gratuiti: 1                  │  │
│ │ Valido fino: 15 Gen 2025          │  │
│ │ PRO diventerà visibile            │  │
│ └───────────────────────────────────┘  │
│                                         │
│      [Annulla]  [Applica Coupon]        │
└─────────────────────────────────────────┘
```

**Conferma**:
```
✅ Coupon FREE-1M applicato con successo!
   PRO: Dr. Mario Rossi
   Gratis fino: 15 Gen 2025
   Profilo ora visibile sulla mappa
```

---

## 📅 Gestione Prenotazioni

### Lista Prenotazioni

**Tabella**:
| ID | Data/Ora | Owner | PRO | Servizio | Status | Importo | Azioni |
|----|----------|-------|-----|----------|--------|---------|--------|
| #1234 | 20 Gen 15:00 | Laura B. | Dr. Rossi | Visita | ✅ Completata | €50 | [Dettagli] |
| #1235 | 22 Gen 10:30 | Marco V. | Dr. Rossi | Vaccinazione | 📅 Accettata | €35 | [Dettagli] [Annulla] |
| #1236 | 25 Gen 16:00 | Sara T. | Laura V. | Toelettatura | ⏳ Pending | €40 | [Dettagli] |

**Filtri**:
- Status (Tutti / Pending / Accettata / Completata / Cancellata)
- Data (Oggi / Questa settimana / Questo mese / Custom)
- PRO (select)
- Categoria servizio

### Dettaglio Prenotazione

```
Prenotazione #1235

Status: 📅 Accettata
Data/Ora: 22 Gennaio 2025, 10:30 - 11:00 (30 min)

OWNER:
- Nome: Marco Verdi
- Email: marco.verdi@email.com
- Pet: Fido (Cane, Golden Retriever, 3 anni)

PRO:
- Nome: Dr. Mario Rossi
- Categoria: Veterinario
- Location: Via Roma 123, Milano

SERVIZIO:
- Titolo: Vaccinazione
- Descrizione: Somministrazione vaccini obbligatori
- Prezzo: €35.00
- Durata: 30 minuti
- Modalità: In persona

PAGAMENTO:
- Provider: Stripe
- Intent ID: pi_xxxxxxxxxxxxx
- Importo totale: €35.00
- Fee piattaforma (5%): €1.75
- Importo PRO: €33.25
- Status: ✅ Pagato (captured 21 Gen 10:45)

POLITICHE:
- Cancellazione entro: 24h prima
- Penale cancellazione tardiva: 50%

AZIONI ADMIN:
[Rimborso Completo]  [Rimborso Parziale]  [Annulla Booking]
```

---

## ⚙️ Impostazioni Sistema

### General Settings

```
┌─────────────────────────────────────────┐
│ Fee Piattaforma                         │
│ [5___] %                                │
│ (Percentuale trattenuta su ogni booking)│
│                                         │
│ URL App                                 │
│ [https://app.mypetcare.it__________]   │
│                                         │
│ Email Assistenza                        │
│ [petcareassistenza@gmail.com_______]   │
│                                         │
│ Modalità Maintenance                    │
│ [ ] App in manutenzione                 │
│                                         │
│         [Annulla]  [Salva Modifiche]    │
└─────────────────────────────────────────┘
```

### Email Templates

**Lista Templates**:
- Verifica Email
- Richiesta Prenotazione (Owner)
- Nuova Richiesta (PRO)
- Prenotazione Accettata (Owner)
- Reminder 48h
- Ricevuta Pagamento
- Cancellazione
- Richiesta Recensione

**Editor Template**:
```
Template: Richiesta Prenotazione

Subject: [✓] Nuova richiesta di prenotazione - MY PET CARE

Variabili disponibili:
{{owner_name}}, {{pro_name}}, {{service_title}}, 
{{booking_date}}, {{booking_time}}, {{price}}

Body:
[Rich text editor con preview]

Ciao {{owner_name}},

La tua richiesta di prenotazione è stata inviata a {{pro_name}}.

Dettagli:
- Servizio: {{service_title}}
- Data: {{booking_date}} alle {{booking_time}}
- Prezzo: {{price}}

Riceverai una notifica appena il professionista accetterà.

Grazie per aver scelto MY PET CARE!

[Preview]  [Test Email]  [Salva Template]
```

### Stripe Configuration

```
API Keys:
- Publishable Key: pk_live_...  [Mostra] [Copia]
- Secret Key: sk_live_...******  [Mostra] [Copia]

Webhook:
- Endpoint URL: https://backend.../stripe/webhook
- Signing Secret: whsec_...******  [Mostra] [Copia]
- Status: ✅ Attivo
- Eventi: 8 configurati

Connect:
- Platform Account ID: acct_...
- Status: ✅ Attivo

[Test Connessione]  [Aggiorna Chiavi]
```

---

## 🔐 Autenticazione Admin

### Login

```
┌─────────────────────────────────────────┐
│                                         │
│         MY PET CARE - Admin             │
│                                         │
│  Email                                  │
│  [admin@mypetcare.it_______________]   │
│                                         │
│  Password                               │
│  [••••••••••••••_________________] 👁  │
│                                         │
│  [Ricordami] Password dimenticata?      │
│                                         │
│         [Accedi come Admin]             │
│                                         │
└─────────────────────────────────────────┘
```

**Requisiti**:
- User con role='admin' in Firestore
- Firebase Auth verificato
- Token JWT con claim admin=true

---

## 🎨 UI/UX Guidelines

### Colori
- **Primary**: `#0F6259` (brand teal)
- **Success**: `#388E3C`
- **Warning**: `#FFA726`
- **Error**: `#D32F2F`
- **Background**: `#F5F5F5`

### Typography
- **Headings**: Poppins SemiBold
- **Body**: Inter Regular
- **Mono**: Roboto Mono (per ID, codici)

### Icons
- Material Icons o Heroicons
- Consistenti con app mobile

### Responsive
- Desktop first (1280px+)
- Tablet (768px-1279px)
- Mobile fallback (<768px)

---

## 🚀 Deploy

### Firebase Hosting (Flutter Web)

```bash
cd admin
flutter build web --release
firebase deploy --only hosting:admin
```

### Vercel (Next.js)

```bash
cd admin
vercel --prod
```

---

## 🔒 Security

- ✅ Richiedi autenticazione admin per ogni route
- ✅ Valida role='admin' lato server (Cloud Functions)
- ✅ Rate limiting su API sensibili
- ✅ Audit log per azioni critiche (applica coupon, rimborsi)
- ✅ HTTPS only
- ✅ CSP headers

---

## 📊 Analytics

Traccia eventi:
- Admin login
- PRO verified
- Coupon created
- Coupon applied
- Booking refunded
- Settings changed

---

**Prossimi Step**: Implementare dashboard con framework scelto seguendo questa spec.
