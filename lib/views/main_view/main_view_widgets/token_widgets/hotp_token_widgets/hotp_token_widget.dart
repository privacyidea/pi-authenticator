import 'package:flutter/material.dart';

import '../../../../../model/tokens/hotp_token.dart';
import '../token_widget.dart';
import '../token_widget_base.dart';
import 'hotp_token_widget_tile.dart';

class HOTPTokenWidget extends TokenWidget {
  final HOTPToken token;
  const HOTPTokenWidget(this.token, {super.key});
  @override
  TokenWidgetBase build(BuildContext context) => TokenWidgetBase(
        token: token,
        tile: HOTPTokenWidgetTile(token: token),
        dragIcon: Icons.replay,
      );
}
