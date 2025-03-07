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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../../views/feedback_view/widgets/feedback_send_row.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/globals.dart';
import '../view_interface.dart';

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
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () => _focusNode.requestFocus());
    });
  }

  @override
  void dispose() {
    _focusNode.unfocus();
    _focusNode.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
                    style: Theme.of(context).textTheme.titleMedium,
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
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          focusNode: _focusNode,
                          controller: _feedbackController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(borderSide: BorderSide(width: 1.5)),
                            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(width: 1.5)),
                            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(width: 1.5)),
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
                                text: AppLocalizations.of(context)!.feedbackPrivacyPolicy2,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue),
                                recognizer: TapGestureRecognizer()..onTap = () => launchUrl(policyStatementUri),
                              ),
                              TextSpan(text: AppLocalizations.of(context)!.feedbackPrivacyPolicy3, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        FeedbackSendRow(feedbackController: _feedbackController),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
