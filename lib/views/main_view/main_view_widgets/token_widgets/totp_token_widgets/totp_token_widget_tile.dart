import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/tokens/totp_token.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/custom_texts.dart';
import '../../../../../widgets/custom_trailing.dart';
import '../../../../../widgets/hideable_widget_.dart';
import '../token_widget_tile.dart';

class TOTPTokenWidgetTile extends ConsumerStatefulWidget {
  final TOTPToken token;
  final bool isPreview;

  const TOTPTokenWidgetTile(this.token, {super.key, this.isPreview = false});

  @override
  ConsumerState<TOTPTokenWidgetTile> createState() => _TOTPTokenWidgetTileState();
}

class _TOTPTokenWidgetTileState extends ConsumerState<TOTPTokenWidgetTile> with SingleTickerProviderStateMixin, LifecycleMixin {
  double secondsLeft = 0;
  late AnimationController animation;
  late DateTime lastCount;

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
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.token.period),
    );
    animation.forward(from: 1 - widget.token.secondsUntilNextOTP / widget.token.period);
    secondsLeft = widget.token.secondsUntilNextOTP;
    lastCount = DateTime.now();
    _startCountDown();
  }

  @override
  dispose() {
    animation.dispose();
    super.dispose();
  }

  void _startCountDown() {
    final now = DateTime.now();
    final msSinceLastCount = now.difference(lastCount).inMilliseconds;
    lastCount = now;
    if (!mounted) return;
    if (secondsLeft - (msSinceLastCount / 1000) > 0) {
      setState(() => secondsLeft -= msSinceLastCount / 1000);
    } else {
      setState(() => secondsLeft = widget.token.secondsUntilNextOTP);
      animation.forward(from: 1 - secondsLeft / widget.token.period);
    }

    final msUntilNextSecond = (secondsLeft * 1000).toInt() % 1000 + 1; // +1 to avoid 0
    Future.delayed(Duration(milliseconds: msUntilNextSecond), () => _startCountDown());
  }

  @override
  void onAppPause() {
    if (!mounted) return;
    animation.stop();
  }

  @override
  void onAppResume() {
    if (!mounted) return;
    setState(() {
      secondsLeft = widget.token.secondsUntilNextOTP;
      animation.forward(from: 1 - secondsLeft / widget.token.period);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TokenWidgetTile(
      isPreview: widget.isPreview,
      key: Key('${widget.token.hashCode}TokenWidgetTile'),
      tokenImage: widget.token.tokenImage,
      tokenIsLocked: widget.token.isLocked,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Tooltip(
          message: widget.token.isHidden ? AppLocalizations.of(context)!.authenticateToShowOtp : AppLocalizations.of(context)!.copyOTPToClipboard,
          child: InkWell(
            onTap: widget.isPreview
                ? null
                : widget.token.isLocked && widget.token.isHidden
                    ? () async => await ref.read(tokenProvider.notifier).showToken(widget.token)
                    : _copyOtpValue,
            child: HideableText(
              key: Key(widget.token.hashCode.toString()),
              text: insertCharAt(widget.token.otpValue, ' ', (widget.token.digits / 2).ceil()),
              textScaleFactor: 1.9,
              enabled: widget.token.isLocked,
              isHidden: widget.token.isHidden,
            ),
          ),
        ),
      ),
      subtitles: widget.isPreview
          ? [
              (widget.token.label.isNotEmpty && widget.token.issuer.isNotEmpty)
                  ? '${widget.token.issuer}: ${widget.token.label}'
                  : widget.token.issuer + widget.token.label,
              'Algorithm: ${widget.token.algorithm.name}',
              'Period: ${widget.token.period} seconds',
            ]
          : [
              if (widget.token.label.isNotEmpty) widget.token.label,
              if (widget.token.issuer.isNotEmpty) widget.token.issuer,
            ],
      trailing: CustomTrailing(
        child: HideableWidget(
          token: widget.token,
          isHidden: widget.token.isHidden && !widget.isPreview,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '${secondsLeft.round()}',
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    value: animation.value,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
