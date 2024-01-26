import 'package:flutter/material.dart';

import '../../utils/app_customizer.dart';
import 'interfaces/flutter_home_widget_base.dart';
import 'interfaces/flutter_home_widget_builder.dart';

class HomeWidgetUnlinkedBuilder extends FlutterHomeWidgetBuilder<HomeWidgetUnlinked> {
  HomeWidgetUnlinkedBuilder({
    required super.lightTheme,
    required super.darkTheme,
    required super.logicalSize,
    required super.homeWidgetKey,
    required super.utils,
  }) : super(
          formWidget: (key, theme, logicalSize, _) => HomeWidgetUnlinked(
            key: key,
            theme: theme,
            logicalSize: logicalSize,
            utils: utils,
          ),
        );
}

class HomeWidgetUnlinked extends FlutterHomeWidgetBase {
  const HomeWidgetUnlinked({super.key, required super.logicalSize, required super.theme, required super.utils});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: logicalSize.width,
        height: logicalSize.height,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.topRight,
          child: Text(
            'Tap to link\nyour token',
            textAlign: TextAlign.center,
            style: theme.extension<ExtendedTextTheme>()?.tokenTileSubtitle,
          ),
        ),
      );
}
