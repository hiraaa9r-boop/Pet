# 🧪 MyPetCare - Test E2E Scenarios

**Comprehensive End-to-End Testing Guide for Production Release**

---

## 📋 Test Credentials

### **Copiaincolla Ready - Credenziali di Test**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧑‍💼 UTENTE PROPRIETARIO (Owner)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Email: owner.test+1@mypetcare.it
Password: Test!2345

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👨‍⚕️ PROFESSIONISTA PRO (Abbonato)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Email: pro.test+1@mypetcare.it
Password: Test!2345

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔧 ADMIN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Email: admin.test@mypetcare.it
Password: Test!2345

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💳 STRIPE TEST CARDS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Standard Success:
   4242 4242 4242 4242 | 12/34 | 123 | 00100

🔐 3DS Required:
   4000 0027 6000 3184 | 12/34 | 123 | 00100

❌ Insufficient Funds:
   4000 0000 0000 9995 | 12/34 | 123 | 00100

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💰 PAYPAL SANDBOX
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛒 Buyer Account:
   buyer-sbx@mypetcare.it | Sbxtest123!

🏢 Business Account:
   merchant-sbx@mypetcare.it | Sbxtest123!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎟️ COUPON CODES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FREE-1M  → 1 mese gratis
FREE-3M  → 3 mesi gratis
FREE-12M → 12 mesi gratis

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📅 SLOT CALENDARIO (PRO)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Data: Oggi+1
Orario: 09:00–13:00
Step: 30 minuti
Posti: 4 per slot

Servizi:
• "Visita base" → 30' | €35
• "Toelettatura small" → 60' | €50
```

---

## 🎯 Test Scenarios (Ordine Esecuzione)

### **1️⃣ Onboarding & Ruoli**

#### **Scenario 1.1: Signup Proprietario**
```
✅ AZIONI:
1. Apri app → Signup
2. Email: owner.test+1@mypetcare.it
3. Password: Test!2345
4. Conferma → Verifica email → Login

🎯 RISULTATO ATTESO:
✓ Ruolo: owner
✓ Profilo completabile (nome, pet, privacy OK)
✓ Accesso immediato senza paywall
✓ Può navigare su mappa e PRO listings
```

#### **Scenario 1.2: Signup PRO (Paywall Block)**
```
✅ AZIONI:
1. Signup PRO → pro.test+1@mypetcare.it
2. Verifica email → Login
3. Tenta di completare profilo PRO

🎯 RISULTATO ATTESO:
✓ Paywall attivo (richiesta sottoscrizione)
✓ Profilo PRO bloccato
✓ Messaggio: "Abbonati per sbloccare funzionalità PRO"
```

---

### **2️⃣ Abbonamento PRO (Stripe)**

#### **Scenario 2.1: Pagamento Stripe Standard**
```
✅ AZIONI:
1. Login come PRO
2. Paywall → "Abbonati ora"
3. Inserisci carta: 4242 4242 4242 4242
4. Scadenza: 12/34 | CVV: 123 | CAP: 00100
5. Conferma pagamento

🎯 RISULTATO ATTESO:
✓ Webhook: invoice.payment_succeeded
✓ Subscription status: active
✓ Ruolo PRO sbloccato
✓ Redirect a pagina profilo PRO
✓ Log backend: "User {uid} subscription activated"
```

#### **Scenario 2.2: Coupon FREE-1M**
```
✅ AZIONI:
1. Paywall → "Hai un codice promozionale?"
2. Inserisci: FREE-1M
3. Applica coupon
4. Conferma (no pagamento richiesto)

🎯 RISULTATO ATTESO:
✓ Trial/discount applicato (1 mese gratis)
✓ Zero addebito
✓ Webhook log: coupon applicato
✓ Profilo PRO sbloccato
```

---

### **3️⃣ Abbonamento PRO (PayPal)**

#### **Scenario 3.1: Pagamento PayPal**
```
✅ AZIONI:
1. Login come nuovo PRO
2. Paywall → "Paga con PayPal"
3. Login PayPal sandbox: buyer-sbx@mypetcare.it
4. Approva pagamento
5. Redirect alla return URL

🎯 RISULTATO ATTESO:
✓ Stato PayPal: APPROVED → ACTIVE
✓ Backend aggiorna pros/{id}
✓ Webhook: BILLING.SUBSCRIPTION.ACTIVATED
✓ Profilo PRO sbloccato
```

---

### **4️⃣ Setup Profilo PRO & Disponibilità**

#### **Scenario 4.1: Completa Profilo PRO**
```
✅ AZIONI:
1. Login come PRO abbonato
2. Completa profilo:
   - Nome: "Toelettatore Test"
   - Bio: "10 anni di esperienza"
   - Foto profilo
   - Specialità: Toelettatura, Bagno
3. Aggiungi servizi:
   - "Visita base" → 30' | €35
   - "Toelettatura small" → 60' | €50
4. Geo-pin su mappa (Sassari, Sardegna)
5. Salva profilo

🎯 RISULTATO ATTESO:
✓ pros/{id} aggiornato in Firestore
✓ Profilo visibile in ricerca pubblica
✓ Rating iniziale: 0.0 (no recensioni)
```

#### **Scenario 4.2: Crea Slot Calendario**
```
✅ AZIONI:
1. Profilo PRO → Calendario
2. Crea disponibilità:
   - Data: Domani (oggi+1)
   - Orario: 09:00–13:00
   - Step: 30 minuti
   - Posti: 4 per slot
3. Salva slot

🎯 RISULTATO ATTESO:
✓ calendars/{proId} creato/aggiornato
✓ 8 slot disponibili (09:00, 09:30, 10:00, ..., 12:30)
✓ Capacità: 4 posti per slot
✓ Slot visibili agli Owners
```

---

### **5️⃣ Ricerca & Filtro Mappa (Owner)**

#### **Scenario 5.1: Ricerca Geolocalizzata**
```
✅ AZIONI:
1. Login come Owner
2. Home → Mappa
3. Consenti geolocalizzazione
4. Filtra: "Toelettatori"
5. Radius: 20 km

🎯 RISULTATO ATTESO:
✓ Lista PRO ordinata per distanza
✓ Mappa con pin PRO vicini
✓ Distanza calcolata correttamente
✓ Radius filter funzionante
✓ PRO "Toelettatore Test" visibile
```

---

### **6️⃣ Booking & Pagamento (Stripe)**

#### **Scenario 6.1: Prenotazione con Stripe**
```
✅ AZIONI:
1. Owner seleziona PRO dalla mappa
2. Scegli servizio: "Visita base" (30' - €35)
3. Seleziona data/ora: domani 09:00
4. Conferma prenotazione
5. Pagamento Stripe: 4242 4242 4242 4242
6. Conferma pagamento

🎯 RISULTATO ATTESO:
✓ bookings/{id} status=confirmed
✓ Webhook: payment_intent.succeeded
✓ Notifica FCM a Owner & PRO
✓ Receipt URL attivo (Stripe dashboard)
✓ Slot calendario aggiornato (posti disponibili: 3/4)
```

---

### **7️⃣ Booking con PayPal**

#### **Scenario 7.1: Prenotazione con PayPal**
```
✅ AZIONI:
1. Owner → nuovo booking
2. Servizio: "Toelettatura small" (60' - €50)
3. Data/ora: domani 10:00
4. Pagamento: "Paga con PayPal"
5. Login PayPal sandbox → Approva

🎯 RISULTATO ATTESO:
✓ Stato PayPal: COMPLETED
✓ Booking confermato
✓ Webhook PayPal: PAYMENT.SALE.COMPLETED
✓ Receipt URL attivo
```

---

### **8️⃣ Coupon in Booking**

#### **Scenario 8.1: Applica Coupon**
```
✅ AZIONI:
1. PRO nuovo applica FREE-1M
2. PRO crea slot calendario
3. Owner prenota servizio
4. Applica coupon (se policy consente)

🎯 RISULTATO ATTESO:
✓ Prezzo scontato o €0
✓ Receipt generata
✓ Webhook log discount
```

---

### **9️⃣ Cancellazione & Penali**

#### **Scenario 9.1: Cancellazione >24h (No Penale)**
```
✅ AZIONI:
1. Owner ha booking tra 48h
2. Booking details → "Cancella prenotazione"
3. Conferma cancellazione

🎯 RISULTATO ATTESO:
✓ status=cancelled
✓ Nessuna penale applicata
✓ Rimborso completo (Stripe/PayPal)
✓ Slot torna disponibile
✓ Notifica FCM a PRO
```

#### **Scenario 9.2: Cancellazione <24h (Penale 50%)**
```
✅ AZIONI:
1. Owner ha booking tra 12h
2. Tenta cancellazione

🎯 RISULTATO ATTESO:
✓ Alert: "Penale 50% applicabile"
✓ Conferma → status=cancelled_with_fee
✓ Addebito penale (€17.50 per Visita base)
✓ Stripe capture separato o partial refund
```

---

### **🔟 No-Show & Controversie**

#### **Scenario 10.1: Marca No-Show**
```
✅ AZIONI:
1. Booking passa orario appuntamento
2. PRO dashboard → Marca "No-Show"
3. Conferma

🎯 RISULTATO ATTESO:
✓ status=no_show
✓ Penale applicata secondo policy
✓ Log audit completo
✓ Notifica a Owner
```

---

### **1️⃣1️⃣ Ricevute & Documenti Fiscali**

#### **Scenario 11.1: Verifica Receipt**
```
✅ AZIONI:
1. Owner → My Bookings
2. Booking completato → Dettagli
3. Click "Vedi ricevuta"

🎯 RISULTATO ATTESO:
✓ Link Stripe/PayPal attivo
✓ Receipt PDF scaricabile
✓ Metadati servizio corretti
✓ IVA 22% applicata
```

---

### **1️⃣2️⃣ Notifiche Push & Email**

#### **Scenario 12.1: Notifiche FCM**
```
✅ TEST:
1. Conferma booking → Notifica immediata
2. Reminder T-24h → Notifica programmata
3. Cancellazione → Notifica istantanea

🎯 RISULTATO ATTESO:
✓ FCM foreground: toast in-app
✓ FCM background: system notification
✓ Deep link navigation corretta
✓ Email transactional recap OK
```

---

### **1️⃣3️⃣ Sicurezza & Accessi**

#### **Scenario 13.1: Tentativo Modifica Non Autorizzata**
```
✅ TEST:
1. Owner tenta modificare booking di altro utente
2. API client: UPDATE bookings/{altrui}

🎯 RISULTATO ATTESO:
✓ 403 Forbidden
✓ Firestore rules bloccano
✓ Log sicurezza registrato
✓ Alert admin (se configurato)
```

---

### **1️⃣4️⃣ Admin: Rimborsi & Sospensione**

#### **Scenario 14.1: Refund Manuale**
```
✅ AZIONI:
1. Admin login
2. Console → Payments
3. Seleziona booking → "Rimborsa"
4. Conferma refund Stripe

🎯 RISULTATO ATTESO:
✓ Webhook: charge.refunded
✓ booking status=refunded
✓ Notifica a Owner
✓ Log audit completo
```

#### **Scenario 14.2: Disabilita PRO**
```
✅ AZIONI:
1. Admin → Users → PRO target
2. "Sospendi abbonamento"
3. Conferma

🎯 RISULTATO ATTESO:
✓ Paywall attivo di nuovo
✓ Prenotazioni future bloccate
✓ PRO non visibile in ricerca
```

---

### **1️⃣5️⃣ Performance & Crash**

#### **Scenario 15.1: Performance Test**
```
✅ TEST:
1. Apri mappa con 20+ PRO
2. Scroll lista veloce
3. Crea booking
4. Naviga tra 10+ pagine

🎯 RISULTATO ATTESO:
✓ Nessun frame drop > 100ms
✓ Smooth animations 60fps
✓ 0 crash su Crashlytics
✓ Memory usage < 150MB
```

---

## ✅ Criteri di Accettazione (Go/No-Go)

### **🔴 BLOCKER (NO-GO se presente)**
- ❌ Crash blocker nelle ultime 24h
- ❌ Tasso successo pagamento < 98%
- ❌ Webhook success rate < 99%
- ❌ Notifiche recap > 5s
- ❌ Violazioni Firestore rules

### **🟢 PERFORMANCE REQUIREMENTS (GO)**
- ✅ 0 crash blocker 24h
- ✅ Tasso successo pagamento ≥ 98%
- ✅ Webhook success rate ≥ 99%
- ✅ Notifiche < 5s
- ✅ Signup → first booking ≥ 60%

---

## 📊 KPI Funnel (Target Metriche)

```
Signup completed:       100 users
  ↓
Email verified:         95 users  (95%)
  ↓
First booking:          60 users  (60%)
  ↓
Payment success:        59 users  (98%)
  ↓
Booking completed:      57 users  (95%)
```

---

## 🛡️ Monitoraggio Post-Rilascio (Prime 72h)

### **Dashboard Eventi Obbligatori:**
- `signup_completed`
- `subscription_started`
- `booking_created`
- `booking_cancelled`
- `refund_issued`
- `payment_failed`
- `notification_sent`

### **Alert Automatici:**
```yaml
HTTP Errors ≥400 > 1%:
  → Alert immediato team dev

Crashlytics nuovi issues:
  → Hotfix +1 build

Stripe Radar false positive:
  → Tuning parametri

Webhook failure > 1%:
  → Check Cloud Functions logs
```

---

## 🚀 Supporto Clienti

```
📧 Email: help@mypetcare.it
💬 In-app chat: Pagina supporto
📞 Telefono: Opzionale (business plan)

SLA: 4h risposta (business hours)
```

---

**🎉 MyPetCare è production-ready quando TUTTI gli scenari sopra sono PASSED! 🐾**
