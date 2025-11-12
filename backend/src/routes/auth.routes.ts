/**
 * Authentication Routes
 * Handles user registration, login, and authentication
 */

import { Router } from 'express';

import { authLimiter } from '../middleware/rateLimit';
import { zodValidate } from '../middleware/zodValidate';
import { signupSchema, loginSchema } from '../schemas/auth';
import { getAuth, getDb } from '../utils/firebaseAdmin';

const router = Router();

/**
 * POST /api/auth/signup
 * Register new user with Firebase Auth
 */
router.post(
  '/signup',
  authLimiter,
  zodValidate({ body: signupSchema }),
  async (req, res, next) => {
    try {
      const { email, password, displayName, role, phoneNumber } = req.body;

      const auth = getAuth();
      const db = getDb();

      // Create Firebase Auth user
      const userRecord = await auth.createUser({
        email,
        password,
        displayName,
        phoneNumber,
      });

      // Set custom claims for role
      await auth.setCustomUserClaims(userRecord.uid, { role });

      // Create user document in Firestore
      await db.collection('users').doc(userRecord.uid).set({
        email,
        displayName,
        role,
        phoneNumber: phoneNumber || null,
        createdAt: new Date().toISOString(),
        active: true,
      });

      return res.status(201).json({
        ok: true,
        message: 'User created successfully',
        uid: userRecord.uid,
        role,
      });
    } catch (error: any) {
      // Handle Firebase Auth errors
      if (error.code === 'auth/email-already-exists') {
        return res.status(409).json({
          ok: false,
          message: 'Email già registrata',
          code: 'EMAIL_ALREADY_EXISTS',
        });
      }

      next(error);
    }
  },
);

/**
 * POST /api/auth/login
 * Login handled by client-side Firebase SDK
 * This endpoint can be used for additional server-side logic if needed
 */
router.post(
  '/login',
  authLimiter,
  zodValidate({ body: loginSchema }),
  async (_req, res) => {
    // Login is handled by Firebase SDK on client side
    // This endpoint can be used for logging, analytics, or custom claims refresh
    return res.status(200).json({
      ok: true,
      message: 'Use Firebase client SDK for authentication',
    });
  },
);

/**
 * POST /api/auth/logout
 * Revoke user's refresh tokens (optional server-side logout)
 */
router.post('/logout', async (req, res, next) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');

    if (token) {
      const auth = getAuth();
      const decodedToken = await auth.verifyIdToken(token);
      await auth.revokeRefreshTokens(decodedToken.uid);
    }

    return res.json({
      ok: true,
      message: 'Logged out successfully',
    });
  } catch (error) {
    next(error);
  }
});

export default router;
