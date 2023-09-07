import 'dart:ui';

import 'package:flutter/material.dart';
import 'rollout_failed_widget.dart';
import 'rollout_widget.dart';

import '../../../../../model/mixins/sortable_mixin.dart';
import '../../../../../model/tokens/push_token.dart';
import '../../../../../utils/identifiers.dart';
import '../token_widget.dart';
import '../token_widget_base.dart';
import 'actions/edit_push_token_action.dart';
import 'push_token_widget_tile.dart';

class PushTokenWidget extends TokenWidget {
  final PushToken token;
  final SortableMixin? previousSortable;
  final bool withDivider;
  bool get rolloutFailed => switch (token.rolloutState) {
        PushTokenRollOutState.generatingRSAKeyPairFailed => true,
        PushTokenRollOutState.sendRSAPublicKeyFailed => true,
        PushTokenRollOutState.parsingResponseFailed => true,
        _ => false,
      };

  const PushTokenWidget(
    this.token, {
    this.withDivider = true,
    this.previousSortable,
    super.key,
  });

  @override
  TokenWidgetBase build(BuildContext context) {
    return TokenWidgetBase(
      key: Key(token.id),
      token: token,
      tile: PushTokenWidgetTile(token),
      dragIcon: Icons.notifications,
      editAction: EditPushTokenAction(token: token, key: Key('${token.id}editAction')),
      stack: [
        if (!token.isRolledOut)
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: rolloutFailed ? RolloutFailedWidget(token: token) : RolloutWidget(token: token),
              ),
            ),
          ),
      ],
    );
  }
}
