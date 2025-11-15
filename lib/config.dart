class AppConfig {
  // URL backend e frontend in produzione
  static const String backendBaseUrl = 'https://api.mypetcareapp.org';
  static const String webBaseUrl = 'https://app.mypetcareapp.org';
  
  // Getter per compatibilità con codice esistente
  static String get effectiveBackendUrl => backendBaseUrl;
  static String get effectiveWebUrl => webBaseUrl;

  // ==========================================
  // STRIPE LIVE CONFIGURATION
  // ==========================================
  // Publishable Key (pubblico, safe per client-side)
  // ⚠️ SOSTITUISCI con la tua chiave da Stripe Dashboard → API Keys
  static const String stripePublishableKey = 'pk_live_YOUR_STRIPE_PUBLISHABLE_KEY_HERE';
  
  // Price IDs - Da sostituire quando crei i prodotti in Stripe Dashboard
  // Formato: price_xxxxxxxxxxxxx
  // Guida completa: docs/STRIPE-LIVE-SETUP.md
  static const String stripeMonthlyPriceId = 'price_STRIPE_MENSILE_LIVE'; 
  static const String stripeYearlyPriceId  = 'price_STRIPE_ANNUALE_LIVE'; 

  // ==========================================
  // PAYPAL LIVE PLAN ID
  // ==========================================
  // Da sostituire con il Plan ID reale ottenuto dalla PayPal Dashboard (modalità LIVE)
  // Formato: P-XXXXXXXXXXXX
  // 
  // Guida completa: docs/PAYPAL-LIVE-SETUP.md
  static const String paypalMonthlyPlanId = 'P_PAYPAL_MENSILE_LIVE';

  // ==========================================
  // NOTE:
  // ==========================================
  // - stripePublishableKey è pubblico e può stare qui (inizia con pk_live_)
  // - Le chiavi segrete (sk_live_, whsec_, PayPal secret) NON vanno MAI messe qui
  // - Le chiavi segrete si configurano solo come variabili d'ambiente su Cloud Run
  // - Per testing: usare .env.development.example con chiavi TEST/SANDBOX
}
