import 'dart:math';

import 'package:flutter/material.dart';

class HomeWidgetConfigure extends StatelessWidget {
  final Size logicalSize;
  final ThemeData theme;
  const HomeWidgetConfigure({required this.logicalSize, required this.theme, super.key});

  @override
  Widget build(BuildContext context) => Icon(
        Icons.settings,
        color: theme.colorScheme.onBackground,
        size: min(logicalSize.width, logicalSize.height),
      );
}
