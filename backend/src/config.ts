// backend/src/config.ts
type Env = "development" | "production" | "test";

const nodeEnv = (process.env.NODE_ENV as Env) || "development";

function requireEnv(name: string, optional = false): string {
  const value = process.env[name];
  if (!value && !optional) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value || "";
}

export const config = {
  env: nodeEnv,

  backendBaseUrl: requireEnv("BACKEND_BASE_URL"),
  webBaseUrl: requireEnv("WEB_BASE_URL"),

  // Stripe
  stripeSecretKey: requireEnv("STRIPE_SECRET_KEY"),
  stripeWebhookSecret: requireEnv("STRIPE_WEBHOOK_SECRET"),

  // PayPal
  paypalClientId: requireEnv("PAYPAL_CLIENT_ID"),
  paypalSecret: requireEnv("PAYPAL_SECRET"),
  paypalWebhookId: requireEnv("PAYPAL_WEBHOOK_ID"),
  paypalApiBaseUrl: requireEnv("PAYPAL_API", true) || "https://api-m.paypal.com",

  // Firestore collections (centralizzate, così se cambi un nome lo fai qui)
  collections: {
    pros: "pros",
    bookings: "bookings",
    calendars: "calendars",
    notifications: "notifications",
    coupons: "coupons",
    users: "users",
  },
};
