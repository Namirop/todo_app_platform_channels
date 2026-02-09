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
      print("results : ${results.failures.length}");
      state = state.copyWith(isSharing: false, shareResult: results);
    } on ValidationException catch (e) {
      state = state.copyWith(isSharing: false, error: e.message);
    } on ForbiddenException catch (e) {
      state = state.copyWith(isSharing: false, error: e.message);
    } on NotFoundException catch (e) {
      state = state.copyWith(isSharing: false, error: e.message);
    } on NetworkException catch (e) {
      state = state.copyWith(isSharing: false, error: e.message);
    } on ServerException catch (e) {
      state = state.copyWith(isSharing: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isSharing: false,
        error: 'Une erreur inattendue est survenue',
      );
    }
  }

  void clearResult() {
    state = state.copyWith(clearResult: true);
  }
}
