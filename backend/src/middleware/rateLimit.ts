/**
 * Rate Limiting Middleware
 * Protects API endpoints from abuse with tiered rate limits
 */

import rateLimit from 'express-rate-limit';

/**
 * General API rate limiter
 * 300 requests per 15 minutes per IP
 */
export const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 300,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    ok: false,
    message: 'Too many requests from this IP, please try again later.',
  },
});

/**
 * Authentication endpoints rate limiter
 * 50 requests per 15 minutes (login/signup)
 */
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 50,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    ok: false,
    message: 'Too many authentication attempts, please try again later.',
  },
});

/**
 * Write operations rate limiter
 * 120 requests per 10 minutes (POST/PUT/DELETE)
 */
export const writeLimiter = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 120,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    ok: false,
    message: 'Too many write requests, please slow down.',
  },
});

/**
 * Payment endpoints rate limiter (stricter)
 * 40 requests per 10 minutes
 */
export const paymentsLimiter = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 40,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    ok: false,
    message: 'Too many payment requests, please try again later.',
  },
});

/**
 * Admin endpoints rate limiter
 * 200 requests per 15 minutes
 */
export const adminLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    ok: false,
    message: 'Too many admin requests, please slow down.',
  },
});
