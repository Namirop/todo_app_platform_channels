import 'package:hive_flutter/hive_flutter.dart';

import '../errors/exceptions.dart';

class CacheService {
  static const String _todosBoxName = 'todos_cache';
  static const String _listsBoxName = 'lists_cache';
  static const String _userBoxName = 'user_cache';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_todosBoxName);
    await Hive.openBox<Map>(_listsBoxName);
    await Hive.openBox<Map>(_userBoxName);
  }

  Future<void> put(
    String boxName,
    String key,
    Map<String, dynamic> value,
  ) async {
    try {
      final box = Hive.box<Map>(boxName);
      await box.put(key, value);
    } catch (e) {
      throw CacheException(message: 'Failed to write to cache: $e');
    }
  }

  Map<String, dynamic>? get(String boxName, String key) {
    try {
      final box = Hive.box<Map>(boxName);
      final value = box.get(key);
      return value != null ? Map<String, dynamic>.from(value) : null;
    } catch (e) {
      throw CacheException(message: 'Failed to read from cache: $e');
    }
  }

  Future<void> delete(String boxName, String key) async {
    try {
      final box = Hive.box<Map>(boxName);
      await box.delete(key);
    } catch (e) {
      throw CacheException(message: 'Failed to delete from cache: $e');
    }
  }

  Future<void> clearBox(String boxName) async {
    try {
      final box = Hive.box<Map>(boxName);
      await box.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }

  List<Map<String, dynamic>> getAll(String boxName) {
    try {
      final box = Hive.box<Map>(boxName);
      return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to read all from cache: $e');
    }
  }

  Future<void> putAll(
    String boxName,
    Map<String, Map<String, dynamic>> entries,
  ) async {
    try {
      final box = Hive.box<Map>(boxName);
      await box.putAll(entries);
    } catch (e) {
      throw CacheException(message: 'Failed to write all to cache: $e');
    }
  }

  Stream<BoxEvent> watch(String boxName, {String? key}) {
    final box = Hive.box<Map>(boxName);
    return box.watch(key: key);
  }

  static String get todosBoxName => _todosBoxName;
  static String get listsBoxName => _listsBoxName;
  static String get userBoxName => _userBoxName;
}
