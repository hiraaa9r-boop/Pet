type Env = "development" | "production" | "test";

const nodeEnv = (process.env.NODE_ENV as Env) || "development";

function requireEnv(name: string, optional = false): string {
  const value = process.env[name];
  if (!value && !optional) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value || "";
}

export const SUPPORT_EMAIL = 'petcareassistenza@gmail.com';

export const config = {
  env: nodeEnv,
  port: parseInt(process.env.PORT || "8080", 10),

  backendBaseUrl: requireEnv("BACKEND_BASE_URL"),
  webBaseUrl: requireEnv("WEB_BASE_URL"),

  stripeSecretKey: requireEnv("STRIPE_SECRET_KEY"),
  stripeWebhookSecret: requireEnv("STRIPE_WEBHOOK_SECRET"),

  paypalClientId: requireEnv("PAYPAL_CLIENT_ID"),
  paypalSecret: requireEnv("PAYPAL_SECRET"),
  paypalWebhookId: requireEnv("PAYPAL_WEBHOOK_ID"),
  paypalApiBaseUrl: requireEnv("PAYPAL_API", true) || "https://api-m.paypal.com",

  supportEmail: SUPPORT_EMAIL,

  collections: {
    pros: "pros",
    bookings: "bookings",
    calendars: "calendars",
    notifications: "notifications",
    coupons: "coupons",
    users: "users",
  },
};

// Validation function to check all required env vars are present
export function validateConfig(): void {
  const required = [
    'BACKEND_BASE_URL',
    'WEB_BASE_URL',
    'STRIPE_SECRET_KEY',
    'STRIPE_WEBHOOK_SECRET',
    'PAYPAL_CLIENT_ID',
    'PAYPAL_SECRET',
    'PAYPAL_WEBHOOK_ID',
  ];

  const missing = required.filter(key => !process.env[key]);

  if (missing.length > 0) {
    console.error('❌ Missing required environment variables:');
    missing.forEach(key => console.error(`   - ${key}`));
    throw new Error('Configuration validation failed');
  }

  console.log('✅ Configuration validated successfully');
}
