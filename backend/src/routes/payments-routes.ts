// backend/src/routes/payments-routes.ts
import { Router } from "express";
import express from "express";
import { createStripeCheckoutSession, stripeWebhook } from "../payments/stripe";
import { createPayPalSubscription, paypalWebhook } from "../payments/paypal";

const router = Router();

// Stripe Checkout
router.post("/stripe/checkout", createStripeCheckoutSession);

// PayPal Subscription
router.post("/paypal/subscription", createPayPalSubscription);

// Webhooks - IMPORTANT: Register these BEFORE express.json() middleware in main app
export function registerWebhookRoutes(app: express.Application) {
  // Stripe webhook needs raw body for signature verification
  app.post(
    "/api/payments/stripe/webhook",
    express.raw({ type: "application/json" }),
    stripeWebhook
  );

  // PayPal webhook
  app.post("/api/payments/paypal/webhook", paypalWebhook);
}

export default router;
