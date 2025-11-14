/**
 * Stripe Webhook Handler
 * Gestisce eventi webhook da Stripe per aggiornare lo stato degli abbonamenti
 */

import { Router } from 'express';
import { raw } from 'body-parser';
import Stripe from 'stripe';
import { db } from '../firebase';

const router = Router();

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', {
  apiVersion: '2024-06-20',
});

/**
 * POST /api/payments/stripe/webhook
 * Endpoint webhook per ricevere eventi da Stripe
 * 
 * IMPORTANTE: Questo endpoint deve usare raw body parser!
 * Configurare in index.ts:
 *   app.use('/api/payments/stripe/webhook', raw({ type: 'application/json' }));
 */
router.post(
  '/stripe/webhook',
  async (req, res) => {
    const sig = req.headers['stripe-signature'] as string;
    
    if (!sig) {
      console.error('No stripe-signature header');
      return res.status(400).send('Webhook Error: No signature');
    }

    let event: Stripe.Event;

    try {
      // Verifica la firma del webhook
      event = stripe.webhooks.constructEvent(
        req.body,
        sig,
        process.env.STRIPE_WEBHOOK_SECRET || ''
      );
    } catch (err: any) {
      console.error('Webhook signature verification failed:', err.message);
      return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    console.log('Stripe webhook event received:', event.type);

    try {
      // Gestisci i vari tipi di eventi
      switch (event.type) {
        case 'customer.subscription.created':
        case 'customer.subscription.updated':
        case 'customer.subscription.deleted': {
          await handleSubscriptionChange(event.data.object as Stripe.Subscription);
          break;
        }

        case 'invoice.payment_succeeded': {
          await handlePaymentSucceeded(event.data.object as Stripe.Invoice);
          break;
        }

        case 'invoice.payment_failed': {
          await handlePaymentFailed(event.data.object as Stripe.Invoice);
          break;
        }

        case 'customer.subscription.trial_will_end': {
          await handleTrialWillEnd(event.data.object as Stripe.Subscription);
          break;
        }

        default:
          console.log(`Unhandled event type: ${event.type}`);
      }

      res.json({ received: true });
      
    } catch (err: any) {
      console.error('Stripe webhook handling error:', err);
      res.status(500).send('Webhook handler error');
    }
  }
);

/**
 * Gestisce cambiamenti nello stato dell'abbonamento
 */
async function handleSubscriptionChange(subscription: Stripe.Subscription) {
  const proId = subscription.metadata.proId || subscription.metadata.firebaseUid;
  
  if (!proId) {
    console.error('No proId in subscription metadata');
    return;
  }

  const status = subscription.status;
  const planNickname = subscription.items.data[0]?.plan.nickname || subscription.items.data[0]?.plan.id;
  
  // Determina lo stato dell'abbonamento
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

  // Aggiorna il documento PRO in Firestore
  await db.collection('pros').doc(proId).update({
    subscriptionStatus,
    subscriptionProvider: 'stripe',
    subscriptionPlan: planNickname,
    stripeSubscriptionId: subscription.id,
    currentPeriodStart: new Date(subscription.current_period_start * 1000),
    currentPeriodEnd: new Date(subscription.current_period_end * 1000),
    cancelAtPeriodEnd: subscription.cancel_at_period_end,
    updatedAt: new Date(),
  });

  console.log(`Updated PRO ${proId} subscription status to ${subscriptionStatus}`);
}

/**
 * Gestisce pagamento riuscito
 */
async function handlePaymentSucceeded(invoice: Stripe.Invoice) {
  const subscriptionId = invoice.subscription as string;
  
  if (!subscriptionId) {
    return;
  }

  const subscription = await stripe.subscriptions.retrieve(subscriptionId);
  const proId = subscription.metadata.proId || subscription.metadata.firebaseUid;
  
  if (!proId) {
    console.error('No proId in subscription metadata');
    return;
  }

  // Aggiorna la data dell'ultimo pagamento
  await db.collection('pros').doc(proId).update({
    lastPaymentAt: new Date(),
    lastPaymentAmount: invoice.amount_paid / 100, // Stripe usa centesimi
    lastPaymentCurrency: invoice.currency,
    updatedAt: new Date(),
  });

  console.log(`Payment succeeded for PRO ${proId}, amount: ${invoice.amount_paid / 100} ${invoice.currency}`);
  
  // TODO: Invia notifica al PRO del pagamento riuscito
}

/**
 * Gestisce pagamento fallito
 */
async function handlePaymentFailed(invoice: Stripe.Invoice) {
  const subscriptionId = invoice.subscription as string;
  
  if (!subscriptionId) {
    return;
  }

  const subscription = await stripe.subscriptions.retrieve(subscriptionId);
  const proId = subscription.metadata.proId || subscription.metadata.firebaseUid;
  
  if (!proId) {
    console.error('No proId in subscription metadata');
    return;
  }

  // Aggiorna lo stato a past_due se il pagamento è fallito
  await db.collection('pros').doc(proId).update({
    subscriptionStatus: 'past_due',
    updatedAt: new Date(),
  });

  console.log(`Payment failed for PRO ${proId}`);
  
  // TODO: Invia notifica al PRO del pagamento fallito
}

/**
 * Gestisce fine trial imminente
 */
async function handleTrialWillEnd(subscription: Stripe.Subscription) {
  const proId = subscription.metadata.proId || subscription.metadata.firebaseUid;
  
  if (!proId) {
    console.error('No proId in subscription metadata');
    return;
  }

  const trialEnd = new Date(subscription.trial_end! * 1000);
  console.log(`Trial will end for PRO ${proId} on ${trialEnd.toISOString()}`);
  
  // TODO: Invia notifica al PRO che il trial sta per finire (3 giorni prima)
}

export default router;
