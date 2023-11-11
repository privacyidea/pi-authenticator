import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/day_password_token_widgets/actions/edit_day_password_token_action.dart';

import '../../../../../l10n/app_localizations.dart';
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
  late DateTime lastCount;
  final ValueNotifier<bool> isHidden = ValueNotifier<bool>(true);

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
      token: widget.token,
      editAction: EditDayPassowrdTokenAction(token: widget.token),
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
      trailing: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () {
          if (widget.token.viewMode == DayPasswordTokenViewMode.VALIDFOR) {
            globalRef?.read(tokenProvider.notifier).updateToken(widget.token, (p0) => p0.copyWith(viewMode: DayPasswordTokenViewMode.VALIDUNTIL));
            return;
          }
          if (widget.token.viewMode == DayPasswordTokenViewMode.VALIDUNTIL) {
            globalRef?.read(tokenProvider.notifier).updateToken(widget.token, (p0) => p0.copyWith(viewMode: DayPasswordTokenViewMode.VALIDFOR));
            return;
          }
        },
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: double.infinity,
          height: double.infinity,
          child: switch (widget.token.viewMode) {
            DayPasswordTokenViewMode.VALIDFOR => Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${AppLocalizations.of(context)!.validFor}:',
                      style: Theme.of(context).listTileTheme.subtitleTextStyle,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        durationString,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ),
                ],
              ),
            DayPasswordTokenViewMode.VALIDUNTIL => Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${AppLocalizations.of(context)!.validUntil}:',
                      style: Theme.of(context).listTileTheme.subtitleTextStyle,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$yMdString\n$ejmString',
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
          },
        ),
      ),
    );
  }
}
