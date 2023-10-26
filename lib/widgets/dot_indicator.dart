import 'package:flutter/material.dart';

class DotIndicator extends StatelessWidget {
  final bool isSelected;

  const DotIndicator({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final ThemeData mode = Theme.of(context);
    Color circleBackgroundColor = mode.brightness == Brightness.dark ? Colors.white38 : Colors.grey;

    Color selectedColor = mode.brightness == Brightness.dark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 6.0,
        width: 6.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? selectedColor : circleBackgroundColor,
        ),
      ),
    );
  }
}
