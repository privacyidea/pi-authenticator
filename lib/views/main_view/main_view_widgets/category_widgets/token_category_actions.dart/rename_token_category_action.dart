import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../model/token_category.dart';
import '../../../../../utils/app_customizer.dart';
import '../../../../../utils/customizations.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod_providers.dart';

class RenameTokenCategoryAction extends StatelessWidget {
  final TokenCategory category;
  const RenameTokenCategoryAction({required this.category, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidableAction(
        label: AppLocalizations.of(context)!.rename,
        backgroundColor: Theme.of(context).brightness == Brightness.light ? ApplicationCustomizer.renameColorLight : ApplicationCustomizer.renameColorDark,
        foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
        icon: Icons.edit,
        onPressed: (context) async {
          if (category.isLocked && await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.unlock) == false) return;
          _showDialog();
        });
  }

  void _showDialog() {
    TextEditingController nameInputController = TextEditingController(text: category.label);
    showDialog(
        context: globalNavigatorKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text(
              AppLocalizations.of(context)!.renameTokenCategory,
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
                  globalRef?.read(tokenCategoryProvider.notifier).updateCategory(category.copyWith(label: newLabel));

                  Logger.info(
                    'Renamed token:',
                    name: 'token_widget_base.dart#TextButton#renameClicked',
                    error: '\'${category.label}\' changed to \'$newLabel\'',
                  );

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
