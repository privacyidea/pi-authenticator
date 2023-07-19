import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_tokens/hotp_token/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_tokens/totp_token/totp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token/push_token.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/hotp_token_widgets/hotp_token_widget.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/push_token_widgets/push_token_widget.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/totp_token_widgets/totp_token_widget.dart';

abstract class TokenWidgetBuilder extends StatelessWidget {
  const TokenWidgetBuilder({Key? key}) : super(key: key);

  @override
  TokenWidget build(BuildContext context);

  factory TokenWidgetBuilder.fromToken(Token token) => switch (token.runtimeType) {
        TOTPToken => TOTPTokenWidget(token as TOTPToken),
        HOTPToken => HOTPTokenWidget(token as HOTPToken),
        PushToken => PushTokenWidget(token as PushToken),
        _ => throw UnimplementedError('Token type (${token.runtimeType}) not supported')
      };
}
