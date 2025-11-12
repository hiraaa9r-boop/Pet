/**
 * Professional (PRO) Zod Schemas
 * Type-safe validation schemas for pro endpoints
 */

import { z } from 'zod';

const categoryEnum = z.enum([
  'veterinari',
  'pet_sitter',
  'taxi_pet',
  'toelettatori',
  'parchi',
  'allevatori',
  'educatori',
  'pensioni',
]);

export const createProSchema = z.object({
  displayName: z.string().min(2).max(80),
  categories: z.array(categoryEnum).min(1, 'Almeno una categoria richiesta'),
  geo: z.object({
    lat: z.number().min(-90).max(90),
    lng: z.number().min(-180).max(180),
  }),
  services: z
    .array(
      z.object({
        id: z.string().min(1),
        name: z.string().min(2).max(80),
        price: z.number().min(0),
        durationMin: z.number().int().min(5).max(600),
        description: z.string().max(500).optional(),
      }),
    )
    .min(1, 'Almeno un servizio richiesto'),
  visible: z.boolean().default(true),
  bio: z.string().max(1000).optional(),
  phoneNumber: z.string().max(20).optional(),
  email: z.string().email().optional(),
  website: z.string().url().optional(),
  address: z.string().max(200).optional(),
});

export type CreateProDTO = z.infer<typeof createProSchema>;

export const updateProSchema = createProSchema.partial();

export type UpdateProDTO = z.infer<typeof updateProSchema>;

export const proIdParams = z.object({
  id: z.string().min(1),
});

export const listProsQuery = z.object({
  category: categoryEnum.optional(),
  nearLat: z.coerce.number().min(-90).max(90).optional(),
  nearLng: z.coerce.number().min(-180).max(180).optional(),
  radiusKm: z.coerce.number().min(1).max(200).optional(),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  visible: z.coerce.boolean().optional(),
  search: z.string().max(100).optional(),
});

export type ListProsQuery = z.infer<typeof listProsQuery>;
