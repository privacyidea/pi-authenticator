import 'package:flutter/material.dart';

import '../pi_circular_progress_indicator.dart';

class CountdownButton extends StatefulWidget {
  final int countdownSeconds;
  final void Function() onPressed;
  final Widget child;
  final Color? color1;
  final Color? color2;
  const CountdownButton({required this.countdownSeconds, required this.onPressed, super.key, required this.child, this.color1, this.color2});

  @override
  State<CountdownButton> createState() => _CountdownButtonState();
}

class _CountdownButtonState extends State<CountdownButton> with SingleTickerProviderStateMixin {
  late int currentCount;
  late AnimationController animation;
  late DateTime lastCountDateTime;
  Future? countDownFuture;

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _resetCount();
  }

  void _resetCount() {
    if (countDownFuture != null) return;
    setState(() {
      currentCount = widget.countdownSeconds;
      animation.forward(from: 0);
      countDownFuture = Future.doWhile(_countDown).then((_) => countDownFuture = null);
    });
  }

  Future<bool> _countDown() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return false;
    animation.forward(from: 0);
    setState(() => currentCount--);
    return currentCount > 0;
  }

  @override
  dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: currentCount > 0
            ? null
            : () {
                widget.onPressed();
                _resetCount();
              },
        child: FittedBox(
          fit: BoxFit.contain,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: currentCount > 0 ? 1 : 0,
                child: AnimatedBuilder(
                  animation: animation,
                  child: null,
                  builder: (context, child) => PiCircularProgressIndicator(
                    animation.value / animation.upperBound,
                    strokeWidth: 5,
                    swapColors: currentCount % 2 == 0,
                    backgroundColor: Theme.of(context).elevatedButtonTheme.style!.backgroundColor!.resolve({WidgetState.disabled}),
                  ),
                ),
              ),
              Opacity(
                opacity: currentCount > 0 ? 1 : 0,
                child: Text(
                  currentCount.toString(),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              Opacity(
                opacity: currentCount > 0 ? 0 : 1,
                child: widget.child,
              ),
            ],
          ),
        ),
      );
}
