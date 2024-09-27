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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';

class LinkInputView extends ConsumerStatefulWidget {
  const LinkInputView({super.key});

  @override
  ConsumerState<LinkInputView> createState() => _LinkInputViewState();
}

class _LinkInputViewState extends ConsumerState<LinkInputView> {
  final textController = TextEditingController();

  Future<void> addToken(Uri link) async {
    if (link.scheme != 'otpauth') {
      ref.read(statusMessageProvider.notifier).state = (AppLocalizations.of(context)!.linkMustOtpAuth, '');
      return;
    }
    await ref.read(tokenProvider.notifier).handleLink(link);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.tokenLink,
                  ),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (text) => addToken(Uri.parse(text)),
                  validator: (value) => value != null
                      ? Uri.tryParse(value) == null
                          ? AppLocalizations.of(context)!.invalidUrl
                          : null
                      : null,
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.paste),
                onPressed: () async {
                  ClipboardData? data = await Clipboard.getData('text/plain');
                  if (data == null || data.text == null || data.text!.isEmpty) {
                    if (context.mounted) ref.read(statusMessageProvider.notifier).state = (AppLocalizations.of(context)!.clipboardEmpty, '');
                    return;
                  }
                  setState(() => textController.text = data.text ?? '');
                },
              ),
            ],
          ),
          Expanded(child: SizedBox()),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              child: Text(
                AppLocalizations.of(context)!.addToken,
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              onPressed: () => addToken(Uri.parse(textController.text)),
            ),
          ),
        ],
      );
}
