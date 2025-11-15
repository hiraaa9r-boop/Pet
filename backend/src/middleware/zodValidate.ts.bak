/**
 * Zod Validation Middleware
 * Validates body, query, params with consistent error format
 */

import { Request, Response, NextFunction } from 'express';
import { ZodError, ZodSchema } from 'zod';

type ValidationParts = Partial<Record<'body' | 'query' | 'params', ZodSchema<any>>>;

/**
 * Validates request parts using Zod schemas
 * Returns 422 JSON response with consistent error format
 */
export function zodValidate(parts: ValidationParts) {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      // Validate body
      if (parts.body) {
        req.body = parts.body.parse(req.body);
      }

      // Validate query
      if (parts.query) {
        req.query = parts.query.parse(req.query) as any;
      }

      // Validate params
      if (parts.params) {
        req.params = parts.params.parse(req.params);
      }

      next();
    } catch (err) {
      if (err instanceof ZodError) {
        return res.status(422).json({
          ok: false,
          message: 'Validation failed',
          errors: err.errors.map(e => ({
            field: e.path?.join('.') || 'unknown',
            message: e.message,
          })),
        });
      }
      next(err);
    }
  };
}
