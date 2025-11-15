import fetch from "node-fetch";
import { Request, Response } from "express";
import { config } from "../config";

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
    const { planId, returnUrl, cancelUrl } = req.body;
    const accessToken = await getPayPalAccessToken();

    const response = await fetch(`${config.paypalApiBaseUrl}/v1/billing/subscriptions`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        plan_id: planId,
        application_context: {
          user_action: "SUBSCRIBE_NOW",
          return_url: returnUrl,
          cancel_url: cancelUrl,
        },
      }),
    });

    const data = await response.json();
    const approveLink = (data.links || []).find(
      (l: any) => l.rel === "approve"
    )?.href;

    return res.json({ approveLink });
  } catch (err) {
    console.error("PayPal subscription error", err);
    return res.status(500).json({ error: "PayPal subscription failed" });
  }
}

export async function paypalWebhook(req: Request, res: Response) {
  try {
    const event = req.body;

    switch (event.event_type) {
      case "BILLING.SUBSCRIPTION.ACTIVATED":
      case "BILLING.SUBSCRIPTION.UPDATED":
      case "BILLING.SUBSCRIPTION.CANCELLED":
      case "BILLING.SUBSCRIPTION.EXPIRED":
        // TODO: aggiorna Firestore -> pros/{uid}.subscriptionStatus
        break;
      default:
        console.log(`Unhandled PayPal event type ${event.event_type}`);
    }

    res.json({ received: true });
  } catch (err) {
    console.error("PayPal webhook error", err);
    res.status(500).send("Webhook handler error");
  }
}
