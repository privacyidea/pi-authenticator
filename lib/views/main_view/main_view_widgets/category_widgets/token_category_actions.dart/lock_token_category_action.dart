import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../model/token_category.dart';
import '../../../../../utils/app_customizer.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod_providers.dart';

class LockTokenCategoryAction extends StatelessWidget {
  final TokenCategory category;

  const LockTokenCategoryAction({super.key, required this.category});
  @override
  Widget build(BuildContext context) {
    return SlidableAction(
      label: category.isLocked ? AppLocalizations.of(context)!.unlock : AppLocalizations.of(context)!.lock,
      backgroundColor: Theme.of(context).brightness == Brightness.light ? ApplicationCustomizer.lockColorLight : ApplicationCustomizer.lockColorDark,
      foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
      icon: Icons.lock,
      onPressed: (context) async {
        if (await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.unlock) == false) return;
        globalRef?.read(tokenCategoryProvider.notifier).updateCategory(category.copyWith(isLocked: !category.isLocked));
      },
    );
  }
}
