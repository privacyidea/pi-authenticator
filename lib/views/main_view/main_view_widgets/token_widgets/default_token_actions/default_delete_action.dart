import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../model/tokens/token.dart';
import '../../../../../utils/app_customizer.dart';
import '../../../../../utils/customizations.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../widgets/default_dialog.dart';
import '../token_action.dart';

class DefaultDeleteAction extends TokenAction {
  final Token token;

  const DefaultDeleteAction({super.key, required this.token});

  @override
  CustomSlidableAction build(BuildContext context) {
    return CustomSlidableAction(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? ApplicationCustomizer.deleteColorLight : ApplicationCustomizer.deleteColorDark,
      foregroundColor: Theme.of(context).brightness == Brightness.light
          ? ApplicationCustomizer.actionButtonForegroundLight
          : ApplicationCustomizer.actionButtonForegroundDark,
      onPressed: (_) async {
        if (token.isLocked && await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.deleteLockedToken) == false) {
          return;
        }
        _showDialog();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.delete),
          Text(
            AppLocalizations.of(context)!.delete,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ],
      ),
    );
  }

  void _showDialog() => showDialog(
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
