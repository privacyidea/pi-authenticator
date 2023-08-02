import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../model/tokens/day_password_token.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../token_widget_tile.dart';

import '../../../../../utils/utils.dart';
import '../../../../../widgets/custom_texts.dart';

class DayPasswordTokenWidgetTile extends ConsumerStatefulWidget {
  final DayPasswordToken token;
  const DayPasswordTokenWidgetTile(this.token, {super.key});

  @override
  ConsumerState<DayPasswordTokenWidgetTile> createState() => _DayPasswordTokenWidgetTileState();
}

class _DayPasswordTokenWidgetTileState extends ConsumerState<DayPasswordTokenWidgetTile> {
  int totalSecondsLeft = 0;
  final ValueNotifier<bool> isHidden = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    totalSecondsLeft = widget.token.durationUntilNextOTP.inSeconds;
    GlobalCountdownTimer.addListener(_setNewTimer);
  }

  @override
  void dispose() {
    super.dispose();
    GlobalCountdownTimer.removeListener(_setNewTimer);
  }

  void _setNewTimer() {
    if (mounted) {
      if (totalSecondsLeft > 0) {
        setState(() {
          totalSecondsLeft--;
        });
      } else {
        setState(() {
          totalSecondsLeft = widget.token.durationUntilNextOTP.inSeconds;
        });
      }
    } else {
      GlobalCountdownTimer.removeListener(_setNewTimer);
    }
  }

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
  Widget build(BuildContext context) {
    final hoursLeft = (totalSecondsLeft ~/ 3600).toString().padLeft(2, '0');
    final minutesLeft = ((totalSecondsLeft % 3600) ~/ 60).toString().padLeft(2, '0');
    final secondsLeft = (totalSecondsLeft % 60).toString().padLeft(2, '0');

    final dateTimeTokenEnd = widget.token.nextOTPTimeStart;
    final currentLocale = ref.watch(settingsProvider).currentLocale;
    final day = DateFormat.EEEE(currentLocale.languageCode).dateSymbols.SHORTWEEKDAYS[dateTimeTokenEnd.day];
    final hour = dateTimeTokenEnd.hour.toString().padLeft(2, '0');
    final minute = dateTimeTokenEnd.minute.toString().padLeft(2, '0');
    return TokenWidgetTile(
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
            textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      ),
      subtitles: [widget.token.label],
      trailing: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () {
          if (widget.token.viewMode == DayPasswordTokenViewMode.timeLeft) {
            globalRef?.read(tokenProvider.notifier).updateToken(widget.token.copyWith(viewMode: DayPasswordTokenViewMode.timePeriod));
            return;
          }
          if (widget.token.viewMode == DayPasswordTokenViewMode.timePeriod) {
            globalRef?.read(tokenProvider.notifier).updateToken(widget.token.copyWith(viewMode: DayPasswordTokenViewMode.timeLeft));
            return;
          }
        },
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: switch (widget.token.viewMode) {
              DayPasswordTokenViewMode.timeLeft => Text(
                  'Expires in:\n'
                  '${hoursLeft != '00' ? '$hoursLeft:' : ''}$minutesLeft:$secondsLeft',
                  style: const TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              DayPasswordTokenViewMode.timePeriod => Text(
                  'Expires at:\n'
                  '$day $hour:$minute',
                  style: const TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
            },
          ),
        ),
      ),
    );
  }
}

/// Calls all listeners every second
class GlobalCountdownTimer {
  static Timer? timer;
  static List<Function> listeners = [];

  static void addListener(Function() fun) {
    listeners.add(fun);
    if (listeners.length > 1) return;
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        for (var element in listeners) {
          element();
        }
      },
    );
  }

  static void removeListener(Function() fun) {
    listeners.remove(fun);
    if (listeners.isEmpty) {
      timer?.cancel();
    }
  }
}
