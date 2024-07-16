import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/token_folder.dart';
import '../../../../../utils/customization/action_theme.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod/riverpod_providers/state_notifier_providers/token_folder_provider.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';

class RenameTokenFolderAction extends StatelessWidget {
  final TokenFolder folder;
  const RenameTokenFolderAction({required this.folder, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
        backgroundColor: Theme.of(context).extension<ActionTheme>()!.editColor,
        foregroundColor: Theme.of(context).extension<ActionTheme>()!.foregroundColor,
        onPressed: (context) async {
          if (folder.isLocked && await lockAuth(localizedReason: AppLocalizations.of(context)!.unlock) == false) return;
          _showDialog();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.edit),
            Text(
              AppLocalizations.of(context)!.rename,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ],
        ));
  }

  void _showDialog() {
    TextEditingController nameInputController = TextEditingController(text: folder.label);
    showDialog(
        useRootNavigator: false,
        context: globalNavigatorKey.currentContext!,
        builder: (BuildContext context) {
          return DefaultDialog(
            scrollable: true,
            title: Text(
              AppLocalizations.of(context)!.renameTokenFolder,
            ),
            content: TextFormField(
              autofocus: true,
              controller: nameInputController,
              onChanged: (value) {},
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
              validator: (value) {
                if (value!.isEmpty) {
                  return AppLocalizations.of(context)!.name;
                }
                return null;
              },
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.rename,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                onPressed: () async {
                  final newLabel = nameInputController.text.trim();
                  if (newLabel.isEmpty) return;
                  final success = await globalRef?.read(tokenFolderProvider.notifier).updateLabel(folder, newLabel);
                  if (success == true) {
                    Logger.info(
                      'Renamed token:',
                      name: 'token_widget_base.dart#TextButton#renameClicked',
                      error: '\'${folder.label}\' changed to \'$newLabel\'',
                    );
                  } else {
                    Logger.warning(
                      'Failed to rename token',
                      name: 'token_widget_base.dart#TextButton#renameClicked',
                      error: '\'${folder.label}\' to \'$newLabel\'',
                    );
                  }
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
