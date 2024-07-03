import 'package:flutter/material.dart';

import '../../../../../model/tokens/totp_token.dart';

class TotpTokenWidgetTileCountdown extends StatefulWidget {
  final TOTPToken token;
  const TotpTokenWidgetTileCountdown(this.token, {super.key});
  @override
  State<TotpTokenWidgetTileCountdown> createState() => _TotpTokenWidgetTileCountdownState();
}

class _TotpTokenWidgetTileCountdownState extends State<TotpTokenWidgetTileCountdown> with SingleTickerProviderStateMixin {
  double secondsLeft = 0;
  late AnimationController animation;
  late DateTime lastCount;
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
      if (msSinceLastCount > 1100) animation.forward(from: 1 - secondsLeft / widget.token.period);
    } else {
      setState(() => secondsLeft = widget.token.secondsUntilNextOTP);
      animation.forward(from: 1 - secondsLeft / widget.token.period);
    }

    final msUntilNextSecond = (secondsLeft * 1000).toInt() % 1000 + 1; // +1 to avoid 0
    Future.delayed(Duration(milliseconds: msUntilNextSecond), () => _startCountDown());
  }

  @override
  Widget build(BuildContext context) => Stack(
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
      );
}
