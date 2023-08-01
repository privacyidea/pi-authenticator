import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../model/token_category.dart';
import '../../../../../utils/app_customizer.dart';
import '../../../../../utils/riverpod_providers.dart';

class DeleteTokenCategoryAction extends StatelessWidget {
  final TokenCategory category;

  const DeleteTokenCategoryAction({super.key, required this.category});
  @override
  Widget build(BuildContext context) {
    return SlidableAction(
      label: AppLocalizations.of(context)!.delete,
      backgroundColor: Theme.of(context).brightness == Brightness.light ? ApplicationCustomizer.deleteColorLight : ApplicationCustomizer.deleteColorDark,
      foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
      icon: Icons.delete,
      onPressed: (_) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.confirmDeletion),
                content: Text(
                  AppLocalizations.of(context)!.confirmDeletionOf(category.label),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final tokens = globalRef?.read(tokenProvider).tokensInCategory(category);
                      if (tokens == null) return;
                      for (var i = 0; i < tokens.length; i++) {
                        tokens[i] = tokens[i].copyWith(categoryId: () => null);
                      }
                      globalRef?.read(tokenProvider.notifier).updateTokens(tokens);
                      globalRef?.read(tokenCategoryProvider.notifier).removeCategory(category);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.delete,
                    ),
                  ),
                ],
              );
            });
      },
    );
  }
}
