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
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_extentions/action_theme.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/tokens/totp_token.dart';
import '../../../../../utils/animations/totp_animation.dart';
import '../../../../../utils/animations/unscaled_animation_controller.dart';
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

class _TOTPTokenWidgetTileState extends ConsumerState<TOTPTokenWidgetTile> with SingleTickerProviderStateMixin {
  late String currentOtpValue = widget.token.otpValue;
  late UnscaledAnimationController _animationController;
  Color? _currentOtpColor;
  Color? _currentCountdownColor;
  double _secondsUntilNextOTP = 0;

  void _copyOtpValue(BuildContext context) {
    if (globalRef?.read(disableCopyOtpProvider) ?? false) return;

    globalRef?.read(disableCopyOtpProvider.notifier).state = true;
    Clipboard.setData(ClipboardData(text: widget.token.otpValue));
    showSnackBar(AppLocalizations.of(context)!.otpValueCopiedMessage(widget.token.otpValue));
    Future.delayed(const Duration(seconds: 5), () => globalRef?.read(disableCopyOtpProvider.notifier).state = false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAnimation());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initAnimation() {
    _animationController = TotpAnimation(
      context: context,
      vsync: this,
      onPeriodEnd: () {
        if (!mounted) return;
        setState(() => currentOtpValue = widget.token.otpValue);
      },
      callback: (v) {
        if (!mounted) return;
        setState(() {
          _currentOtpColor = v.otpColor;
          _currentCountdownColor = v.countdownColor;
          _secondsUntilNextOTP = v.secondsUntilNextOTP;
        });
      },
      totalDuration: Duration(seconds: widget.token.period),
      warningDuration: Duration(seconds: 2),
      criticalDuration: Duration(seconds: 3),
      defaultOtpColor: Theme.of(context).extension<TokenTileTheme>()!.defaultOtpColor,
      warningOtpColor: Theme.of(context).extension<TokenTileTheme>()!.warningOtpColor,
      criticalOtpColor: Theme.of(context).extension<TokenTileTheme>()!.criticalOtpColor,
      defaultCountdownColor: Theme.of(context).extension<TokenTileTheme>()!.defaultCountdownColor,
      warningCountdownColor: Theme.of(context).extension<TokenTileTheme>()!.warningCountdownColor,
      criticalCountdownColor: Theme.of(context).extension<TokenTileTheme>()!.criticalCountdownColor,
    ).createAnimation();
  }

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
      titleStyle: TextStyle(
        color: _currentOtpColor,
      ),
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
            currentColor: _currentCountdownColor ?? Theme.of(context).extension<TokenTileTheme>()!.defaultCountdownColor,
            secondsUntilNextOTP: _secondsUntilNextOTP,
          ),
        ),
      ),
    );
  }
}
