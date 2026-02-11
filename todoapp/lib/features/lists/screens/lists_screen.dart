import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todoapp/features/auth/providers/auth_provider.dart';
import 'package:todoapp/features/lists/providers/lists_provider.dart';
import 'package:todoapp/features/lists/screens/widgets/list_card.dart';
import 'package:todoapp/features/lists/state/lists_state.dart';
import 'package:todoapp/shared/widgets/app_error_widget.dart';
import 'package:todoapp/shared/widgets/loading_widget.dart';

class ListsScreen extends ConsumerStatefulWidget {
  const ListsScreen({super.key});

  @override
  ConsumerState<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends ConsumerState<ListsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(listsProvider.notifier).fetchLists());
  }

  @override
  Widget build(BuildContext context) {
    final listsState = ref.watch(listsProvider);
    final authState = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes listes'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://api.dicebear.com/7.x/avataaars/png?seed=${authState.user!.email}',
                    ),
                  ),
                  title: Text(
                    authState.user?.name ??
                        authState.user?.email ??
                        'Utilisateur',
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Déconnexion'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(listsState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/lists/create'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle liste'),
      ),
    );
  }

  Widget _buildBody(ListsState state) {
    final allLists = state.allLists;

    if (state.isLoading && allLists.isEmpty) {
      return const LoadingWidget(message: 'Chargement des listes...');
    }

    if (state.error != null && allLists.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(listsProvider.notifier).fetchLists(),
      );
    }

    if (allLists.isEmpty) {
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
            Text('Aucune liste', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur + pour créer votre première liste',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(listsProvider.notifier).fetchLists(),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Perso :',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (state.ownedLists.isNotEmpty)
            ...state.ownedLists.map((list) => ListCard(list: list)),
          const SizedBox(height: 24),
          if (state.sharedLists.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Partagées avec moi :',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...state.sharedLists.map((list) => ListCard(list: list)),
          ],
        ],
      ),
    );
  }
}
