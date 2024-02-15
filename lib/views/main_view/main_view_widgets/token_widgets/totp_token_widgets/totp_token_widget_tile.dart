import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../widgets/custom_trailing.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/tokens/totp_token.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/custom_texts.dart';
import '../../../../../widgets/hideable_widget_.dart';
import '../token_widget_tile.dart';

class TOTPTokenWidgetTile extends ConsumerStatefulWidget {
  final TOTPToken token;
  final bool isPreview;

  const TOTPTokenWidgetTile(this.token, {super.key, this.isPreview = false});

  @override
  ConsumerState<TOTPTokenWidgetTile> createState() => _TOTPTokenWidgetTileState();
}

class _TOTPTokenWidgetTileState extends ConsumerState<TOTPTokenWidgetTile> with SingleTickerProviderStateMixin {
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

  void _onAppStateChange(AppLifecycleState? state) {
    if (!mounted) return;
    if (state == AppLifecycleState.resumed) {
      setState(() => secondsLeft = widget.token.secondsUntilNextOTP);
      animation.forward(from: 1 - secondsLeft / widget.token.period);
      return;
    }
    if (state == AppLifecycleState.paused) {
      animation.stop();
      return;
    }
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
  Widget build(BuildContext context) {
    final appstate = ref.watch(appStateProvider);
    _onAppStateChange(appstate);
    return TokenWidgetTile(
      isPreview: widget.isPreview,
      key: Key('${widget.token.hashCode}TokenWidgetTile'),
      tokenImage: widget.token.tokenImage,
      tokenIsLocked: widget.token.isLocked,
      title: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: widget.isPreview
              ? null
              : widget.token.isLocked && widget.token.isHidden
                  ? () async => await ref.read(tokenProvider.notifier).showToken(widget.token)
                  : _copyOtpValue,
          child: HideableText(
            key: Key(widget.token.hashCode.toString()),
            text: insertCharAt(widget.token.otpValue, ' ', widget.token.digits ~/ 2),
            textScaleFactor: 1.9,
            enabled: widget.token.isLocked,
            isHidden: widget.token.isHidden,
          ),
        ),
      ),
      subtitles: widget.isPreview
          ? [
              (widget.token.label.isNotEmpty && widget.token.issuer.isNotEmpty)
                  ? '${widget.token.issuer}: ${widget.token.label}'
                  : widget.token.issuer + widget.token.label,
              'Algorithm: ${enumAsString(widget.token.algorithm)}',
              'Period: ${widget.token.period} seconds',
            ]
          : [
              if (widget.token.label.isNotEmpty) widget.token.label,
              if (widget.token.issuer.isNotEmpty) widget.token.issuer,
            ],
      trailing: CustomTrailing(
        child: HideableWidget(
          token: widget.token,
          isHidden: widget.token.isHidden,
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
