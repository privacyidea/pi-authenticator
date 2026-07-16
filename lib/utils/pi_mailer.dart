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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

import '../l10n/app_localizations.dart';
import '../widgets/dialog_widgets/default_dialog.dart';
import 'logger.dart';
import 'view_utils.dart';

class PiMailer {
  static const MethodChannel _androidMailerChannel = MethodChannel(
    'it.netknights.piauthenticator/mailer',
  );

  static String _mailSubject(String subject, String? subjectPrefix) {
    if (subjectPrefix == null) return subject;
    return subject.isEmpty ? subjectPrefix : '$subjectPrefix $subject';
  }

  static Future<bool> sendMail({
    required Set<String> mailRecipients,
    required String subject,
    String? subjectPrefix,
    required String body,
    List<String> attachmentPaths = const [],
  }) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _androidMailerChannel.invokeMethod('send', {
          'recipients': [...mailRecipients],
          'subject': _mailSubject(subject, subjectPrefix),
          'body': body,
          'attachmentPath': attachmentPaths.isEmpty ? null : attachmentPaths.first,
        });
      } else {
        final Email email = Email(
          body: body,
          subject: _mailSubject(subject, subjectPrefix),
          recipients: [...mailRecipients],
          attachmentPaths: attachmentPaths,
        );
        await FlutterEmailSender.send(email);
      }
    } catch (e, stackTrace) {
      final noMailAppAvailable =
          e is FlutterEmailSenderNotAvailableException ||
          (e is PlatformException && e.code == 'not_available');
      showAsyncDialog(
        builder: (context) {
          final AppLocalizations appLocalizations = AppLocalizations.of(
            context,
          )!;
          return DefaultDialog(
            title: Text(appLocalizations.noMailAppTitle),
            content: Text(appLocalizations.noMailAppDescription),
            actions: [
              DialogAction(
                label: appLocalizations.ok,
                intent: ActionIntent.neutral,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
      if (noMailAppAvailable) {
        Logger.warning(
          'No mail app available to send the Email',
          error: e,
          stackTrace: stackTrace,
        );
      } else {
        Logger.error(
          'Was not able to send the Email',
          error: e,
          stackTrace: stackTrace,
        );
      }
      return false;
    }
    return true;
  }
}
