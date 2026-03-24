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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/pi_mailer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String channelName = 'flutter_mailer';
  final List<MethodCall> methodCalls = <MethodCall>[];

  setUp(() {
    methodCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(channelName), (
          MethodCall methodCall,
        ) async {
          methodCalls.add(methodCall);
          if (methodCall.method == 'send') {
            return 'sent';
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(channelName), null);
  });

  group('PiMailer - sendMail', () {
    test('should send mail with correct arguments', () async {
      final result = await PiMailer.sendMail(
        mailRecipients: {'test@test.com'},
        subject: 'TestSubject',
        subjectPrefix: 'Prefix',
        body: 'TestBody',
        attachments: ['path/to/file'],
      );

      expect(result, isTrue);
      expect(methodCalls.length, 1);

      final Map<dynamic, dynamic> args = methodCalls.first.arguments;
      expect(args['subject'], 'Prefix TestSubject');
      expect(args['recipients'], ['test@test.com']);
    });

    test('should return false on UNAVAILABLE PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), (
            MethodCall methodCall,
          ) async {
            throw PlatformException(code: 'UNAVAILABLE');
          });

      final result = await PiMailer.sendMail(
        mailRecipients: {'test@test.com'},
        subject: 'Test',
        body: 'Body',
      );

      expect(result, isFalse);
    });

    test('should return false on any other PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), (
            MethodCall methodCall,
          ) async {
            throw PlatformException(code: 'ERROR_500');
          });

      final result = await PiMailer.sendMail(
        mailRecipients: {'test@test.com'},
        subject: 'Test',
        body: 'Body',
      );

      expect(result, isFalse);
    });

    test('should correctly format subject prefix when provided', () async {
      await PiMailer.sendMail(
        mailRecipients: {'test@test.com'},
        subject: 'Subject',
        subjectPrefix: 'News:',
        body: 'Body',
      );

      final Map<dynamic, dynamic> args = methodCalls.first.arguments;
      expect(args['subject'], 'News: Subject');
    });

    test('should catch non-platform exceptions', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), (
            MethodCall methodCall,
          ) async {
            throw StateError('Unexpected state');
          });

      final result = await PiMailer.sendMail(
        mailRecipients: {'test@test.com'},
        subject: 'Test',
        body: 'Body',
      );

      expect(result, isFalse);
    });
  });
}
