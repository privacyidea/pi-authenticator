import 'package:flutter/material.dart';

import '../../../utils/home_widget_utils.dart';
import '../../../utils/logger.dart';
import 'flutter_home_widget_base.dart';

abstract class FlutterHomeWidgetBuilder<T extends FlutterHomeWidgetBase> {
  final Key? key;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final Size logicalSize;
  final String homeWidgetKey;
  final T Function(Key? key, ThemeData theme, Size logicalSize, String? aditionalSuffix) _formWidget;
  final HomeWidgetUtils utils;
  const FlutterHomeWidgetBuilder({
    this.key,
    required this.lightTheme,
    required this.darkTheme,
    required this.logicalSize,
    required T Function(Key? key, ThemeData theme, Size logicalSize, String? aditionalSuffix) formWidget,
    required this.homeWidgetKey,
    required this.utils,
  }) : _formWidget = formWidget;

  T getWidget({bool isDark = false, String? aditionalSuffix}) => _formWidget(
        key,
        isDark ? darkTheme : lightTheme,
        logicalSize,
        aditionalSuffix,
      );

  /// Additonal suffix comes always after the key and before the light/dark suffix
  Future<dynamic> renderFlutterWidgets({String additionalSuffix = ''}) async {
    await utils.renderFlutterWidget(
      getWidget(isDark: true, aditionalSuffix: additionalSuffix),
      key: '$homeWidgetKey$additionalSuffix${utils.keySuffixDark}',
      logicalSize: logicalSize,
    );
    Logger.info('Saved widget under key: $homeWidgetKey$additionalSuffix${utils.keySuffixDark}');
    await utils.renderFlutterWidget(
      getWidget(isDark: false, aditionalSuffix: additionalSuffix),
      key: '$homeWidgetKey$additionalSuffix${utils.keySuffixLight}',
      logicalSize: logicalSize,
    );
    Logger.info('Saved widget under key: $homeWidgetKey$additionalSuffix${utils.keySuffixLight}');
  }
}
