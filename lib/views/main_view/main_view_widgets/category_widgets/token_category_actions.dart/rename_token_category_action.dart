import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../model/token_category.dart';
import '../../../../../utils/app_customizer.dart';
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
        onPressed: (context) {
          TextEditingController nameInputController = TextEditingController(text: category.label);
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.renameToken),
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
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text(
                        AppLocalizations.of(context)!.rename,
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
        });
  }
}
