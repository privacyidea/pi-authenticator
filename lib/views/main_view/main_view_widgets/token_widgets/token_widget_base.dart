import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';

import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_actions/default_delete_action.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_actions/default_edit_action.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_actions/default_lock_action.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_actions/token_action.dart';

class TokenWidgetBase extends ConsumerWidget {
  final Token token;
  final TokenAction? deleteAction;

  final TokenAction? editAction;

  final TokenAction? lockAction;

  final Widget tile;

  final List<Widget> stack;

  const TokenWidgetBase({
    required this.token,
    this.deleteAction,
    this.editAction,
    this.lockAction,
    this.stack = const <Widget>[],
    required this.tile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TokenAction> actions = [
      deleteAction ?? DefaultDeleteAction(token: token),
      editAction ?? DefaultEditAction(token: token),
    ];

    if ((token.pin == null || token.pin == false)) {
      actions.add(
        lockAction ?? DefaultLockAction(token: token),
      );
    }

    return Column(
      children: [
        Slidable(
          key: ValueKey(token.id),
          groupTag: 'myTag', // This is used to only let one be open at a time.
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 1,
            children: actions,
          ),
          child: Stack(
            children: [
              tile,
              ...stack,
            ],
          ),
        ),
        Divider(
          thickness: 1.5,
          indent: 8,
          endIndent: 8,
        ),
      ],
    );
  }
}
