import prisma from '../config/database.js';

export const searchUsers = async (req, res, next) => {
  try {
    const { query } = req.params;

    if (!query || query.length < 2) {
      return res.json([]);
    }

    const users = await prisma.user.findMany({
      where: {
        OR: [
          { name: { contains: query, mode: 'insensitive' } },
          { email: { contains: query, mode: 'insensitive' } },
        ],
        NOT: { id: req.user.userId },
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
