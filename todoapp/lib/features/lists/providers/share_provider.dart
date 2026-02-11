import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todoapp/core/di/providers.dart';
import 'package:todoapp/core/errors/exceptions.dart';
import 'package:todoapp/domain/repositories/lists_repository.dart';
import 'package:todoapp/features/lists/state/share_state.dart';

final shareProvider = StateNotifierProvider<ShareNotifier, ShareState>((ref) {
  return ShareNotifier(ref.watch(listsRepositoryProvider));
});

class ShareNotifier extends StateNotifier<ShareState> {
  final ListsRepository _listsRepository;

  ShareNotifier(this._listsRepository) : super(const ShareState());

  Future<void> shareList(
    String listId,
    List<Map<String, String>> shares,
  ) async {
    state = state.copyWith(isSharing: true, clearResult: true);
    try {
      final results = await _listsRepository.shareList(listId, shares);
      state = state.copyWith(
        isSharing: false,
        shareResult: results,
        hasShared: true,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isSharing: false,
        hasShared: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isSharing: false,
        hasShared: false,
        error: 'Une erreur inattendue est survenue',
      );
    }
  }

  void clearResult() {
    state = state.copyWith(clearResult: true);
  }
}
