import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/utils/pi_mailer.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view.dart';
import 'package:privacyidea_authenticator/views/view_interface.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/app_info_utils.dart';
import '../../utils/globals.dart';

class FeedbackView extends StatefulView {
  static const String routeName = '/feedback';

  @override
  get routeSettings => const RouteSettings(name: routeName);

  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  final TextEditingController _feedbackController = TextEditingController();
  bool addDeviceInfo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.feedback),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  AppLocalizations.of(context)!.feedbackTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.feedbackDescription,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _feedbackController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: AppLocalizations.of(context)!.feedback,
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${AppLocalizations.of(context)!.feedbackHint} ',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            TextSpan(text: AppLocalizations.of(context)!.feedbackPrivacyPolicy1, style: Theme.of(context).textTheme.bodySmall),
                            TextSpan(
                              text: AppLocalizations.of(context)!.feedbackPrivacyPolicy1,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue),
                              recognizer: TapGestureRecognizer()..onTap = () => launchUrl(policyStatementUri),
                            ),
                            TextSpan(text: AppLocalizations.of(context)!.feedbackPrivacyPolicy3, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => setState(() => addDeviceInfo = !addDeviceInfo),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          child: Text(
                            AppLocalizations.of(context)!.addSystemInfo,
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: addDeviceInfo,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                addDeviceInfo = value;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final String mailText;
                      if (addDeviceInfo) {
                        mailText = _addDeviceInfoToMail(_feedbackController.text);
                      } else {
                        mailText = _feedbackController.text;
                      }
                      final sended = await _sendMail(mailText);
                      if (sended) {
                        showAsyncDialog(
                          builder: (context) => DefaultDialog(
                            title: Text(AppLocalizations.of(context)!.feedbackSentTitle),
                            content: Text(AppLocalizations.of(context)!.feedbackSentDescription),
                            actionsAlignment: MainAxisAlignment.center,
                            actions: [
                              ElevatedButton(
                                  onPressed: () => Navigator.of(context).popUntil((route) => route.settings.name == MainView.routeName),
                                  child: Text(AppLocalizations.of(context)!.ok))
                            ],
                          ),
                          barrierDismissible: false,
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppLocalizations.of(context)!.send),
                        const SizedBox(width: 8),
                        const Icon(Icons.mail_outline),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _addDeviceInfoToMail(String feedback) => '$feedback\n\n[${AppInfoUtils.appVersionAndBuildNumber}] ${AppInfoUtils.deviceInfoString}';
  Future<bool> _sendMail(String mailText) => PiMailer.sendMail(subjectPrefix: 'Feedback', body: mailText, subjectAppVersion: false);
}
