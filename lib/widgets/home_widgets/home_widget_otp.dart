import 'package:flutter/material.dart';

import '../../utils/app_customizer.dart';
import '../../utils/utils.dart';
import 'interfaces/flutter_home_widget_base.dart';
import 'interfaces/flutter_home_widget_builder.dart';

class HomeWidgetOtpBuilder extends FlutterHomeWidgetBuilder<HomeWidgetOtp> {
  final String otp;
  final String? issuer;
  final String? label;
  HomeWidgetOtpBuilder({
    super.key,
    this.issuer,
    this.label,
    required this.otp,
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
            utils: utils,
          ),
        );
}

class HomeWidgetOtp extends FlutterHomeWidgetBase {
  final String otp;
  final String issuer;
  final String label;
  const HomeWidgetOtp({
    super.key,
    this.issuer = '',
    this.label = '',
    required this.otp,
    required super.theme,
    required super.logicalSize,
    required super.utils,
  });

  @override
  Widget build(BuildContext context) {
    String text = otp.length > 10 ? insertCharAt(otp, '\n', otp.length ~/ 2) : insertCharAt(otp, ' ', otp.length ~/ 2);
    return SizedBox(
      width: logicalSize.width,
      height: logicalSize.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.bottomLeft,
              child: Text(
                text,
                style: theme.extension<ExtendedTextTheme>()?.tokenTile,
                maxLines: 2,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              alignment: Alignment.topLeft,
              child: Text(
                '$issuer${issuer.isNotEmpty && label.isNotEmpty ? ':' : ''}$label',
                style: theme.extension<ExtendedTextTheme>()?.tokenTileSubtitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
