import 'package:flutter/material.dart';
import '../token_widget_actions/edit_hotp_token_action.dart';

import '../../../../../model/tokens/hotp_token.dart';
import '../token_widget.dart';
import '../token_widget_base.dart';
import 'hotp_token_widget_tile.dart';

class HOTPTokenWidget extends TokenWidget {
  final HOTPToken token;
  final bool withDivider;

  const HOTPTokenWidget(
    this.token, {
    this.withDivider = true,
    super.key,
  });
  @override
  TokenWidgetBase build(BuildContext context) {
    return TokenWidgetBase(
      token: token,
      tile: HOTPTokenWidgetTile(token: token, key: ValueKey(token.id)),
      dragIcon: Icons.replay,
      editAction: EditHOTPTokenAction(token: token),
    );
  }
}
