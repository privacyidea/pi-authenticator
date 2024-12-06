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

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/tokens/totp_token.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../utils/utils.dart';
import '../../../../../utils/view_utils.dart';
import '../../../../../widgets/custom_trailing.dart';
import '../../../../../widgets/hideable_widget_.dart';
import '../token_widget_tile.dart';
import 'totp_token_widget_tile_countdown.dart';

class TOTPTokenWidgetTile extends ConsumerStatefulWidget {
  final TOTPToken token;
  final bool isPreview;

  const TOTPTokenWidgetTile(this.token, {super.key, this.isPreview = false});

  @override
  ConsumerState<TOTPTokenWidgetTile> createState() => _TOTPTokenWidgetTileState();
}

class _TOTPTokenWidgetTileState extends ConsumerState<TOTPTokenWidgetTile> {
  void _copyOtpValue(BuildContext context) {
    if (globalRef?.read(disableCopyOtpProvider) ?? false) return;

    globalRef?.read(disableCopyOtpProvider.notifier).state = true;
    Clipboard.setData(ClipboardData(text: widget.token.otpValue));
    showSnackBar(AppLocalizations.of(context)!.otpValueCopiedMessage(widget.token.otpValue));
    Future.delayed(const Duration(seconds: 5), () => globalRef?.read(disableCopyOtpProvider.notifier).state = false);
  }

  late String currentOtpValue = widget.token.otpValue;

  @override
  Widget build(BuildContext context) {
    return TokenWidgetTile(
      key: Key('${widget.token.hashCode}TokenWidgetTile'),
      semanticsLabel: widget.token.isHidden ? AppLocalizations.of(context)!.authenticateToShowOtp : AppLocalizations.of(context)!.copyOTPToClipboard,
      titleOnTap: widget.isPreview
          ? null
          : widget.token.isLocked && widget.token.isHidden
              ? () async => await ref.read(tokenProvider.notifier).showToken(widget.token)
              : () => _copyOtpValue(context),
      token: widget.token,
      title: insertCharAt(widget.token.otpValue, ' ', (widget.token.digits / 2).ceil()),
      additionalSubtitles: widget.isPreview
          ? [
              'Algorithm: ${widget.token.algorithm.name}',
              'Period: ${widget.token.period} seconds',
            ]
          : [],
      trailing: CustomTrailing(
        child: HideableWidget(
          token: widget.token,
          isHidden: widget.token.isHidden && !widget.isPreview,
          child: TotpTokenWidgetTileCountdown(
            period: widget.token.period,
            onPeriodEnd: () => setState(
              () => currentOtpValue = widget.token.otpValue,
            ),
          ),
        ),
      ),
    );
  }
}
