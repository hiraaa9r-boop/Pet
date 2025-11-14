// backend/src/middleware/auth.ts
// Middleware di autenticazione e autorizzazione Firebase

import { Request, Response, NextFunction } from 'express';
import { adminAuth, db } from '../firebase';

/**
 * Interfaccia utente autenticato
 */
export interface AuthUser {
  uid: string;
  role?: 'owner' | 'pro' | 'admin';
}

/**
 * Request estesa con informazioni utente
 */
export interface AuthRequest extends Request {
  user?: AuthUser;
}

/**
 * Middleware: Richiede autenticazione Firebase
 * Verifica il token Firebase nel header Authorization
 * Popola req.user con uid e role
 */
export async function requireAuth(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;

    // Verifica presenza header Authorization
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({ error: 'Missing or invalid Authorization header' });
      return;
    }

    // Estrai token
    const token = authHeader.split(' ')[1];

    // Verifica token Firebase
    const decoded = await adminAuth.verifyIdToken(token);

    // Recupera role da custom claims o da Firestore
    let role = (decoded.role as AuthUser['role']) || undefined;

    if (!role) {
      const userDoc = await db.collection('users').doc(decoded.uid).get();
      role = (userDoc.data()?.role as AuthUser['role']) || 'owner';
    }

    // Popola req.user
    req.user = {
      uid: decoded.uid,
      role
    };

    next();
  } catch (err: any) {
    console.error('❌ Auth error:', err.message);
    res.status(401).json({ error: 'Invalid or expired token' });
    return;
  }
}

/**
 * Middleware: Richiede ruolo admin
 * Deve essere usato DOPO requireAuth
 */
export function requireAdmin(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void {
  if (!req.user) {
    res.status(401).json({ error: 'Authentication required' });
    return;
  }

  if (req.user.role !== 'admin') {
    res.status(403).json({ error: 'Admin access required' });
    return;
  }

  next();
}

/**
 * Middleware: Richiede ruolo PRO
 * Deve essere usato DOPO requireAuth
 */
export function requirePro(
  req: AuthRequest,
  res: Response,
  next: NextFunction
): void {
  if (!req.user) {
    res.status(401).json({ error: 'Authentication required' });
    return;
  }

  if (req.user.role !== 'pro' && req.user.role !== 'admin') {
    res.status(403).json({ error: 'PRO access required' });
    return;
  }

  next();
}
