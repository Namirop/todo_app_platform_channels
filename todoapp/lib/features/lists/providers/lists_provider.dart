import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todoapp/domain/entities/list.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/repositories/lists_repository.dart';
import '../state/lists_state.dart';

final listsProvider = StateNotifierProvider<ListsNotifier, ListsState>((ref) {
  return ListsNotifier(ref.watch(listsRepositoryProvider));
});

class ListsNotifier extends StateNotifier<ListsState> {
  final ListsRepository _listsRepository;
  StreamSubscription<(List<ListEntity>, List<ListEntity>)>? _subscription;

  ListsNotifier(this._listsRepository) : super(const ListsState());

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void watchLists() {
    _subscription?.cancel();

    state = state.copyWith(isLoading: true, clearError: true);

    _subscription = _listsRepository.watchLists().listen(
      ((List<ListEntity>, List<ListEntity>) data) {
        final (owned, shared) = data;
        state = state.copyWith(
          ownedLists: owned,
          sharedLists: shared,
          isLoading: false,
        );
      },
      onError: (error, stackTrace) {
        if (error is ServerException) {
          state = state.copyWith(isLoading: false, error: error.message);
        } else if (error is NetworkException) {
          state = state.copyWith(isLoading: false, error: error.message);
        } else {
          debugPrint('watchLists error: $error\n$stackTrace');
          state = state.copyWith(
            isLoading: false,
            error: 'Une erreur est survenue',
          );
        }
      },
    );
  }

  Future<void> fetchLists() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final (owned, shared) = await _listsRepository.getLists();
      state = state.copyWith(
        ownedLists: owned,
        sharedLists: shared,
        isLoading: false,
      );
    } on ServerException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } on NetworkException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e, stackTrace) {
      debugPrint('fetchLists error: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Une erreur est survenue',
      );
    }
  }

  Future<bool> createList(String name) async {
    try {
      final newList = await _listsRepository.createList(name);
      state = state.copyWith(ownedLists: [newList, ...state.ownedLists]);
      return true;
    } on ServerException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } on NetworkException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e, stackTrace) {
      debugPrint('createList error: $e\n$stackTrace');
      state = state.copyWith(error: 'Une erreur est survenue');
      return false;
    }
  }

  Future<bool> updateList(String id, {String? name}) async {
    try {
      final updatedList = await _listsRepository.updateList(id, name: name);
      state = state.copyWith(
        ownedLists: state.ownedLists
            .map((l) => l.id == id ? updatedList : l)
            .toList(),
        sharedLists: state.sharedLists
            .map((l) => l.id == id ? updatedList : l)
            .toList(),
      );
      return true;
    } on ServerException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } on NetworkException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e, stackTrace) {
      debugPrint('updateList error: $e\n$stackTrace');
      state = state.copyWith(error: 'Une erreur est survenue');
      return false;
    }
  }

  Future<bool> deleteList(String id) async {
    try {
      await _listsRepository.deleteList(id);
      state = state.copyWith(
        ownedLists: state.ownedLists.where((l) => l.id != id).toList(),
        sharedLists: state.sharedLists.where((l) => l.id != id).toList(),
      );
      return true;
    } on ServerException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } on NetworkException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e, stackTrace) {
      debugPrint('deleteList error: $e\n$stackTrace');
      state = state.copyWith(error: 'Une erreur est survenue');
      return false;
    }
  }

  Future<void> refresh() async {
    try {
      await _listsRepository.refreshLists();
    } catch (e, stackTrace) {
      debugPrint('refreshLists error: $e\n$stackTrace');
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
