import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../model/tokens/totp_token.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/custom_texts.dart';
import '../../../../../widgets/hideable_widget_.dart';
import '../token_widget_tile.dart';

class TOTPTokenWidgetTile extends ConsumerStatefulWidget {
  final TOTPToken token;

  const TOTPTokenWidgetTile(this.token, {super.key});

  @override
  ConsumerState<TOTPTokenWidgetTile> createState() => _TOTPTokenWidgetTileState();
}

class _TOTPTokenWidgetTileState extends ConsumerState<TOTPTokenWidgetTile> with SingleTickerProviderStateMixin {
  double secondsLeft = 0;
  late AnimationController _animation;
  final ValueNotifier<bool> isHidden = ValueNotifier<bool>(true);

  void _copyOtpValue() {
    if (globalRef?.read(disableCopyOtpProvider) ?? false) return;

    globalRef?.read(disableCopyOtpProvider.notifier).state = true;
    Clipboard.setData(ClipboardData(text: widget.token.otpValue));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.otpValueCopiedMessage(widget.token.otpValue))),
    );
    Future.delayed(const Duration(seconds: 5), () {
      globalRef?.read(disableCopyOtpProvider.notifier).state = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.token.period),
    );
    _animation.forward(from: 1 - secondsLeft / widget.token.period);
    _countDown(0);
  }

  @override
  dispose() {
    _animation.dispose();
    super.dispose();
  }

  void _countDown(int msSinceLastCount) {
    if (!mounted) return;
    if (secondsLeft - (msSinceLastCount / 1000) > 0) {
      setState(() => secondsLeft -= msSinceLastCount / 1000);
    } else {
      setState(() => secondsLeft = widget.token.secondsUntilNextOTP);
      _animation.forward(from: 1 - secondsLeft / widget.token.period);
    }
    final msUntilNextSecond = (secondsLeft * 1000).toInt() % 1000 + 1; // +1 to avoid 0
    Future.delayed(
        Duration(
          milliseconds: msUntilNextSecond,
        ),
        () => _countDown(msUntilNextSecond));
  }

  @override
  Widget build(BuildContext context) {
    return TokenWidgetTile(
      key: Key('${widget.token.hashCode}TokenWidgetTile'),
      tokenImage: widget.token.tokenImage,
      tokenIsLocked: widget.token.isLocked,
      title: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: widget.token.isLocked && isHidden.value
              ? () async {
                  if (await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.authenticateToShowOtp)) {
                    isHidden.value = false;
                  }
                }
              : _copyOtpValue,
          child: HideableText(
            key: Key(widget.token.hashCode.toString()),
            text: insertCharAt(widget.token.otpValue, ' ', widget.token.digits ~/ 2),
            textScaleFactor: 1.9,
            enabled: widget.token.isLocked,
            isHiddenNotifier: isHidden,
          ),
        ),
      ),
      subtitles: [
        if (widget.token.label.isNotEmpty) widget.token.label,
        if (widget.token.issuer.isNotEmpty) widget.token.issuer,
      ],
      trailing: HideableWidget(
        token: widget.token,
        isHiddenNotifier: isHidden,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                Center(child: Text('${secondsLeft.ceil()}')), // ceil to show 30 -> 1 instead of 29 -> 0
                Center(
                  child: CircularProgressIndicator(
                    value: _animation.value,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
