import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/riverpod_providers.dart';
import '../../widgets/default_dialog.dart';

class AddTokenFolderDialog extends ConsumerWidget {
  final textController = TextEditingController();

  AddTokenFolderDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultDialog(
      scrollable: true,
      title: Text(AppLocalizations.of(context)!.addANewFolder),
      content: TextFormField(
        controller: textController,
        autofocus: true,
        onChanged: (value) {},
        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.folderName),
        validator: (value) {
          if (value!.isEmpty) {
            return AppLocalizations.of(context)!.folderName;
          }
          return null;
        },
      ),
      actions: [
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
              ref.read(tokenFolderProvider.notifier).addFolder(textController.text);
              Navigator.pop(context);
            }),
      ],
    );
  }
}
