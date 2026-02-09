import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../state/auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState.initial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final hasTokens = await _authRepository.isAuthenticated();
    if (hasTokens) {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _authRepository.login(email, password);
      state = AuthState.authenticated(user);
      return true;
    } on ServerException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } on NetworkException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e, stackTrace) {
      debugPrint('Login error: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Une erreur est survenue',
      );
      return false;
    }
  }

  Future<bool> register(String email, String password, String? name) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _authRepository.register(email, password, name);
      state = AuthState.authenticated(user);
      return true;
    } on ServerException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } on NetworkException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e, stackTrace) {
      debugPrint('Register error: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Une erreur est survenue',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState.initial();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
