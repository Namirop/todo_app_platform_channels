import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/domain/entities/todo.dart';
import 'package:todoapp/features/todos/providers/todos_provider.dart';

class TodoTile extends ConsumerWidget {
  final TodoEntity todo;

  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.error,
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer la tâche ?'),
            content: Text('Voulez-vous vraiment supprimer "${todo.title}" ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        ref.read(todosProvider.notifier).deleteTodo(todo.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${todo.title} supprimée')));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: Checkbox(
            value: todo.completed,
            onChanged: (value) {
              ref
                  .read(todosProvider.notifier)
                  .toggleCompleted(todo.id, value ?? false);
            },
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.completed ? TextDecoration.lineThrough : null,
              color: todo.completed
                  ? Theme.of(context).colorScheme.outline
                  : null,
            ),
          ),
          subtitle: todo.dueDate != null
              ? Text(
                  dateFormat.format(todo.dueDate!),
                  style: TextStyle(
                    color: todo.isOverdue
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                )
              : null,
          trailing: todo.list != null
              ? Chip(
                  label: Text(
                    todo.list!.name,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                )
              : null,
        ),
      ),
    );
  }
}
