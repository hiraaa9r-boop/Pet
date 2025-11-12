/**
 * Booking Zod Schemas
 * Type-safe validation schemas for booking endpoints
 */

import { z } from 'zod';

export const createBookingSchema = z.object({
  proId: z.string().min(1, 'proId obbligatorio'),
  userId: z.string().min(1, 'userId obbligatorio').optional(), // from auth middleware
  date: z.string().datetime({ message: 'date deve essere ISO8601' }),
  serviceId: z.string().min(1, 'serviceId obbligatorio'),
  serviceName: z.string().min(2).max(100).optional(),
  timeStart: z
    .string()
    .regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, 'timeStart deve essere HH:MM'),
  timeEnd: z
    .string()
    .regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, 'timeEnd deve essere HH:MM'),
  price: z.number().min(0).max(10000).optional(),
  appFee: z.number().min(0).max(1000).optional(),
  totalPaid: z.number().min(0).optional(),
  notes: z.string().max(500).optional(),
  petIds: z.array(z.string()).optional(),
});

export type CreateBookingDTO = z.infer<typeof createBookingSchema>;

export const getBookingsQuery = z.object({
  from: z.string().datetime().optional(),
  to: z.string().datetime().optional(),
  proId: z.string().optional(),
  userId: z.string().optional(),
  status: z
    .enum(['pending', 'confirmed', 'cancelled', 'completed', 'pending_payment'])
    .optional(),
  limit: z.coerce.number().int().min(1).max(100).optional(),
});

export type GetBookingsQuery = z.infer<typeof getBookingsQuery>;

export const bookingIdParams = z.object({
  id: z.string().min(1),
});

export const holdSlotSchema = z.object({
  proId: z.string().min(1, 'proId obbligatorio'),
  dateISO: z.string().datetime({ message: 'dateISO deve essere ISO8601' }),
  start: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, 'start deve essere HH:MM'),
  end: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, 'end deve essere HH:MM'),
});

export type HoldSlotDTO = z.infer<typeof holdSlotSchema>;

export const releaseSlotSchema = z.object({
  proId: z.string().min(1, 'proId obbligatorio'),
  dateISO: z.string().datetime({ message: 'dateISO deve essere ISO8601' }),
  start: z.string().regex(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, 'start deve essere HH:MM'),
});

export type ReleaseSlotDTO = z.infer<typeof releaseSlotSchema>;
