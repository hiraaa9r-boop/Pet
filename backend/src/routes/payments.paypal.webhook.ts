// backend/src/routes/payments.paypal.webhook.ts
// Webhook handler PayPal per eventi subscription/payment

import { Router } from 'express';
import fetch from 'node-fetch';
import { db } from '../firebase';
import { config } from '../config';

const router = Router();

/**
 * POST /api/payments/paypal/webhook
 * Gestisce webhook PayPal per eventi subscription
 * 
 * Eventi gestiti:
 * - BILLING.SUBSCRIPTION.CREATED
 * - BILLING.SUBSCRIPTION.ACTIVATED
 * - BILLING.SUBSCRIPTION.UPDATED
 * - BILLING.SUBSCRIPTION.CANCELLED
 * - BILLING.SUBSCRIPTION.SUSPENDED
 * - BILLING.SUBSCRIPTION.EXPIRED
 * - PAYMENT.SALE.COMPLETED
 */
router.post('/paypal/webhook', async (req, res) => {
  try {
    const body = req.body;

    // Headers PayPal per verifica firma
    const transmissionId = req.header('paypal-transmission-id');
    const transmissionTime = req.header('paypal-transmission-time');
    const certUrl = req.header('paypal-cert-url');
    const authAlgo = req.header('paypal-auth-algo');
    const transmissionSig = req.header('paypal-transmission-sig');
    const webhookId = config.paypalWebhookId;

    // Verifica presenza headers
    if (
      !transmissionId ||
      !transmissionTime ||
      !certUrl ||
      !authAlgo ||
      !transmissionSig
    ) {
      console.error('❌ PayPal webhook: missing headers');
      return res.status(400).send('Missing PayPal headers');
    }

    // Verifica firma webhook PayPal
    const token = await getPayPalAccessToken();
    const verifyResp = await fetch(
      `${config.paypalApi}/v1/notifications/verify-webhook-signature`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          transmission_id: transmissionId,
          transmission_time: transmissionTime,
          cert_url: certUrl,
          auth_algo: authAlgo,
          transmission_sig: transmissionSig,
          webhook_id: webhookId,
          webhook_event: body
        })
      }
    );

    const verifyData = (await verifyResp.json()) as any;

    if (!verifyResp.ok || verifyData.verification_status !== 'SUCCESS') {
      console.error('❌ PayPal webhook verification failed:', verifyData);
      return res.status(400).send('Invalid PayPal signature');
    }

    const eventType = body.event_type as string;
    console.log(`✅ PayPal webhook received: ${eventType}`);

    // Gestione eventi subscription
    if (eventType.startsWith('BILLING.SUBSCRIPTION.')) {
      await handleSubscriptionEvent(body);
    }

    // Gestione eventi payment
    if (eventType.startsWith('PAYMENT.')) {
      await handlePaymentEvent(body);
    }

    return res.json({ received: true });
  } catch (err: any) {
    console.error('❌ PayPal webhook error:', err.message);
    return res.status(500).send('Webhook handler error');
  }
});

/**
 * Gestisce eventi subscription PayPal
 */
async function handleSubscriptionEvent(body: any): Promise<void> {
  const resource = body.resource;
  const eventType = body.event_type as string;

  // Recupera proId da custom_id o subscription_id
  const proId = (resource.custom_id || resource.id) as string | undefined;
  const status = resource.status as string | undefined;

  if (!proId || !status) {
    console.warn('⚠️  PayPal subscription event: missing proId or status');
    return;
  }

  // Determina se subscription è attiva
  const isActive = status === 'ACTIVE' || status === 'APPROVED';

  // Aggiorna Firestore
  await db
    .collection('pros')
    .doc(proId)
    .update({
      subscriptionStatus: isActive ? 'active' : 'inactive',
      subscriptionProvider: 'paypal',
      subscriptionPlan: resource.plan_id ?? null,
      paypalOrderId: resource.id,
      updatedAt: new Date()
    });

  console.log(`✅ PRO ${proId} PayPal subscription updated: ${eventType}, status=${status}`);
}

/**
 * Gestisce eventi payment PayPal
 */
async function handlePaymentEvent(body: any): Promise<void> {
  const resource = body.resource;
  const eventType = body.event_type as string;

  // Recupera proId da custom field
  const proId = resource.custom as string | undefined;

  if (!proId) {
    console.warn('⚠️  PayPal payment event: missing proId in custom field');
    return;
  }

  // Se pagamento completato, aggiorna lastPaymentAt
  if (eventType === 'PAYMENT.SALE.COMPLETED') {
    await db
      .collection('pros')
      .doc(proId)
      .update({
        lastPaymentAt: new Date(),
        updatedAt: new Date()
      });

    console.log(`✅ PRO ${proId} PayPal payment completed: ${resource.id}`);
  }
}

/**
 * Ottiene access token PayPal (riusa token cached)
 */
let cachedPayPalToken: { accessToken: string; expiresAt: number } | null = null;

async function getPayPalAccessToken(): Promise<string> {
  // Riusa token se ancora valido
  if (
    cachedPayPalToken &&
    Date.now() < cachedPayPalToken.expiresAt - 60000
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

export default router;
