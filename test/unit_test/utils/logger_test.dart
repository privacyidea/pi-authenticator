/*
 * privacyIDEA Authenticator
 *
 * Copyright (c) 2026 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart' as printer;
import 'package:privacyidea_authenticator/utils/logger.dart';

void main() {
  test('filters private client keys from log output', () {
    const privateKey = 'SAMPLE_PRIVATE_KEY_123';
    const publicKey = 'SAMPLE_PUBLIC_KEY_456';
    final output = printer.MemoryOutput();
    final originalPrinter = Logger.print;
    addTearDown(() => Logger.print = originalPrinter);
    Logger.print = printer.Logger(
      printer: printer.SimplePrinter(colors: false),
      output: output,
    );

    Logger.info(
      'Saving container: '
      'TokenContainerFinalized('
      'publicClientKey: $publicKey, '
      'privateClientKey: $privateKey)',
    );

    final loggedText = output.buffer.expand((event) => event.lines).join('\n');
    expect(loggedText, contains('publicClientKey: $publicKey'));
    expect(loggedText, contains('privateClientKey'));
    expect(loggedText, contains('******'));
    expect(loggedText, isNot(contains(privateKey)));
  });
}
