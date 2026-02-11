import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/list.dart';

class ListCard extends ConsumerWidget {
  final ListEntity list;
  final int index;

  const ListCard({super.key, required this.list, this.index = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        print("ID LIST : ${list.id}");
        context.push('/lists/${list.id}/todos', extra: list);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 2,
            color: const Color.fromARGB(255, 111, 96, 175),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    list.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd MMM yyyy', 'fr_FR').format(list.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (list.isShared) ...[
                  SizedBox(
                    height: 30,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://api.dicebear.com/7.x/avataaars/png?seed=${list.ownerMail}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Partagée par ',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    list.ownerName!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),

                  const SizedBox(width: 16),
                ],
                Icon(Icons.task_alt, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${list.todosCount} tâche${list.todosCount > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 4),
                Text(
                  list.permission!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
