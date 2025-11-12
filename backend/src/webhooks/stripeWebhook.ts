/**
 * Stripe Webhook Handler
 * Processes Stripe events for subscriptions and payments
 */

import { Request, Response } from 'express';
import Stripe from 'stripe';

import { getDb } from '../utils/firebaseAdmin';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY as string, {
  apiVersion: '2024-06-20',
});

const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET as string;

/**
 * Handle Stripe Webhook Events
 * Verifies signature and processes events
 */
export async function handleStripeWebhook(req: Request, res: Response) {
  const sig = req.headers['stripe-signature'] as string;

  // Get raw body (must be set by middleware before this handler)
  const rawBody = (req as any).rawBody;

  if (!rawBody) {
    console.error('❌ Stripe webhook: raw body not available');
    return res.status(400).send('Raw body required for webhook signature verification');
  }

  let event: Stripe.Event;

  try {
    // Verify webhook signature
    event = stripe.webhooks.constructEvent(rawBody, sig, endpointSecret);
  } catch (err: any) {
    console.error('❌ Stripe webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  console.log(`✅ Stripe webhook received: ${event.type}`);

  // Process event
  try {
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutSessionCompleted(event.data.object as Stripe.Checkout.Session);
        break;

      case 'customer.subscription.created':
        await handleSubscriptionCreated(event.data.object as Stripe.Subscription);
        break;

      case 'customer.subscription.updated':
        await handleSubscriptionUpdated(event.data.object as Stripe.Subscription);
        break;

      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object as Stripe.Subscription);
        break;

      case 'customer.subscription.paused':
        await handleSubscriptionPaused(event.data.object as Stripe.Subscription);
        break;

      case 'invoice.paid':
        await handleInvoicePaid(event.data.object as Stripe.Invoice);
        break;

      case 'invoice.payment_failed':
        await handleInvoicePaymentFailed(event.data.object as Stripe.Invoice);
        break;

      case 'payment_intent.succeeded':
        await handlePaymentIntentSucceeded(event.data.object as Stripe.PaymentIntent);
        break;

      case 'payment_intent.payment_failed':
        await handlePaymentIntentFailed(event.data.object as Stripe.PaymentIntent);
        break;

      default:
        console.log(`ℹ️  Unhandled event type: ${event.type}`);
    }

    // Return 200 to acknowledge receipt
    res.json({ received: true });
  } catch (error: any) {
    console.error('❌ Error processing webhook:', error);
    res.status(500).json({ error: 'Webhook processing failed' });
  }
}

/**
 * Handle checkout.session.completed
 * User completed checkout - activate subscription
 */
async function handleCheckoutSessionCompleted(session: Stripe.Checkout.Session) {
  console.log('💳 Checkout session completed:', session.id);

  const db = getDb();
  const customerId = session.customer as string;
  const subscriptionId = session.subscription as string;

  // Find user by customer ID
  const usersSnapshot = await db
    .collection('users')
    .where('stripeCustomerId', '==', customerId)
    .limit(1)
    .get();

  if (!usersSnapshot.empty) {
    const userDoc = usersSnapshot.docs[0];

    // Update user with subscription info
    await userDoc.ref.update({
      subscriptionId,
      subscriptionStatus: 'active',
      subscribedAt: new Date().toISOString(),
    });

    console.log(`✅ User ${userDoc.id} subscription activated`);
  }
}

/**
 * Handle customer.subscription.created
 */
async function handleSubscriptionCreated(subscription: Stripe.Subscription) {
  console.log('📦 Subscription created:', subscription.id);

  const db = getDb();
  const customerId = subscription.customer as string;

  const usersSnapshot = await db
    .collection('users')
    .where('stripeCustomerId', '==', customerId)
    .limit(1)
    .get();

  if (!usersSnapshot.empty) {
    await usersSnapshot.docs[0].ref.update({
      subscriptionId: subscription.id,
      subscriptionStatus: subscription.status,
    });
  }
}

/**
 * Handle customer.subscription.updated
 */
async function handleSubscriptionUpdated(subscription: Stripe.Subscription) {
  console.log('🔄 Subscription updated:', subscription.id);

  const db = getDb();

  const usersSnapshot = await db
    .collection('users')
    .where('subscriptionId', '==', subscription.id)
    .limit(1)
    .get();

  if (!usersSnapshot.empty) {
    await usersSnapshot.docs[0].ref.update({
      subscriptionStatus: subscription.status,
    });
  }
}

/**
 * Handle customer.subscription.deleted
 * Revoke pro access
 */
async function handleSubscriptionDeleted(subscription: Stripe.Subscription) {
  console.log('🚫 Subscription deleted:', subscription.id);

  const db = getDb();

  const usersSnapshot = await db
    .collection('users')
    .where('subscriptionId', '==', subscription.id)
    .limit(1)
    .get();

  if (!usersSnapshot.empty) {
    await usersSnapshot.docs[0].ref.update({
      subscriptionStatus: 'cancelled',
      subscriptionId: null,
    });

    console.log(`❌ User ${usersSnapshot.docs[0].id} subscription revoked`);
  }
}

/**
 * Handle customer.subscription.paused
 */
async function handleSubscriptionPaused(subscription: Stripe.Subscription) {
  console.log('⏸️  Subscription paused:', subscription.id);

  const db = getDb();

  const usersSnapshot = await db
    .collection('users')
    .where('subscriptionId', '==', subscription.id)
    .limit(1)
    .get();

  if (!usersSnapshot.empty) {
    await usersSnapshot.docs[0].ref.update({
      subscriptionStatus: 'paused',
    });
  }
}

/**
 * Handle invoice.paid
 */
async function handleInvoicePaid(invoice: Stripe.Invoice) {
  console.log('💰 Invoice paid:', invoice.id);
  // Additional logic for successful payments
}

/**
 * Handle invoice.payment_failed
 */
async function handleInvoicePaymentFailed(invoice: Stripe.Invoice) {
  console.log('⚠️  Invoice payment failed:', invoice.id);

  // TODO: Send notification to user about failed payment
  // TODO: Consider pausing subscription after multiple failures
}

/**
 * Handle payment_intent.succeeded
 */
async function handlePaymentIntentSucceeded(paymentIntent: Stripe.PaymentIntent) {
  console.log('✅ Payment intent succeeded:', paymentIntent.id);
  // Logic for one-time payments
}

/**
 * Handle payment_intent.payment_failed
 */
async function handlePaymentIntentFailed(paymentIntent: Stripe.PaymentIntent) {
  console.log('❌ Payment intent failed:', paymentIntent.id);
  // Logic for failed payments
}
