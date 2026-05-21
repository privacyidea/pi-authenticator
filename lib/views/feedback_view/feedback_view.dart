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

enum FeedbackCategory { improvement, bugReport, loginTokenHelp }

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
  FeedbackCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 200),
        () => _focusNode.requestFocus(),
      );
    });
  }

  @override
  void dispose() {
    _focusNode.unfocus();
    _focusNode.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  String _categoryLabel(AppLocalizations l10n, FeedbackCategory category) =>
      switch (category) {
        FeedbackCategory.improvement => l10n.feedbackCategoryImprovement,
        FeedbackCategory.bugReport => l10n.feedbackCategoryBugReport,
        FeedbackCategory.loginTokenHelp => l10n.feedbackCategoryLoginTokenHelp,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.feedback,
          overflow: TextOverflow.ellipsis, // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  l10n.feedbackTitle,
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
                        l10n.feedbackDescription,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<FeedbackCategory>(
                        decoration: InputDecoration(
                          labelText: l10n.feedbackCategoryLabel,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(width: 1.5),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(width: 1.5),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(width: 1.5),
                          ),
                        ),
                        initialValue: _selectedCategory,
                        items: FeedbackCategory.values
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(_categoryLabel(l10n, c)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() {
                          _selectedCategory = value;
                          if (value != FeedbackCategory.loginTokenHelp) {
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () => _focusNode.requestFocus(),
                            );
                          }
                        }),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedCategory ==
                          FeedbackCategory.loginTokenHelp) ...[
                        _LoginTokenHelpInfo(
                          infoText: l10n.feedbackCategoryLoginTokenHelpInfo,
                        ),
                      ] else ...[
                        TextField(
                          onTapOutside: (event) {
                            _focusNode.unfocus();
                          },
                          focusNode: _focusNode,
                          controller: _feedbackController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(width: 1.5),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(width: 1.5),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(width: 1.5),
                            ),
                            labelText: l10n.feedback,
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final linkText = l10n.feedbackPrivacyPolicyLinkText;
                            final parts = l10n.feedbackPrivacyPolicyFull(linkText).split(linkText);
                            return RichText(
                              textAlign: TextAlign.justify,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${l10n.feedbackHint} ${parts[0]}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  TextSpan(
                                    text: linkText,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => launchUrl(policyStatementUri),
                                  ),
                                  TextSpan(
                                    text: parts[1],
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        FeedbackSendRow(
                          feedbackController: _feedbackController,
                        ),
                      ],
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
}

class _LoginTokenHelpInfo extends StatelessWidget {
  final String infoText;

  const _LoginTokenHelpInfo({required this.infoText});

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.secondaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              infoText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
