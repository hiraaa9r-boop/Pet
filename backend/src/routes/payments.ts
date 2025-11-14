// backend/src/routes/payments.ts
// Route pagamenti: Stripe checkout + PayPal create-order

import { Router } from 'express';
import Stripe from 'stripe';
import fetch from 'node-fetch';
import { db } from '../firebase';
import { config } from '../config';

const router = Router();

// Inizializza Stripe
const stripe = new Stripe(config.stripeSecretKey, {
  apiVersion: '2024-06-20'
});

/**
 * POST /api/payments/stripe/checkout
 * Crea una sessione di checkout Stripe per abbonamento PRO
 * 
 * Body:
 * - proId: string (ID del professionista)
 * - priceId: string (ID del piano Stripe, es. price_1234567890)
 * - successUrl?: string (default: webBaseUrl/subscribe/success?session_id={CHECKOUT_SESSION_ID})
 * - cancelUrl?: string (default: webBaseUrl/subscribe/cancel)
 * 
 * Response:
 * - url: string (URL della pagina di checkout Stripe)
 */
router.post('/stripe/checkout', async (req, res) => {
  try {
    const { proId, priceId, successUrl, cancelUrl } = req.body;

    // Validazione input
    if (!proId || !priceId) {
      return res.status(400).json({ error: 'Missing required params: proId, priceId' });
    }

    // Verifica esistenza PRO
    const proSnap = await db.collection('pros').doc(proId).get();
    if (!proSnap.exists) {
      return res.status(404).json({ error: 'PRO not found' });
    }

    const pro = proSnap.data() || {};
    const stripeCustomerId = pro.stripeCustomerId as string | undefined;

    // Crea sessione checkout Stripe
    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      customer: stripeCustomerId,
      line_items: [{ price: priceId, quantity: 1 }],
      success_url:
        successUrl ||
        `${config.webBaseUrl}/subscribe/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: cancelUrl || `${config.webBaseUrl}/subscribe/cancel`,
      metadata: { proId }
    });

    console.log(`✅ Stripe checkout session created: ${session.id} for PRO: ${proId}`);

    return res.json({ url: session.url });
  } catch (err: any) {
    console.error('❌ Stripe checkout error:', err.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

/**
 * Funzione helper: Ottiene access token PayPal via OAuth2
 * Cache il token per evitare richieste ripetute
 */
let cachedPayPalToken: { accessToken: string; expiresAt: number } | null = null;

async function getPayPalAccessToken(): Promise<string> {
  // Riusa token se ancora valido
  if (
    cachedPayPalToken &&
    Date.now() < cachedPayPalToken.expiresAt - 60000 // 1 minuto di margine
  ) {
    return cachedPayPalToken.accessToken;
  }

  // Richiedi nuovo token
  const auth = Buffer.from(
    `${config.paypalClientId}:${config.paypalSecret}`
  ).toString('base64');

  const resp = await fetch(`${config.paypalApi}/v1/oauth2/token`, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${auth}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: 'grant_type=client_credentials'
  });

  const data = (await resp.json()) as any;

  if (!resp.ok) {
    console.error('❌ PayPal token error:', data);
    throw new Error('PayPal authentication failed');
  }

  // Cache token
  cachedPayPalToken = {
    accessToken: data.access_token as string,
    expiresAt: Date.now() + (data.expires_in as number) * 1000
  };

  return cachedPayPalToken.accessToken;
}

/**
 * POST /api/payments/paypal/create-order
 * Crea un ordine PayPal per pagamento una tantum
 * 
 * Body:
 * - proId: string (ID del professionista)
 * - amount: string (importo in EUR, es. "9.99")
 * - returnUrl?: string (default: webBaseUrl/subscribe/success)
 * - cancelUrl?: string (default: webBaseUrl/subscribe/cancel)
 * 
 * Response:
 * - approvalLink: string (URL per approvazione ordine PayPal)
 */
router.post('/paypal/create-order', async (req, res) => {
  try {
    const { proId, amount, returnUrl, cancelUrl } = req.body;

    // Validazione input
    if (!proId || !amount) {
      return res.status(400).json({ error: 'Missing required params: proId, amount' });
    }

    // Ottieni access token
    const token = await getPayPalAccessToken();

    // Crea ordine PayPal
    const resp = await fetch(`${config.paypalApi}/v2/checkout/orders`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        intent: 'CAPTURE',
        purchase_units: [
          {
            reference_id: proId,
            custom_id: proId,
            amount: {
              currency_code: 'EUR',
              value: amount
            },
            description: 'MyPetCare PRO Subscription'
          }
        ],
        application_context: {
          return_url: returnUrl || `${config.webBaseUrl}/subscribe/success`,
          cancel_url: cancelUrl || `${config.webBaseUrl}/subscribe/cancel`,
          brand_name: 'MyPetCare',
          user_action: 'PAY_NOW'
        }
      })
    });

    const data = (await resp.json()) as any;

    if (!resp.ok) {
      console.error('❌ PayPal create order error:', data);
      return res.status(500).json({ error: 'PayPal order creation failed' });
    }

    // Estrai link approvazione
    const approvalLink = data.links?.find((l: any) => l.rel === 'approve')?.href;

    if (!approvalLink) {
      console.error('❌ PayPal approval link not found in response');
      return res.status(500).json({ error: 'PayPal approval link missing' });
    }

    console.log(`✅ PayPal order created: ${data.id} for PRO: ${proId}`);

    return res.json({ approvalLink });
  } catch (err: any) {
    console.error('❌ PayPal create-order error:', err.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

export default router;
