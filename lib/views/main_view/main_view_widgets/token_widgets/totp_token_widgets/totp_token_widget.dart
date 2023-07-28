import 'package:flutter/material.dart';

import '../../../../../model/tokens/totp_token.dart';
import '../token_widget.dart';
import '../token_widget_base.dart';
import 'totp_token_widget_tile.dart';

class TOTPTokenWidget extends TokenWidget {
  final TOTPToken token;

  const TOTPTokenWidget(this.token, {super.key});

  @override
  TokenWidgetBase build(BuildContext context) => TokenWidgetBase(
        token: token,
        tile: TOTPTokenWidgetTile(token),
        dragIcon: Icons.alarm,
      );
}
