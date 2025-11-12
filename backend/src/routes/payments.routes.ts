/**
 * Payments Routes (Stripe)
 * Handles Stripe checkout, portal, and payment operations
 */

import { Router } from 'express';
import Stripe from 'stripe';

import { paymentsLimiter } from '../middleware/rateLimit';

const router = Router();

// Initialize Stripe with API version
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY as string, {
  apiVersion: '2024-06-20',
});

/**
 * POST /api/payments/checkout
 * Create Stripe Checkout Session
 */
router.post('/checkout', paymentsLimiter, async (req, res, next) => {
  try {
    const { priceId, successUrl, cancelUrl, customerEmail, mode = 'subscription' } =
      req.body || {};

    // Validation
    if (!priceId || !successUrl || !cancelUrl) {
      return res.status(400).json({
        ok: false,
        message: 'Missing required fields: priceId, successUrl, cancelUrl',
        code: 'MISSING_FIELDS',
      });
    }

    // Create checkout session
    const session = await stripe.checkout.sessions.create({
      mode: mode as 'subscription' | 'payment',
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: successUrl,
      cancel_url: cancelUrl,
      customer_email: customerEmail,
      allow_promotion_codes: true,
      billing_address_collection: 'required',
    });

    return res.status(201).json({
      ok: true,
      sessionId: session.id,
      url: session.url,
    });
  } catch (error: any) {
    console.error('Stripe checkout error:', error);
    next(error);
  }
});

/**
 * POST /api/payments/portal
 * Create Stripe Customer Portal Session
 */
router.post('/portal', paymentsLimiter, async (req, res, next) => {
  try {
    const { customerId, returnUrl } = req.body || {};

    // Validation
    if (!customerId || !returnUrl) {
      return res.status(400).json({
        ok: false,
        message: 'Missing required fields: customerId, returnUrl',
        code: 'MISSING_FIELDS',
      });
    }

    // Create portal session
    const session = await stripe.billingPortal.sessions.create({
      customer: customerId,
      return_url: returnUrl,
    });

    return res.status(201).json({
      ok: true,
      url: session.url,
    });
  } catch (error: any) {
    console.error('Stripe portal error:', error);
    next(error);
  }
});

/**
 * POST /api/payments/create-payment-intent
 * Create PaymentIntent for one-time payments
 */
router.post('/create-payment-intent', paymentsLimiter, async (req, res, next) => {
  try {
    const { amount, currency = 'eur', description, metadata } = req.body || {};

    // Validation
    if (!amount || amount < 50) {
      // Minimum 0.50 EUR
      return res.status(400).json({
        ok: false,
        message: 'Amount must be at least 50 cents (0.50 EUR)',
        code: 'INVALID_AMOUNT',
      });
    }

    // Create payment intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount), // Amount in cents
      currency,
      description,
      metadata: metadata || {},
      automatic_payment_methods: {
        enabled: true,
      },
    });

    return res.status(201).json({
      ok: true,
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    });
  } catch (error: any) {
    console.error('Payment intent creation error:', error);
    next(error);
  }
});

/**
 * GET /api/payments/subscription/:subscriptionId
 * Get subscription details
 */
router.get('/subscription/:subscriptionId', async (req, res, next) => {
  try {
    const { subscriptionId } = req.params;

    const subscription = await stripe.subscriptions.retrieve(subscriptionId);

    return res.json({
      ok: true,
      subscription: {
        id: subscription.id,
        status: subscription.status,
        currentPeriodStart: subscription.current_period_start,
        currentPeriodEnd: subscription.current_period_end,
        cancelAtPeriodEnd: subscription.cancel_at_period_end,
      },
    });
  } catch (error: any) {
    console.error('Subscription retrieval error:', error);
    next(error);
  }
});

/**
 * POST /api/payments/cancel-subscription
 * Cancel subscription at period end
 */
router.post('/cancel-subscription', paymentsLimiter, async (req, res, next) => {
  try {
    const { subscriptionId } = req.body || {};

    if (!subscriptionId) {
      return res.status(400).json({
        ok: false,
        message: 'Missing required field: subscriptionId',
        code: 'MISSING_FIELD',
      });
    }

    // Cancel at period end (don't cancel immediately)
    const subscription = await stripe.subscriptions.update(subscriptionId, {
      cancel_at_period_end: true,
    });

    return res.json({
      ok: true,
      message: 'Subscription will cancel at period end',
      cancelAt: subscription.cancel_at,
    });
  } catch (error: any) {
    console.error('Subscription cancellation error:', error);
    next(error);
  }
});

export default router;
