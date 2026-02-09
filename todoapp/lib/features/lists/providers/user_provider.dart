import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todoapp/core/di/providers.dart';
import 'package:todoapp/domain/repositories/users_repository.dart';
import 'package:todoapp/features/lists/state/user_search_state.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserSearchState>((
  ref,
) {
  return UserNotifier(ref.watch(usersRepositoryProvider));
});

class UserNotifier extends StateNotifier<UserSearchState> {
  final UsersRepository _userRepository;

  UserNotifier(this._userRepository) : super(const UserSearchState());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      state = const UserSearchState();
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final users = await _userRepository.searchUsers(query);
      state = state.copyWith(users: users, isLoading: false);
    } catch (e, strackTrace) {
      debugPrint('search user error: $e\n$strackTrace');
      state = state.copyWith(
        isLoading: false,
        error: "Erreur lors de la recherche",
      );
    }
  }

  void resetSearch() {
    state = const UserSearchState();
  }
}
