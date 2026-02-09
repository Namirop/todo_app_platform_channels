import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todoapp/features/lists/providers/lists_provider.dart';
import 'package:todoapp/features/todos/screens/widgets/todo_tile.dart';

import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../providers/todos_provider.dart';
import '../state/todos_state.dart';

class TodosScreen extends ConsumerStatefulWidget {
  final String listId;
  const TodosScreen({super.key, required this.listId});

  @override
  ConsumerState<TodosScreen> createState() => _ListScreenState();
}

class _ListScreenState extends ConsumerState<TodosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(todosProvider.notifier).fetchTodos(widget.listId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todosState = ref.watch(todosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Tâches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(todosProvider.notifier).refresh(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'share') {
                context.go('/lists/${widget.listId}/share');
              }
              if (value == 'delete') {
                ref.read(listsProvider.notifier).deleteList(widget.listId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Liste supprimée')),
                );
                context.pop();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Partager la liste"),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Supprimer'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(todosState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/todos/create'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle tâche'),
      ),
    );
  }

  Widget _buildBody(TodosState state) {
    if (state.isLoading && state.todos.isEmpty) {
      return const LoadingWidget(message: 'Chargement des tâches...');
    }

    if (state.error != null && state.todos.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () =>
            ref.read(todosProvider.notifier).fetchTodos(widget.listId),
      );
    }

    if (state.todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text('Aucune tâche', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur + pour créer votre première tâche',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(todosProvider.notifier).fetchTodos(widget.listId),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: state.todos.length,
        itemBuilder: (context, index) {
          final todo = state.todos[index];
          return TodoTile(todo: todo);
        },
      ),
    );
  }
}
