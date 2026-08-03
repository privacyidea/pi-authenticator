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

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

/// The log file that [Logger] writes, for a test to read.
///
/// This is the file the user attaches when they send in an error report, and
/// it is not the same as what the console shows: only the file is written
/// through the sensitive value filter, and only what is logged verbosely or
/// while verbose logging is on reaches it at all.
class LogFile {
  /// Starts every entry, which is the line holding the level, the time and the
  /// place the entry was logged from.
  static final _entryStart = RegExp(
    r'^\[[A-Z]+\] \d{4}-\d{2}-\d{2} ',
    multiLine: true,
  );

  final Directory _directory;

  LogFile._(this._directory);

  /// Points [Logger] at a log file in a temporary directory and turns writing
  /// to it on.
  ///
  /// Belongs in a setUpAll and has to run before anything logs: [Logger] keeps
  /// one instance per isolate and only the first setup of it takes effect.
  static Future<LogFile> setUp() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final directory = Directory.systemTemp.createTempSync('pi_authenticator');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => directory.path,
        );
    // Writing to file starts once the app is running, which an empty runner is
    // enough to stand in for.
    Logger.init(appRunner: () {});
    final logFile = LogFile._(directory);
    await logFile.clear();
    return logFile;
  }

  /// Removes the directory the log file was written to.
  void tearDown() => _directory.deleteSync(recursive: true);

  Future<void> clear() async {
    Logger.clearErrorLog();
    await pumpEventQueue();
  }

  /// The log file as it stands, after the entries that are still on their way
  /// into it arrived.
  Future<String> read() async {
    await pumpEventQueue();
    return Logger.getErrorLog();
  }

  /// The log file split into one string per logged entry.
  Future<List<String>> entries() async {
    final text = await read();
    final starts = _entryStart.allMatches(text).map((m) => m.start).toList();
    return [
      for (var i = 0; i < starts.length; i++)
        text
            .substring(
              starts[i],
              i + 1 < starts.length ? starts[i + 1] : text.length,
            )
            .trim(),
    ];
  }

  /// The entries of the log file that contain [part].
  Future<List<String>> entriesContaining(String part) async =>
      (await entries()).where((entry) => entry.contains(part)).toList();
}
