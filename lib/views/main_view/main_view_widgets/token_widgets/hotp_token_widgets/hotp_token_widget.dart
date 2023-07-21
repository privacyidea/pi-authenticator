import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_tokens/hotp_token/hotp_token.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/hotp_token_widgets/hotp_token_widget_tile.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_base.dart';

class HOTPTokenWidget extends TokenWidget {
  final HOTPToken token;
  final bool withDivider;

  HOTPTokenWidget(this.token, {this.withDivider = true, super.key});
  @override
  TokenWidgetBase build(BuildContext context) {
    return TokenWidgetBase(
      token: token,
      tile: HOTPTokenWidgetTile(token: token, key: ValueKey(token.id)),
      withDivider: withDivider,
    );
  }
}
