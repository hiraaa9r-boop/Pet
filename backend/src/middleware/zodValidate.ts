// backend/src/middleware/zodValidate.ts
// Minimal stub for build compatibility

import { Request, Response, NextFunction } from 'express';

export function zodValidate(schema: any) {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      schema.parse(req.body);
      next();
    } catch (error: any) {
      return res.status(400).json({
        error: 'Validation failed',
        details: error?.issues || []
      });
    }
  };
}
