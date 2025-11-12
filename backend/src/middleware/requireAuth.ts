import { Request, Response, NextFunction } from 'express'

/**
 * requireAuth middleware
 * Estrae uid da req.uid (middleware Firebase) o da header X-User-Id (dev/test)
 * In produzione, sostituire con verifyIdToken di Firebase Admin SDK
 */
export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const uid = (req as any).uid || (req.headers['x-user-id'] as string)
  if (!uid) {
    return res.status(401).json({ ok: false, message: 'Unauthorized' })
  }
  ;(req as any).user = { uid }
  next()
}
