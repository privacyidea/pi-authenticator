import 'package:flutter/material.dart';

class HomeWidgetContainer extends StatelessWidget {
  final String otp;
  final Size logicalSize;
  late final ThemeData theme;
  HomeWidgetContainer({super.key, required this.otp, ThemeData? theme, required this.logicalSize}) {
    this.theme = theme ?? ThemeData.light();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: logicalSize.width,
      height: logicalSize.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: theme.colorScheme.background,
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
