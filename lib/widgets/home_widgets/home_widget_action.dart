import 'dart:math';

import 'package:flutter/material.dart';

import '../../extensions/color_extension.dart';
import '../../utils/home_widget_utils.dart';
import 'interfaces/flutter_home_widget_base.dart';
import 'interfaces/flutter_home_widget_builder.dart';

class HomeWidgetAction extends FlutterHomeWidgetBase {
  final IconData icon;
  const HomeWidgetAction({
    required this.icon,
    super.key,
    required super.theme,
    required super.logicalSize,
    required super.utils,
    required super.aditionalSuffix,
  });

  @override
  Widget build(BuildContext context) => (aditionalSuffix == HomeWidgetUtils.keySuffixActive)
      ? Icon(
          icon,
          size: min(logicalSize.width, logicalSize.height),
          color: theme.listTileTheme.iconColor,
        )
      : (aditionalSuffix == HomeWidgetUtils.keySuffixInactive)
          ? Icon(
              icon,
              size: min(logicalSize.width, logicalSize.height),
              color: theme.listTileTheme.iconColor?.mixWith(theme.scaffoldBackgroundColor),
            )
          : const SizedBox();
}

class HomeWidgetActionBuilder extends FlutterHomeWidgetBuilder<HomeWidgetAction> {
  final IconData icon;
  HomeWidgetActionBuilder({
    super.key,
    required this.icon,
    required super.lightTheme,
    required super.darkTheme,
    required super.logicalSize,
    required super.homeWidgetKey,
    required super.utils,
  }) : super(
          formWidget: (key, theme, logicalSize, additionalSuffix) => HomeWidgetAction(
            icon: icon,
            key: key,
            theme: theme,
            logicalSize: logicalSize,
            aditionalSuffix: additionalSuffix ?? '',
            utils: utils,
          ),
        );

  @override
  Future<dynamic> renderFlutterWidgets({String additionalSuffix = ''}) async {
    await super.renderFlutterWidgets(additionalSuffix: '$additionalSuffix${HomeWidgetUtils.keySuffixActive}');
    await super.renderFlutterWidgets(additionalSuffix: '$additionalSuffix${HomeWidgetUtils.keySuffixInactive}');
  }
}
