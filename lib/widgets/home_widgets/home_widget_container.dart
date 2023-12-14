import 'dart:math';

import 'package:flutter/material.dart';
import '../../utils/home_widget_utils.dart';
import '../../utils/logger.dart';
import '../../utils/utils.dart';
import '../../extensions/color_extension.dart';

const _fontSize = 60.0;
const _otpTextStyle = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
);

abstract class HomeWidgetModul<T extends FlutterHomeWidget> {
  final Key? key;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final Size logicalSize;
  final String homeWidgetKey;
  final T Function(Key? key, ThemeData theme, Size logicalSize, String? aditionalSuffix) _formWidget;
  final HomeWidgetUtils utils;
  const HomeWidgetModul({
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
    Logger.warning('Saved widget under key: $homeWidgetKey$additionalSuffix${utils.keySuffixDark}');
    await utils.renderFlutterWidget(
      getWidget(isDark: false, aditionalSuffix: additionalSuffix),
      key: '$homeWidgetKey$additionalSuffix${utils.keySuffixLight}',
      logicalSize: logicalSize,
    );
    Logger.warning('Saved widget under key: $homeWidgetKey$additionalSuffix${utils.keySuffixLight}');
  }
}

class HwBackgroundModul extends HomeWidgetModul<FlutterHomeWidget> {
  final Color? color;
  HwBackgroundModul({
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

class HwOtpModul extends HomeWidgetModul<HomeWidgetOtp> {
  final String? otp;
  final int? otpLength;
  final String? issuer;
  final String? label;
  HwOtpModul({
    super.key,
    this.otp,
    this.otpLength,
    this.issuer,
    this.label,
    required super.lightTheme,
    required super.darkTheme,
    required super.logicalSize,
    required super.homeWidgetKey,
    required super.utils,
  }) : super(
          formWidget: (key, theme, logicalSize, _) => HomeWidgetOtp(
            key: key,
            theme: theme,
            logicalSize: logicalSize,
            otp: otp,
            issuer: issuer ?? '',
            label: label ?? '',
            otpLength: otpLength,
            utils: utils,
          ),
        );
}

class HwIconModul extends HomeWidgetModul<HomeWidgetIcon> {
  HwIconModul({
    super.key,
    required IconData icon,
    required super.lightTheme,
    required super.darkTheme,
    required super.logicalSize,
    required super.homeWidgetKey,
    required super.utils,
  }) : super(
          formWidget: (key, theme, logicalSize, _) => HomeWidgetIcon(
            icon: icon,
            key: key,
            theme: theme,
            logicalSize: logicalSize,
            utils: utils,
          ),
        );
}

class HwActionModul extends HomeWidgetModul<HomeWidgetAction> {
  final IconData icon;
  HwActionModul({
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
    await super.renderFlutterWidgets(additionalSuffix: '$additionalSuffix${super.utils.keySuffixActive}');
    await super.renderFlutterWidgets(additionalSuffix: '$additionalSuffix${super.utils.keySuffixInactive}');
  }
}

abstract class FlutterHomeWidget extends StatelessWidget {
  final HomeWidgetUtils utils;
  final Size logicalSize;
  final ThemeData theme;
  final String aditionalSuffix;

  const FlutterHomeWidget({super.key, required this.logicalSize, required this.theme, this.aditionalSuffix = '', required this.utils});
}

class HomeWidgetBackground extends FlutterHomeWidget {
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

class HomeWidgetOtp extends FlutterHomeWidget {
  final String? otp;
  final int? otpLength;
  final String issuer;
  final String label;
  const HomeWidgetOtp({
    super.key,
    this.otp,
    this.issuer = '',
    this.label = '',
    this.otpLength,
    required super.theme,
    required super.logicalSize,
    required super.utils,
  });

  @override
  Widget build(BuildContext context) {
    String text = '';
    if (otp != null) {
      text = otp!;
    } else if (otpLength != null) {
      text = '\u2022' * otpLength!;
    }
    text = text.length > 10 ? insertCharAt(text, '\n', text.length ~/ 2) : insertCharAt(text, ' ', text.length ~/ 2);
    return SizedBox(
      width: logicalSize.width,
      height: logicalSize.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.bottomLeft,
              child: Text(
                text,
                style: _otpTextStyle.copyWith(
                  color: theme.primaryColor,
                ),
                maxLines: 2,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.topLeft,
              child: Text(
                '$issuer${issuer.isNotEmpty && label.isNotEmpty ? ':' : ''}$label',
                style: _otpTextStyle.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeWidgetIcon extends FlutterHomeWidget {
  final IconData icon;
  const HomeWidgetIcon({
    required this.icon,
    super.key,
    required super.theme,
    required super.logicalSize,
    required super.utils,
  });

  @override
  Widget build(BuildContext context) => Icon(
        icon,
        size: min(logicalSize.width, logicalSize.height),
        color: theme.listTileTheme.iconColor,
      );
}

class HomeWidgetAction extends FlutterHomeWidget {
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
  Widget build(BuildContext context) => (aditionalSuffix == super.utils.keySuffixActive)
      ? Icon(
          icon,
          size: min(logicalSize.width, logicalSize.height),
          color: theme.listTileTheme.iconColor,
        )
      : (aditionalSuffix == super.utils.keySuffixInactive)
          ? Icon(
              icon,
              size: min(logicalSize.width, logicalSize.height),
              color: theme.listTileTheme.iconColor?.mixWith(theme.scaffoldBackgroundColor),
            )
          : const SizedBox();
}
