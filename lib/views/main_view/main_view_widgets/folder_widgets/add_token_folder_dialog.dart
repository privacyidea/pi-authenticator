/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../../widgets/pi_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../model/enums/introduction.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../../../../widgets/dialog_widgets/default_dialog.dart';

class AddTokenFolderDialog extends ConsumerWidget {
  final textController = TextEditingController();

  AddTokenFolderDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultDialog(
      scrollable: true,
      title: Text(AppLocalizations.of(context)!.addANewFolder),
      content: PiTextField(
        controller: textController,
        autofocus: true,
        onChanged: (value) {},
        labelText: AppLocalizations.of(context)!.folderName,
        validator: (value) => value!.isEmpty ? AppLocalizations.of(context)!.folderName : null,
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
              AppLocalizations.of(context)!.create,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            onPressed: () async {
              if (!(await ref.read(introductionNotifierProvider.future)).isCompleted(Introduction.addFolder)) {
                ref.read(introductionNotifierProvider.notifier).complete(Introduction.addFolder);
              }
              ref.read(tokenFolderProvider.notifier).addNewFolder(textController.text);
              if (!context.mounted) return;
              Navigator.pop(context);
            }),
      ],
    );
  }
}
