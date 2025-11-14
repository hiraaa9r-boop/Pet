/**
 * Unified Payments Routes
 * Combines Stripe and PayPal payment handling
 */

import express, { Router } from 'express';
import Stripe from 'stripe';
import fetch from 'node-fetch';
import { db } from '../firebase';

const router = Router();

// Initialize Stripe
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY as string, {
  apiVersion: '2024-06-20',
});

// ============================================================================
// STRIPE CHECKOUT (SUBSCRIPTION)
// ============================================================================

/**
 * POST /api/payments/stripe/checkout
 * Creates a Stripe Checkout Session for PRO subscription
 * 
 * Body: { proId: string, priceId: string, successUrl: string, cancelUrl: string }
 */
router.post('/stripe/checkout', async (req, res) => {
  try {
    const { proId, priceId, successUrl, cancelUrl } = req.body;

    if (!proId || !priceId || !successUrl || !cancelUrl) {
      return res.status(400).json({ error: 'Missing required parameters' });
    }

    const proRef = db.collection('pros').doc(proId);
    const proSnap = await proRef.get();
    
    if (!proSnap.exists) {
      return res.status(404).json({ error: 'PRO not found' });
    }

    const proData = proSnap.data() || {};
    const stripeCustomerId = proData.stripeCustomerId as string | undefined;

    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      customer: stripeCustomerId,
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: `${successUrl}?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: cancelUrl,
      metadata: { proId },
    });

    return res.json({ url: session.url });
  } catch (error) {
    console.error('Stripe checkout error:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

// ============================================================================
// STRIPE WEBHOOK
// ============================================================================

/**
 * POST /api/payments/stripe/webhook
 * Handles Stripe webhook events
 * 
 * IMPORTANT: This route MUST use express.raw() middleware
 */
router.post(
  '/stripe/webhook',
  express.raw({ type: 'application/json' }),
  async (req, res) => {
    const sig = req.headers['stripe-signature'] as string;

    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(
        req.body,
        sig,
        process.env.STRIPE_WEBHOOK_SECRET as string
      );
    } catch (err: any) {
      console.error('Stripe webhook signature error:', err.message);
      return res.status(400).send('Webhook Error');
    }

    try {
      // Handle subscription lifecycle events
      if (
        event.type === 'customer.subscription.created' ||
        event.type === 'customer.subscription.updated' ||
        event.type === 'customer.subscription.deleted'
      ) {
        const sub = event.data.object as Stripe.Subscription;

        // Extract proId from metadata
        const metadata = sub.metadata as any;
        const itemPrice = sub.items.data[0]?.price;
        const proIdFromMetadata = metadata?.proId;
        const proIdFromPrice = (itemPrice?.metadata as any)?.proId;
        const proId = proIdFromMetadata || proIdFromPrice;

        if (!proId) {
          console.warn('No proId in subscription metadata, skipping update');
        } else {
          const status = sub.status; // trialing, active, past_due, canceled, etc.

          // Map Stripe status to our subscription status
          let subscriptionStatus: 'active' | 'inactive' | 'trial' | 'past_due';
          
          if (status === 'active') {
            subscriptionStatus = 'active';
          } else if (status === 'trialing') {
            subscriptionStatus = 'trial';
          } else if (status === 'past_due') {
            subscriptionStatus = 'past_due';
          } else {
            subscriptionStatus = 'inactive';
          }

          // Update Firestore
          await db.collection('pros').doc(proId).update({
            subscriptionStatus,
            subscriptionProvider: 'stripe',
            subscriptionPlan: itemPrice?.nickname || itemPrice?.id || null,
            stripeSubscriptionId: sub.id,
            currentPeriodStart: new Date(sub.current_period_start * 1000),
            currentPeriodEnd: new Date(sub.current_period_end * 1000),
            lastPaymentAt: sub.latest_invoice != null
              ? new Date(sub.current_period_start * 1000)
              : null,
            cancelAtPeriodEnd: sub.cancel_at_period_end,
            updatedAt: new Date(),
          });

          console.log(`✅ Updated PRO ${proId} subscription status to ${subscriptionStatus}`);
        }
      }

      // Handle payment success/failure
      if (event.type === 'invoice.payment_succeeded') {
        const invoice = event.data.object as Stripe.Invoice;
        const subscriptionId = invoice.subscription as string;

        if (subscriptionId) {
          const subscription = await stripe.subscriptions.retrieve(subscriptionId);
          const proId = subscription.metadata.proId;

          if (proId) {
            await db.collection('pros').doc(proId).update({
              lastPaymentAt: new Date(),
              lastPaymentAmount: invoice.amount_paid / 100,
              lastPaymentCurrency: invoice.currency,
              updatedAt: new Date(),
            });

            console.log(`✅ Payment succeeded for PRO ${proId}`);
          }
        }
      }

      if (event.type === 'invoice.payment_failed') {
        const invoice = event.data.object as Stripe.Invoice;
        const subscriptionId = invoice.subscription as string;

        if (subscriptionId) {
          const subscription = await stripe.subscriptions.retrieve(subscriptionId);
          const proId = subscription.metadata.proId;

          if (proId) {
            await db.collection('pros').doc(proId).update({
              subscriptionStatus: 'past_due',
              updatedAt: new Date(),
            });

            console.log(`⚠️ Payment failed for PRO ${proId}`);
            // TODO: Send notification to PRO
          }
        }
      }

      res.json({ received: true });
    } catch (error) {
      console.error('Stripe webhook handling error:', error);
      res.status(500).send('Webhook handler error');
    }
  }
);

// ============================================================================
// PAYPAL UTILITIES
// ============================================================================

async function getPayPalAccessToken(): Promise<string> {
  const auth = Buffer.from(
    `${process.env.PAYPAL_CLIENT_ID}:${process.env.PAYPAL_SECRET}`
  ).toString('base64');

  const resp = await fetch(
    `${process.env.PAYPAL_API}/v1/oauth2/token`,
    {
      method: 'POST',
      headers: {
        Authorization: `Basic ${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    }
  );

  const data = (await resp.json()) as any;
  if (!resp.ok) {
    console.error('PayPal token error:', data);
    throw new Error('PayPal token error');
  }

  return data.access_token as string;
}

// ============================================================================
// PAYPAL CREATE ORDER
// ============================================================================

/**
 * POST /api/payments/paypal/create-order
 * Creates a PayPal order for PRO subscription
 * 
 * Body: { proId: string, amount: string, returnUrl: string, cancelUrl: string }
 */
router.post('/paypal/create-order', async (req, res) => {
  try {
    const { proId, amount, returnUrl, cancelUrl } = req.body;
    
    if (!proId || !amount || !returnUrl || !cancelUrl) {
      return res.status(400).json({ error: 'Missing required parameters' });
    }

    const token = await getPayPalAccessToken();

    const resp = await fetch(
      `${process.env.PAYPAL_API}/v2/checkout/orders`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          intent: 'CAPTURE',
          purchase_units: [
            {
              reference_id: proId,
              amount: {
                currency_code: 'EUR',
                value: amount,
              },
              description: 'MyPetCare PRO Subscription',
            },
          ],
          application_context: {
            brand_name: 'MyPetCare',
            landing_page: 'BILLING',
            user_action: 'PAY_NOW',
            return_url: returnUrl,
            cancel_url: cancelUrl,
          },
        }),
      }
    );

    const data = (await resp.json()) as any;
    
    if (!resp.ok) {
      console.error('PayPal create order error:', data);
      return res.status(500).json({ error: 'PayPal create order error' });
    }

    const approvalLink = data.links?.find(
      (l: any) => l.rel === 'approve'
    )?.href;

    if (!approvalLink) {
      return res.status(500).json({ error: 'No approval link found' });
    }

    return res.json({ approvalLink, orderId: data.id });
  } catch (error) {
    console.error('PayPal create-order error:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

/**
 * POST /api/payments/paypal/capture-order
 * Captures a PayPal order after user approval
 * 
 * Body: { orderId: string, proId: string }
 */
router.post('/paypal/capture-order', async (req, res) => {
  try {
    const { orderId, proId } = req.body;
    
    if (!orderId || !proId) {
      return res.status(400).json({ error: 'Missing orderId or proId' });
    }

    const token = await getPayPalAccessToken();

    const resp = await fetch(
      `${process.env.PAYPAL_API}/v2/checkout/orders/${orderId}/capture`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      }
    );

    const data = (await resp.json()) as any;
    
    if (!resp.ok || data.status !== 'COMPLETED') {
      console.error('PayPal capture error:', data);
      return res.status(500).json({ error: 'PayPal capture failed' });
    }

    // Update Firestore with active subscription
    const now = new Date();
    const periodEnd = new Date(now);
    periodEnd.setMonth(periodEnd.getMonth() + 1); // 1 month subscription

    await db.collection('pros').doc(proId).update({
      subscriptionStatus: 'active',
      subscriptionProvider: 'paypal',
      subscriptionPlan: 'MONTHLY',
      paypalOrderId: data.id,
      currentPeriodStart: now,
      currentPeriodEnd: periodEnd,
      lastPaymentAt: now,
      lastPaymentAmount: parseFloat(data.purchase_units[0]?.amount?.value || '0'),
      lastPaymentCurrency: data.purchase_units[0]?.amount?.currency_code || 'EUR',
      updatedAt: now,
    });

    console.log(`✅ PayPal order captured for PRO ${proId}`);

    return res.json({
      status: 'COMPLETED',
      orderId: data.id,
      subscriptionStatus: 'active',
    });
  } catch (error) {
    console.error('PayPal capture-order error:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

export default router;
