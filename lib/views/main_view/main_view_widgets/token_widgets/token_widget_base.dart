import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/utils/lock_auth.dart';
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
          child: tile,
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

class HideableWidgetTrailing extends StatelessWidget {
  final Token token;
  final ValueNotifier<bool> isHiddenNotifier;
  final Widget child;
  const HideableWidgetTrailing({
    required this.child,
    required this.token,
    required this.isHiddenNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.15,
      height: MediaQuery.of(context).size.width * 0.15,
      child: token.isLocked && isHiddenNotifier.value
          ? IconButton(
              onPressed: () async {
                if (await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.authenticateToShowOtp)) {
                  isHiddenNotifier.value = false;
                }
              },
              icon: Icon(Icons.remove_red_eye_outlined),
            )
          : child,
    );
  }
}
