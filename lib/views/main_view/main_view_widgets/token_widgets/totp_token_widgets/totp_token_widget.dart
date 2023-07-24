import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_tokens/totp_token/totp_token.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_base.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/totp_token_widgets/totp_token_widget_tile.dart';

class TOTPTokenWidget extends TokenWidget {
  final TOTPToken token;

  TOTPTokenWidget(this.token, {super.key});

  @override
  TokenWidgetBase build(BuildContext context) {
    return TokenWidgetBase(
      token: token,
      tile: TOTPTokenWidgetTile(token),
    );
  }
}
