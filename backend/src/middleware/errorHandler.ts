/**
 * Global Error Handler Middleware
 * Catches all errors and returns consistent JSON responses
 */

import { Request, Response, NextFunction } from 'express';

/**
 * Custom error class with additional properties
 */
export class AppError extends Error {
  statusCode: number;
  code: string;
  isOperational: boolean;

  constructor(message: string, statusCode: number = 500, code: string = 'INTERNAL_ERROR') {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.isOperational = true;

    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * Global error handler
 * Transforms errors into consistent JSON format
 */
export function errorHandler(
  err: any,
  _req: Request,
  res: Response,
  _next: NextFunction,
) {
  // Extract error details
  const statusCode = err.statusCode || err.status || 500;
  const message = err.message || 'Internal Server Error';
  const code = err.code || 'INTERNAL_ERROR';

  // Log error in development
  if (process.env.NODE_ENV !== 'production') {
    console.error('❌ Error:', {
      statusCode,
      code,
      message,
      stack: err.stack,
    });
  }

  // Send error response
  res.status(statusCode).json({
    ok: false,
    message,
    code,
    // Include stack trace only in development
    ...(process.env.NODE_ENV !== 'production' && { details: err.stack }),
  });
}

/**
 * Not Found Error Handler
 * Creates 404 errors for undefined routes
 */
export function notFoundHandler(_req: Request, _res: Response, next: NextFunction) {
  const error = new AppError('Route not found', 404, 'NOT_FOUND');
  next(error);
}
