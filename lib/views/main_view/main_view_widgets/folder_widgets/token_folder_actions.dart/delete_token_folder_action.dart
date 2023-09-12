import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../model/token_folder.dart';
import '../../../../../utils/app_customizer.dart';
import '../../../../../utils/customizations.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../widgets/default_dialog.dart';

class DeleteTokenFolderAction extends StatelessWidget {
  final TokenFolder folder;

  const DeleteTokenFolderAction({super.key, required this.folder});
  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      backgroundColor: Theme.of(context).extension<ActionTheme>()!.deleteColor,
      foregroundColor: Theme.of(context).extension<ActionTheme>()!.foregroundColor,
      onPressed: (context) async {
        if (folder.isLocked && await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.unlock) == false) return;
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
      useRootNavigator: false,
      context: globalNavigatorKey.currentContext!,
      builder: (BuildContext context) {
        return DefaultDialog(
          scrollable: true,
          title: Text(
            AppLocalizations.of(context)!.confirmDeletion,
          ),
          content: Text(AppLocalizations.of(context)!.confirmDeletionOf(folder.label)),
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
                final tokens = globalRef?.read(tokenProvider).tokensInFolder(folder);
                if (tokens == null) return;
                for (var i = 0; i < tokens.length; i++) {
                  tokens[i] = tokens[i].copyWith(folderId: () => null);
                }
                globalRef?.read(tokenProvider.notifier).addOrReplaceTokens(tokens);
                globalRef?.read(tokenFolderProvider.notifier).removeFolder(folder);
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
