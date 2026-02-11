import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:todoapp/features/lists/providers/share_provider.dart';
import 'package:todoapp/features/lists/providers/user_provider.dart';
import 'package:todoapp/features/lists/screens/widgets/permission_switch.dart';
import 'package:todoapp/features/lists/state/share_state.dart';
import 'package:todoapp/features/lists/state/user_search_state.dart';
import 'package:todoapp/shared/widgets/app_error_widget.dart';
import 'package:todoapp/shared/widgets/loading_widget.dart';

class ShareScreen extends ConsumerStatefulWidget {
  final String listId;
  const ShareScreen({super.key, required this.listId});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceSearch;

  final Map<String, String> _selectedUsers = {};

  @override
  void dispose() {
    _searchController.dispose();
    _debounceSearch?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final shareState = ref.watch(shareProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 5),
            Expanded(child: _buildContent(userState)),
          ],
        ),
      ),
      floatingActionButton: _buildShareButton(shareState),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/lists');
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: TextField(
              controller: _searchController,
              cursorColor: Colors.black,
              cursorWidth: 1.0,
              cursorHeight: 18.0,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s]')),
              ],
              decoration: const InputDecoration(
                hintText: 'Rechercher une personne',
                hintStyle: TextStyle(fontSize: 15),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 18, color: Colors.black),
              onChanged: (query) {
                _debounceSearch?.cancel();
                _debounceSearch = Timer(
                  const Duration(milliseconds: 500),
                  () => ref.read(userProvider.notifier).searchUsers(query),
                );
              },
            ),
          ),
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.xmark, size: 20),
          onPressed: () {
            setState(() {
              _searchController.clear();
              ref.read(userProvider.notifier).resetSearch();
            });
          },
        ),
      ],
    );
  }

  Widget _buildContent(UserSearchState userState) {
    if (userState.users.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? "Veuillez entrer un contact (prénom ou mail)"
              : "Aucun utilisateur trouvé",
          textAlign: TextAlign.center,
        ),
      );
    }

    if (userState.isLoading) {
      return const LoadingWidget(message: "Recherche en cours");
    }

    if (userState.error != null) {
      return AppErrorWidget(
        message: userState.error!,
        onRetry: () =>
            ref.read(userProvider.notifier).searchUsers(_searchController.text),
      );
    }

    return ListView.builder(
      itemCount: userState.users.length,
      itemBuilder: (context, index) {
        final user = userState.users[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedUsers.containsKey(user.email)) {
                _selectedUsers.remove(user.email);
              } else {
                _selectedUsers[user.email] = 'read';
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: _selectedUsers.containsKey(user.email)
                  ? Colors.white
                  : Colors.grey[0],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://api.dicebear.com/7.x/avataaars/png?seed=${user.email}',
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          user.displayName,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PermissionToggle(
                    key: ValueKey(
                      '${user.email}_${_selectedUsers.containsKey(user.email)}',
                    ),
                    initialValue: _selectedUsers[user.email] ?? 'read',
                    onChanged: (permission) {
                      setState(() {
                        _selectedUsers[user.email] = permission;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareButton(ShareState shareState) {
    return FloatingActionButton.extended(
      onPressed: _selectedUsers.isEmpty || shareState.isSharing ? null : _share,
      icon: shareState.isSharing
          ? const Icon(Icons.do_not_touch_rounded)
          : const Icon(Icons.add),
      label: _selectedUsers.isEmpty
          ? const Text("Choissisez un partage")
          : Row(
              children: [
                const Text('Partager avec'),
                const SizedBox(width: 10),
                SizedBox(
                  width: _selectedUsers.length * 20 + 20,
                  height: 40,
                  child: Stack(
                    children: List.generate(_selectedUsers.length, (index) {
                      final userEmail = _selectedUsers.keys.toList()[index];
                      return Positioned(
                        left: index * 25,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://api.dicebear.com/7.x/avataaars/png?seed=$userEmail',
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _share() async {
    final shares = _selectedUsers.entries
        .map((entry) => {'email': entry.key, 'permission': entry.value})
        .toList();

    await ref.read(shareProvider.notifier).shareList(widget.listId, shares);

    if (!mounted) return;

    final state = ref.read(shareProvider);

    if (state.error != null) {
      context.go('/lists');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opération impossible : ${state.error}')),
      );
      return;
    }

    if (state.hasShared) {
      if (state.shareResult!.failures.isEmpty) {
        context.go('/lists');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Liste partagée avec ${state.shareResult!.successCount} personnes',
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Partage partiel'),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ ${state.shareResult!.successCount} réussi${state.shareResult!.successCount > 1 ? 's' : ''}',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Échecs :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...state.shareResult!.failures.map(
                    (failure) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  failure.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  failure.error,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
