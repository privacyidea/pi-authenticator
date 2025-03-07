import 'package:flutter/material.dart';

import '../pi_circular_progress_indicator.dart';

class DelayedElevatedButton extends StatefulWidget {
  final int delaySeconds;
  final void Function() onPressed;
  final Widget child;
  const DelayedElevatedButton({
    required this.child,
    required this.onPressed,
    this.delaySeconds = 3,
    super.key,
  });

  @override
  State<DelayedElevatedButton> createState() => _DelayedElevatedButtonState();
}

class _DelayedElevatedButtonState extends State<DelayedElevatedButton> with SingleTickerProviderStateMixin {
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
      currentCount = widget.delaySeconds;
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
  Widget build(BuildContext context) => currentCount > 0
      ? ElevatedButton(
          onPressed: null,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: currentCount > 0 ? 1 : 0,
                  child: AnimatedBuilder(
                    animation: animation,
                    child: widget.child,
                    builder: (context, child) => PiCircularProgressIndicator(
                      animation.value / animation.upperBound,
                      strokeWidth: 5,
                      swapColors: currentCount % 2 == 0,
                      backgroundColor: Theme.of(context).elevatedButtonTheme.style!.backgroundColor!.resolve({WidgetState.disabled}),
                    ),
                  ),
                ),
                Text(
                  currentCount.toString(),
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        )
      : ElevatedButton(
          onPressed: () => widget.onPressed(),
          child: widget.child,
        );
}
