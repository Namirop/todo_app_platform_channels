import type { Request, Response, NextFunction } from 'express';
import prisma from '../config/database.js';

export const searchUsers = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const query = req.params.query as string;

    if (!query || query.length < 2) {
      res.json([]);
      return;
    }

    const users = await prisma.user.findMany({
      where: {
        OR: [
          { name: { contains: query, mode: 'insensitive' } },
          { email: { contains: query, mode: 'insensitive' } },
        ],
        NOT: { id: req.user!.userId },
      },
      select: {
        id: true,
        name: true,
        email: true,
      },
      take: 10,
    });

    res.json(users);
  } catch (err) {
    next(err);
  }
};
