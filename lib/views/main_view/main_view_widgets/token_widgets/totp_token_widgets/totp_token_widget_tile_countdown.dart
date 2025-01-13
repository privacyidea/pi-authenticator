/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../widgets/pi_circular_progress_indicator.dart';

class TotpTokenWidgetTileCountdown extends StatefulWidget {
  final int period;
  final Function onPeriodEnd;
  const TotpTokenWidgetTileCountdown({required this.period, required this.onPeriodEnd, super.key});
  @override
  State<TotpTokenWidgetTileCountdown> createState() => _TotpTokenWidgetTileCountdownState();
}

class _TotpTokenWidgetTileCountdownState extends State<TotpTokenWidgetTileCountdown> with SingleTickerProviderStateMixin {
  double secondsUntilNextOTP = 0;
  late AnimationController animation;
  late DateTime lastCount;
  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.period),
    );
    lastCount = DateTime.now();
    secondsUntilNextOTP = widget.period - (lastCount.millisecondsSinceEpoch % (widget.period * 1000)) / 1000;
    animation.forward(from: 1 - secondsUntilNextOTP / widget.period);
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
    if (secondsUntilNextOTP - (msSinceLastCount / 1000) > 0) {
      setState(() {
        secondsUntilNextOTP -= msSinceLastCount / 1000;
        animation.forward(from: 1 - secondsUntilNextOTP / widget.period);
      });
    } else {
      setState(() {
        secondsUntilNextOTP = widget.period - (lastCount.millisecondsSinceEpoch % (widget.period * 1000)) / 1000;
        animation.forward(from: 1 - secondsUntilNextOTP / widget.period);
      });
      widget.onPeriodEnd.call();
    }

    final msUntilNextSecond = (secondsUntilNextOTP * 1000).toInt() % 1000 + 1; // +1 to avoid 0
    Future.delayed(Duration(milliseconds: msUntilNextSecond), () => _startCountDown());
  }

  @override
  Widget build(BuildContext context) => FittedBox(
        clipBehavior: Clip.hardEdge,
        fit: BoxFit.contain,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${secondsUntilNextOTP.round()}',
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return PiCircularProgressIndicator(
                  animation.value,
                  semanticsLabel: AppLocalizations.of(context)!.a11ySecondsUntilNextOTP(secondsUntilNextOTP.round()),
                  semanticsValue: '${secondsUntilNextOTP.round()}',
                );
              },
            ),
          ],
        ),
      );
}
