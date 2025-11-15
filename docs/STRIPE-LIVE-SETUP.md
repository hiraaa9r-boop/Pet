# Configurazione Stripe LIVE per MyPetCare

## 🎯 Obiettivo
Configurare **Stripe in modalità LIVE** per gestire abbonamenti ricorrenti per l'app MyPetCare PRO.

---

## 📋 Prerequisiti
- Account Stripe verificato e attivato per pagamenti LIVE
- Accesso alla Stripe Dashboard
- Dominio backend configurato: `https://api.mypetcareapp.org`

---

## 🔧 Passi di Configurazione

### **Step 1: Attivare Modalità LIVE**
1. Accedi alla [Stripe Dashboard](https://dashboard.stripe.com/)
2. In alto a destra, passa da **"Test mode"** a **"LIVE mode"**
3. Verifica che tutti i passi successivi vengano effettuati in modalità LIVE

---

### **Step 2: Creare Prodotti e Prezzi Ricorrenti**

#### **Prodotto 1: MyPetCare PRO Mensile**
1. Vai su **Products** → **Add product**
2. Compila i campi:
   - **Name:** `MyPetCare PRO Mensile`
   - **Description:** `Abbonamento mensile per professionisti del settore pet care`
   - **Pricing model:** `Standard pricing`
   - **Price:** Inserisci il prezzo mensile (es. `€9,99`)
   - **Billing period:** `Monthly`
   - **Currency:** `EUR`
   - **Type:** `Recurring`
3. Salva il prodotto
4. **Copia il Price ID** (formato: `price_xxxxxxxxxxxxx`)
   - Questo sarà il tuo **`stripeMonthlyPriceId`**

#### **Prodotto 2: MyPetCare PRO Annuale** (Opzionale)
1. Ripeti il processo per un piano annuale:
   - **Name:** `MyPetCare PRO Annuale`
   - **Price:** Inserisci il prezzo annuale (es. `€99,99`)
   - **Billing period:** `Yearly`
   - **Currency:** `EUR`
2. **Copia il Price ID** (formato: `price_yyyyyyyyyyyyy`)
   - Questo sarà il tuo **`stripeYearlyPriceId`**

---

### **Step 3: Configurare Webhook LIVE**

1. Vai su **Developers** → **Webhooks** → **Add endpoint**
2. Compila i campi:
   - **Endpoint URL:** `https://api.mypetcareapp.org/webhooks/stripe`
   - **Description:** `MyPetCare Production Webhook`
   - **Version:** Latest API version (2024-06-20 o successiva)
3. Seleziona gli eventi da ascoltare:
   - ✅ `customer.subscription.created`
   - ✅ `customer.subscription.updated`
   - ✅ `customer.subscription.deleted`
4. Salva l'endpoint
5. **Copia il Signing Secret** (formato: `whsec_xxxxxxxxxxxxx`)
   - Questo sarà il tuo **`STRIPE_WEBHOOK_SECRET`**

---

### **Step 4: Recuperare Chiavi API LIVE**

1. Vai su **Developers** → **API keys**
2. Verifica che sei in **modalità LIVE**
3. Copia le seguenti chiavi:
   - **Secret key** (formato: `sk_live_xxxxxxxxxxxxx`)
     - Questo sarà il tuo **`STRIPE_SECRET_KEY`**
   - **Publishable key** (formato: `pk_live_xxxxxxxxxxxxx`)
     - Da usare eventualmente nel frontend (non necessaria per backend)

---

## 🔐 Variabili d'Ambiente da Configurare

Le seguenti variabili **DEVONO** essere impostate nelle variabili d'ambiente di Cloud Run:

```bash
# Stripe LIVE keys
STRIPE_SECRET_KEY=sk_live_xxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx
```

⚠️ **IMPORTANTE:** 
- **MAI committare queste chiavi nel codice**
- Usare solo variabili d'ambiente (Cloud Run Console)
- Le chiavi TEST (`sk_test_`, `whsec_test_`) funzionano SOLO in test mode

---

## 📱 Aggiornamenti nel Codice

### **1. Aggiornare `lib/config.dart` (Flutter)**

Sostituisci i placeholder con i Price ID reali ottenuti allo Step 2:

```dart
class AppConfig {
  // ...altre configurazioni...

  // Stripe LIVE price IDs
  static const String stripeMonthlyPriceId = 'price_xxxxxxxxxxxxx'; // ← Price ID Mensile
  static const String stripeYearlyPriceId  = 'price_yyyyyyyyyyyyy'; // ← Price ID Annuale
}
```

### **2. Verificare Endpoint Backend**

Assicurati che il frontend Flutter chiami correttamente l'endpoint di checkout:

```dart
// Esempio chiamata HTTP dal Flutter app
final response = await http.post(
  Uri.parse('${AppConfig.backendBaseUrl}/api/payments/stripe/checkout'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'priceId': AppConfig.stripeMonthlyPriceId,
    'successUrl': '${AppConfig.webBaseUrl}/payment-success',
    'cancelUrl': '${AppConfig.webBaseUrl}/payment-cancel',
    'customerEmail': userEmail,
  }),
);
```

---

## ✅ Checklist Finale

Prima di andare in produzione, verifica:

- [ ] Modalità LIVE attivata in Stripe Dashboard
- [ ] Prodotti e prezzi creati con Price IDs copiati
- [ ] Webhook configurato con Signing Secret copiato
- [ ] Chiavi API LIVE copiate (`sk_live_`, `whsec_`)
- [ ] Variabili d'ambiente configurate su Cloud Run
- [ ] `lib/config.dart` aggiornato con Price IDs reali
- [ ] Test pagamento con carta reale (es. carta personale)
- [ ] Webhook riceve eventi correttamente (`/webhooks/stripe` risponde 200)

---

## 🧪 Test in Produzione

### Test Checkout:
```bash
# Postman/cURL - Creare sessione di checkout
curl -X POST https://api.mypetcareapp.org/api/payments/stripe/checkout \
  -H "Content-Type: application/json" \
  -d '{
    "priceId": "price_xxxxxxxxxxxxx",
    "successUrl": "https://app.mypetcareapp.org/success",
    "cancelUrl": "https://app.mypetcareapp.org/cancel",
    "customerEmail": "test@example.com"
  }'
```

### Test Webhook:
1. Vai su Stripe Dashboard → Webhooks → Seleziona endpoint
2. Click su **"Send test webhook"**
3. Seleziona evento `customer.subscription.created`
4. Verifica che il backend risponda con status `200 OK`

---

## 📚 Risorse Utili

- [Stripe Dashboard](https://dashboard.stripe.com/)
- [Stripe API Docs - Subscriptions](https://stripe.com/docs/billing/subscriptions)
- [Stripe Webhooks Guide](https://stripe.com/docs/webhooks)
- [Testing in Production](https://stripe.com/docs/testing#live-mode)

---

**✅ Configurazione completata! Stripe LIVE è pronto per elaborare pagamenti reali.**
