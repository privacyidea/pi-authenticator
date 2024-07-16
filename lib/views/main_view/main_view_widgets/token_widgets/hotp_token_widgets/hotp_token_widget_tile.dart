import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/tokens/hotp_token.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/riverpod/riverpod_providers/state_notifier_providers/token_provider.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/custom_texts.dart';
import '../../../../../widgets/custom_trailing.dart';
import '../../../../../widgets/hideable_widget_.dart';
import '../token_widget_tile.dart';

class HOTPTokenWidgetTile extends ConsumerStatefulWidget {
  final HOTPToken token;
  final bool isPreview;

  const HOTPTokenWidgetTile(this.token, {super.key, this.isPreview = false});

  @override
  ConsumerState<HOTPTokenWidgetTile> createState() => _HOTPTokenWidgetTileState();
}

class _HOTPTokenWidgetTileState extends ConsumerState<HOTPTokenWidgetTile> {
  bool disableTrailingButton = false;

  void _updateOtpValue() {
    setState(() {
      globalRef?.read(tokenProvider.notifier).incrementCounter(widget.token);
      disableTrailingButton = true;
    });
    _disableButtons();
  }

  void _disableButtons() {
    setState(() {
      disableTrailingButton = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          disableTrailingButton = false;
        });
      }
    });
  }

  void _copyOtpValue() {
    if (globalRef?.read(disableCopyOtpProvider) ?? false) return;

    globalRef?.read(disableCopyOtpProvider.notifier).state = true;
    Clipboard.setData(ClipboardData(text: widget.token.otpValue));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.otpValueCopiedMessage(widget.token.otpValue)),
      ),
    );
    Future.delayed(const Duration(seconds: 5), () {
      globalRef?.read(disableCopyOtpProvider.notifier).state = false;
    });
  }

  @override
  Widget build(BuildContext context) => TokenWidgetTile(
        key: Key('${widget.token.hashCode}TokenWidgetTile'),
        tokenImage: widget.token.tokenImage,
        tokenIsLocked: widget.token.isLocked,
        isPreview: widget.isPreview,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Tooltip(
            message: widget.token.isHidden ? AppLocalizations.of(context)!.authenticateToShowOtp : AppLocalizations.of(context)!.copyOTPToClipboard,
            triggerMode: TooltipTriggerMode.longPress,
            child: InkWell(
              onTap: widget.isPreview
                  ? null
                  : widget.token.isLocked && widget.token.isHidden
                      ? () async => await ref.read(tokenProvider.notifier).showToken(widget.token)
                      : _copyOtpValue,
              child: HideableText(
                textScaleFactor: 1.9,
                isHidden: widget.token.isHidden,
                text: insertCharAt(widget.token.otpValue, ' ', (widget.token.digits / 2).ceil()),
                enabled: widget.token.isLocked,
              ),
            ),
          ),
        ),
        subtitles: widget.isPreview
            ? [
                (widget.token.label.isNotEmpty && widget.token.issuer.isNotEmpty)
                    ? '${widget.token.issuer}: ${widget.token.label}'
                    : '${widget.token.issuer}${widget.token.label}',
                'Algorithm: ${widget.token.algorithm.name}',
                'Counter: ${widget.token.counter}',
              ]
            : [
                if (widget.token.label.isNotEmpty) widget.token.label,
                if (widget.token.issuer.isNotEmpty) widget.token.issuer,
              ],
        trailing: CustomTrailing(
          child: widget.isPreview
              ? const FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(size: 100, Icons.replay),
                )
              : HideableWidget(
                  token: widget.token,
                  isHidden: widget.token.isHidden,
                  child: IconButton(
                    tooltip: AppLocalizations.of(context)!.increaseCounter,
                    padding: const EdgeInsets.all(0),
                    onPressed: disableTrailingButton ? null : () => _updateOtpValue(),
                    icon: const FittedBox(
                      fit: BoxFit.contain,
                      child: Icon(size: 100, Icons.replay),
                    ),
                  ),
                ),
        ),
      );
}
