import 'package:flutter/material.dart';

import '../../../../model/tokens/day_password_token.dart';
import '../../../../model/tokens/hotp_token.dart';
import '../../../../model/tokens/push_token.dart';
import '../../../../model/tokens/token.dart';
import '../../../../model/tokens/totp_token.dart';
import 'day_password_token_widgets/day_password_token_widget.dart';
import 'hotp_token_widgets/hotp_token_widget.dart';
import 'push_token_widgets/push_token_widget.dart';
import 'token_widget.dart';
import 'totp_token_widgets/totp_token_widget.dart';

abstract class TokenWidgetBuilder {
  static TokenWidget fromToken(
    Token token, {
    bool withDivider = true,
    Key? key,
  }) =>
      switch (token.runtimeType) {
        const (TOTPToken) => TOTPTokenWidget(token as TOTPToken, key: key),
        const (HOTPToken) => HOTPTokenWidget(token as HOTPToken, key: key),
        const (PushToken) => PushTokenWidget(token as PushToken, key: key),
        const (DayPasswordToken) => DayPasswordTokenWidget(token as DayPasswordToken, key: key),
        _ => throw UnimplementedError('Token type (${token.runtimeType}) not supported in this Version of the App')
      };
}
