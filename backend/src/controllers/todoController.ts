import type { Request, Response, NextFunction } from 'express';
import prisma from '../config/database.js';

// Get all todos for the authenticated user (from owned and shared lists)
export const getTodos = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const listId = req.params.listId as string | undefined;

    const ownedLists = await prisma.list.findMany({
      where: { ownerId: userId },
      select: { id: true },
    });

    const sharedLists = await prisma.listShare.findMany({
      where: { userId },
      select: { listId: true },
    });

    const accessibleListIds = [...ownedLists.map((l) => l.id), ...sharedLists.map((s) => s.listId)];

    const whereClause: { listId: string | { in: string[] } } = {
      listId: { in: accessibleListIds },
    };

    if (listId) {
      if (!accessibleListIds.includes(listId)) {
        res.status(403).json({ error: 'Access denied to this list' });
        return;
      }
      whereClause.listId = listId;
    }

    const todos = await prisma.todo.findMany({
      where: whereClause,
      include: {
        list: {
          select: { id: true, name: true },
        },
      },
      orderBy: [{ priority: 'desc' }, { createdAt: 'desc' }],
    });

    res.json(todos);
  } catch (err) {
    next(err);
  }
};

export const getTodo = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const id = req.params.id as string;

    const todo = await prisma.todo.findUnique({
      where: { id },
      include: {
        list: {
          select: { id: true, name: true, ownerId: true },
        },
      },
    });

    if (!todo) {
      res.status(404).json({ error: 'Todo not found' });
      return;
    }

    const hasAccess =
      todo.list.ownerId === userId ||
      (await prisma.listShare.findUnique({
        where: { listId_userId: { listId: todo.listId, userId } },
      }));

    if (!hasAccess) {
      res.status(403).json({ error: 'Access denied' });
      return;
    }

    res.json(todo);
  } catch (err) {
    next(err);
  }
};

export const createTodo = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { title, description, dueDate, priority, listId } = req.body;

    if (!title) {
      res.status(400).json({ error: 'Title is required' });
      return;
    }

    // If no listId provided, use the user's default list (first created)
    let targetListId = listId;

    if (!targetListId) {
      const defaultList = await prisma.list.findFirst({
        where: { ownerId: userId },
        orderBy: { createdAt: 'asc' },
      });

      if (!defaultList) {
        res.status(400).json({ error: 'No list found. Please create a list first.' });
        return;
      }
      targetListId = defaultList.id;
    }

    const list = await prisma.list.findUnique({
      where: { id: targetListId },
    });

    if (!list) {
      res.status(404).json({ error: 'List not found' });
      return;
    }

    console.log('list owner : ' + list.ownerId);
    console.log('userId :' + userId);

    const isOwner = list.ownerId === userId;
    const share = await prisma.listShare.findUnique({
      where: { listId_userId: { listId: targetListId, userId } },
    });
    const hasWriteAccess = isOwner || (share && share.permission === 'write');

    if (!hasWriteAccess) {
      res.status(403).json({ error: 'Write access denied to this list' });
      return;
    }

    const todo = await prisma.todo.create({
      data: {
        title,
        description,
        dueDate: dueDate ? new Date(dueDate) : null,
        priority: priority || 0,
        listId: targetListId,
        createdById: userId,
      },
      include: {
        list: {
          select: { id: true, name: true },
        },
      },
    });

    res.status(201).json(todo);
  } catch (err) {
    next(err);
  }
};

export const updateTodo = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const id = req.params.id as string;
    const { title, description, completed, dueDate, priority } = req.body;

    const existingTodo = await prisma.todo.findUnique({
      where: { id },
      include: { list: true },
    });

    if (!existingTodo) {
      res.status(404).json({ error: 'Todo not found' });
      return;
    }

    const isOwner = existingTodo.list.ownerId === userId;
    const share = await prisma.listShare.findUnique({
      where: { listId_userId: { listId: existingTodo.listId, userId } },
    });
    const hasWriteAccess = isOwner || (share && share.permission === 'write');

    if (!hasWriteAccess) {
      res.status(403).json({ error: 'Write access denied' });
      return;
    }

    const updateData: {
      title?: string;
      description?: string;
      completed?: boolean;
      dueDate?: Date | null;
      priority?: number;
    } = {};
    if (title !== undefined) {
      updateData.title = title;
    }
    if (description !== undefined) {
      updateData.description = description;
    }
    if (completed !== undefined) {
      updateData.completed = completed;
    }
    if (dueDate !== undefined) {
      updateData.dueDate = dueDate ? new Date(dueDate) : null;
    }
    if (priority !== undefined) {
      updateData.priority = priority;
    }

    const todo = await prisma.todo.update({
      where: { id },
      data: updateData,
      include: {
        list: {
          select: { id: true, name: true },
        },
      },
    });

    res.json(todo);
  } catch (err) {
    next(err);
  }
};

export const deleteTodo = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const id = req.params.id as string;

    const existingTodo = await prisma.todo.findUnique({
      where: { id },
      include: { list: true },
    });

    if (!existingTodo) {
      res.status(404).json({ error: 'Todo not found' });
      return;
    }

    const isOwner = existingTodo.list.ownerId === userId;
    const share = await prisma.listShare.findUnique({
      where: { listId_userId: { listId: existingTodo.listId, userId } },
    });
    const hasWriteAccess = isOwner || (share && share.permission === 'write');

    if (!hasWriteAccess) {
      res.status(403).json({ error: 'Write access denied' });
      return;
    }

    await prisma.todo.delete({
      where: { id },
    });

    res.status(204).send();
  } catch (err) {
    next(err);
  }
};
