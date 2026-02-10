import type { Request, Response, NextFunction } from 'express';
import prisma from '../config/database.js';

export const getLists = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userId = req.user!.userId;

    const ownedLists = await prisma.list.findMany({
      where: { ownerId: userId },
      include: {
        _count: {
          select: { todos: true },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    const sharedLists = await prisma.listShare.findMany({
      where: { userId },
      include: {
        list: {
          include: {
            _count: {
              select: { todos: true },
            },
            owner: {
              select: { name: true, email: true, id: true },
            },
          },
        },
      },
    });

    const owned = ownedLists.map((list) => ({
      id: list.id,
      name: list.name,
      ownerId: list.ownerId,
      createdAt: list.createdAt,
      updatedAt: list.updatedAt,
      isShared: false,
      permission: 'write',
      ownerName: req.user!.name,
      todosCount: list._count.todos,
    }));

    const shared = sharedLists.map((share) => ({
      id: share.list.id,
      name: share.list.name,
      ownerId: share.list.owner.id,
      createdAt: share.list.createdAt,
      updatedAt: share.list.updatedAt,
      isShared: true,
      permission: share.permission,
      ownerName: share.list.owner.name || share.list.owner.email,
      todosCount: share.list._count.todos,
    }));

    res.json({
      ownedLists: owned,
      sharedLists: shared,
    });
  } catch (err) {
    next(err);
  }
};

export const createList = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { name } = req.body;

    if (!name) {
      res.status(400).json({ error: 'Title is required' });
      return;
    }

    const list = await prisma.list.create({
      data: {
        name: name,
        ownerId: userId,
      },
    });

    res.status(201).json(list);
  } catch (err) {
    next(err);
  }
};

export const deleteList = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const listId = req.params.listId as string;

    const existingList = await prisma.list.findUnique({
      where: { id: listId },
    });

    if (!existingList) {
      res.status(404).json({ error: 'List not found' });
      return;
    }

    if (existingList.ownerId !== userId) {
      res.status(404).json({ error: 'You are not the owner of the list' });
      return;
    }

    await prisma.list.delete({
      where: { id: listId, ownerId: userId },
    });

    res.status(201).json();
  } catch (err) {
    next(err);
  }
};

interface ShareInput {
  email: string;
  permission: string;
}

interface ShareResult {
  name?: string;
  success: boolean;
  error?: string;
}

export const shareList = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const listId = req.params.listId as string;
    const { shares } = req.body as { shares: ShareInput[] };

    if (!shares || !Array.isArray(shares) || shares.length === 0) {
      console.warn(`[WARN] Invalid shares data from user ${userId}`);
      res.status(400).json({
        error: 'Données invalides',
      });
      return;
    }

    const results = await prisma.$transaction(async (tx) => {
      const existingList = await tx.list.findUnique({ where: { id: listId } });

      if (!existingList) {
        console.warn(`[WARN] List ${listId} not found`);
        throw new Error('Liste introuvable');
      }
      if (existingList.ownerId !== userId) {
        console.warn(`[WARN] User ${userId} tried to share list ${listId} without permission`);
        throw new Error("Vous n'êtes pas propriétaire de cette liste");
      }

      console.log(`[INFO] Sharing list ${listId} with ${shares.length} users`);

      return Promise.all(
        shares.map(async ({ email, permission }): Promise<ShareResult> => {
          try {
            const targetUser = await tx.user.findUnique({
              where: { email },
              select: { id: true, name: true },
            });

            if (!targetUser) {
              console.warn(`[WARN] Target user not found: ${email}`);
              return {
                name: email.split('@')[0],
                success: false,
                error: 'Utilisateur introuvable',
              };
            }

            await tx.listShare.upsert({
              where: {
                listId_userId: { listId, userId: targetUser.id },
              },
              update: { permission },
              create: { listId, userId: targetUser.id, permission },
            });

            console.log(`[INFO] Shared with ${email} (${permission})`);

            return { success: true };
          } catch (error) {
            console.error(`[ERROR] Failed to share with ${email}:`, error);
            return {
              name: email.split('@')[0],
              success: false,
              error: 'Erreur générale lors du partage',
            };
          }
        })
      );
    });

    const successCount = results.filter((r) => r.success).length;
    const failCount = results.filter((r) => !r.success).length;
    const failures = results.filter((r) => !r.success);

    console.log(`[INFO] Share completed: ${successCount} success, ${failCount} failures`);

    res.json({ successCount, failures }); // Only return the fails
  } catch (err) {
    console.error('[ERROR] shareList error:', err);
    if (err instanceof Error) {
      if (err.message === 'Liste introuvable') {
        res.status(404).json({ error: err.message });
        return;
      }
      if (err.message === "Vous n'êtes pas propriétaire de cette liste") {
        res.status(403).json({ error: err.message });
        return;
      }
    }
    next(err);
  }
};

export const leaveList = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const listId = req.params.listId as string;

    const existingList = await prisma.list.findUnique({
      where: { id: listId },
    });

    if (!existingList) {
      res.status(404).json({ error: 'List not found' });
      return;
    }

    await prisma.listShare.delete({
      where: { listId_userId: { listId, userId } },
    });

    res.status(201).json();
  } catch (err) {
    next(err);
  }
};
