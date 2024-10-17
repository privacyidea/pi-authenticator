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

import '../../../l10n/app_localizations.dart';
import '../../../utils/app_info_utils.dart';
import '../../../utils/pi_mailer.dart';
import '../../../utils/view_utils.dart';
import '../../../widgets/dialog_widgets/default_dialog.dart';
import '../../main_view/main_view.dart';

class FeedbackSendRow extends StatefulWidget {
  final TextEditingController feedbackController;

  const FeedbackSendRow({super.key, required this.feedbackController});

  @override
  State<FeedbackSendRow> createState() => _FeedbackSendRowState();
}

class _FeedbackSendRowState extends State<FeedbackSendRow> {
  late final _feedbackController = widget.feedbackController;
  bool _addDeviceInfo = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(child: SizedBox()),
              Expanded(
                flex: 4,
                child: TextButton(
                  onPressed: () => setState(() => _addDeviceInfo = !_addDeviceInfo),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
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
                            value: _addDeviceInfo,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _addDeviceInfo = value;
                              });
                            }),
                      ),
                    ],
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: ElevatedButton(
              onPressed: () async {
                final String mailText;
                if (_addDeviceInfo) {
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
          ),
        ),
      ],
    );
  }

  String _addDeviceInfoToMail(String feedback) => '$feedback\n\n[${AppInfoUtils.currentVersionAndBuildNumber}] ${AppInfoUtils.deviceInfoString}';
  Future<bool> _sendMail(String mailText) => PiMailer.sendMail(subjectPrefix: 'Feedback', body: mailText, subjectAppVersion: false);
}
