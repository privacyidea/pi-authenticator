/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
  const SecureStorageMutexed();

  static final Mutex _m = Mutex();
  static final FlutterSecureStorage storage = const FlutterSecureStorage();

  /// Function [f] is executed, protected by Mutex [_m].
  /// That means, that calls of this method will always be executed serial.
  Future<T> _protect<T>(Future<T> Function() f) => _m.protect<T>(f);

  Future<void> write({required String key, required String value}) => _protect(() => storage.write(key: key, value: value));
  Future<String?> read({required String key}) => _protect(() => storage.read(key: key));
  Future<Map<String, String>> readAll() => _protect(() => storage.readAll());
  Future<void> delete({required String key}) => _protect(() => storage.delete(key: key));
  Future<void> deleteAll() => _protect(() => storage.deleteAll());
}
