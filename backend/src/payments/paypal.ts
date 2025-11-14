// backend/src/payments/paypal.ts
import fetch from "node-fetch";
import { Request, Response } from "express";
import { config } from "../config";
import { db } from "../firebase";

async function getPayPalAccessToken(): Promise<string> {
  const auth = Buffer.from(
    `${config.paypalClientId}:${config.paypalSecret}`
  ).toString("base64");

  const res = await fetch(`${config.paypalApiBaseUrl}/v1/oauth2/token`, {
    method: "POST",
    headers: {
      Authorization: `Basic ${auth}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: "grant_type=client_credentials",
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`PayPal token error: ${res.status} ${body}`);
  }

  const data = (await res.json()) as { access_token: string };
  return data.access_token;
}

export async function createPayPalSubscription(req: Request, res: Response) {
  try {
    const { planId, returnUrl, cancelUrl, customId } = req.body;

    if (!planId) {
      return res.status(400).json({ error: "Missing planId" });
    }

    const accessToken = await getPayPalAccessToken();

    const response = await fetch(`${config.paypalApiBaseUrl}/v1/billing/subscriptions`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        plan_id: planId,
        custom_id: customId,
        application_context: {
          user_action: "SUBSCRIBE_NOW",
          return_url: returnUrl || `${config.webBaseUrl}/subscribe/success`,
          cancel_url: cancelUrl || `${config.webBaseUrl}/subscribe/cancel`,
        },
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error("PayPal create subscription error", data);
      return res.status(500).json({ 
        error: "PayPal subscription failed",
        details: data 
      });
    }

    const approveLink = (data.links || []).find(
      (l: any) => l.rel === "approve"
    )?.href;

    return res.json({ 
      approveLink,
      subscriptionId: data.id 
    });
  } catch (err: any) {
    console.error("PayPal subscription error", err);
    return res.status(500).json({ 
      error: "PayPal subscription failed",
      message: err.message 
    });
  }
}

export async function paypalWebhook(req: Request, res: Response) {
  // TODO: Implementare validazione firma con PAYPAL_WEBHOOK_ID
  // https://developer.paypal.com/docs/api-basics/notifications/webhooks/notification-messages/#link-verifysignature
  
  try {
    const event = req.body;
    const eventType = event.event_type;

    console.log(`PayPal webhook received: ${eventType}`);

    switch (eventType) {
      case "BILLING.SUBSCRIPTION.ACTIVATED": {
        const subscription = event.resource;
        const proId = subscription.custom_id;

        if (proId) {
          await db.collection(config.collections.pros).doc(proId).update({
            subscriptionStatus: "active",
            subscriptionProvider: "paypal",
            subscriptionPlan: subscription.plan_id,
            paypalSubscriptionId: subscription.id,
            currentPeriodStart: new Date(subscription.start_time),
            currentPeriodEnd: new Date(subscription.billing_info?.next_billing_time || Date.now()),
            updatedAt: new Date(),
          });

          console.log(`PayPal subscription activated for PRO ${proId}`);
        }
        break;
      }

      case "BILLING.SUBSCRIPTION.UPDATED": {
        const subscription = event.resource;
        const proId = subscription.custom_id;

        if (proId) {
          const status = subscription.status === "ACTIVE" ? "active" : "inactive";

          await db.collection(config.collections.pros).doc(proId).update({
            subscriptionStatus: status,
            currentPeriodEnd: new Date(subscription.billing_info?.next_billing_time || Date.now()),
            updatedAt: new Date(),
          });

          console.log(`PayPal subscription updated for PRO ${proId}: ${status}`);
        }
        break;
      }

      case "BILLING.SUBSCRIPTION.CANCELLED":
      case "BILLING.SUBSCRIPTION.EXPIRED":
      case "BILLING.SUBSCRIPTION.SUSPENDED": {
        const subscription = event.resource;
        const proId = subscription.custom_id;

        if (proId) {
          await db.collection(config.collections.pros).doc(proId).update({
            subscriptionStatus: "inactive",
            updatedAt: new Date(),
          });

          console.log(`PayPal subscription ${eventType} for PRO ${proId}`);
        }
        break;
      }

      case "PAYMENT.SALE.COMPLETED": {
        const sale = event.resource;
        const subscriptionId = sale.billing_agreement_id;

        if (subscriptionId) {
          // Trova PRO by paypalSubscriptionId
          const prosSnap = await db.collection(config.collections.pros)
            .where("paypalSubscriptionId", "==", subscriptionId)
            .limit(1)
            .get();

          if (!prosSnap.empty) {
            const proDoc = prosSnap.docs[0];
            await proDoc.ref.update({
              lastPaymentAt: new Date(),
              lastPaymentAmount: parseFloat(sale.amount?.total || "0"),
              lastPaymentCurrency: sale.amount?.currency || "EUR",
              updatedAt: new Date(),
            });

            console.log(`PayPal payment completed for PRO ${proDoc.id}`);
          }
        }
        break;
      }

      default:
        console.log(`Unhandled PayPal event type ${eventType}`);
    }

    res.json({ received: true });
  } catch (err: any) {
    console.error("PayPal webhook error", err);
    res.status(500).send("Webhook handler error");
  }
}
