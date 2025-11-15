import { Router } from 'express';
import { gdprLimiter } from '../middleware/rateLimit';
import { requireAuth } from '../middleware/requireAuth';
import { getDb, getAuth } from '../utils/firebaseAdmin';

const db = getDb();
const auth = getAuth();

const router = Router();

/**
 * GET /api/gdpr/me
 * GDPR Art. 15 - Right to data portability & Art. 20 - Right to data access
 * Restituisce tutti i dati personali legati all'utente loggato
 */
router.get('/me', requireAuth, gdprLimiter, async (req, res) => {
  const uid = (req as any).user.uid as string;

  try {
    const [userDoc, proDoc, bookingsAsOwnerSnap, bookingsAsProSnap, reviewsSnap] =
      await Promise.all([
        db.collection('users').doc(uid).get(),
        db.collection('pros').doc(uid).get(),
        db.collection('bookings').where('ownerId', '==', uid).get(),
        db.collection('bookings').where('proId', '==', uid).get(),
        db.collection('reviews').where('ownerId', '==', uid).get(),
      ]);

    const data = {
      uid,
      user: userDoc.exists ? { id: userDoc.id, ...userDoc.data() } : null,
      pro: proDoc.exists ? { id: proDoc.id, ...proDoc.data() } : null,
      bookingsAsOwner: bookingsAsOwnerSnap.docs.map(d => ({ id: d.id, ...d.data() })),
      bookingsAsPro: bookingsAsProSnap.docs.map(d => ({ id: d.id, ...d.data() })),
      reviews: reviewsSnap.docs.map(d => ({ id: d.id, ...d.data() })),
      exportedAt: new Date().toISOString(),
    };

    res.json({ ok: true, data });
  } catch (err: any) {
    console.error('GDPR export error', err);
    res.status(500).json({ ok: false, error: 'GDPR_EXPORT_FAILED', message: err.message });
  }
});

/**
 * DELETE /api/gdpr/me
 * GDPR Art. 17 - Right to erasure (soft-delete con anonimizzazione)
 * Soft-delete account + disabilita utente Firebase Auth
 */
router.delete('/me', requireAuth, gdprLimiter, async (req, res) => {
  const uid = (req as any).user.uid as string;

  try {
    const now = new Date().toISOString();

    // Soft delete profili users e pros
    await Promise.all([
      db.collection('users').doc(uid).set(
        { deletedAt: now, active: false },
        { merge: true },
      ),
      db.collection('pros').doc(uid).set(
        { deletedAt: now, active: false },
        { merge: true },
      ),
    ]);

    // Marca bookings e reviews come "utente cancellato"
    const batch = db.batch();

    const [bookingsOwner, bookingsPro, reviews] = await Promise.all([
      db.collection('bookings').where('ownerId', '==', uid).get(),
      db.collection('bookings').where('proId', '==', uid).get(),
      db.collection('reviews').where('ownerId', '==', uid).get(),
    ]);

    bookingsOwner.forEach(doc => batch.update(doc.ref, { ownerDeleted: true, updatedAt: now }));
    bookingsPro.forEach(doc => batch.update(doc.ref, { proDeleted: true, updatedAt: now }));
    reviews.forEach(doc => batch.update(doc.ref, { ownerDeleted: true, updatedAt: now }));

    // Verifica che non ecceda il limite di 500 operazioni batch
    const totalDocs = bookingsOwner.size + bookingsPro.size + reviews.size;
    if (totalDocs > 450) {
      return res.status(400).json({
        ok: false,
        error: 'TOO_MANY_DOCUMENTS',
        message: 'Troppi documenti da elaborare. Contatta il supporto.',
      });
    }

    await batch.commit();

    // Disabilita utente in Firebase Auth
    await auth.updateUser(uid, { disabled: true });

    res.json({
      ok: true,
      status: 'DELETED',
      deletedAt: now,
      message: 'Account disabilitato e dati anonimizzati con successo',
      affectedDocuments: totalDocs,
    });
  } catch (err: any) {
    console.error('GDPR delete error', err);
    res.status(500).json({ ok: false, error: 'GDPR_DELETE_FAILED', message: err.message });
  }
});

export default router;
