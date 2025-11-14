/**
 * Stripe Payment Routes
 * Gestisce checkout session e creazione abbonamenti PRO
 */

import { Router } from 'express';
import Stripe from 'stripe';
import { db } from '../firebase';

const router = Router();

// Inizializza Stripe con la secret key
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', {
  apiVersion: '2024-06-20',
});

/**
 * POST /api/payments/stripe/checkout
 * Crea una Stripe Checkout Session per l'abbonamento PRO
 * 
 * Body:
 * - proId: string (ID del professionista)
 * - priceId: string (Stripe Price ID del piano)
 * - successUrl: string (URL di ritorno dopo successo)
 * - cancelUrl: string (URL di ritorno dopo annullamento)
 */
router.post('/stripe/checkout', async (req, res) => {
  try {
    const { proId, priceId, successUrl, cancelUrl } = req.body;
    
    // Validazione parametri
    if (!proId || !priceId) {
      return res.status(400).json({ error: 'Missing required parameters: proId, priceId' });
    }

    // Verifica che il PRO esista
    const proSnap = await db.collection('pros').doc(proId).get();
    if (!proSnap.exists) {
      return res.status(404).json({ error: 'PRO not found' });
    }

    const proData = proSnap.data()!;
    const email = proData.email;
    
    // Se il PRO ha già un Stripe Customer ID, lo riutilizziamo
    let customerId = proData.stripeCustomerId;
    
    // Altrimenti creiamo un nuovo customer
    if (!customerId) {
      const customer = await stripe.customers.create({
        email,
        metadata: {
          proId,
          firebaseUid: proId,
        },
      });
      customerId = customer.id;
      
      // Salviamo il customer ID in Firestore
      await db.collection('pros').doc(proId).update({
        stripeCustomerId: customerId,
        updatedAt: new Date(),
      });
    }

    // Crea la Checkout Session
    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      customer: customerId,
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      success_url: `${successUrl}?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: cancelUrl,
      metadata: {
        proId,
        firebaseUid: proId,
      },
      subscription_data: {
        metadata: {
          proId,
          firebaseUid: proId,
        },
      },
    });

    // Ritorna l'URL della checkout page
    return res.json({ 
      url: session.url,
      sessionId: session.id,
    });
    
  } catch (err: any) {
    console.error('Stripe checkout error:', err);
    return res.status(500).json({ 
      error: 'Internal server error',
      message: err.message,
    });
  }
});

/**
 * GET /api/payments/stripe/session/:sessionId
 * Recupera informazioni su una checkout session
 */
router.get('/stripe/session/:sessionId', async (req, res) => {
  try {
    const { sessionId } = req.params;
    
    const session = await stripe.checkout.sessions.retrieve(sessionId);
    
    return res.json({
      status: session.status,
      paymentStatus: session.payment_status,
      customerId: session.customer,
      subscriptionId: session.subscription,
    });
    
  } catch (err: any) {
    console.error('Stripe session retrieve error:', err);
    return res.status(500).json({ 
      error: 'Internal server error',
      message: err.message,
    });
  }
});

/**
 * POST /api/payments/stripe/portal
 * Crea un link al Customer Portal per gestire l'abbonamento
 */
router.post('/stripe/portal', async (req, res) => {
  try {
    const { proId, returnUrl } = req.body;
    
    if (!proId) {
      return res.status(400).json({ error: 'Missing proId' });
    }

    const proSnap = await db.collection('pros').doc(proId).get();
    if (!proSnap.exists) {
      return res.status(404).json({ error: 'PRO not found' });
    }

    const proData = proSnap.data()!;
    const customerId = proData.stripeCustomerId;
    
    if (!customerId) {
      return res.status(400).json({ error: 'No Stripe customer found' });
    }

    const session = await stripe.billingPortal.sessions.create({
      customer: customerId,
      return_url: returnUrl,
    });

    return res.json({ url: session.url });
    
  } catch (err: any) {
    console.error('Stripe portal error:', err);
    return res.status(500).json({ 
      error: 'Internal server error',
      message: err.message,
    });
  }
});

export default router;
