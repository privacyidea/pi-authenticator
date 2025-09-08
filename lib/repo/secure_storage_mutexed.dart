/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mutex/mutex.dart';

class SecureStorageMutexed {
  static final Mutex _m = Mutex();
  final FlutterSecureStorage storage;
  final String storagePrefix;

  SecureStorageMutexed({
    required this.storagePrefix,
    AndroidOptions aOptions = const AndroidOptions(),
    IOSOptions iOptions = const IOSOptions(),
    LinuxOptions lOptions = const LinuxOptions(),
    MacOsOptions mOptions = const MacOsOptions(),
    WindowsOptions wOptions = const WindowsOptions(),
  }) : storage = FlutterSecureStorage(aOptions: aOptions, iOptions: iOptions, lOptions: lOptions, mOptions: mOptions, wOptions: wOptions);

  String _fullKey(String key) => "${storagePrefix}_$key";

  /// Function [f] is executed, protected by Mutex [_m].
  /// That means, that calls of this method will always be executed serial.
  Future<T> _protect<T>(Future<T> Function() f) => _m.protect<T>(f);

  /// Writes the given key-value pair to the secure storage.
  Future<void> write({required String key, required String value}) => _protect(() => storage.write(key: _fullKey(key), value: value));

  /// Reads the value for the given key from the secure storage.
  Future<String?> read({required String key}) => _protect(() => storage.read(key: _fullKey(key)));

  /// Reads all key-value pairs from the secure storage that start with the storagePrefix.
  Future<Map<String, String>> readAll() => _protect(() async {
        final allPairs = await storage.readAll();
        final allKeys = allPairs.keys.where((key) => key.startsWith(storagePrefix)).toList();
        final result = <String, String>{};
        for (var key in allKeys) {
          final shortKey = key.substring(storagePrefix.length + 1);
          result[shortKey] = allPairs[key]!;
        }
        return result;
      });

  /// Deletes the entry with the given key from the secure storage.
  Future<void> delete({required String key}) => _protect(() => storage.delete(key: _fullKey(key)));

  /// Deletes all entries from the secure storage that start with the storagePrefix.
  Future<void> deleteAll() => _protect(() async {
        final allPairs = await storage.readAll();
        final allKeys = allPairs.keys.where((key) => key.startsWith(storagePrefix)).toList();
        for (var key in allKeys) {
          await storage.delete(key: key);
        }
      });
}
