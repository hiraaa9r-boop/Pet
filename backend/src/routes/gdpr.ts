import { Router } from 'express'

import { gdprLimiter } from '../middleware/rateLimit'
import { requireAuth } from '../middleware/requireAuth'
import { anonymize, pseudoId, PiiMap } from '../utils/anonymize'
import { getDb } from '../utils/firebaseAdmin'

const db = getDb()

const router = Router()

/**
 * GET /api/user/data
 * GDPR Art. 15 - Right to data portability
 * Esporta tutti i dati personali dell'utente
 */
router.get('/user/data', requireAuth, gdprLimiter, async (req, res) => {
  try {
    const uid = (req as any).user.uid

    // Raccogli dati da tutte le collezioni
    const [profileSnap, bookingsSnap, reviewsSnap, paymentsSnap] = await Promise.all([
      db.collection('profiles').doc(uid).get(),
      db.collection('bookings').where('userId', '==', uid).get(),
      db.collection('reviews').where('userId', '==', uid).get(),
      db.collection('payments').where('userId', '==', uid).get(),
    ])

    const data = {
      profile: profileSnap.exists ? profileSnap.data() : null,
      bookings: bookingsSnap.docs.map((d) => ({ id: d.id, ...d.data() })),
      reviews: reviewsSnap.docs.map((d) => ({ id: d.id, ...d.data() })),
      payments: paymentsSnap.docs.map((d) => ({ id: d.id, ...d.data() })),
      exportedAt: new Date().toISOString(),
    }

    res.json({ ok: true, data })
  } catch (err: any) {
    res.status(500).json({ ok: false, message: err.message })
  }
})

/**
 * DELETE /api/user/delete
 * GDPR Art. 17 - Right to erasure (soft delete con anonimizzazione)
 * Elimina/anonimizza dati personali mantenendo record necessari per accounting/legal
 */
router.delete('/user/delete', requireAuth, gdprLimiter, async (req, res) => {
  try {
    const uid = (req as any).user.uid
    const batch = db.batch()

    // 1. Profilo → pseudonimizzazione completa
    const profileRef = db.collection('profiles').doc(uid)
    const profileSnap = await profileRef.get()

    if (profileSnap.exists) {
      const profileRules: PiiMap = {
        fullName: 'mask',
        email: 'mask',
        phone: 'mask',
        bio: 'drop',
        photoURL: 'drop',
      }
      const anonProfile = anonymize(profileSnap.data()!, profileRules)
      batch.update(profileRef, {
        ...anonProfile,
        deletedAt: new Date().toISOString(),
        userId: pseudoId(),
      })
    }

    // 2. Bookings → mantieni per accounting, anonimizza PII
    const bookingsSnap = await db.collection('bookings').where('userId', '==', uid).get()
    const bookingRules: PiiMap = {
      userId: 'hash',
      userName: 'mask',
      userEmail: 'mask',
      userPhone: 'mask',
      notes: 'drop',
    }

    for (const doc of bookingsSnap.docs) {
      const anon = anonymize(doc.data(), bookingRules)
      batch.update(doc.ref, { ...anon, deletedAt: new Date().toISOString() })
    }

    // 3. Reviews → anonimizza autore
    const reviewsSnap = await db.collection('reviews').where('userId', '==', uid).get()
    const reviewRules: PiiMap = {
      userId: 'hash',
      userName: 'mask',
      text: 'keep', // Mantieni recensioni per trasparenza
    }

    for (const doc of reviewsSnap.docs) {
      const anon = anonymize(doc.data(), reviewRules)
      batch.update(doc.ref, { ...anon, deletedAt: new Date().toISOString() })
    }

    // 4. Payments → mantieni per legge, anonimizza PII
    const paymentsSnap = await db.collection('payments').where('userId', '==', uid).get()
    const paymentRules: PiiMap = {
      userId: 'hash',
      amount: 'keep',
      currency: 'keep',
      stripePaymentIntentId: 'keep',
      customerEmail: 'mask',
    }

    for (const doc of paymentsSnap.docs) {
      const anon = anonymize(doc.data(), paymentRules)
      batch.update(doc.ref, { ...anon, deletedAt: new Date().toISOString() })
    }

    // Commit batch (max 450 docs per safety, sotto limite 500)
    const allDocs = [
      profileSnap,
      ...bookingsSnap.docs,
      ...reviewsSnap.docs,
      ...paymentsSnap.docs,
    ].filter((d) => d.exists)

    if (allDocs.length > 450) {
      return res.status(400).json({
        ok: false,
        message: 'Too many documents to delete in single batch. Contact support.',
      })
    }

    await batch.commit()

    res.json({
      ok: true,
      message: 'User data anonymized successfully',
      deletedDocs: allDocs.length,
    })
  } catch (err: any) {
    res.status(500).json({ ok: false, message: err.message })
  }
})

export default router
