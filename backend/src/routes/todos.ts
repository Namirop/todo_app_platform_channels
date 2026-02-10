import express from 'express';
import { authenticateToken } from '../middleware/auth.js';
import {
  getTodos,
  getTodo,
  createTodo,
  updateTodo,
  deleteTodo,
} from '../controllers/todoController.js';

const router = express.Router();
router.use(authenticateToken);

router.get('/:listId', getTodos);
router.get('/:id', getTodo);
router.post('/', createTodo);
router.patch('/:id', updateTodo);
router.delete('/:id', deleteTodo);

export default router;
