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
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

import '../l10n/app_localizations.dart';
import '../widgets/dialog_widgets/default_dialog.dart';
import 'logger.dart';
import 'view_utils.dart';

class PiMailer {
  static String _mailSubject(String subject, String? subjectPrefix) {
    return subjectPrefix != null ? '$subjectPrefix $subject' : subject;
  }

  static Future<bool> sendMail({
    required Set<String> mailRecipients,
    required String subject,
    String? subjectPrefix,
    required String body,
    List<String> attachments = const [],
  }) async {
    try {
      final Email email = Email(
        body: body,
        subject: _mailSubject(subject, subjectPrefix),
        recipients: [...mailRecipients],
        attachmentPaths: attachments,
      );
      await FlutterEmailSender.send(email);
    } on FlutterEmailSenderNotAvailableException catch (e, stackTrace) {
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
      Logger.warning(
        'No mail app available to send the Email',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      Logger.error(
        'Was not able to send the Email',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
    return true;
  }
}
