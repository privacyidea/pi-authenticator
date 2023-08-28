import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../model/tokens/day_password_token.dart';
import '../../../../../utils/identifiers.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/custom_texts.dart';
import '../token_widget_tile.dart';

class DayPasswordTokenWidgetTile extends ConsumerStatefulWidget {
  final DayPasswordToken token;
  const DayPasswordTokenWidgetTile(this.token, {super.key});

  @override
  ConsumerState<DayPasswordTokenWidgetTile> createState() => _DayPasswordTokenWidgetTileState();
}

class _DayPasswordTokenWidgetTileState extends ConsumerState<DayPasswordTokenWidgetTile> {
  double secondsLeft = 0;
  final ValueNotifier<bool> isHidden = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    secondsLeft = widget.token.durationUntilNextOTP.inMilliseconds / 1000;
    _countDown(0);
  }

  void _countDown(int msSinceLastCount) {
    if (!mounted) return;
    if (secondsLeft - (msSinceLastCount / 1000) > 0) {
      setState(() => secondsLeft -= msSinceLastCount / 1000);
    } else {
      setState(() => secondsLeft = widget.token.durationUntilNextOTP.inMilliseconds / 1000);
    }
    final msUntilNextSecond = (secondsLeft * 1000).toInt() % 1000 + 1; // +1 to avoid 0
    Future.delayed(
        Duration(
          milliseconds: msUntilNextSecond,
        ),
        () => _countDown(msUntilNextSecond));
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
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(settingsProvider).currentLocale;
    final dateTimeTokenEnd = widget.token.nextOTPTimeStart;
    final yMdFormat = DateFormat.yMMMd(currentLocale.languageCode);
    final yMdString = yMdFormat.format(dateTimeTokenEnd);
    final ejmFormat = DateFormat.E(currentLocale.languageCode).add_jm();
    final ejmString = ejmFormat.format(dateTimeTokenEnd);
    final duration = Duration(seconds: secondsLeft.ceil());
    final durationString = duration.toString().split('.').first;
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
      trailing: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () {
          if (widget.token.viewMode == DayPasswordTokenViewMode.VALIDFOR) {
            globalRef?.read(tokenProvider.notifier).updateToken(widget.token.copyWith(viewMode: DayPasswordTokenViewMode.VALIDUNTIL));
            return;
          }
          if (widget.token.viewMode == DayPasswordTokenViewMode.VALIDUNTIL) {
            globalRef?.read(tokenProvider.notifier).updateToken(widget.token.copyWith(viewMode: DayPasswordTokenViewMode.VALIDFOR));
            return;
          }
        },
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: switch (widget.token.viewMode) {
              DayPasswordTokenViewMode.VALIDFOR => Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.validFor}:',
                      style: Theme.of(context).listTileTheme.subtitleTextStyle,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          durationString,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    )
                  ],
                ),
              DayPasswordTokenViewMode.VALIDUNTIL => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.validUntil}:',
                      style: Theme.of(context).listTileTheme.subtitleTextStyle,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          yMdString,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          ejmString,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ],
                )
            },
          ),
        ),
      ),
    );
  }
}
