import Stripe from "stripe";
import { Request, Response } from "express";
import { config } from "../config";

const stripe = new Stripe(config.stripeSecretKey, {
  apiVersion: "2024-06-20",
});

export async function createStripeCheckoutSession(req: Request, res: Response) {
  try {
    const { priceId, successUrl, cancelUrl, customerEmail } = req.body;

    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: successUrl,
      cancel_url: cancelUrl,
      customer_email: customerEmail,
      allow_promotion_codes: true,
    });

    return res.json({ url: session.url });
  } catch (err) {
    console.error("Stripe checkout error", err);
    return res.status(500).json({ error: "Stripe checkout failed" });
  }
}

export async function stripeWebhook(req: Request, res: Response) {
  const sig = req.headers["stripe-signature"] as string | undefined;

  if (!sig) return res.status(400).send("Missing Stripe signature");

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      config.stripeWebhookSecret
    );
  } catch (err: any) {
    console.error("Stripe webhook signature verification failed", err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  try {
    switch (event.type) {
      case "customer.subscription.created":
      case "customer.subscription.updated":
      case "customer.subscription.deleted": {
        const subscription = event.data.object as Stripe.Subscription;
        // TODO: aggiorna Firestore con subscriptionStatus
        break;
      }
      default:
        console.log(`Unhandled Stripe event type ${event.type}`);
    }

    res.json({ received: true });
  } catch (err) {
    console.error("Stripe webhook error", err);
    res.status(500).send("Webhook handler error");
  }
}
