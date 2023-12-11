import 'dart:math';

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

const _fontSize = 60.0;
const _otpTextStyle = TextStyle(
  fontFamily: 'monospace',
  fontWeight: FontWeight.bold,
);

class HomeWidgetContainer extends StatelessWidget {
  final String? otp;
  final int? otpLength;
  final String issuer;
  final String label;
  final Size logicalSize;
  final ThemeData theme;
  const HomeWidgetContainer({
    super.key,
    this.otp,
    required this.theme,
    required this.logicalSize,
    this.issuer = '',
    this.label = '',
    this.otpLength,
  });

  @override
  Widget build(BuildContext context) {
    print('theme.primaryColor: ${theme.primaryColor}');
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: logicalSize.width,
        height: logicalSize.height,
        padding: EdgeInsets.symmetric(horizontal: logicalSize.width / 20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(logicalSize.height / 4),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              otp != null
                  ? Text(
                      otp!.length <= 8
                          ? insertCharAt(otp!, ' ', otp!.length ~/ 2)
                          : '${otp!.substring(0, otp!.length ~/ 2)}\n${otp!.substring(otp!.length ~/ 2)}',
                      style: _otpTextStyle.copyWith(
                        fontSize: _fontSize,
                        color: theme.primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : otpLength != null
                      ? Text(
                          insertCharAt(
                            '\u2022' * otpLength!,
                            ' ',
                            otpLength! ~/ 2,
                          ),
                          style: _otpTextStyle.copyWith(
                            fontSize: _fontSize,
                            color: theme.primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      : SizedBox(),
              if (issuer.isNotEmpty || label.isNotEmpty)
                Text(
                  '$issuer${issuer.isNotEmpty && label.isNotEmpty ? ':' : ''}$label',
                  style: _otpTextStyle.copyWith(
                    fontSize: _fontSize / 2,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeWidgetSettings extends StatelessWidget {
  final Size logicalSize;
  final ThemeData theme;
  const HomeWidgetSettings({super.key, required this.theme, required this.logicalSize});

  @override
  Widget build(BuildContext context) => Icon(
        Icons.settings,
        size: min(logicalSize.width, logicalSize.height),
        color: theme.textTheme.bodyLarge?.color,
      );
}
