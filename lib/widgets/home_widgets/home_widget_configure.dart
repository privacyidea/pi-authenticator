import 'dart:math';

import 'package:flutter/material.dart';

import 'interfaces/flutter_home_widget_base.dart';
import 'interfaces/flutter_home_widget_builder.dart';

class HomeWidgetConfigBuilder extends FlutterHomeWidgetBuilder<HomeWidgetIcon> {
  HomeWidgetConfigBuilder({
    super.key,
    required super.lightTheme,
    required super.darkTheme,
    required super.logicalSize,
    required super.homeWidgetKey,
    required super.utils,
  }) : super(
          formWidget: (key, theme, logicalSize, _) => HomeWidgetIcon(
            key: key,
            theme: theme,
            logicalSize: logicalSize,
            utils: utils,
          ),
        );
}

class HomeWidgetIcon extends FlutterHomeWidgetBase {
  const HomeWidgetIcon({
    super.key,
    required super.theme,
    required super.logicalSize,
    required super.utils,
  });

  @override
  Widget build(BuildContext context) => Icon(
        Icons.settings,
        size: min(logicalSize.width, logicalSize.height),
        color: theme.listTileTheme.iconColor,
      );
}
