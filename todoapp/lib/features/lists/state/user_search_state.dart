import 'package:todoapp/domain/entities/user.dart';

class UserSearchState {
  final List<UserEntity> users;
  final bool isLoading;
  final String? error;

  const UserSearchState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  UserSearchState copyWith({
    List<UserEntity>? users,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return UserSearchState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
