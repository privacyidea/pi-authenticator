import 'package:flutter/material.dart';

class Countdownbutton extends StatefulWidget {
  final int countdownSeconds;
  final void Function() onPressed;
  final Widget child;
  final Color? color1;
  final Color? color2;
  const Countdownbutton({required this.countdownSeconds, required this.onPressed, super.key, required this.child, this.color1, this.color2});

  @override
  State<Countdownbutton> createState() => _CountdownbuttonState();
}

class _CountdownbuttonState extends State<Countdownbutton> with SingleTickerProviderStateMixin {
  late int currentCount;
  late AnimationController animation;
  late DateTime lastCountDateTime;
  Future? countDownFuture;
  Color color1 = Colors.blue.shade600;
  Color color2 = Colors.blue.shade700;

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    if (widget.color1 != null) color1 = widget.color1!;
    if (widget.color2 != null) color2 = widget.color2!;
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
    setState(() {
      currentCount--;
      final temp = color2;
      color2 = color1;
      color1 = temp;
    });
    print(currentCount);
    print(currentCount > 0);
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
                  builder: (context, child) => CircularProgressIndicator(
                    value: animation.value / animation.upperBound,
                    strokeWidth: 5,
                    backgroundColor: color1,
                    valueColor: AlwaysStoppedAnimation<Color>(color2),
                  ),
                ),
              ),
              Opacity(
                opacity: currentCount > 0 ? 1 : 0,
                child: AnimatedBuilder(
                  animation: animation,
                  child: null,
                  builder: (context, child) => Text(
                    currentCount.toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
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
