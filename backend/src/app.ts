/**
 * MyPetCare Express Application Setup
 * Separates app configuration from server startup for testing
 * Updated with Zod validation, rate limiting, and improved middleware structure
 */

import bodyParser from 'body-parser';
import compression from 'compression';
import express, { Request, Response } from 'express';
import helmet from 'helmet';
import xss from 'xss-clean';

import { handlePaypalWebhook } from './functions/paypalWebhook';
import { corsAllowlist } from './middleware/corsAllowlist';
import {
  errorHandler,
  notFoundHandler,
} from './middleware/errorHandler';
import {
  apiLimiter,
  authLimiter,
  adminLimiter,
} from './middleware/rateLimit';
import { trimStrings } from './middleware/validateRequest';

// Routers
import adminRouter from './routes/admin';
import authRouter from './routes/auth.routes';
import bookingsRouter from './routes/booking.routes';
import jobsRouter from './routes/jobs';
import messagesRouter from './routes/messages';
import paymentsRouter from './routes/payments.routes';
import reviewsRouter from './routes/reviews.routes';
import suggestionsRouter from './routes/suggestions.routes';

// Webhooks
import { handleStripeWebhook } from './webhooks/stripeWebhook';

// ==========================================
// Express App Configuration
// ==========================================

export const app = express();

// Trust proxy (required for rate limiting behind Cloud Run/Load Balancer)
app.set('trust proxy', 1);

// ==========================================
// Webhook Endpoints (MUST be before express.json())
// ==========================================
// Stripe requires raw body for signature verification

app.post(
  '/api/payments/webhook',
  bodyParser.raw({ type: 'application/json' }),
  (req, _res, next) => {
    // Store raw body for Stripe signature verification
    (req as any).rawBody = req.body;
    next();
  },
  handleStripeWebhook,
);

// PayPal webhook
app.post(
  '/webhooks/paypal',
  bodyParser.json(),
  handlePaypalWebhook,
);

// ==========================================
// Security & Performance Middleware
// ==========================================

// CORS with allowlist
app.use(corsAllowlist);

// Parse JSON bodies (for all other routes)
app.use(express.json());

// Helmet - Security headers
app.use(helmet());

// XSS Protection
app.use(xss() as any);

// Compression - Gzip/Brotli
app.use(compression());

// Trim strings from all inputs
app.use(trimStrings);

// ==========================================
// Health Check (no authentication)
// ==========================================

app.get('/health', (_req: Request, res: Response) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    maintenanceMode: process.env.MAINTENANCE_MODE === 'true',
  });
});

// ==========================================
// Rate Limiting (applied to API routes)
// ==========================================

// General API rate limiter
app.use('/api', apiLimiter);

// ==========================================
// API Routes
// ==========================================

// Authentication routes (with stricter rate limit)
app.use('/api/auth', authLimiter, authRouter);

// Booking routes
app.use('/api/bookings', bookingsRouter);

// Reviews routes
app.use('/api/reviews', reviewsRouter);

// Payment routes (handled in payments.routes.ts with paymentsLimiter)
app.use('/api/payments', paymentsRouter);

// Suggestions routes
app.use('/api/suggestions', suggestionsRouter);

// Admin routes (with admin rate limiter)
app.use('/admin', adminLimiter, adminRouter);

// Jobs routes (CRON protected)
app.use('/jobs', jobsRouter);

// Messages/Chat routes
app.use('/messages', messagesRouter);

// ==========================================
// Error Handling
// ==========================================

// 404 handler (must be after all routes)
app.use(notFoundHandler);

// Global error handler (must be last)
app.use(errorHandler);
