import 'dotenv/config';
import express from 'express';
import type { Request, Response, NextFunction } from 'express';
import authRoutes from './src/routes/auth.js';
import todoRoutes from './src/routes/todos.js';
import listRoutes from './src/routes/lists.js';
import userRoutes from './src/routes/user.js';
import errorHandler from './src/middleware/errorHandler.js';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.use((_req: Request, res: Response, next: NextFunction) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PATCH, DELETE, OPTIONS');
  res.header(
    'Access-Control-Allow-Headers',
    'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  );
  next();
});

app.get('/health', (_req: Request, res: Response) => {
  res.json({ status: 'ok' });
});

app.use('/api/auth', authRoutes);
app.use('/api/todos', todoRoutes);
app.use('/api/lists', listRoutes);
app.use('/api/users', userRoutes);

app.use(errorHandler);

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
