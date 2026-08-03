/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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
import 'dart:async';

/// Self contained replacement for the `Mutex` of the `mutex` package.
///
/// Provides mutual exclusion with first-in-first-out ordering of waiters.
class Mutex {
  final _waiting = <Completer<void>>[];
  bool _locked = false;

  /// Indicates if a lock has been acquired and not released.
  bool get isLocked => _locked;

  /// Acquires the lock.
  ///
  /// Returns a future that completes once the lock has been acquired.
  Future<void> acquire() {
    if (!_locked) {
      _locked = true;
      return Future.value();
    }
    final completer = Completer<void>();
    _waiting.add(completer);
    return completer.future;
  }

  /// Releases a lock that has been acquired.
  ///
  /// Throws a [StateError] if no lock is currently held.
  void release() {
    if (!_locked) {
      throw StateError('no lock to release');
    }
    if (_waiting.isNotEmpty) {
      // Hand the lock over to the next waiter without unlocking in between.
      _waiting.removeAt(0).complete();
    } else {
      _locked = false;
    }
  }

  /// Acquires the lock, runs [criticalSection] and always releases the lock.
  Future<T> protect<T>(Future<T> Function() criticalSection) async {
    await acquire();
    try {
      return await criticalSection();
    } finally {
      release();
    }
  }
}
