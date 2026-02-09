import express from 'express';
import { authenticateToken } from '../middleware/auth.js';
import { searchUsers } from '../controllers/userController.js';

const router = express.Router();
router.use(authenticateToken);
router.get('/search/:query', searchUsers);

export default router;
