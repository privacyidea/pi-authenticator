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

class AddTokenFolderDialog extends ConsumerStatefulWidget {
  const AddTokenFolderDialog({super.key});

  @override
  ConsumerState<AddTokenFolderDialog> createState() =>
      _AddTokenFolderDialogState();
}

class _AddTokenFolderDialogState extends ConsumerState<AddTokenFolderDialog> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    // Listen to text changes to update the button state live
    _textController.addListener(_validate);
  }

  void _validate() {
    final currentlyValid = _textController.text.isNotEmpty;
    if (currentlyValid != _isValid) {
      setState(() => _isValid = currentlyValid);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return DefaultDialog(
      scrollable: true,
      title: Text(localizations.addANewFolder),
      content: Form(
        key: _formKey,
        child: PiTextField(
          controller: _textController,
          autofocus: true,
          labelText: localizations.folderName,
          validator: (value) => (value == null || value.isEmpty)
              ? localizations.folderName
              : null,
        ),
      ),
      actions: [
        DialogAction(
          label: localizations.cancel,
          intent: DialogActionIntent.cancel,
          onPressed: () => Navigator.pop(context),
        ),
        DialogAction(
          label: localizations.create,
          intent: DialogActionIntent.confirm,
          onPressed: _isValid ? _handleCreate : null,
        ),
      ],
    );
  }

  Future<void> _handleCreate() async {
    final intro = await ref.read(introductionNotifierProvider.future);
    if (!intro.isCompleted(Introduction.addFolder)) {
      await ref
          .read(introductionNotifierProvider.notifier)
          .complete(Introduction.addFolder);
    }

    ref.read(tokenFolderProvider.notifier).addNewFolder(_textController.text);

    if (mounted) Navigator.pop(context);
  }
}
