import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../model/token_folder.dart';
import '../../../../../utils/app_customizer.dart';
import '../../../../../utils/customizations.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../widgets/default_dialog.dart';

class RenameTokenFolderAction extends StatelessWidget {
  final TokenFolder folder;
  const RenameTokenFolderAction({required this.folder, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
        backgroundColor: Theme.of(context).brightness == Brightness.light ? ApplicationCustomizer.renameColorLight : ApplicationCustomizer.renameColorDark,
        foregroundColor: Theme.of(context).brightness == Brightness.light
            ? ApplicationCustomizer.actionButtonForegroundLight
            : ApplicationCustomizer.actionButtonForegroundDark,
        onPressed: (context) async {
          if (folder.isLocked && await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.unlock) == false) return;
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
                onPressed: () {
                  final newLabel = nameInputController.text.trim();
                  if (newLabel.isEmpty) return;
                  globalRef?.read(tokenFolderProvider.notifier).updateFolder(folder.copyWith(label: newLabel));

                  Logger.info(
                    'Renamed token:',
                    name: 'token_widget_base.dart#TextButton#renameClicked',
                    error: '\'${folder.label}\' changed to \'$newLabel\'',
                  );

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
