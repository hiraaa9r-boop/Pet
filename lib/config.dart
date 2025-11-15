class AppConfig {
  // URL backend e frontend in produzione
  static const String backendBaseUrl = 'https://api.mypetcareapp.org';
  static const String webBaseUrl = 'https://app.mypetcareapp.org';
  
  // Getter per compatibilità con codice esistente
  static String get effectiveBackendUrl => backendBaseUrl;
  static String get effectiveWebUrl => webBaseUrl;

  // ==========================================
  // STRIPE TEST CONFIGURATION
  // ==========================================
  // ⚠️ IMPORTANTE: Queste sono chiavi TEST - NON accettano pagamenti reali!
  // Per passare a LIVE: sostituisci con chiavi da Stripe Dashboard → API Keys (LIVE mode)
  
  // Publishable Key (pubblico, safe per client-side)
  static const String stripePublishableKey = 'pk_test_51SPft3Lc9uOEhD6QYYeRjm5GDHtW61arr1b2ykzHnap1kkzW8aM7FbFSYDXn6Rj5veLmWfXwh5PifBs3BOdnSSBe00eGgsupFk';
  
  // Price IDs - Da creare in Stripe Dashboard (modalità TEST)
  // Formato: price_xxxxxxxxxxxxx
  // Guida: Crea prodotti in TEST mode → copia Price IDs
  static const String stripeMonthlyPriceId = 'price_TEST_MONTHLY'; 
  static const String stripeYearlyPriceId  = 'price_TEST_YEARLY'; 

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
