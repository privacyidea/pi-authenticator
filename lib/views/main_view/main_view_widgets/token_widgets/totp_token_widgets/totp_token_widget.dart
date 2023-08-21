import 'package:flutter/material.dart';

import '../../../../../model/mixins/sortable_mixin.dart';
import '../../../../../model/tokens/totp_token.dart';
import '../token_widget.dart';
import '../token_widget_base.dart';
import 'actions/edit_totp_token_action.dart';
import 'totp_token_widget_tile.dart';

class TOTPTokenWidget extends TokenWidget {
  final TOTPToken token;
  final SortableMixin? previousSortable;
  final bool withDivider;

  const TOTPTokenWidget(
    this.token, {
    this.withDivider = true,
    super.key,
    this.previousSortable,
  });

  @override
  TokenWidgetBase build(BuildContext context) {
    return TokenWidgetBase(
      token: token,
      tile: TOTPTokenWidgetTile(token),
      dragIcon: Icons.alarm,
      editAction: EditTOTPTokenAction(token: token),
    );
  }
}
