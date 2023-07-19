import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_tokens/hotp_token/hotp_token.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/hotp_token_widgets/hotp_token_widget_tile.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_builder.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget.dart';

class HOTPTokenWidget extends TokenWidgetBuilder {
  final HOTPToken token;

  HOTPTokenWidget(this.token) : super(key: ValueKey(token.id));
  @override
  TokenWidget build(BuildContext context) {
    return TokenWidget(
      token: token,
      tile: HOTPTokenWidgetTile(token: token, key: ValueKey(token.id)),
    );
  }
}
