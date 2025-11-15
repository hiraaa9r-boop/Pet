# Configurazione PayPal LIVE per MyPetCare

## 🎯 Obiettivo
Configurare **PayPal in modalità LIVE** per gestire abbonamenti ricorrenti (billing subscriptions) per l'app MyPetCare PRO.

---

## 📋 Prerequisiti
- Account PayPal Business verificato
- Accesso al [PayPal Developer Dashboard](https://developer.paypal.com/)
- Dominio backend configurato: `https://api.mypetcareapp.org`

---

## 🔧 Passi di Configurazione

### **Step 1: Accedere alla Modalità LIVE**
1. Vai su [PayPal Developer Dashboard](https://developer.paypal.com/dashboard/)
2. In alto a destra, seleziona **"LIVE"** invece di "Sandbox"
3. Verifica che tutti i passi successivi vengano effettuati in modalità LIVE

---

### **Step 2: Creare REST API App LIVE**

1. Vai su **"My Apps & Credentials"**
2. Nella sezione **"REST API apps"**, sotto **LIVE**, clicca **"Create App"**
3. Compila i campi:
   - **App Name:** `MyPetCare Production`
   - **App Type:** `Merchant`
4. Salva l'applicazione
5. **Copia le credenziali:**
   - **Client ID** (formato: `XXXXXXXXXXXXXX`)
     - Questo sarà il tuo **`PAYPAL_CLIENT_ID`**
   - **Secret** (clicca "Show" per visualizzarlo)
     - Questo sarà il tuo **`PAYPAL_SECRET`**

---

### **Step 3: Creare Billing Plan (Piano di Abbonamento)**

#### **Metodo A: Via Dashboard (Raccomandato)**

1. Vai su **[PayPal Business Dashboard](https://www.paypal.com/businessmanage/)**
2. Naviga: **"Products & Services"** → **"Subscriptions"** → **"Create subscription button"**
3. Crea un nuovo prodotto:
   - **Product Name:** `MyPetCare PRO`
   - **Product Type:** `Digital goods` o `Service`
4. Crea un piano di abbonamento:
   - **Plan Name:** `MyPetCare PRO Monthly`
   - **Billing cycle:** `1 month`
   - **Price:** Inserisci il prezzo mensile (es. `€9.99`)
   - **Currency:** `EUR`
5. Salva il piano
6. **Copia il Plan ID** (formato: `P-XXXXXXXXXXXX`)
   - Questo sarà il tuo **`paypalMonthlyPlanId`**

#### **Metodo B: Via API REST** (Avanzato)

Se preferisci creare il piano tramite API:

```bash
# Ottieni access token
curl -X POST https://api-m.paypal.com/v1/oauth2/token \
  -H "Authorization: Basic $(echo -n CLIENT_ID:SECRET | base64)" \
  -d "grant_type=client_credentials"

# Crea prodotto
curl -X POST https://api-m.paypal.com/v1/catalogs/products \
  -H "Authorization: Bearer ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "MyPetCare PRO",
    "type": "SERVICE"
  }'

# Crea piano di billing
curl -X POST https://api-m.paypal.com/v1/billing/plans \
  -H "Authorization: Bearer ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": "PROD-XXXXX",
    "name": "MyPetCare PRO Monthly",
    "billing_cycles": [{
      "frequency": {"interval_unit": "MONTH", "interval_count": 1},
      "tenure_type": "REGULAR",
      "sequence": 1,
      "total_cycles": 0,
      "pricing_scheme": {
        "fixed_price": {"value": "9.99", "currency_code": "EUR"}
      }
    }],
    "payment_preferences": {
      "auto_bill_outstanding": true
    }
  }'
```

#### **Piano Annuale** (Opzionale)
Ripeti il processo per creare un piano annuale:
- **Plan Name:** `MyPetCare PRO Yearly`
- **Billing cycle:** `1 year`
- **Price:** Inserisci il prezzo annuale (es. `€99.99`)

---

### **Step 4: Configurare Webhook LIVE**

1. Vai su **"My Apps & Credentials"** → Seleziona la tua app LIVE
2. Scorri fino alla sezione **"Webhooks"**
3. Clicca **"Add Webhook"**
4. Compila i campi:
   - **Webhook URL:** `https://api.mypetcareapp.org/webhooks/paypal`
5. Seleziona gli eventi da ascoltare:
   - ✅ `BILLING.SUBSCRIPTION.ACTIVATED`
   - ✅ `BILLING.SUBSCRIPTION.UPDATED`
   - ✅ `BILLING.SUBSCRIPTION.CANCELLED`
   - ✅ `BILLING.SUBSCRIPTION.EXPIRED`
   - ✅ `BILLING.SUBSCRIPTION.SUSPENDED` (opzionale)
   - ✅ `BILLING.SUBSCRIPTION.PAYMENT.FAILED` (opzionale)
6. Salva il webhook
7. **Copia il Webhook ID** (visibile nella lista dei webhook)
   - Questo sarà il tuo **`PAYPAL_WEBHOOK_ID`**

---

## 🔐 Variabili d'Ambiente da Configurare

Le seguenti variabili **DEVONO** essere impostate nelle variabili d'ambiente di Cloud Run:

```bash
# PayPal LIVE credentials
PAYPAL_CLIENT_ID=XXXXXXXXXXXXXX
PAYPAL_SECRET=YYYYYYYYYYYYYYYY
PAYPAL_WEBHOOK_ID=ZZZZZZZZZZZZZZ

# PayPal API base URL (LIVE)
PAYPAL_API=https://api-m.paypal.com
```

⚠️ **IMPORTANTE:**
- **MAI committare queste credenziali nel codice**
- Usare solo variabili d'ambiente (Cloud Run Console)
- Sandbox URL: `https://api-m.sandbox.paypal.com` (solo per test)
- Production URL: `https://api-m.paypal.com` (per LIVE)

---

## 📱 Aggiornamenti nel Codice

### **1. Aggiornare `lib/config.dart` (Flutter)**

Sostituisci il placeholder con il Plan ID reale ottenuto allo Step 3:

```dart
class AppConfig {
  // ...altre configurazioni...

  // PayPal LIVE plan ID
  static const String paypalMonthlyPlanId = 'P-XXXXXXXXXXXX'; // ← Plan ID Mensile
}
```

### **2. Verificare Backend Configuration**

Assicurati che `backend/src/config.ts` utilizzi la variabile d'ambiente:

```typescript
export const config = {
  // ...
  paypalApiBaseUrl: requireEnv("PAYPAL_API", true) || "https://api-m.paypal.com",
};
```

⚠️ **NON hardcodare** l'URL nel codice! Usa sempre `config.paypalApiBaseUrl`.

### **3. Verificare Endpoint Backend**

Assicurati che il frontend Flutter chiami correttamente l'endpoint di checkout:

```dart
// Esempio chiamata HTTP dal Flutter app
final response = await http.post(
  Uri.parse('${AppConfig.backendBaseUrl}/api/payments/paypal/checkout'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'planId': AppConfig.paypalMonthlyPlanId,
    'returnUrl': '${AppConfig.webBaseUrl}/payment-success',
    'cancelUrl': '${AppConfig.webBaseUrl}/payment-cancel',
  }),
);

// Risposta contiene: { "approveLink": "https://www.paypal.com/checkoutnow?token=..." }
// Reindirizza l'utente a approveLink per completare il pagamento
```

---

## ✅ Checklist Finale

Prima di andare in produzione, verifica:

- [ ] Modalità LIVE attivata in PayPal Developer Dashboard
- [ ] REST API App LIVE creata con Client ID e Secret copiati
- [ ] Billing Plan creato con Plan ID copiato
- [ ] Webhook configurato con eventi subscription
- [ ] Webhook ID copiato
- [ ] Variabili d'ambiente configurate su Cloud Run
- [ ] `lib/config.dart` aggiornato con Plan ID reale
- [ ] `backend/src/config.ts` usa `config.paypalApiBaseUrl` (no hardcode)
- [ ] Test abbonamento con account PayPal reale
- [ ] Webhook riceve eventi correttamente (`/webhooks/paypal` risponde 200)

---

## 🧪 Test in Produzione

### Test Checkout:
```bash
# Postman/cURL - Creare subscription
curl -X POST https://api.mypetcareapp.org/api/payments/paypal/checkout \
  -H "Content-Type: application/json" \
  -d '{
    "planId": "P-XXXXXXXXXXXX",
    "returnUrl": "https://app.mypetcareapp.org/success",
    "cancelUrl": "https://app.mypetcareapp.org/cancel"
  }'

# Risposta: { "approveLink": "https://www.paypal.com/checkoutnow?token=..." }
```

### Test Webhook:
1. Vai su PayPal Developer Dashboard → Webhooks
2. Seleziona il webhook creato
3. Click su **"Send test notification"**
4. Seleziona evento `BILLING.SUBSCRIPTION.ACTIVATED`
5. Verifica che il backend risponda con status `200 OK`

### Test Completo:
1. Crea una subscription tramite API
2. Apri `approveLink` in un browser
3. Accedi con account PayPal reale
4. Completa il pagamento
5. Verifica che il webhook riceva evento `BILLING.SUBSCRIPTION.ACTIVATED`
6. Controlla i log di Cloud Run per confermare elaborazione

---

## 🔍 Debugging Comune

### Errore: "INVALID_CLIENT"
- Verifica che Client ID e Secret siano corretti
- Assicurati di essere in modalità LIVE (non Sandbox)

### Errore: "PLAN_ID_INVALID"
- Verifica che il Plan ID esista in modalità LIVE
- Il Plan deve essere in stato "ACTIVE"

### Webhook non riceve eventi
- Verifica che l'URL webhook sia raggiungibile pubblicamente
- Testa con `curl` da esterno
- Verifica che Cloud Run non richieda autenticazione (`--allow-unauthenticated`)

---

## 📚 Risorse Utili

- [PayPal Developer Dashboard](https://developer.paypal.com/dashboard/)
- [PayPal Subscriptions API](https://developer.paypal.com/docs/subscriptions/)
- [PayPal Webhooks Guide](https://developer.paypal.com/api/rest/webhooks/)
- [PayPal Business Dashboard](https://www.paypal.com/businessmanage/)

---

**✅ Configurazione completata! PayPal LIVE è pronto per elaborare abbonamenti reali.**
