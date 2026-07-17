import 'package:flutter/material.dart';

import '../../../utils/home_widget_utils.dart';
import 'flutter_home_widget_base.dart';

abstract class FlutterHomeWidgetBuilder<T extends FlutterHomeWidgetBase> {
  final Key? key;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final Size logicalSize;
  final String homeWidgetKey;
  final T Function(
    Key? key,
    ThemeData theme,
    Size logicalSize,
    String? additionalSuffix,
  )
  _formWidget;
  final HomeWidgetUtils utils;
  const FlutterHomeWidgetBuilder({
    this.key,
    required this.lightTheme,
    required this.darkTheme,
    required this.logicalSize,
    required this._formWidget,
    required this.homeWidgetKey,
    required this.utils,
  });

  T getWidget({bool isDark = false, String? additionalSuffix}) => _formWidget(
    key,
    isDark ? darkTheme : lightTheme,
    logicalSize,
    additionalSuffix,
  );

  /// Additional suffix comes always after the key and before the light/dark suffix
  Future<dynamic> renderFlutterWidgets({String additionalSuffix = ''}) async {
    await utils.renderFlutterWidget(
      getWidget(isDark: true, additionalSuffix: additionalSuffix),
      key: '$homeWidgetKey$additionalSuffix${HomeWidgetUtils.keySuffixDark}',
      logicalSize: logicalSize,
    );
    await utils.renderFlutterWidget(
      getWidget(isDark: false, additionalSuffix: additionalSuffix),
      key: '$homeWidgetKey$additionalSuffix${HomeWidgetUtils.keySuffixLight}',
      logicalSize: logicalSize,
    );
  }
}
