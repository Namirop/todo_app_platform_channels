import type { Request, Response, NextFunction } from 'express';

interface AppError extends Error {
  code?: string;
  statusCode?: number;
}

const errorHandler = (err: AppError, _req: Request, res: Response, _next: NextFunction): void => {
  console.error('Error:', err);

  // Prisma known errors
  if (err.code === 'P2002') {
    res.status(409).json({
      error: 'A record with this value already exists',
    });
    return;
  }

  if (err.code === 'P2025') {
    res.status(404).json({
      error: 'Record not found',
    });
    return;
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    res.status(401).json({
      error: 'Invalid token',
    });
    return;
  }

  if (err.name === 'TokenExpiredError') {
    res.status(401).json({
      error: 'Token expired',
    });
    return;
  }

  // Default error
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal server error';

  res.status(statusCode).json({ error: message });
};

export default errorHandler;
