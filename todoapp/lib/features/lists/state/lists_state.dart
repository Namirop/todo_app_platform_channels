import '../../../domain/entities/list.dart';

class ListsState {
  final List<ListEntity> ownedLists;
  final List<ListEntity> sharedLists;
  final bool isLoading;
  final String? error;

  const ListsState({
    this.ownedLists = const [],
    this.sharedLists = const [],
    this.isLoading = false,
    this.error,
  });

  ListsState copyWith({
    List<ListEntity>? ownedLists,
    List<ListEntity>? sharedLists,
    bool? isLoading,
    bool? isSuccessShare,
    String? error,
    String? successShareCount,
    String? failShareCount,
    bool clearError = false,
  }) {
    return ListsState(
      ownedLists: ownedLists ?? this.ownedLists,
      sharedLists: sharedLists ?? this.sharedLists,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<ListEntity> get allLists => [...ownedLists, ...sharedLists];

  ListEntity? getById(String id) {
    try {
      return allLists.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ListEntity> ownedBy(String userId) =>
      allLists.where((l) => l.isOwnedBy(userId)).toList();
}
