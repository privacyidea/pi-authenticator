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

import '../../../../../../../utils/view_utils.dart';
import '../../../../../../../widgets/button_widgets/cooldown_button.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/tokens/hotp_token.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/custom_trailing.dart';
import '../../../../../widgets/hideable_widget_.dart';
import '../token_widget_tile.dart';

class HOTPTokenWidgetTile extends ConsumerWidget {
  final HOTPToken token;
  final bool isPreview;

  const HOTPTokenWidgetTile(this.token, {super.key, this.isPreview = false});

  void _updateOtpValue() {
    globalRef?.read(tokenProvider.notifier).incrementCounter(token);
  }

  void _copyOtpValue(BuildContext context) {
    if (globalRef?.read(disableCopyOtpProvider) ?? false) return;

    globalRef?.read(disableCopyOtpProvider.notifier).state = true;
    Clipboard.setData(ClipboardData(text: token.otpValue));
    showSnackBar(AppLocalizations.of(context)!.otpValueCopiedMessage(token.otpValue));
    Future.delayed(const Duration(seconds: 5), () {
      globalRef?.read(disableCopyOtpProvider.notifier).state = false;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => TokenWidgetTile(
        key: Key('${token.hashCode}TokenWidgetTile'),
        token: token,
        semanticsLabel: token.isHidden ? AppLocalizations.of(context)!.authenticateToShowOtp : AppLocalizations.of(context)!.copyOTPToClipboard,
        titleOnTap: isPreview
            ? null
            : token.isLocked && token.isHidden
                ? () async => await ref.read(tokenProvider.notifier).showToken(token)
                : () => _copyOtpValue(context),
        title: insertCharAt(token.otpValue, ' ', (token.digits / 2).ceil()),
        additionalSubtitles: isPreview
            ? [
                'Algorithm: ${token.algorithm.name}',
                'Counter: ${token.counter}',
              ]
            : [],
        trailing: CustomTrailing(
          child: isPreview
              ? FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    size: 100,
                    Icons.replay,
                  ),
                )
              : HideableWidget(
                  token: token,
                  isHidden: token.isHidden,
                  child: Semantics(
                    label: AppLocalizations.of(context)!.increaseCounter,
                    child: CooldownButton(
                      styleType: CooldownButtonStyleType.iconButton,
                      onPressed: () async => _updateOtpValue(),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Icon(
                          size: 100,
                          Icons.replay,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      );
}
