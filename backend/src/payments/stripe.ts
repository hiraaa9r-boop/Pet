// backend/src/payments/stripe.ts
import Stripe from "stripe";
import { Request, Response } from "express";
import { config } from "../config";
import { db } from "../firebase";

const stripe = new Stripe(config.stripeSecretKey, {
  apiVersion: "2024-06-20",
});

export async function createStripeCheckoutSession(req: Request, res: Response) {
  try {
    const { priceId, successUrl, cancelUrl, customerEmail, metadata } = req.body;

    if (!priceId) {
      return res.status(400).json({ error: "Missing priceId" });
    }

    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: successUrl || `${config.webBaseUrl}/subscribe/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: cancelUrl || `${config.webBaseUrl}/subscribe/cancel`,
      customer_email: customerEmail,
      allow_promotion_codes: true,
      metadata: metadata || {},
    });

    return res.json({ url: session.url, sessionId: session.id });
  } catch (err: any) {
    console.error("Stripe checkout error", err);
    return res.status(500).json({ 
      error: "Stripe checkout failed",
      message: err.message 
    });
  }
}

export async function stripeWebhook(req: Request, res: Response) {
  const sig = req.headers["stripe-signature"] as string | undefined;

  if (!sig) {
    return res.status(400).send("Missing Stripe signature");
  }

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
      case "customer.subscription.updated": {
        const subscription = event.data.object as Stripe.Subscription;
        const proId = subscription.metadata?.proId;

        if (proId) {
          const status = subscription.status === "active" || subscription.status === "trialing" 
            ? "active" 
            : "inactive";

          await db.collection(config.collections.pros).doc(proId).update({
            subscriptionStatus: status,
            subscriptionProvider: "stripe",
            subscriptionPlan: subscription.items.data[0]?.price.id || null,
            stripeCustomerId: subscription.customer as string,
            stripeSubscriptionId: subscription.id,
            currentPeriodStart: new Date(subscription.current_period_start * 1000),
            currentPeriodEnd: new Date(subscription.current_period_end * 1000),
            cancelAtPeriodEnd: subscription.cancel_at_period_end,
            updatedAt: new Date(),
          });

          console.log(`Stripe subscription ${event.type} for PRO ${proId}: ${status}`);
        }
        break;
      }

      case "customer.subscription.deleted": {
        const subscription = event.data.object as Stripe.Subscription;
        const proId = subscription.metadata?.proId;

        if (proId) {
          await db.collection(config.collections.pros).doc(proId).update({
            subscriptionStatus: "inactive",
            updatedAt: new Date(),
          });

          console.log(`Stripe subscription deleted for PRO ${proId}`);
        }
        break;
      }

      case "invoice.payment_succeeded": {
        const invoice = event.data.object as Stripe.Invoice;
        const subscriptionId = invoice.subscription as string;

        if (subscriptionId) {
          const subscription = await stripe.subscriptions.retrieve(subscriptionId);
          const proId = subscription.metadata?.proId;

          if (proId) {
            await db.collection(config.collections.pros).doc(proId).update({
              lastPaymentAt: new Date(),
              lastPaymentAmount: invoice.amount_paid / 100,
              lastPaymentCurrency: invoice.currency.toUpperCase(),
              updatedAt: new Date(),
            });

            console.log(`Stripe payment succeeded for PRO ${proId}`);
          }
        }
        break;
      }

      case "invoice.payment_failed": {
        const invoice = event.data.object as Stripe.Invoice;
        const subscriptionId = invoice.subscription as string;

        if (subscriptionId) {
          const subscription = await stripe.subscriptions.retrieve(subscriptionId);
          const proId = subscription.metadata?.proId;

          if (proId) {
            await db.collection(config.collections.pros).doc(proId).update({
              subscriptionStatus: "past_due",
              updatedAt: new Date(),
            });

            console.log(`Stripe payment failed for PRO ${proId}`);
          }
        }
        break;
      }

      default:
        console.log(`Unhandled Stripe event type ${event.type}`);
    }

    res.json({ received: true });
  } catch (err: any) {
    console.error("Error handling Stripe webhook", err);
    res.status(500).send("Webhook handler error");
  }
}
