#!/usr/bin/env node
/**
 * MY PET CARE - Stripe Setup Script
 * 
 * Crea automaticamente:
 * - 3 Products: PRO Monthly, PRO Quarterly, PRO Annual
 * - 3 Prices: €29/mese, €79/3 mesi, €299/anno
 * - 3 Coupons: FREE-1M, FREE-3M, FREE-12M (100% off)
 * - 3 Promotion Codes: Codici promo per i coupon
 * 
 * Utilizzo:
 *   echo "STRIPE_KEY=sk_test_..." > .env
 *   node --env-file=.env stripe_setup.ts
 */

import Stripe from 'stripe';

// Verifica che STRIPE_KEY sia impostato
if (!process.env.STRIPE_KEY) {
  console.error('❌ Errore: STRIPE_KEY non trovato nelle variabili d\'ambiente');
  console.error('💡 Crea un file .env con: STRIPE_KEY=sk_test_...');
  process.exit(1);
}

const stripe = new Stripe(process.env.STRIPE_KEY, { apiVersion: '2024-06-20' });

console.log('🚀 MY PET CARE - Stripe Setup Script');
console.log('====================================\n');

async function main() {
  try {
    // ========================================
    // STEP 1: Crea Products e Prices
    // ========================================
    console.log('📦 Creazione Products e Prices...\n');

    // Product 1: PRO Monthly
    const monthlyProduct = await stripe.products.create({
      name: 'PRO Monthly',
      description: 'Abbonamento mensile PRO per professionisti pet care',
      metadata: {
        app: 'my_pet_care',
        plan: 'monthly'
      }
    });

    const monthlyPrice = await stripe.prices.create({
      product: monthlyProduct.id,
      currency: 'eur',
      unit_amount: 2900, // €29.00
      recurring: {
        interval: 'month',
        interval_count: 1
      },
      metadata: {
        plan: 'monthly'
      }
    });

    console.log('✅ Product creato: PRO Monthly');
    console.log(`   Price ID: ${monthlyPrice.id}`);
    console.log(`   Prezzo: €29.00/mese\n`);

    // Product 2: PRO Quarterly
    const quarterlyProduct = await stripe.products.create({
      name: 'PRO Quarterly',
      description: 'Abbonamento trimestrale PRO per professionisti pet care',
      metadata: {
        app: 'my_pet_care',
        plan: 'quarterly'
      }
    });

    const quarterlyPrice = await stripe.prices.create({
      product: quarterlyProduct.id,
      currency: 'eur',
      unit_amount: 7900, // €79.00
      recurring: {
        interval: 'month',
        interval_count: 3
      },
      metadata: {
        plan: 'quarterly'
      }
    });

    console.log('✅ Product creato: PRO Quarterly');
    console.log(`   Price ID: ${quarterlyPrice.id}`);
    console.log(`   Prezzo: €79.00/3 mesi\n`);

    // Product 3: PRO Annual
    const annualProduct = await stripe.products.create({
      name: 'PRO Annual',
      description: 'Abbonamento annuale PRO per professionisti pet care',
      metadata: {
        app: 'my_pet_care',
        plan: 'annual'
      }
    });

    const annualPrice = await stripe.prices.create({
      product: annualProduct.id,
      currency: 'eur',
      unit_amount: 29900, // €299.00
      recurring: {
        interval: 'year',
        interval_count: 1
      },
      metadata: {
        plan: 'annual'
      }
    });

    console.log('✅ Product creato: PRO Annual');
    console.log(`   Price ID: ${annualPrice.id}`);
    console.log(`   Prezzo: €299.00/anno\n`);

    // ========================================
    // STEP 2: Crea Coupons e Promotion Codes
    // ========================================
    console.log('🎫 Creazione Coupons e Promotion Codes...\n');

    // Coupon 1: FREE-1M (1 mese gratis)
    const coupon1M = await stripe.coupons.create({
      name: 'FREE-1M',
      duration: 'repeating',
      duration_in_months: 1,
      percent_off: 100,
      metadata: {
        app: 'my_pet_care',
        type: 'admin_promo'
      }
    });

    console.log('✅ Coupon creato: FREE-1M');
    console.log(`   ID: ${coupon1M.id}`);
    console.log(`   Sconto: 100% per 1 mese\n`);

    const promo1M = await stripe.promotionCodes.create({
      coupon: coupon1M.id,
      code: 'FREE-1M',
      metadata: {
        app: 'my_pet_care',
        months: '1'
      }
    });

    console.log('✅ Promotion Code creato: FREE-1M');
    console.log(`   ID: ${promo1M.id}`);
    console.log(`   Code: ${promo1M.code}`);
    console.log(`   Restrictions: None\n`);

    // Coupon 2: FREE-3M (3 mesi gratis)
    const coupon3M = await stripe.coupons.create({
      name: 'FREE-3M',
      duration: 'repeating',
      duration_in_months: 3,
      percent_off: 100,
      metadata: {
        app: 'my_pet_care',
        type: 'admin_promo'
      }
    });

    console.log('✅ Coupon creato: FREE-3M');
    console.log(`   ID: ${coupon3M.id}`);
    console.log(`   Sconto: 100% per 3 mesi\n`);

    const promo3M = await stripe.promotionCodes.create({
      coupon: coupon3M.id,
      code: 'FREE-3M',
      metadata: {
        app: 'my_pet_care',
        months: '3'
      }
    });

    console.log('✅ Promotion Code creato: FREE-3M');
    console.log(`   ID: ${promo3M.id}`);
    console.log(`   Code: ${promo3M.code}`);
    console.log(`   Restrictions: None\n`);

    // Coupon 3: FREE-12M (12 mesi gratis)
    const coupon12M = await stripe.coupons.create({
      name: 'FREE-12M',
      duration: 'repeating',
      duration_in_months: 12,
      percent_off: 100,
      metadata: {
        app: 'my_pet_care',
        type: 'admin_promo'
      }
    });

    console.log('✅ Coupon creato: FREE-12M');
    console.log(`   ID: ${coupon12M.id}`);
    console.log(`   Sconto: 100% per 12 mesi\n`);

    const promo12M = await stripe.promotionCodes.create({
      coupon: coupon12M.id,
      code: 'FREE-12M',
      metadata: {
        app: 'my_pet_care',
        months: '12'
      }
    });

    console.log('✅ Promotion Code creato: FREE-12M');
    console.log(`   ID: ${promo12M.id}`);
    console.log(`   Code: ${promo12M.code}`);
    console.log(`   Restrictions: None\n`);

    // ========================================
    // STEP 3: Summary e Next Steps
    // ========================================
    console.log('🎉 Setup completato con successo!\n');
    console.log('📋 Prossimi Passi:');
    console.log('1. Copia i Price ID sopra nel file backend/.env:\n');
    console.log(`   STRIPE_PRICE_PRO_MONTHLY=${monthlyPrice.id}`);
    console.log(`   STRIPE_PRICE_PRO_QUARTERLY=${quarterlyPrice.id}`);
    console.log(`   STRIPE_PRICE_PRO_ANNUAL=${annualPrice.id}\n`);
    console.log('2. (Opzionale) Copia i Promotion Code ID:\n');
    console.log(`   STRIPE_PROMO_FREE_1M=${promo1M.id}`);
    console.log(`   STRIPE_PROMO_FREE_3M=${promo3M.id}`);
    console.log(`   STRIPE_PROMO_FREE_12M=${promo12M.id}\n`);
    console.log('3. Riavvia il backend per applicare le modifiche\n');
    console.log('✨ Fatto! Il sistema di abbonamenti è configurato.\n');

  } catch (error: any) {
    console.error('❌ Errore durante setup:', error.message);
    if (error.type === 'StripeAuthenticationError') {
      console.error('💡 Verifica che la STRIPE_KEY sia corretta e valida');
    }
    process.exit(1);
  }
}

// Esegui script
main();
