import 'package:flutter/material.dart';

class PulseIcon extends StatefulWidget {
  const PulseIcon({required this.size, required this.child, this.isPulsing = true, super.key});

  final double size;
  final Widget child;
  final bool isPulsing;

  @override
  State<PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<PulseIcon> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isPulsing) {
      _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
      _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          if (widget.isPulsing)
            Center(
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    width: widget.size,
                    height: widget.size,
                  ),
                ),
              ),
            ),
          Center(child: widget.child),
        ],
      );
}
