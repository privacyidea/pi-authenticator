import 'package:flutter/material.dart';

class TotpTokenWidgetTileCountdown extends StatefulWidget {
  final int period;
  const TotpTokenWidgetTileCountdown(this.period, {super.key});
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
    }

    final msUntilNextSecond = (secondsUntilNextOTP * 1000).toInt() % 1000 + 1; // +1 to avoid 0
    Future.delayed(Duration(milliseconds: msUntilNextSecond), () => _startCountDown());
  }

  @override
  Widget build(BuildContext context) => Stack(
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
              return CircularProgressIndicator(
                value: animation.value,
              );
            },
          ),
        ],
      );
}
