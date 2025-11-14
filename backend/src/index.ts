// backend/src/index.ts
// MyPetCare Backend - Entry Point Express Server

import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import { config, validateConfig } from './config';

// Routes
import paymentsRouter from './routes/payments';
import paypalWebhookRouter from './routes/payments.paypal.webhook';
import notificationsRouter from './routes/notifications';
import adminRouter from './routes/admin';
import prosRouter from './routes/pros';
import bookingsRouter from './routes/bookings';
import { stripeWebhookHandler } from './routes/payments.stripe.webhook';

// Load environment variables
dotenv.config();

// Validate configuration
validateConfig();

const app = express();

// ⚠️ CRITICO: Stripe webhook DEVE usare raw body PRIMA di express.json()
// Questo endpoint usa express.raw() per verifica firma webhook
app.post(
  '/api/payments/stripe/webhook',
  express.raw({ type: 'application/json' }),
  stripeWebhookHandler
);

// Middleware globali (DOPO webhook raw)
app.use(express.json());
app.use(cors());
app.use(helmet());

// Request logging middleware
app.use((req, _res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Healthcheck
app.get('/health', (_req, res) => {
  res.json({
    ok: true,
    service: 'mypetcare-backend',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    env: config.env
  });
});

// API Routes
app.use('/api/payments', paymentsRouter);
app.use('/api/payments', paypalWebhookRouter);
app.use('/api/notifications', notificationsRouter);
app.use('/api/admin', adminRouter);
app.use('/api/pros', prosRouter);
app.use('/api/bookings', bookingsRouter);

// 404 handler
app.use((_req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Error handler
app.use((err: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error('❌ Unhandled error:', err);
  res.status(500).json({ error: 'Internal Server Error' });
});

// Start server
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
