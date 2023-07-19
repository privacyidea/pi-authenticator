import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token/push_token.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/push_token_widgets/push_token_widget_tile.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_builder.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget.dart';

class PushTokenWidget extends TokenWidgetBuilder {
  final PushToken token;

  PushTokenWidget(this.token) : super(key: ValueKey(token.id));

  @override
  TokenWidget build(BuildContext context) {
    return TokenWidget(
      token: token,
      tile: PushTokenWidgetTile(token),
    );
  }
}
