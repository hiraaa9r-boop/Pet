// backend/src/routes/pros.ts
// Route gestione profili PRO

import { Router } from 'express';
import { db } from '../firebase';
import { requireAuth, AuthRequest } from '../middleware/auth';

const router = Router();

/**
 * POST /api/pros/me
 * Crea/Aggiorna profilo PRO del current user (proId = uid)
 * Richiede autenticazione
 */
router.post('/me', requireAuth, async (req: AuthRequest, res) => {
  try {
    const uid = req.user!.uid;
    const {
      displayName,
      city,
      services,
      categories,
      description,
      phone
    } = req.body;

    await db
      .collection('pros')
      .doc(uid)
      .set(
        {
          uid,
          displayName,
          city,
          services,
          categories,
          description,
          phone,
          status: 'pending',
          subscriptionStatus: 'inactive',
          updatedAt: new Date()
        },
        { merge: true }
      );

    console.log(`✅ PRO profile created/updated for user: ${uid}`);

    return res.json({ ok: true, proId: uid });
  } catch (err: any) {
    console.error('❌ Create/update PRO error:', err.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

/**
 * GET /api/pros
 * Lista PRO visibili nella mappa (solo approved + abbonati attivi)
 */
router.get('/', async (_req, res) => {
  try {
    const snap = await db
      .collection('pros')
      .where('status', '==', 'approved')
      .where('subscriptionStatus', '==', 'active')
      .get();

    const items = snap.docs.map((d) => ({ id: d.id, ...d.data() }));

    return res.json(items);
  } catch (err: any) {
    console.error('❌ List PROs error:', err.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

/**
 * GET /api/pros/:id
 * Dettaglio singolo PRO
 */
router.get('/:id', async (req, res) => {
  try {
    const snap = await db.collection('pros').doc(req.params.id).get();

    if (!snap.exists) {
      return res.status(404).json({ error: 'PRO not found' });
    }

    return res.json({ id: snap.id, ...snap.data() });
  } catch (err: any) {
    console.error('❌ Get PRO error:', err.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

export default router;
