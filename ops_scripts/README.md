# 🛠️ MY PET CARE - Operational Scripts

Script operativi per configurazione e gestione del sistema MY PET CARE.

---

## 📋 Script Disponibili

### 1. `stripe_setup.ts` - Stripe Configuration Automation

Script automatico per creare Products, Prices e Promotion Codes su Stripe.

**Cosa Crea**:
- ✅ 3 **Subscription Products**: PRO Monthly, PRO Quarterly, PRO Annual
- ✅ 3 **Price Objects**: €29/mese, €79/3 mesi, €299/anno
- ✅ 3 **Coupons**: FREE-1M (100% off, 1 mese), FREE-3M (3 mesi), FREE-12M (12 mesi)
- ✅ 3 **Promotion Codes**: Codici promo da usare in Stripe Checkout

---

## 🚀 Utilizzo: stripe_setup.ts

### Prerequisiti

1. **Account Stripe**: Registra su https://dashboard.stripe.com/
2. **Secret Key**: Ottieni da Dashboard → Developers → API Keys
3. **Node.js 18+**: Installato sul sistema

### Setup Rapido (3 minuti)

```bash
# 1. Vai nella directory ops_scripts
cd ops_scripts/

# 2. Crea file .env con la tua Stripe Secret Key
echo "STRIPE_KEY=sk_test_..." > .env

# O per produzione:
echo "STRIPE_KEY=sk_live_..." > .env

# 3. Installa dipendenze (se necessario)
npm install stripe

# 4. Esegui lo script
node --env-file=.env stripe_setup.ts
```

### Output Atteso

```
🚀 MY PET CARE - Stripe Setup Script
====================================

📦 Creazione Products e Prices...

✅ Product creato: PRO Monthly
   Price ID: price_1ABC123DEF456GHI789
   Prezzo: €29.00/mese

✅ Product creato: PRO Quarterly
   Price ID: price_1JKL012MNO345PQR678
   Prezzo: €79.00/3 mesi

✅ Product creato: PRO Annual
   Price ID: price_1STU901VWX234YZA567
   Prezzo: €299.00/anno

🎫 Creazione Coupons e Promotion Codes...

✅ Coupon creato: FREE-1M
   ID: coupon_ABC123
   Sconto: 100% per 1 mese
   
✅ Coupon creato: FREE-3M
   ID: coupon_DEF456
   Sconto: 100% per 3 mesi
   
✅ Coupon creato: FREE-12M
   ID: coupon_GHI789
   Sconto: 100% per 12 mesi

✅ Promotion Code creato: FREE-1M
   ID: promo_1ABC123DEF
   Code: FREE-1M
   Restrictions: None
   
✅ Promotion Code creato: FREE-3M
   ID: promo_1GHI456JKL
   Code: FREE-3M
   Restrictions: None
   
✅ Promotion Code creato: FREE-12M
   ID: promo_1MNO789PQR
   Code: FREE-12M
   Restrictions: None

🎉 Setup completato con successo!

📋 Prossimi Passi:
1. Copia i Price ID sopra nel file backend/.env:
   STRIPE_PRICE_PRO_MONTHLY=price_1ABC123DEF456GHI789
   STRIPE_PRICE_PRO_QUARTERLY=price_1JKL012MNO345PQR678
   STRIPE_PRICE_PRO_ANNUAL=price_1STU901VWX234YZA567

2. (Opzionale) Copia i Promotion Code ID:
   STRIPE_PROMO_FREE_1M=promo_1ABC123DEF
   STRIPE_PROMO_FREE_3M=promo_1GHI456JKL
   STRIPE_PROMO_FREE_12M=promo_1MNO789PQR

3. Riavvia il backend per applicare le modifiche
```

---

## 🔧 Configurazione Backend

Dopo aver eseguito lo script, aggiorna il backend `.env`:

```bash
cd ../backend/

# Modifica .env
nano .env
```

**Aggiungi/Aggiorna queste righe** (sostituisci con gli ID effettivi):

```env
# === Stripe Subscription Configuration ===

# Price IDs (RICHIESTO - copia dall'output dello script)
STRIPE_PRICE_PRO_MONTHLY=price_1ABC123DEF456GHI789
STRIPE_PRICE_PRO_QUARTERLY=price_1JKL012MNO345PQR678
STRIPE_PRICE_PRO_ANNUAL=price_1STU901VWX234YZA567

# Promotion Code IDs (OPZIONALE - per attivazione automatica coupon)
STRIPE_PROMO_FREE_1M=promo_1ABC123DEF
STRIPE_PROMO_FREE_3M=promo_1GHI456JKL
STRIPE_PROMO_FREE_12M=promo_1MNO789PQR
```

**Riavvia il backend**:
```bash
npm run dev  # Per test locale
# O
gcloud run deploy ...  # Per produzione
```

---

## 🧪 Testing

### Test 1: Verifica Products su Stripe Dashboard

1. Vai su https://dashboard.stripe.com/products
2. Verifica la presenza di:
   - PRO Monthly (€29.00/month)
   - PRO Quarterly (€79.00/every 3 months)
   - PRO Annual (€299.00/year)

### Test 2: Verifica Coupons

1. Vai su https://dashboard.stripe.com/coupons
2. Verifica la presenza di:
   - FREE-1M (100% off, duration: repeating, duration_in_months: 1)
   - FREE-3M (100% off, duration: repeating, duration_in_months: 3)
   - FREE-12M (100% off, duration: repeating, duration_in_months: 12)

### Test 3: Verifica Promotion Codes

1. Vai su https://dashboard.stripe.com/coupons → Clicca su un coupon
2. Verifica la presenza dei Promotion Codes associati:
   - Code: FREE-1M (attivo)
   - Code: FREE-3M (attivo)
   - Code: FREE-12M (attivo)

### Test 4: Test Backend Endpoint

```bash
# Test creazione checkout session (richiede auth token Firebase)
curl -X POST http://localhost:8080/pro/subscribe \
  -H "Authorization: Bearer YOUR_FIREBASE_ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "plan": "monthly",
    "free": 0
  }'

# Response attesa:
# {"ok":true,"url":"https://checkout.stripe.com/c/pay/cs_test_..."}
```

### Test 5: Test Promotion Code Application

```bash
# Test checkout con coupon FREE-1M
curl -X POST http://localhost:8080/pro/subscribe \
  -H "Authorization: Bearer YOUR_FIREBASE_ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "plan": "monthly",
    "free": 1
  }'

# Il checkout URL dovrebbe applicare automaticamente il promo code
```

---

## 🔄 Re-esecuzione dello Script

Se devi ri-eseguire lo script (es. ambiente test → produzione):

### Opzione A: Usa Account Stripe Separato (Raccomandato)

```bash
# Test Environment
echo "STRIPE_KEY=sk_test_..." > .env.test
node --env-file=.env.test stripe_setup.ts

# Production Environment
echo "STRIPE_KEY=sk_live_..." > .env.prod
node --env-file=.env.prod stripe_setup.ts
```

### Opzione B: Cancella Prodotti Esistenti Manualmente

1. Vai su Stripe Dashboard
2. Products → Seleziona prodotto → Archive
3. Coupons → Seleziona coupon → Delete
4. Promotion Codes → Seleziona promo → Delete
5. Re-esegui script

**Nota**: Lo script crea nuovi oggetti ogni volta. Non sovrascrive quelli esistenti.

---

## 📊 Dettagli Tecnici

### Products Creati

| Nome | Prezzo | Intervallo | Price ID Format |
|------|--------|------------|-----------------|
| PRO Monthly | €29.00 | month | `price_xxx...` |
| PRO Quarterly | €79.00 | 3 months | `price_xxx...` |
| PRO Annual | €299.00 | year | `price_xxx...` |

### Coupons Creati

| Code | Discount | Duration | Duration Months | Restrictions |
|------|----------|----------|----------------|--------------|
| FREE-1M | 100% | repeating | 1 | None |
| FREE-3M | 100% | repeating | 3 | None |
| FREE-12M | 100% | repeating | 12 | None |

**Note**:
- `duration: repeating` significa che lo sconto si applica per N mesi consecutivi
- Dopo il periodo gratuito, il PRO paga il prezzo pieno automaticamente
- I coupon non hanno limiti di utilizzo totali (possono essere assegnati a infiniti PRO)

### Promotion Codes Creati

| Code | Coupon | Active | Max Redemptions | Expires |
|------|--------|--------|----------------|---------|
| FREE-1M | coupon_xxx | ✅ | Unlimited | Never |
| FREE-3M | coupon_xxx | ✅ | Unlimited | Never |
| FREE-12M | coupon_xxx | ✅ | Unlimited | Never |

**Restrictions**: Nessuna restrizione applicata (tutti i customer possono usarli)

---

## 🚨 Troubleshooting

### Errore: "Invalid API Key"

**Problema**: La Stripe Secret Key non è valida

**Fix**:
```bash
# Verifica che la key inizi con sk_test_ o sk_live_
cat .env

# Ottieni nuova key da Stripe Dashboard → Developers → API Keys
echo "STRIPE_KEY=sk_test_NEW_KEY" > .env
```

---

### Errore: "Product already exists"

**Problema**: Stai tentando di creare prodotti che già esistono

**Fix**: Lo script crea sempre nuovi prodotti. Se vuoi riutilizzare quelli esistenti:

```bash
# Opzione 1: Cancella prodotti esistenti su Stripe Dashboard
# Opzione 2: Modifica script per usare Product ID esistenti
# Opzione 3: Copia manualmente i Price ID da Stripe Dashboard → backend .env
```

---

### Errore: "node: command not found"

**Problema**: Node.js non installato

**Fix**:
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install nodejs npm

# macOS
brew install node

# Windows
# Scarica installer da https://nodejs.org/
```

---

### Errore: "Cannot find module 'stripe'"

**Problema**: Pacchetto Stripe non installato

**Fix**:
```bash
npm install stripe
```

---

## 📚 Riferimenti

### Documentazione Stripe
- **Products API**: https://stripe.com/docs/api/products
- **Prices API**: https://stripe.com/docs/api/prices
- **Coupons API**: https://stripe.com/docs/api/coupons
- **Promotion Codes API**: https://stripe.com/docs/api/promotion_codes
- **Subscriptions**: https://stripe.com/docs/billing/subscriptions/overview

### Documentazione MY PET CARE
- **Subscription Integration**: `../SUBSCRIPTION_INTEGRATION.md`
- **Quick Start**: `../QUICK_START.md`
- **Backend API**: `../backend/src/index.ts`
- **Setup Checklist**: `../SETUP_CHECKLIST.md`

---

## ✅ Checklist Post-Esecuzione

Dopo aver eseguito lo script con successo:

- [ ] Script eseguito senza errori
- [ ] Tutti gli ID copiati dall'output
- [ ] Backend `.env` aggiornato con Price IDs
- [ ] Backend `.env` aggiornato con Promo Code IDs (opzionale)
- [ ] Prodotti verificati su Stripe Dashboard
- [ ] Coupons verificati su Stripe Dashboard
- [ ] Promotion Codes verificati
- [ ] Backend riavviato con nuove variabili
- [ ] Test endpoint `/pro/subscribe` funzionante
- [ ] Test checkout Stripe completo

---

**Script pronto all'uso! 🚀**

Per supporto: petcareassistenza@gmail.com
