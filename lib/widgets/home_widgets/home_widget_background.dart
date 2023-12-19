import 'package:flutter/material.dart';

import 'interfaces/flutter_home_widget_base.dart';
import 'interfaces/flutter_home_widget_builder.dart';

class HomeWidgetBackgroundBuilder extends FlutterHomeWidgetBuilder<FlutterHomeWidgetBase> {
  final Color? color;
  HomeWidgetBackgroundBuilder({
    super.key,
    this.color,
    required super.lightTheme,
    required super.darkTheme,
    required super.logicalSize,
    required super.homeWidgetKey,
    required super.utils,
  }) : super(
          formWidget: (key, theme, logicalSize, _) => HomeWidgetBackground(
            key: key,
            theme: theme,
            logicalSize: logicalSize,
            utils: utils,
          ),
        );
}

class HomeWidgetBackground extends FlutterHomeWidgetBase {
  const HomeWidgetBackground({
    super.key,
    required super.theme,
    required super.logicalSize,
    required super.utils,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: logicalSize.width,
        height: logicalSize.height,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(logicalSize.height / 4),
        ),
      );
}
