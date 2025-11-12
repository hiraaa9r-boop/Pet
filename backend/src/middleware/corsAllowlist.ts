/**
 * CORS Allowlist Middleware
 * Restricts cross-origin requests to approved domains
 */

import cors from 'cors';

// Parse allowed origins from environment variable
const allowlist = (process.env.CORS_ORIGINS || '')
  .split(',')
  .map(s => s.trim())
  .filter(Boolean);

/**
 * CORS middleware with origin allowlist
 * If CORS_ORIGINS is not set or empty, allows all origins
 * Mobile apps (no origin header) are always allowed
 */
export const corsAllowlist = cors({
  origin(origin, callback) {
    // Allow requests with no origin (mobile apps, curl, postman)
    if (!origin) {
      return callback(null, true);
    }

    // If no allowlist configured, allow all
    if (allowlist.length === 0) {
      console.warn('⚠️ CORS_ORIGINS not configured - allowing all origins');
      return callback(null, true);
    }

    // Check if origin is in allowlist
    if (allowlist.includes(origin)) {
      return callback(null, true);
    }

    // Origin not allowed
    console.warn(`🚫 CORS blocked origin: ${origin}`);
    callback(new Error('Not allowed by CORS'));
  },
  credentials: true,
});
