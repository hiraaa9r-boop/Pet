import express, { Request, Response } from 'express';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { config } from '../config';

export const authRouter = express.Router();

/**
 * POST /api/auth/register
 * 
 * Crea profilo utente su Firestore dopo registrazione Firebase Auth
 * Body: { uid, role, fullName, phone, proPhone?, proEmail?, website?, notifications }
 */
authRouter.post('/register', express.json(), async (req: Request, res: Response) => {
  try {
    const {
      uid,
      role,
      fullName,
      phone,
      proPhone,
      proEmail,
      website,
      notifications,
    } = req.body;

    // Validazione input
    if (!uid || !role || !fullName) {
      return res.status(400).json({
        error: 'Missing required fields',
        required: ['uid', 'role', 'fullName'],
      });
    }

    if (role !== 'owner' && role !== 'pro') {
      return res.status(400).json({
        error: 'Invalid role',
        message: 'Role must be either "owner" or "pro"',
      });
    }

    const db = getFirestore();

    // Crea documento utente base
    const userDoc = {
      role,
      fullName,
      phone: phone || '',
      notifications: {
        push: notifications?.push ?? true,
        email: notifications?.email ?? true,
        marketing: notifications?.marketing ?? false,
      },
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    };

    // Aggiungi campi specifici per PRO
    if (role === 'pro') {
      Object.assign(userDoc, {
        proPhone: proPhone || phone || '',
        proEmail: proEmail || '',
        website: website || '',
        verified: false, // PRO deve essere verificato da admin
        active: false,   // Account disattivato fino a verifica
        rating: 0,
        reviewCount: 0,
      });

      // Crea anche documento nella collection "pros"
      await db.collection(config.collections.pros).doc(uid).set({
        fullName,
        phone: proPhone || phone || '',
        email: proEmail || '',
        website: website || '',
        verified: false,
        active: false,
        rating: 0,
        reviewCount: 0,
        services: [],
        availability: {},
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    // Salva utente nella collection "users"
    await db.collection(config.collections.users).doc(uid).set(userDoc);

    return res.status(201).json({
      success: true,
      message: 'User profile created successfully',
      uid,
      role,
    });

  } catch (error: any) {
    console.error('Error in /api/auth/register:', error);
    return res.status(500).json({
      error: 'Internal server error',
      message: error.message,
    });
  }
});

/**
 * GET /api/auth/user/:uid
 * 
 * Recupera profilo utente
 */
authRouter.get('/user/:uid', async (req: Request, res: Response) => {
  try {
    const { uid } = req.params;

    if (!uid) {
      return res.status(400).json({ error: 'Missing uid parameter' });
    }

    const db = getFirestore();
    const userDoc = await db.collection(config.collections.users).doc(uid).get();

    if (!userDoc.exists) {
      return res.status(404).json({
        error: 'User not found',
        uid,
      });
    }

    return res.status(200).json({
      success: true,
      user: {
        uid,
        ...userDoc.data(),
      },
    });

  } catch (error: any) {
    console.error('Error in /api/auth/user/:uid:', error);
    return res.status(500).json({
      error: 'Internal server error',
      message: error.message,
    });
  }
});

/**
 * PATCH /api/auth/user/:uid
 * 
 * Aggiorna profilo utente
 */
authRouter.patch('/user/:uid', express.json(), async (req: Request, res: Response) => {
  try {
    const { uid } = req.params;
    const updates = req.body;

    if (!uid) {
      return res.status(400).json({ error: 'Missing uid parameter' });
    }

    // Campi che non possono essere modificati dall'utente
    const protectedFields = ['uid', 'role', 'createdAt', 'verified', 'active'];
    protectedFields.forEach(field => delete updates[field]);

    // Aggiungi timestamp aggiornamento
    updates.updatedAt = FieldValue.serverTimestamp();

    const db = getFirestore();
    await db.collection(config.collections.users).doc(uid).update(updates);

    // Se è un PRO, aggiorna anche la collection "pros"
    const userDoc = await db.collection(config.collections.users).doc(uid).get();
    if (userDoc.exists && userDoc.data()?.role === 'pro') {
      await db.collection(config.collections.pros).doc(uid).update(updates);
    }

    return res.status(200).json({
      success: true,
      message: 'User profile updated successfully',
      uid,
    });

  } catch (error: any) {
    console.error('Error in /api/auth/user/:uid PATCH:', error);
    return res.status(500).json({
      error: 'Internal server error',
      message: error.message,
    });
  }
});
