/**
 * Reviews Routes
 * Handles review creation, listing, and management
 */

import { Router } from 'express';

import { writeLimiter } from '../middleware/rateLimit';
import { zodValidate } from '../middleware/zodValidate';
import {
  createReviewSchema,
  listReviewsQuery,
  reviewIdParams,
  updateReviewSchema,
} from '../schemas/review';
import { getDb } from '../utils/firebaseAdmin';

const router = Router();

/**
 * POST /api/reviews
 * Create a new review
 */
router.post(
  '/',
  writeLimiter,
  zodValidate({ body: createReviewSchema }),
  async (req, res, next) => {
    try {
      const db = getDb();
      const { proId, rating, comment, bookingId, userId } = req.body;

      // TODO: Add requireAuth middleware to get userId from token
      // const userId = req.user?.uid;

      // Check if user already reviewed this pro
      const existingReviews = await db
        .collection('reviews')
        .where('proId', '==', proId)
        .where('userId', '==', userId || 'anonymous')
        .limit(1)
        .get();

      if (!existingReviews.empty) {
        return res.status(409).json({
          ok: false,
          message: 'Hai già recensito questo professionista',
          code: 'REVIEW_ALREADY_EXISTS',
        });
      }

      // Create review document
      const reviewData = {
        proId,
        userId: userId || 'anonymous',
        rating,
        comment: comment || null,
        bookingId: bookingId || null,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      const ref = await db.collection('reviews').add(reviewData);

      // Update pro's average rating (in real app, use Cloud Function)
      await updateProRating(proId, db);

      return res.status(201).json({
        ok: true,
        message: 'Recensione creata con successo',
        id: ref.id,
      });
    } catch (error) {
      next(error);
    }
  },
);

/**
 * GET /api/reviews
 * List reviews with optional filters
 */
router.get('/', zodValidate({ query: listReviewsQuery }), async (req, res, next) => {
  try {
    const db = getDb();
    const { proId, userId, rating, limit, orderBy, order } = req.query as any;

    let query: any = db.collection('reviews');

    // Apply filters
    if (proId) {
      query = query.where('proId', '==', proId);
    }

    if (userId) {
      query = query.where('userId', '==', userId);
    }

    if (rating) {
      query = query.where('rating', '==', parseInt(rating));
    }

    // Apply ordering
    query = query.orderBy(orderBy || 'createdAt', order || 'desc');

    // Apply limit
    query = query.limit(limit || 20);

    const snapshot = await query.get();
    const reviews = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    }));

    return res.json({
      ok: true,
      data: reviews,
      count: reviews.length,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/reviews/:id
 * Get single review by ID
 */
router.get('/:id', zodValidate({ params: reviewIdParams }), async (req, res, next) => {
  try {
    const db = getDb();
    const doc = await db.collection('reviews').doc(req.params.id).get();

    if (!doc.exists) {
      return res.status(404).json({
        ok: false,
        message: 'Recensione non trovata',
        code: 'REVIEW_NOT_FOUND',
      });
    }

    return res.json({
      ok: true,
      data: {
        id: doc.id,
        ...doc.data(),
      },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * PATCH /api/reviews/:id
 * Update review (only by owner)
 */
router.patch(
  '/:id',
  writeLimiter,
  zodValidate({ params: reviewIdParams, body: updateReviewSchema }),
  async (req, res, next) => {
    try {
      const db = getDb();
      const { id } = req.params;

      // TODO: Add requireAuth and check if user owns this review
      // if (req.user?.uid !== review.userId) { return 403 }

      const updateData = {
        ...req.body,
        updatedAt: new Date().toISOString(),
      };

      await db.collection('reviews').doc(id).update(updateData);

      // Update pro's average rating
      const doc = await db.collection('reviews').doc(id).get();
      if (doc.exists) {
        await updateProRating((doc.data() as any).proId, db);
      }

      return res.json({
        ok: true,
        message: 'Recensione aggiornata con successo',
      });
    } catch (error) {
      next(error);
    }
  },
);

/**
 * DELETE /api/reviews/:id
 * Delete review (only by owner or admin)
 */
router.delete('/:id', writeLimiter, async (req, res, next) => {
  try {
    const db = getDb();
    const { id } = req.params;

    // TODO: Add requireAuth and check permissions

    const doc = await db.collection('reviews').doc(id).get();

    if (!doc.exists) {
      return res.status(404).json({
        ok: false,
        message: 'Recensione non trovata',
        code: 'REVIEW_NOT_FOUND',
      });
    }

    const proId = (doc.data() as any).proId;
    await db.collection('reviews').doc(id).delete();

    // Update pro's average rating
    await updateProRating(proId, db);

    return res.json({
      ok: true,
      message: 'Recensione eliminata con successo',
    });
  } catch (error) {
    next(error);
  }
});

/**
 * Helper: Update pro's average rating
 */
async function updateProRating(proId: string, db: any) {
  try {
    const reviews = await db.collection('reviews').where('proId', '==', proId).get();

    if (reviews.empty) {
      await db.collection('pros').doc(proId).update({
        averageRating: 0,
        reviewCount: 0,
      });
      return;
    }

    let totalRating = 0;
    reviews.forEach((doc: any) => {
      totalRating += doc.data().rating;
    });

    const averageRating = totalRating / reviews.size;

    await db.collection('pros').doc(proId).update({
      averageRating: parseFloat(averageRating.toFixed(2)),
      reviewCount: reviews.size,
    });
  } catch (error) {
    console.error('Error updating pro rating:', error);
  }
}

export default router;
