import 'package:flutter/material.dart';

import '../../utils/customization/theme_extentions/extended_text_theme.dart';
import 'interfaces/flutter_home_widget_base.dart';
import 'interfaces/flutter_home_widget_builder.dart';

class HomeWidgetCopiedBuilder extends FlutterHomeWidgetBuilder<HomeWidgetCopied> {
  HomeWidgetCopiedBuilder({
    required super.lightTheme,
    required super.darkTheme,
    required super.logicalSize,
    required super.homeWidgetKey,
    required super.utils,
  }) : super(
          formWidget: (key, theme, logicalSize, _) => HomeWidgetCopied(
            key: key,
            theme: theme,
            logicalSize: logicalSize,
            utils: utils,
          ),
        );
}

class HomeWidgetCopied extends FlutterHomeWidgetBase {
  const HomeWidgetCopied({
    super.key,
    required super.theme,
    required super.logicalSize,
    required super.utils,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: logicalSize.width,
        height: logicalSize.height,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Text(
            'Password copied\nto Clipboard',
            textAlign: TextAlign.center,
            style: theme.extension<ExtendedTextTheme>()?.tokenTile,
          ),
        ),
      );
}
