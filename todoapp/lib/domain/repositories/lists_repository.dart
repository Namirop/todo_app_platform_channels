import 'package:todoapp/features/lists/models/share_result.dart';

import '../entities/list.dart';
import '../entities/list_share.dart';

abstract class ListsRepository {
  Stream<(List<ListEntity> ownedLists, List<ListEntity> sharedLists)>
  watchLists();
  Future<(List<ListEntity> ownedLists, List<ListEntity> sharedLists)>
  getLists();
  Future<ListEntity> getListById(String id);
  Future<ListEntity> createList(String name);
  Future<ListEntity> updateList(String id, {String? name});
  Future<void> deleteList(String id);
  Future<ShareResult> shareList(
    String listId,
    List<Map<String, String>> shares,
  );
  Future<void> removeShare(String listId);
  Future<List<ListShare>> getListShares(String listId);
}
