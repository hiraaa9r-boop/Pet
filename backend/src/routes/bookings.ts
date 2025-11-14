// backend/src/routes/bookings.ts
// Route gestione prenotazioni con notifiche automatiche

import { Router } from 'express';
import { db } from '../firebase';
import { requireAuth, AuthRequest } from '../middleware/auth';
import { sendNotificationToUser } from './notifications';

const router = Router();

/**
 * POST /api/bookings
 * Crea nuova prenotazione e invia notifiche a owner e PRO
 * 
 * Body:
 * - proId: string
 * - serviceId: string
 * - serviceName: string
 * - startTime: string (ISO 8601)
 * - endTime: string (ISO 8601)
 * - notes?: string
 */
router.post('/', requireAuth, async (req: AuthRequest, res) => {
  try {
    const ownerId = req.user!.uid;
    const {
      proId,
      serviceId,
      serviceName,
      startTime,
      endTime,
      notes
    } = req.body;

    // Validazione input
    if (!proId || !serviceId || !serviceName || !startTime || !endTime) {
      return res.status(400).json({
        error: 'Missing required params: proId, serviceId, serviceName, startTime, endTime'
      });
    }

    // Crea documento prenotazione
    const bookingRef = db.collection('bookings').doc();
    const bookingId = bookingRef.id;

    const start = new Date(startTime);
    const end = new Date(endTime);

    await bookingRef.set({
      ownerId,
      proId,
      serviceId,
      serviceName,
      startTime: start,
      endTime: end,
      notes: notes || null,
      status: 'booked',
      createdAt: new Date()
    });

    console.log(`✅ Booking created: ${bookingId} (owner: ${ownerId}, pro: ${proId})`);

    // Recupera dati per notifiche
    const ownerDoc = await db.collection('users').doc(ownerId).get();
    const proDoc = await db.collection('pros').doc(proId).get();

    const ownerName = (ownerDoc.data()?.displayName as string) || 'Cliente';
    const proName = (proDoc.data()?.displayName as string) || 'Professionista';

    const formattedDate = start.toLocaleString('it-IT', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });

    // Notifica owner
    await sendNotificationToUser(ownerId, {
      type: 'booking_created',
      title: 'Prenotazione confermata',
      body: `Hai prenotato ${serviceName} con ${proName} per il ${formattedDate}`,
      data: { bookingId, proId }
    });

    // Notifica PRO
    await sendNotificationToUser(proId, {
      type: 'booking_created',
      title: 'Nuova prenotazione',
      body: `${ownerName} ha prenotato ${serviceName} per il ${formattedDate}`,
      data: { bookingId, ownerId }
    });

    return res.json({ ok: true, bookingId });
  } catch (err: any) {
    console.error('❌ Create booking error:', err.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

/**
 * GET /api/bookings/my
 * Lista prenotazioni dell'utente autenticato
 */
router.get('/my', requireAuth, async (req: AuthRequest, res) => {
  try {
    const uid = req.user!.uid;
    const role = req.user!.role;

    // Owner: prenotazioni dove ownerId = uid
    // PRO: prenotazioni dove proId = uid
    const field = role === 'pro' ? 'proId' : 'ownerId';

    const snap = await db
      .collection('bookings')
      .where(field, '==', uid)
      .orderBy('startTime', 'desc')
      .limit(100)
      .get();

    const bookings = snap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data()
    }));

    return res.json(bookings);
  } catch (err: any) {
    console.error('❌ Get user bookings error:', err.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

/**
 * GET /api/bookings/:id
 * Dettaglio singola prenotazione
 */
router.get('/:id', requireAuth, async (req: AuthRequest, res) => {
  try {
    const bookingDoc = await db.collection('bookings').doc(req.params.id).get();

    if (!bookingDoc.exists) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    const booking = bookingDoc.data();

    // Verifica che l'utente sia owner o PRO della prenotazione
    const uid = req.user!.uid;
    if (booking?.ownerId !== uid && booking?.proId !== uid) {
      return res.status(403).json({ error: 'Access denied' });
    }

    return res.json({ id: bookingDoc.id, ...booking });
  } catch (err: any) {
    console.error('❌ Get booking error:', err.message);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

export default router;
