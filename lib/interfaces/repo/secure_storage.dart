import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorageInterface {
  /// Forwarded methods to the underlying storage.
  Future<void> delete({required String key});

  /// Forwarded methods to the underlying storage.
  Future<void> deleteAll();

  /// Forwarded methods to the underlying storage.
  Future<String?> read({required String key});

  /// Forwarded methods to the underlying storage.
  Future<Map<String, String>> readAll();

  /// Forwarded methods to the underlying storage.
  Future<void> write({required String key, required String value});

  /// Underlying storage used to store the data.
  FlutterSecureStorage get storage;

  /// Prefix for all keys stored in this storage.
  /// It is required to destinguish different data types in the same underlying storage to easily simulate multiple different storages.
  String get storagePrefix;

  /// Separator between storagePrefix and key in the full key.
  String get seperator => '_';

  /// Returns the full key used to store the given key in the underlying storage.
  String getFullKey(String key);
}
