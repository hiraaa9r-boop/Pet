// backend/src/config.ts
// Configurazione centralizzata per MyPetCare Backend

export const config = {
  // Server
  port: process.env.PORT || 8080,
  env: process.env.NODE_ENV || 'development',

  // Stripe
  stripeSecretKey: process.env.STRIPE_SECRET_KEY || '',
  stripeWebhookSecret: process.env.STRIPE_WEBHOOK_SECRET || '',

  // PayPal
  paypalClientId: process.env.PAYPAL_CLIENT_ID || '',
  paypalSecret: process.env.PAYPAL_SECRET || '',
  paypalApi: process.env.PAYPAL_API || 'https://api-m.sandbox.paypal.com',
  paypalWebhookId: process.env.PAYPAL_WEBHOOK_ID || '',

  // URLs
  backendBaseUrl: process.env.BACKEND_BASE_URL || 'http://localhost:8080',
  webBaseUrl: process.env.WEB_BASE_URL || 'http://localhost:52000'
};

// Validazione configurazione critica
export function validateConfig(): void {
  const errors: string[] = [];

  if (!config.stripeSecretKey) {
    errors.push('STRIPE_SECRET_KEY is required');
  }

  if (!config.stripeWebhookSecret) {
    errors.push('STRIPE_WEBHOOK_SECRET is required');
  }

  if (!config.paypalClientId) {
    errors.push('PAYPAL_CLIENT_ID is required');
  }

  if (!config.paypalSecret) {
    errors.push('PAYPAL_SECRET is required');
  }

  if (errors.length > 0) {
    console.warn('⚠️  Configuration warnings:');
    errors.forEach((err) => console.warn(`   - ${err}`));
  }
}
