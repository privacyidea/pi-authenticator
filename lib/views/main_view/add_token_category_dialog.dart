import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/riverpod_providers.dart';
import '../../widgets/default_dialog.dart';

class AddTokenCategoryDialog extends ConsumerWidget {
  final textController = TextEditingController();

  AddTokenCategoryDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: DefaultDialog(
        scrollable: true,
        title: Text(AppLocalizations.of(context)!.addANewCategory),
        content: TextFormField(
          controller: textController,
          autofocus: true,
          onChanged: (value) {},
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.categoryName),
          validator: (value) {
            if (value!.isEmpty) {
              return AppLocalizations.of(context)!.categoryName;
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
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
              child: Text(
                AppLocalizations.of(context)!.save,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              onPressed: () {
                ref.read(tokenCategoryProvider.notifier).addCategory(textController.text);
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }
}
