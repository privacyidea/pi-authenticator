import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/enums/day_password_token_view_mode.dart';
import '../../../../../model/tokens/day_password_token.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/custom_texts.dart';
import '../../../../../widgets/custom_trailing.dart';
import '../../../../../widgets/hideable_widget_.dart';
import '../token_widget_tile.dart';

class DayPasswordTokenWidgetTile extends ConsumerStatefulWidget {
  final DayPasswordToken token;
  final bool isPreview;
  const DayPasswordTokenWidgetTile(this.token, {this.isPreview = false, super.key});

  @override
  ConsumerState<DayPasswordTokenWidgetTile> createState() => _DayPasswordTokenWidgetTileState();
}

class _DayPasswordTokenWidgetTileState extends ConsumerState<DayPasswordTokenWidgetTile> {
  double secondsLeft = 0;
  late DateTime lastCount;

  @override
  void initState() {
    super.initState();
    secondsLeft = widget.token.durationUntilNextOTP.inMilliseconds / 1000;
    lastCount = DateTime.now();
    _startCountDown();
  }

  void _startCountDown() {
    final now = DateTime.now();
    final msSinceLastCount = now.difference(lastCount).inMilliseconds;
    lastCount = now;
    if (!mounted) return;
    if (secondsLeft - (msSinceLastCount / 1000) > 0) {
      setState(() => secondsLeft -= msSinceLastCount / 1000);
    } else {
      setState(() => secondsLeft = widget.token.durationUntilNextOTP.inMilliseconds / 1000);
    }
    final msUntilNextSecond = (secondsLeft * 1000).toInt() % 1000 + 1; // +1 to avoid 0
    Future.delayed(Duration(milliseconds: msUntilNextSecond), () => _startCountDown());
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
      isPreview: widget.isPreview,
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
                text: insertCharAt(widget.token.otpValue, ' ', (widget.token.digits / 2).ceil()),
                textScaleFactor: 1.9,
                enabled: widget.token.isLocked,
                isHidden: widget.token.isHidden),
          ),
        ),
      ),
      subtitles: widget.isPreview
          ? [
              (widget.token.label.isNotEmpty && widget.token.issuer.isNotEmpty)
                  ? '${widget.token.issuer}: ${widget.token.label}'
                  : widget.token.issuer + widget.token.label,
              'Algorithm: ${widget.token.algorithm.name}',
              'Period: ${widget.token.period.toString().split('.').first}',
            ]
          : [
              if (widget.token.label.isNotEmpty) widget.token.label,
              if (widget.token.issuer.isNotEmpty) widget.token.issuer,
            ],
      trailing: SizedBox(
        height: double.maxFinite,
        child: CustomTrailing(
          padding: const EdgeInsets.all(0),
          fit: BoxFit.contain,
          child: HideableWidget(
            isHidden: widget.token.isHidden && !widget.isPreview,
            token: widget.token,
            child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onTap: widget.isPreview
                  ? null
                  : () {
                      if (widget.token.viewMode == DayPasswordTokenViewMode.VALIDFOR) {
                        globalRef?.read(tokenProvider.notifier).updateToken(widget.token, (p0) => p0.copyWith(viewMode: DayPasswordTokenViewMode.VALIDUNTIL));
                        return;
                      }
                      if (widget.token.viewMode == DayPasswordTokenViewMode.VALIDUNTIL) {
                        globalRef?.read(tokenProvider.notifier).updateToken(widget.token, (p0) => p0.copyWith(viewMode: DayPasswordTokenViewMode.VALIDFOR));
                        return;
                      }
                    },
              child: SizedBox(
                height: Theme.of(context).textTheme.bodyLarge!.fontSize! * (Theme.of(context).textTheme.bodyLarge?.height ?? 1.2) * 3.1,
                child: Column(
                  children: [
                    Expanded(
                      child: Text(
                        switch (widget.token.viewMode) {
                          DayPasswordTokenViewMode.VALIDFOR => '${AppLocalizations.of(context)!.validFor}:',
                          DayPasswordTokenViewMode.VALIDUNTIL => '${AppLocalizations.of(context)!.validUntil}:',
                        },
                        style: Theme.of(context).listTileTheme.subtitleTextStyle,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          switch (widget.token.viewMode) {
                            DayPasswordTokenViewMode.VALIDFOR => durationString,
                            DayPasswordTokenViewMode.VALIDUNTIL => '$yMdString\n$ejmString',
                          },
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
