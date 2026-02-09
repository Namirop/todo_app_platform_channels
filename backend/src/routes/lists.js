import express from 'express';
import { authenticateToken } from '../middleware/auth.js';
import {
  getLists,
  createList,
  deleteList,
  shareList,
  leaveList,
} from '../controllers/listController.js';

const router = express.Router();

// All routes require authentication
router.use(authenticateToken);

router.get('/', getLists);
router.post('/', createList);
router.delete('/:listId', deleteList);
router.post('/:listId/shares', shareList);
router.delete('/:listId/shares', leaveList);

export default router;
