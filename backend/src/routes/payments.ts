// backend/src/routes/payments.ts
// MyPetCare Backend - Payments Routes (Stripe + PayPal Checkout)

import express from "express";
import { createStripeCheckoutSession } from "../payments/stripe";
import { createPayPalSubscription } from "../payments/paypal";

export const paymentsRouter = express.Router();

// ==========================================
// STRIPE CHECKOUT
// ==========================================
// Endpoint: POST /api/payments/stripe/checkout
// Body: { priceId, successUrl, cancelUrl, customerEmail }
// Response: { url: "https://checkout.stripe.com/..." }
paymentsRouter.post("/stripe/checkout", express.json(), createStripeCheckoutSession);

// ==========================================
// PAYPAL CHECKOUT (Subscription)
// ==========================================
// Endpoint: POST /api/payments/paypal/checkout
// Body: { planId, returnUrl, cancelUrl }
// Response: { approveLink: "https://www.paypal.com/..." }
paymentsRouter.post("/paypal/checkout", express.json(), createPayPalSubscription);
