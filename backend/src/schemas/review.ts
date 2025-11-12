/**
 * Review Zod Schemas
 * Type-safe validation schemas for review endpoints
 */

import { z } from 'zod';

export const createReviewSchema = z.object({
  proId: z.string().min(1, 'proId obbligatorio'),
  rating: z.number().int().min(1, 'Rating minimo 1').max(5, 'Rating massimo 5'),
  comment: z.string().max(1000, 'Commento troppo lungo').optional(),
  bookingId: z.string().min(1).optional(), // per legarla a prenotazione
  userId: z.string().min(1).optional(), // from auth middleware
});

export type CreateReviewDTO = z.infer<typeof createReviewSchema>;

export const updateReviewSchema = z.object({
  rating: z.number().int().min(1).max(5).optional(),
  comment: z.string().max(1000).optional(),
});

export type UpdateReviewDTO = z.infer<typeof updateReviewSchema>;

export const listReviewsQuery = z.object({
  proId: z.string().min(1, 'proId obbligatorio').optional(),
  userId: z.string().optional(),
  rating: z.coerce.number().int().min(1).max(5).optional(),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  cursor: z.string().optional(),
  orderBy: z.enum(['createdAt', 'rating']).default('createdAt'),
  order: z.enum(['asc', 'desc']).default('desc'),
});

export type ListReviewsQuery = z.infer<typeof listReviewsQuery>;

export const reviewIdParams = z.object({
  id: z.string().min(1),
});

export type ReviewIdParams = z.infer<typeof reviewIdParams>;
