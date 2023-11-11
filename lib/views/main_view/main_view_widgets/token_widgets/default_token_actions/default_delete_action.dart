import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/customizations.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../widgets/default_dialog.dart';
import '../token_action.dart';

class DefaultDeleteAction extends TokenAction {
  final Token token;

  const DefaultDeleteAction({required this.token});

  @override
  void handle(BuildContext context) async {
    if (token.isLocked && await lockAuth(context: context, localizedReason: AppLocalizations.of(context)?.deleteLockedToken ?? '') == false) {
      return;
    }
    _showDialog();
  }

  void _showDialog() => globalNavigatorKey.currentContext == null
      ? null
      : showDialog(
          useRootNavigator: false,
          context: globalNavigatorKey.currentContext!,
          builder: (BuildContext context) {
            return DefaultDialog(
              scrollable: true,
              title: Text(
                AppLocalizations.of(context)!.confirmDeletion,
              ),
              content: Text(
                AppLocalizations.of(context)!.confirmDeletionOf(token.label),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    globalRef?.read(tokenProvider.notifier).removeToken(token);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.delete,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ],
            );
          });
}
