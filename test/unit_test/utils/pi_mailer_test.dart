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

import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_email_sender_platform_interface/flutter_email_sender_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/pi_mailer.dart';

class FakeFlutterEmailSenderPlatform extends FlutterEmailSenderPlatform {
  FakeFlutterEmailSenderPlatform({this.sendError});

  final Object? sendError;
  Email? lastSentEmail;

  @override
  Future<void> send(Email email) async {
    if (sendError != null) throw sendError!;
    lastSentEmail = email;
  }

  @override
  Future<EmailCapabilities> getCapabilities() async => const EmailCapabilities(
    canSend: true,
    supportsCc: true,
    supportsBcc: true,
    supportsSubject: true,
    supportsPlainTextBody: true,
    supportsHtmlBody: true,
    supportsAttachments: true,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final originalPlatform = FlutterEmailSenderPlatform.instance;
  late FakeFlutterEmailSenderPlatform fakePlatform;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    fakePlatform = FakeFlutterEmailSenderPlatform();
    FlutterEmailSenderPlatform.instance = fakePlatform;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    FlutterEmailSenderPlatform.instance = originalPlatform;
  });

  group('PiMailer - sendMail', () {
    test('should send mail with correct arguments', () async {
      final result = await PiMailer.sendMail(
        mailRecipients: {'test@test.com'},
        subject: 'TestSubject',
        subjectPrefix: 'Prefix',
        body: 'TestBody',
        attachmentPaths: ['path/to/file'],
      );

      expect(result, isTrue);
      final sentEmail = fakePlatform.lastSentEmail!;
      expect(sentEmail.subject, 'Prefix TestSubject');
      expect(sentEmail.recipients, ['test@test.com']);
      expect(sentEmail.body, 'TestBody');
      expect(sentEmail.attachmentPaths, ['path/to/file']);
    });

    test('should return false on not_available PlatformException', () async {
      fakePlatform = FakeFlutterEmailSenderPlatform(
        sendError: const FlutterEmailSenderNotAvailableException(),
      );
      FlutterEmailSenderPlatform.instance = fakePlatform;

      final result = await PiMailer.sendMail(
        mailRecipients: {'test@test.com'},
        subject: 'Test',
        body: 'Body',
      );

      expect(result, isFalse);
    });

    test('should return false on any other platform exception', () async {
      fakePlatform = FakeFlutterEmailSenderPlatform(
        sendError: const FlutterEmailSenderPlatformException(
          code: 'ERROR_500',
          message: 'boom',
        ),
      );
      FlutterEmailSenderPlatform.instance = fakePlatform;

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

      expect(fakePlatform.lastSentEmail!.subject, 'News: Subject');
    });

    test(
      'should not add a trailing space when subject is empty but a prefix is given',
      () async {
        await PiMailer.sendMail(
          mailRecipients: {'test@test.com'},
          subject: '',
          subjectPrefix: 'Feedback:',
          body: 'Body',
        );

        expect(fakePlatform.lastSentEmail!.subject, 'Feedback:');
      },
    );

    test('should catch non-platform exceptions', () async {
      fakePlatform = FakeFlutterEmailSenderPlatform(
        sendError: StateError('Unexpected state'),
      );
      FlutterEmailSenderPlatform.instance = fakePlatform;

      final result = await PiMailer.sendMail(
        mailRecipients: {'test@test.com'},
        subject: 'Test',
        body: 'Body',
      );

      expect(result, isFalse);
    });
  });
}
