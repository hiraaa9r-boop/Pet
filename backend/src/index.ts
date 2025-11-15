// backend/src/index.ts
// MyPetCare Backend - Entry Point Express Server

import express from 'express';
import helmet from 'helmet';
import dotenv from 'dotenv';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';

import { config, validateConfig } from './config';
import { corsMiddleware } from './middleware/cors';

// Routes
import { authRouter } from './routes/auth';
import { paymentsRouter } from './routes/payments';
import notificationsRouter from './routes/notifications';
import adminRouter from './routes/admin';
import prosRouter from './routes/pros';
import bookingsRouter from './routes/bookings';
import gdprRouter from './routes/gdpr';

// Webhook Handlers
import { stripeWebhookHandler } from './routes/payments.stripe.webhook';
// import paypalWebhookRouter from './routes/payments.paypal.webhook'; // TODO: Fix TypeScript errors

// ==============================
// ENV & CONFIG
// ==============================
dotenv.config();      // per uso locale con .env
validateConfig();     // controlla che tutte le variabili ci siano

const app = express();

// ==============================
// WEBHOOKS (DEVONO essere PRIMA di express.json())
// ==============================

// Stripe webhook: DEVE usare raw body per signature verification
app.post(
  '/webhooks/stripe',
  express.raw({ type: 'application/json' }),
  stripeWebhookHandler
);

// PayPal webhook: può usare JSON body
// app.use('/webhooks', paypalWebhookRouter); // TODO: Fix TypeScript errors

// ==============================
// MIDDLEWARE GLOBALI (DOPO webhook raw)
// ==============================

// Body parser
app.use(express.json());

// CORS stretto
app.use(corsMiddleware);

// Security headers
app.use(
  helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' },
  })
);

// Request logging
app.use(morgan('combined'));

// Rate limiting base su tutte le API (/api/*)
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minuti
  max: 100,                  // 100 richieste per IP
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api', apiLimiter);

// Healthcheck
app.get('/health', (_req, res) => {
  res.json({
    ok: true,
    service: 'mypetcare-backend',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    env: config.env,
  });
});

// ==============================
// API ROUTES
// ==============================
app.use('/api/auth', authRouter);
app.use('/api/payments', paymentsRouter);
app.use('/api/notifications', notificationsRouter);
app.use('/api/admin', adminRouter);
app.use('/api/pros', prosRouter);
app.use('/api/bookings', bookingsRouter);
app.use('/api/gdpr', gdprRouter);

// 404 handler
app.use((_req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Error handler
app.use(
  (
    err: any,
    _req: express.Request,
    res: express.Response,
    _next: express.NextFunction
  ) => {
    console.error('❌ Unhandled error:', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
);

// Start server (locale o Cloud Run)
const PORT = config.port;
app.listen(PORT, () => {
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('🐾 MyPetCare Backend Server');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`✅ Server listening on port ${PORT}`);
  console.log(`🌍 Environment: ${config.env}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
});

export default app;
