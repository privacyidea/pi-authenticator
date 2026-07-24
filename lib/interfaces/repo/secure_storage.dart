import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Key-value storage backed by the platform's secure storage.
///
/// Every key is stored as its own entry, never as one combined blob.
///
/// iOS: One keychain item per key, the value is stored as is and encrypted by
/// the system. Keychain items survive an uninstall of the app.
///
/// Android: One entry per key in a SharedPreferences file, each value
/// encrypted with AES-GCM. The AES key is stored next to it, wrapped by an
/// RSA key that never leaves the Android KeyStore. Uninstalling deletes both
/// the entries and the KeyStore key.
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
  /// It is required to distinguish different data types in the same underlying storage to easily simulate multiple different storages.
  String get storagePrefix;

  /// Separator between storagePrefix and key in the full key.
  String get separator => '_';

  /// Prefixes of other storages that start with this storage's prefix.
  /// Their keys are not part of this storage and are left untouched.
  List<String> get excludedPrefixes => const [];

  /// Returns the full key used to store the given key in the underlying storage.
  String getFullKey(String key);
}
