// backend/src/routes/payments.stripe.webhook.ts
// Webhook handler Stripe per eventi subscription

import { Request, Response } from 'express';
import Stripe from 'stripe';
import { db } from '../firebase';
import { config } from '../config';

const stripe = new Stripe(config.stripeSecretKey, {
  apiVersion: '2024-06-20'
});

/**
 * Handler webhook Stripe
 * IMPORTANTE: Deve ricevere raw body tramite express.raw()
 * 
 * Gestisce eventi:
 * - customer.subscription.created
 * - customer.subscription.updated
 * - customer.subscription.deleted
 * - invoice.payment_succeeded
 * - invoice.payment_failed
 */
export async function stripeWebhookHandler(
  req: Request,
  res: Response
): Promise<void> {
  const sig = req.headers['stripe-signature'] as string;
  let event: Stripe.Event;

  // Verifica firma webhook
  try {
    event = stripe.webhooks.constructEvent(
      (req as any).body, // raw body fornito da express.raw
      sig,
      config.stripeWebhookSecret
    );
  } catch (err: any) {
    console.error('❌ Stripe webhook signature error:', err.message);
    res.status(400).send('Webhook signature verification failed');
    return;
  }

  console.log(`✅ Stripe webhook received: ${event.type}`);

  try {
    // Gestione eventi subscription
    if (
      event.type === 'customer.subscription.created' ||
      event.type === 'customer.subscription.updated' ||
      event.type === 'customer.subscription.deleted'
    ) {
      await handleSubscriptionEvent(event);
    }

    // Gestione eventi invoice (pagamento)
    if (
      event.type === 'invoice.payment_succeeded' ||
      event.type === 'invoice.payment_failed'
    ) {
      await handleInvoiceEvent(event);
    }

    res.json({ received: true });
  } catch (err: any) {
    console.error('❌ Stripe webhook handler error:', err.message);
    res.status(500).send('Webhook handler error');
  }
}

/**
 * Gestisce eventi subscription Stripe
 */
async function handleSubscriptionEvent(event: Stripe.Event): Promise<void> {
  const sub = event.data.object as Stripe.Subscription;
  const metadata = sub.metadata as any;
  const price = sub.items.data[0]?.price;

  // Recupera proId da metadata subscription o metadata price
  const proIdFromMeta = metadata?.proId;
  const proIdFromPrice = (price?.metadata as any)?.proId;
  const proId = proIdFromMeta || proIdFromPrice;

  if (!proId) {
    console.warn(`⚠️  Stripe subscription ${sub.id}: no proId in metadata, skipping`);
    return;
  }

  // Determina status subscription
  const status = sub.status; // active, trialing, canceled, incomplete, etc.
  const isActive = status === 'active' || status === 'trialing';

  // Aggiorna Firestore
  await db
    .collection('pros')
    .doc(proId)
    .update({
      subscriptionStatus: isActive ? 'active' : 'inactive',
      subscriptionProvider: 'stripe',
      subscriptionPlan: price?.nickname || price?.id || null,
      currentPeriodStart: new Date(sub.current_period_start * 1000),
      currentPeriodEnd: new Date(sub.current_period_end * 1000),
      lastPaymentAt:
        sub.latest_invoice != null
          ? new Date(sub.current_period_start * 1000)
          : null,
      cancelAtPeriodEnd: sub.cancel_at_period_end,
      stripeCustomerId: sub.customer as string,
      stripeSubscriptionId: sub.id,
      updatedAt: new Date()
    });

  console.log(
    `✅ PRO ${proId} subscription updated: status=${sub.status}, active=${isActive}`
  );
}

/**
 * Gestisce eventi invoice Stripe (pagamento)
 */
async function handleInvoiceEvent(event: Stripe.Event): Promise<void> {
  const invoice = event.data.object as Stripe.Invoice;
  const subId = invoice.subscription as string | null;

  if (!subId) {
    console.warn('⚠️  Stripe invoice without subscription, skipping');
    return;
  }

  // Recupera subscription per ottenere proId
  const sub = await stripe.subscriptions.retrieve(subId);
  const proId = (sub.metadata as any)?.proId;

  if (!proId) {
    console.warn(`⚠️  Stripe subscription ${subId}: no proId in metadata, skipping`);
    return;
  }

  // Aggiorna lastPaymentAt se pagamento riuscito
  if (event.type === 'invoice.payment_succeeded') {
    await db
      .collection('pros')
      .doc(proId)
      .update({
        lastPaymentAt: new Date(),
        updatedAt: new Date()
      });

    console.log(`✅ PRO ${proId} payment succeeded for invoice ${invoice.id}`);
  }

  // Gestisci pagamento fallito
  if (event.type === 'invoice.payment_failed') {
    await db
      .collection('pros')
      .doc(proId)
      .update({
        subscriptionStatus: 'past_due',
        updatedAt: new Date()
      });

    console.log(`⚠️  PRO ${proId} payment failed for invoice ${invoice.id}`);
  }
}
