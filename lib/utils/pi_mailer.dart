import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mailer/flutter_mailer.dart';

import '../l10n/app_localizations.dart';
import '../widgets/dialog_widgets/default_dialog.dart';
import 'app_info_utils.dart';
import 'logger.dart';
import 'view_utils.dart';

class PiMailer {
  static String get _mailRecipient => 'app-crash@netknights.it';
  static String _mailSubject(String? subject, String? subjectPrefix, bool subjectAppVersion) {
    String mailSubject = subjectPrefix != null ? '[$subjectPrefix] ' : '';
    if (subjectAppVersion) mailSubject += '(${AppInfoUtils.currentVersionString}+${AppInfoUtils.currentBuildNumber}) ';
    mailSubject += '${AppInfoUtils.appName}';
    if (subject != null) mailSubject += ' >>> $subject';
    return mailSubject;
  }

  static Future<bool> sendMail({
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
        recipients: [_mailRecipient],
        attachments: attachments,
      );
      await FlutterMailer.send(mailOptions);
    } on PlatformException catch (e, stackTrace) {
      if (e.code == 'UNAVAILABLE') {
        showAsyncDialog(
          builder: (context) => DefaultDialog(
            title: Text(AppLocalizations.of(context)!.noMailAppTitle),
            content: Text(AppLocalizations.of(context)!.noMailAppDescription),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return false;
      }
      Logger.error('Was not able to send the Email', error: e, stackTrace: stackTrace, name: 'pi_mailer.dart#sendMail');
      return false;
    } catch (e, stackTrace) {
      Logger.error('Was not able to send the Email', error: e, stackTrace: stackTrace, name: 'pi_mailer.dart#sendMail');
      return false;
    }
    return true;
  }
}
