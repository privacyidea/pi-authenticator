import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorageInterface {
  Future<void> delete({required String key});
  Future<void> deleteAll();
  Future<String?> read({required String key});
  Future<Map<String, String>> readAll();
  FlutterSecureStorage get storage;
  String get storagePrefix;
  Future<void> write({required String key, required String value});

  String getFullKey(String key);
}
