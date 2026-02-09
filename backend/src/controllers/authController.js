import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import prisma from '../config/database.js';

const SALT_ROUNDS = 10;
const ACCESS_TOKEN_EXPIRY = '15m';
const REFRESH_TOKEN_EXPIRY = '7d';

const generateTokens = (userId) => {
  const accessToken = jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: ACCESS_TOKEN_EXPIRY,
  });

  const refreshToken = jwt.sign({ userId }, process.env.JWT_REFRESH_SECRET, {
    expiresIn: REFRESH_TOKEN_EXPIRY,
  });

  return { accessToken, refreshToken };
};

export const register = async (req, res, next) => {
  try {
    const { email, password, name } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const existingUser = await prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      return res.status(409).json({ error: 'User already exists' });
    }

    const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);

    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
        name,
      },
      select: {
        id: true,
        email: true,
        name: true,
        createdAt: true,
      },
    });

    await prisma.list.create({
      data: {
        name: 'Ma première liste',
        ownerId: user.id,
      },
    });

    const tokens = generateTokens(user.id);

    res.status(201).json({
      user,
      ...tokens,
    });
  } catch (err) {
    next(err);
  }
};

export const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const validPassword = await bcrypt.compare(password, user.passwordHash);

    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const tokens = generateTokens(user.id);

    res.json({
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        createdAt: user.createdAt,
      },
      ...tokens,
    });
  } catch (err) {
    next(err);
  }
};

export const refresh = async (req, res, _next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ error: 'Refresh token is required' });
    }

    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
    });

    if (!user) {
      return res.status(401).json({ error: 'User not found' });
    }

    const accessToken = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, {
      expiresIn: ACCESS_TOKEN_EXPIRY,
    });

    res.json({ accessToken });
  } catch {
    return res.status(401).json({ error: 'Invalid refresh token' });
  }
};
