import 'package:flutter/material.dart';

class HomeWidgetContainer extends StatelessWidget {
  final String otp;
  final Size logicalSize;
  final ThemeData theme;
  const HomeWidgetContainer({super.key, required this.otp, required this.theme, required this.logicalSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: logicalSize.width,
      height: logicalSize.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(logicalSize.height / 4),
      ),
      child: Center(
        child: Text(
          otp,
          style: theme.textTheme.titleLarge?.copyWith(fontSize: 60),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
