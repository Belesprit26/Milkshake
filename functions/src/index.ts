import { HttpsError, onCall, onRequest } from "firebase-functions/v2/https";
import { defineSecret, defineString } from "firebase-functions/params";
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import Stripe from "stripe";

initializeApp();

export const health = onRequest((_req: any, res: any) => {
  res.status(200).send("ok");
});

const seedToken = defineSecret("SEED_TOKEN");
const adminToken = defineSecret("ADMIN_TOKEN");
const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");
const webBaseUrl = defineString("WEB_BASE_URL");

export const seedFirestore = onRequest(
  { secrets: [seedToken], invoker: "public" as any },
  async (req: any, res: any) => {
  try {
    const _req = req as any;
    const _res = res as any;
    const provided = (_req.query.token ?? "").toString();
    if (!provided || provided !== seedToken.value()) {
      _res.status(401).send("Unauthorized");
      return;
    }

    const db = getFirestore();

    const configRef = db.collection("config").doc("current");
    await configRef.set(
      {
        vatPercent: 15,
        maxDrinks: 10,
        baseDrinkPriceCents: 2500,
        version: "v1",
        discount: {
          maxDiscountCents: 5000,
          tiers: [
            { minPaidOrders: 3, minDrinksPerOrder: 2, percentOff: 5 },
            { minPaidOrders: 5, minDrinksPerOrder: 3, percentOff: 10 },
            { minPaidOrders: 10, minDrinksPerOrder: 3, percentOff: 15 },
          ],
        },
        seededAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    const lookups = [
      { id: "flavour_vanilla", type: "flavour", name: "Vanilla", priceDeltaCents: 100, active: true },
      { id: "flavour_strawberry", type: "flavour", name: "Strawberry", priceDeltaCents: 100, active: true },
      { id: "flavour_chocolate", type: "flavour", name: "Chocolate", priceDeltaCents: 150, active: true },
      { id: "flavour_coffee", type: "flavour", name: "Coffee", priceDeltaCents: 150, active: true },
      { id: "flavour_banana", type: "flavour", name: "Banana", priceDeltaCents: 100, active: true },
      { id: "flavour_oreo", type: "flavour", name: "Oreo", priceDeltaCents: 200, active: true },
      { id: "flavour_bar_one", type: "flavour", name: "Bar one", priceDeltaCents: 250, active: true },

      {
        id: "topping_frozen_strawberries",
        type: "topping",
        name: "Frozen Strawberries",
        priceDeltaCents: 200,
        active: true,
      },
      {
        id: "topping_freeze_dried_banana",
        type: "topping",
        name: "Freeze-dried banana",
        priceDeltaCents: 200,
        active: true,
      },
      { id: "topping_oreo_crumbs", type: "topping", name: "Oreo crumbs", priceDeltaCents: 250, active: true },
      { id: "topping_bar_one_syrup", type: "topping", name: "Bar one syrup", priceDeltaCents: 300, active: true },
      {
        id: "topping_coffee_powder_choc",
        type: "topping",
        name: "Coffee powder with choc",
        priceDeltaCents: 250,
        active: true,
      },
      {
        id: "topping_choc_vermicelli",
        type: "topping",
        name: "Chocolate vermicelli",
        priceDeltaCents: 150,
        active: true,
      },

      {
        id: "consistency_double_thick",
        type: "consistency",
        name: "Double thick",
        priceDeltaCents: 300,
        active: true,
      },
      { id: "consistency_thick", type: "consistency", name: "Thick", priceDeltaCents: 150, active: true },
      { id: "consistency_milky", type: "consistency", name: "Milky", priceDeltaCents: 0, active: true },
      { id: "consistency_icy", type: "consistency", name: "Icy", priceDeltaCents: -100, active: true },

      { id: "store_southdowns", type: "store", name: "Southdowns (Irene)", priceDeltaCents: 0, active: true },
      { id: "store_menlyn", type: "store", name: "Menlyn Maine", priceDeltaCents: 0, active: true },
    ] as const;

    const batch = db.batch();
    for (const finalLookup of lookups) {
      const ref = db.collection("lookups").doc(finalLookup.id);
      batch.set(
        ref,
        {
          type: finalLookup.type,
          name: finalLookup.name,
          priceDeltaCents: finalLookup.priceDeltaCents,
          active: finalLookup.active,
          seededAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }
    await batch.commit();

    _res.status(200).json({
      ok: true,
      seeded: {
        config: "config/current",
        lookups: lookups.length,
      },
    });
  } catch (e) {
    (res as any).status(500).send(`Seed failed: ${String(e)}`);
  }
},
);

export const setUserRole = onRequest(
  { secrets: [adminToken], invoker: "public" as any },
  async (req: any, res: any) => {
    try {
      const provided = (req.query.token ?? "").toString();
      if (!provided || provided !== adminToken.value()) {
        res.status(401).send("Unauthorized");
        return;
      }

      const uid = (req.query.uid ?? "").toString();
      const email = (req.query.email ?? "").toString();
      const role = (req.query.role ?? "").toString();

      let targetUid = uid;
      if (!targetUid && email) {
        const u = await getAuth().getUserByEmail(email);
        targetUid = u.uid;
      }

      if (!targetUid) {
        res.status(400).send("Missing uid or email");
        return;
      }

      if (!role) {
        await getAuth().setCustomUserClaims(targetUid, {});
        res.status(200).json({ ok: true, uid: targetUid, role: null });
        return;
      }

      await getAuth().setCustomUserClaims(targetUid, { role });
      res.status(200).json({ ok: true, uid: targetUid, role });
    } catch (e) {
      res.status(500).send(`Failed: ${String(e)}`);
    }
  },
);

export const createCheckoutSession = onCall(
  { secrets: [stripeSecretKey] },
  async (request: any) => {
    const auth = request.auth;
    if (!auth?.uid) {
      throw new HttpsError("unauthenticated", "You must be signed in.");
    }
    const orderId = (request.data?.orderId ?? "").toString();
    if (!orderId) {
      throw new HttpsError("invalid-argument", "Missing orderId.");
    }

    const db = getFirestore();
    const ref = db.collection("orders").doc(orderId);
    const snap = await ref.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "Order not found.");
    }
    const data = snap.data() as any;
    if (!data || data.uid !== auth.uid) {
      throw new HttpsError("permission-denied", "Order does not belong to you.");
    }
    if (data.status !== "pending_payment") {
      throw new HttpsError(
        "failed-precondition",
        "Order must be pending_payment before checkout can start.",
      );
    }

    const totals = data.totals ?? {};
    const totalCents = Number(totals.totalCents ?? 0);
    if (!Number.isFinite(totalCents) || totalCents <= 0) {
      throw new HttpsError("failed-precondition", "Order total is invalid.");
    }

    const stripe = new Stripe(stripeSecretKey.value(), {
      apiVersion: "2024-06-20",
    });

    const base = _inferWebBaseUrl(request) || (webBaseUrl.value() as any);
    if (!base || typeof base !== "string") {
      throw new HttpsError(
        "failed-precondition",
        "WEB_BASE_URL is not set and request origin could not be inferred.",
      );
    }

    const successUrl = `${base}/?payment=success&orderId=${encodeURIComponent(orderId)}`;
    const cancelUrl = `${base}/?payment=cancel&orderId=${encodeURIComponent(orderId)}`;

    const authUser = await getAuth().getUser(auth.uid);
    const email = authUser.email ?? data?.email ?? undefined;

    const session = await stripe.checkout.sessions.create({
      mode: "payment",
      success_url: successUrl,
      cancel_url: cancelUrl,
      customer_email: email,
      metadata: {
        orderId,
        uid: auth.uid,
      },
      line_items: [
        {
          quantity: 1,
          price_data: {
            currency: "zar",
            unit_amount: Math.round(totalCents),
            product_data: {
              name: "Milkshake order",
            },
          },
        },
      ],
    });

    await ref.set(
      {
        email: email ?? null,
        payment: {
          provider: "stripe",
          checkoutSessionId: session.id,
          status: "created",
          createdAt: FieldValue.serverTimestamp(),
        },
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    return { checkoutUrl: session.url };
  },
);

function _inferWebBaseUrl(request: any): string | null {
  const origin = request?.rawRequest?.headers?.origin;
  if (typeof origin === "string" && origin.startsWith("http")) return origin;

  const referer = request?.rawRequest?.headers?.referer;
  if (typeof referer === "string" && referer.startsWith("http")) {
    try {
      const u = new URL(referer);
      return `${u.protocol}//${u.host}`;
    } catch {
      return null;
    }
  }
  return null;
}

export const stripeWebhook = onRequest(
  { secrets: [stripeSecretKey, stripeWebhookSecret], invoker: "public" as any },
  async (req: any, res: any) => {
    try {
      const stripe = new Stripe(stripeSecretKey.value(), { apiVersion: "2024-06-20" });
      const sig = req.headers["stripe-signature"];
      if (!sig) {
        res.status(400).send("Missing signature");
        return;
      }

      const event = stripe.webhooks.constructEvent(
        req.rawBody,
        sig,
        stripeWebhookSecret.value(),
      );

      if (event.type === "checkout.session.completed") {
        const session = event.data.object as any;
        const orderId = session?.metadata?.orderId;
        const customerEmail =
          session?.customer_details?.email ?? session?.customer_email ?? null;
        if (orderId) {
          const db = getFirestore();
          const ref = db.collection("orders").doc(orderId);
          await ref.set(
            {
              status: "paid",
              email: customerEmail,
              payment: {
                provider: "stripe",
                checkoutSessionId: session.id,
                paymentIntentId: session.payment_intent ?? null,
                status: "paid",
                paidAt: FieldValue.serverTimestamp(),
              },
              updatedAt: FieldValue.serverTimestamp(),
            },
            { merge: true },
          );

          if (customerEmail) {
            const subject = `Milky Shaky - Payment received (${orderId})`;
            const text = `Your payment was successful.\n\nOrder: ${orderId}\nStatus: paid\n\nThank you for your order.`;
            const html = `<p>Your payment was successful.</p><p><strong>Order:</strong> ${orderId}<br/><strong>Status:</strong> paid</p><p>Thank you for your order.</p>`;
            await db.collection("mail").add({
              to: [customerEmail],
              message: {
                subject,
                text,
                html,
              },
              createdAt: FieldValue.serverTimestamp(),
              orderId,
            });
          }
        }
      }

      res.json({ received: true });
    } catch (e) {
      res.status(400).send(`Webhook Error: ${String(e)}`);
    }
  },
);


