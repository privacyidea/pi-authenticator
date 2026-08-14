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
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../utils/utils.dart';
import '../../../../../utils/view_utils.dart';
import '../../../../../widgets/custom_trailing.dart';
import '../../../../../widgets/token_visibility_shield.dart';
import '../token_widget_tile.dart';
import 'totp_token_widget_tile_countdown.dart';

class TOTPTokenWidgetTile extends ConsumerStatefulWidget {
  final TOTPToken token;
  final bool isPreview;

  const TOTPTokenWidgetTile(this.token, {super.key, this.isPreview = false});

  @override
  ConsumerState<TOTPTokenWidgetTile> createState() =>
      _TOTPTokenWidgetTileState();
}

class _TOTPTokenWidgetTileState extends ConsumerState<TOTPTokenWidgetTile>
    with SingleTickerProviderStateMixin {
  late String currentOtpValue = widget.token.otpValue;
  TotpAnimation? _animation;
  UnscaledAnimationController? _animationController;
  TokenTileTheme? _tokenTileTheme;
  Color? _currentOtpColor;
  Color? _currentCountdownColor;
  double _secondsUntilNextOTP = 0;

  void _copyOtpValue(BuildContext context) {
    if (globalRef?.read(disableCopyOtpProvider) ?? false) return;

    globalRef?.read(disableCopyOtpProvider.notifier).state = true;
    Clipboard.setData(ClipboardData(text: widget.token.otpValue));
    showSnackBar(
      AppLocalizations.of(
        context,
      )!.otpValueCopiedMessage(widget.token.otpValue),
    );
    Future.delayed(
      const Duration(seconds: 5),
      () => globalRef?.read(disableCopyOtpProvider.notifier).state = false,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tokenTileTheme = Theme.of(context).extension<TokenTileTheme>();
    if (tokenTileTheme == null) {
      Logger.error("TokenTileTheme is not set");
      return;
    }
    _tokenTileTheme = tokenTileTheme;
    final animation = _animation;
    if (animation == null) {
      _initAnimation(tokenTileTheme);
      return;
    }
    animation.updateColors(
      defaultOtpColor: tokenTileTheme.defaultOtpColor,
      warningOtpColor: tokenTileTheme.warningOtpColor,
      criticalOtpColor: tokenTileTheme.criticalOtpColor,
      defaultCountdownColor: tokenTileTheme.defaultCountdownColor,
      warningCountdownColor: tokenTileTheme.warningCountdownColor,
      criticalCountdownColor: tokenTileTheme.criticalCountdownColor,
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _initAnimation(TokenTileTheme tokenTileTheme) {
    final animation = TotpAnimation(
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
      defaultOtpColor: tokenTileTheme.defaultOtpColor,
      warningOtpColor: tokenTileTheme.warningOtpColor,
      criticalOtpColor: tokenTileTheme.criticalOtpColor,
      defaultCountdownColor: tokenTileTheme.defaultCountdownColor,
      warningCountdownColor: tokenTileTheme.warningCountdownColor,
      criticalCountdownColor: tokenTileTheme.criticalCountdownColor,
    );
    _animation = animation;
    _animationController = animation.createAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return TokenWidgetTile(
      key: Key('${widget.token.hashCode}TokenWidgetTile'),
      semanticsLabel: widget.token.isHidden
          ? AppLocalizations.of(context)!.authenticateToShowOtp
          : AppLocalizations.of(context)!.copyOTPToClipboard,
      titleOnTap: widget.isPreview
          ? null
          : widget.token.isLocked && widget.token.isHidden
          ? () async =>
                await ref.read(tokenProvider.notifier).showToken(widget.token)
          : () => _copyOtpValue(context),
      token: widget.token,
      title: insertCharAt(
        widget.token.otpValue,
        ' ',
        (widget.token.digits / 2).ceil(),
      ),
      titleStyle: TextStyle(color: _currentOtpColor),
      additionalSubtitles: widget.isPreview
          ? [
              'Algorithm: ${widget.token.algorithm.name}',
              'Period: ${widget.token.period} seconds',
            ]
          : [],
      trailing: CustomTrailing(
        child: TokenVisibilityShield(
          token: widget.token,
          isHidden: widget.token.isHidden && !widget.isPreview,
          child: TotpTokenWidgetTileCountdown(
            period: widget.token.period,
            currentColor:
                _currentCountdownColor ??
                _tokenTileTheme?.defaultCountdownColor ??
                Theme.of(context).colorScheme.primary,
            secondsUntilNextOTP: _secondsUntilNextOTP,
          ),
        ),
      ),
    );
  }
}
