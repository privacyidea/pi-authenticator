import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/tokens/totp_token.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/custom_texts.dart';
import '../../../../../widgets/custom_trailing.dart';
import '../../../../../widgets/hideable_widget_.dart';
import '../token_widget_tile.dart';
import 'totp_token_widget_tile_countdown.dart';

class TOTPTokenWidgetTile extends ConsumerWidget {
  final TOTPToken token;
  final bool isPreview;

  const TOTPTokenWidgetTile(this.token, {super.key, this.isPreview = false});

  void _copyOtpValue(BuildContext context) {
    if (globalRef?.read(disableCopyOtpProvider) ?? false) return;

    globalRef?.read(disableCopyOtpProvider.notifier).state = true;
    Clipboard.setData(ClipboardData(text: token.otpValue));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.otpValueCopiedMessage(token.otpValue))),
    );
    Future.delayed(const Duration(seconds: 5), () => globalRef?.read(disableCopyOtpProvider.notifier).state = false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TokenWidgetTile(
      isPreview: isPreview,
      key: Key('${token.hashCode}TokenWidgetTile'),
      tokenImage: token.tokenImage,
      tokenIsLocked: token.isLocked,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Tooltip(
          message: token.isHidden ? AppLocalizations.of(context)!.authenticateToShowOtp : AppLocalizations.of(context)!.copyOTPToClipboard,
          triggerMode: TooltipTriggerMode.longPress,
          child: InkWell(
            onTap: isPreview
                ? null
                : token.isLocked && token.isHidden
                    ? () async => await ref.read(tokenProvider.notifier).showToken(token)
                    : () => _copyOtpValue(context),
            child: HideableText(
              key: Key(token.hashCode.toString()),
              text: insertCharAt(token.otpValue, ' ', (token.digits / 2).ceil()),
              textScaleFactor: 1.9,
              enabled: token.isLocked,
              isHidden: token.isHidden,
            ),
          ),
        ),
      ),
      subtitles: isPreview
          ? [
              (token.label.isNotEmpty && token.issuer.isNotEmpty) ? '${token.issuer}: ${token.label}' : token.issuer + token.label,
              'Algorithm: ${token.algorithm.name}',
              'Period: ${token.period} seconds',
            ]
          : [
              if (token.label.isNotEmpty) token.label,
              if (token.issuer.isNotEmpty) token.issuer,
            ],
      trailing: CustomTrailing(
        child: HideableWidget(
          token: token,
          isHidden: token.isHidden && !isPreview,
          child: TotpTokenWidgetTileCountdown(token),
        ),
      ),
    );
  }
}
