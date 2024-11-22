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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mailer/flutter_mailer.dart';

import '../l10n/app_localizations.dart';
import '../widgets/dialog_widgets/default_dialog.dart';
import 'app_info_utils.dart';
import 'logger.dart';
import 'view_utils.dart';

class PiMailer {
  final Set<String> mailRecipients;
  const PiMailer({required this.mailRecipients});

  static String _mailSubject(String? subject, String? subjectPrefix, bool subjectAppVersion) {
    String mailSubject = subjectPrefix != null ? '[$subjectPrefix] ' : '';
    if (subjectAppVersion) mailSubject += '(${InfoUtils.currentVersionString}+${InfoUtils.currentBuildNumber}) ';
    mailSubject += '${InfoUtils.appName}';
    if (subject != null) mailSubject += ' >>> $subject';
    return mailSubject;
  }

  Future<bool> sendMail({
    String? subject,
    String? subjectPrefix,
    bool subjectAppVersion = true,
    required String body,
    List<String> attachments = const [],
  }) async {
    try {
      final MailOptions mailOptions = MailOptions(
        body: body,
        subject: _mailSubject(subject, subjectPrefix, subjectAppVersion),
        recipients: [...mailRecipients],
        attachments: attachments,
      );
      await FlutterMailer.send(mailOptions);
    } on PlatformException catch (e, stackTrace) {
      if (e.code == 'UNAVAILABLE') {
        showAsyncDialog(
          builder: (context) {
            final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
            return DefaultDialog(
              title: Text(appLocalizations.noMailAppTitle),
              content: Text(appLocalizations.noMailAppDescription),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(appLocalizations.ok),
                ),
              ],
            );
          },
        );
        return false;
      }
      Logger.error('Was not able to send the Email', error: e, stackTrace: stackTrace);
      return false;
    } catch (e, stackTrace) {
      Logger.error('Was not able to send the Email', error: e, stackTrace: stackTrace);
      return false;
    }
    return true;
  }
}
