import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../model/tokens/token.dart';
import '../../../../../utils/app_customizer.dart';
import '../../../../../utils/customizations.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../token_action.dart';

class DefaultDeleteAction extends TokenAction {
  final Token token;

  const DefaultDeleteAction({super.key, required this.token});

  @override
  SlidableAction build(BuildContext context) {
    return SlidableAction(
      label: AppLocalizations.of(context)!.delete,
      backgroundColor: Theme.of(context).brightness == Brightness.light ? ApplicationCustomizer.deleteColorLight : ApplicationCustomizer.deleteColorDark,
      foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
      icon: Icons.delete,
      onPressed: (_) async {
        if (token.isLocked && await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.deleteLockedToken) == false) {
          return;
        }
        _showDialog();
      },
    );
  }

  void _showDialog() => showDialog(
      context: globalNavigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
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
