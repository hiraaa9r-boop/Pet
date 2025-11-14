/**
 * PayPal Payment Routes
 * Gestisce checkout e creazione ordini PayPal per abbonamenti PRO
 */

import { Router } from 'express';
import fetch from 'node-fetch';
import { db } from '../firebase';

const router = Router();

const PAYPAL_API = process.env.PAYPAL_API || 'https://api-m.sandbox.paypal.com';
const PAYPAL_CLIENT_ID = process.env.PAYPAL_CLIENT_ID || '';
const PAYPAL_SECRET = process.env.PAYPAL_SECRET || '';

/**
 * Ottiene un access token PayPal per le API calls
 */
async function getPayPalAccessToken(): Promise<string> {
  const auth = Buffer.from(`${PAYPAL_CLIENT_ID}:${PAYPAL_SECRET}`).toString('base64');
  
  const response = await fetch(`${PAYPAL_API}/v1/oauth2/token`, {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${auth}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: 'grant_type=client_credentials',
  });

  const data = await response.json() as any;
  return data.access_token as string;
}

/**
 * POST /api/payments/paypal/create-order
 * Crea un ordine PayPal per l'abbonamento PRO
 * 
 * Body:
 * - proId: string
 * - planId: string (PayPal Plan ID o amount)
 * - planType: 'MONTHLY' | 'YEARLY'
 * - returnUrl: string
 * - cancelUrl: string
 */
router.post('/paypal/create-order', async (req, res) => {
  try {
    const { proId, planId, planType, returnUrl, cancelUrl } = req.body;
    
    if (!proId || !planType) {
      return res.status(400).json({ error: 'Missing required parameters' });
    }

    // Verifica che il PRO esista
    const proSnap = await db.collection('pros').doc(proId).get();
    if (!proSnap.exists) {
      return res.status(404).json({ error: 'PRO not found' });
    }

    const token = await getPayPalAccessToken();
    
    // Determina l'importo in base al piano
    const amount = planType === 'MONTHLY' ? '9.99' : '99.99';
    const currency = 'EUR';

    // Crea l'ordine PayPal
    const response = await fetch(`${PAYPAL_API}/v2/checkout/orders`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        intent: 'CAPTURE',
        purchase_units: [
          {
            reference_id: proId,
            description: `MyPetCare PRO - ${planType} Subscription`,
            amount: {
              currency_code: currency,
              value: amount,
            },
            custom_id: `${proId}|${planType}`,
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
    });

    const data = await response.json() as any;
    
    if (data.error) {
      console.error('PayPal create order error:', data);
      return res.status(500).json({ error: data.error });
    }

    // Trova il link di approvazione
    const approvalLink = data.links?.find((link: any) => link.rel === 'approve')?.href;
    
    if (!approvalLink) {
      return res.status(500).json({ error: 'No approval link found' });
    }

    return res.json({
      orderId: data.id,
      approvalLink,
    });
    
  } catch (err: any) {
    console.error('PayPal create order error:', err);
    return res.status(500).json({ 
      error: 'Internal server error',
      message: err.message,
    });
  }
});

/**
 * POST /api/payments/paypal/capture-order
 * Cattura un ordine PayPal dopo l'approvazione dell'utente
 * 
 * Body:
 * - orderId: string
 * - proId: string
 */
router.post('/paypal/capture-order', async (req, res) => {
  try {
    const { orderId, proId } = req.body;
    
    if (!orderId || !proId) {
      return res.status(400).json({ error: 'Missing orderId or proId' });
    }

    const token = await getPayPalAccessToken();
    
    // Cattura l'ordine
    const response = await fetch(`${PAYPAL_API}/v2/checkout/orders/${orderId}/capture`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    });

    const data = await response.json() as any;
    
    if (data.error || data.status !== 'COMPLETED') {
      console.error('PayPal capture order error:', data);
      return res.status(500).json({ error: data.error || 'Capture failed' });
    }

    // Estrai informazioni dal custom_id (proId|planType)
    const customId = data.purchase_units[0]?.custom_id || '';
    const [_, planType] = customId.split('|');
    
    // Aggiorna lo stato dell'abbonamento in Firestore
    const now = new Date();
    const periodEnd = new Date(now);
    
    if (planType === 'MONTHLY') {
      periodEnd.setMonth(periodEnd.getMonth() + 1);
    } else if (planType === 'YEARLY') {
      periodEnd.setFullYear(periodEnd.getFullYear() + 1);
    }

    await db.collection('pros').doc(proId).update({
      subscriptionStatus: 'active',
      subscriptionProvider: 'paypal',
      subscriptionPlan: planType,
      paypalOrderId: data.id,
      currentPeriodStart: now,
      currentPeriodEnd: periodEnd,
      lastPaymentAt: now,
      lastPaymentAmount: parseFloat(data.purchase_units[0]?.amount?.value || '0'),
      lastPaymentCurrency: data.purchase_units[0]?.amount?.currency_code || 'EUR',
      updatedAt: now,
    });

    console.log(`PayPal order captured for PRO ${proId}, order: ${orderId}`);

    return res.json({
      status: 'COMPLETED',
      orderId: data.id,
      subscriptionStatus: 'active',
    });
    
  } catch (err: any) {
    console.error('PayPal capture order error:', err);
    return res.status(500).json({ 
      error: 'Internal server error',
      message: err.message,
    });
  }
});

/**
 * GET /api/payments/paypal/order/:orderId
 * Recupera informazioni su un ordine PayPal
 */
router.get('/paypal/order/:orderId', async (req, res) => {
  try {
    const { orderId } = req.params;
    const token = await getPayPalAccessToken();
    
    const response = await fetch(`${PAYPAL_API}/v2/checkout/orders/${orderId}`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    });

    const data = await response.json() as any;
    
    return res.json({
      orderId: data.id,
      status: data.status,
      amount: data.purchase_units[0]?.amount,
    });
    
  } catch (err: any) {
    console.error('PayPal get order error:', err);
    return res.status(500).json({ 
      error: 'Internal server error',
      message: err.message,
    });
  }
});

export default router;
