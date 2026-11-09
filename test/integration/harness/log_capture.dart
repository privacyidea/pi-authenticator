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

import 'package:logger/logger.dart' as printer;
import 'package:privacyidea_authenticator/utils/logger.dart';

class CapturedLog {
  final printer.Level level;
  final String message;
  final Object? error;

  const CapturedLog(this.level, this.message, this.error);

  @override
  String toString() =>
      '[${level.name}] $message${error != null ? ' | error: $error' : ''}';
}

/// Collects what the app logs instead of printing it, so a flow can assert
/// that it ran without errors. Set INTEGRATION_LOGS=1 to also print it.
class LogCapture {
  final List<CapturedLog> entries = [];
  static final _echo = Platform.environment['INTEGRATION_LOGS'] == '1';

  LogCapture._();

  factory LogCapture.install() {
    final capture = LogCapture._();
    Logger.print = printer.Logger(
      filter: _AllowAll(),
      printer: _Collect(capture),
      output: _echo ? printer.ConsoleOutput() : _Discard(),
    );
    return capture;
  }

  Iterable<CapturedLog> get errors =>
      entries.where((e) => e.level.value >= printer.Level.error.value);

  Iterable<CapturedLog> get warnings =>
      entries.where((e) => e.level == printer.Level.warning);

  bool contains(Pattern pattern) =>
      entries.any((e) => e.message.contains(pattern));

  String dump() => entries.join('\n');
}

class _AllowAll extends printer.LogFilter {
  @override
  bool shouldLog(printer.LogEvent event) => true;
}

class _Discard extends printer.LogOutput {
  @override
  void output(printer.OutputEvent event) {}
}

class _Collect extends printer.LogPrinter {
  final LogCapture capture;
  _Collect(this.capture);

  @override
  List<String> log(printer.LogEvent event) {
    final message = '${event.message}';
    capture.entries.add(CapturedLog(event.level, message, event.error));
    return [
      '[${event.level.name}] $message${event.error != null ? ' | ${event.error}' : ''}',
    ];
  }
}
