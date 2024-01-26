import 'package:flutter/material.dart';

import '../../../utils/home_widget_utils.dart';

abstract class FlutterHomeWidgetBase extends StatelessWidget {
  final HomeWidgetUtils utils;
  final Size logicalSize;
  final ThemeData theme;
  final String aditionalSuffix;

  const FlutterHomeWidgetBase({super.key, required this.logicalSize, required this.theme, this.aditionalSuffix = '', required this.utils});
}
