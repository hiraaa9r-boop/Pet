/**
 * Authentication Zod Schemas
 * Type-safe validation schemas for auth endpoints
 */

import { z } from 'zod';

export const signupSchema = z.object({
  email: z.string().email('Email non valida'),
  password: z
    .string()
    .min(8, 'Password deve essere almeno 8 caratteri')
    .max(128, 'Password troppo lunga'),
  role: z.enum(['proprietario', 'professionista']).default('proprietario'),
  displayName: z.string().min(2, 'Nome troppo corto').max(80, 'Nome troppo lungo'),
  phoneNumber: z.string().max(20).optional(),
});

export type SignupDTO = z.infer<typeof signupSchema>;

export const loginSchema = z.object({
  email: z.string().email('Email non valida'),
  password: z.string().min(8).max(128),
});

export type LoginDTO = z.infer<typeof loginSchema>;

export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token richiesto'),
});

export type RefreshTokenDTO = z.infer<typeof refreshTokenSchema>;

export const resetPasswordSchema = z.object({
  email: z.string().email('Email non valida'),
});

export type ResetPasswordDTO = z.infer<typeof resetPasswordSchema>;

export const updatePasswordSchema = z.object({
  currentPassword: z.string().min(8),
  newPassword: z.string().min(8).max(128),
});

export type UpdatePasswordDTO = z.infer<typeof updatePasswordSchema>;
