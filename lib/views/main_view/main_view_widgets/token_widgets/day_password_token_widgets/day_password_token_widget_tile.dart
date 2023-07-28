import 'dart:async';

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_tile.dart';

import '../../../../../utils/utils.dart';
import '../../../../../widgets/custom_texts.dart';

class DayPasswordTokenWidgetTile extends StatefulWidget {
  final DayPasswordToken token;
  const DayPasswordTokenWidgetTile(this.token, {super.key});

  @override
  State<DayPasswordTokenWidgetTile> createState() => _DayPasswordTokenWidgetTileState();
}

class _DayPasswordTokenWidgetTileState extends State<DayPasswordTokenWidgetTile> {
  int secondsLeft = 0;
  final ValueNotifier<bool> isHidden = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    secondsLeft = widget.token.durationUntilNextOTP.inSeconds;
    GlobalTimer.addListener(_setNewTimer);
  }

  @override
  void dispose() {
    super.dispose();
    GlobalTimer.removeListener(_setNewTimer);
  }

  void _setNewTimer() {
    if (mounted) {
      if (secondsLeft > 0) {
        setState(() {
          secondsLeft--;
        });
      } else {
        setState(() {
          secondsLeft = widget.token.durationUntilNextOTP.inSeconds;
        });
      }
    } else {
      GlobalTimer.removeListener(_setNewTimer);
    }
  }

  @override
  Widget build(BuildContext context) {
    //allways two digits
    final hours = (secondsLeft ~/ 3600).toString().padLeft(2, '0');
    //allways two digits
    final minutes = ((secondsLeft % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsLeft % 60).toString().padLeft(2, '0');
    return TokenWidgetTile(
      tokenIsLocked: widget.token.isLocked,
      title: HideableText(
        key: Key(widget.token.hashCode.toString()),
        text: insertCharAt(widget.token.otpValue, ' ', widget.token.digits ~/ 2),
        textScaleFactor: 1.9,
        enabled: widget.token.isLocked,
        isHiddenNotifier: isHidden,
        textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.secondary),
      ),
      subtitles: [widget.token.label],
      trailing: GestureDetector(
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
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: switch (widget.token.viewMode) {
              DayPasswordTokenViewMode.timeLeft => Text('${hours != '00' ? hours : ''}:$minutes:$seconds'),
              DayPasswordTokenViewMode.timePeriod => Text('TimePeriod'),
            },
          ),
        ),
      ),
    );
  }
}

class GlobalTimer {
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
