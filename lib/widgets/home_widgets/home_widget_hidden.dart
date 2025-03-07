import 'package:flutter/material.dart';

import '../../utils/customization/theme_extentions/extended_text_theme.dart';
import 'home_widget_otp.dart';
import 'interfaces/flutter_home_widget_base.dart';
import 'interfaces/flutter_home_widget_builder.dart';

class HomeWidgetHiddenBuilder extends FlutterHomeWidgetBuilder<HomeWidgetHidden> {
  final int otpLength;
  final String? issuer;
  final String? label;
  HomeWidgetHiddenBuilder({
    super.key,
    this.issuer,
    this.label,
    required this.otpLength,
    required super.lightTheme,
    required super.darkTheme,
    required super.logicalSize,
    required super.homeWidgetKey,
    required super.utils,
  }) : super(
          formWidget: (key, theme, logicalSize, _) => HomeWidgetHidden(
            key: key,
            theme: theme,
            logicalSize: logicalSize,
            issuer: issuer ?? '',
            label: label ?? '',
            otpLength: otpLength,
            utils: utils,
          ),
        );
}

class HomeWidgetHidden extends FlutterHomeWidgetBase {
  final int otpLength;
  final String issuer;
  final String label;
  const HomeWidgetHidden({
    super.key,
    this.issuer = '',
    this.label = '',
    required this.otpLength,
    required super.theme,
    required super.logicalSize,
    required super.utils,
  });

  @override
  Widget build(BuildContext context) {
    final veilingCharacter = theme.extension<ExtendedTextTheme>()?.veilingCharacter ?? '●';
    return HomeWidgetOtp(
      theme: theme,
      logicalSize: logicalSize,
      utils: utils,
      otp: veilingCharacter * otpLength,
      label: label,
      issuer: issuer,
    );
  }
}
