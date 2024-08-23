/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';

class DefaultEditActionDialog extends ConsumerStatefulWidget {
  final Token token;
  final List<Widget>? additionalChildren;

  /// Should return false if an input is invalid. Name and image URL are validated regardless of whether the function is set or not.
  final bool additionalSaveValidation;
  final FutureOr<void> Function({required String newLabel, required String? newImageUrl})? onSaveButtonPressed;
  const DefaultEditActionDialog({
    required this.token,
    this.onSaveButtonPressed,
    this.additionalChildren,
    this.additionalSaveValidation = true,
    super.key,
  });

  @override
  ConsumerState<DefaultEditActionDialog> createState() => _DefaultEditActionDialogState();
}

class _DefaultEditActionDialogState extends ConsumerState<DefaultEditActionDialog> {
  late final TextEditingController nameInputController = TextEditingController(text: widget.token.label);
  late final TextEditingController imageUrlController = TextEditingController(text: widget.token.tokenImage);
  bool _nameIsValid = true;
  bool _imageUrlIsValid = true;
  late final bool _additionalSaveValidation = widget.additionalSaveValidation;
  bool get _canSave => _nameIsValid && _imageUrlIsValid && _additionalSaveValidation;

  String? _validateName(String? value) {
    if (value == null || value.isNotEmpty) return null;
    return AppLocalizations.of(context)!.mustNotBeEmpty(AppLocalizations.of(context)!.name);
  }

  String? _validateImageUrl(String? value) {
    if (value == null) return null;
    final uri = Uri.tryParse(value);
    if (value.isNotEmpty && (uri == null || uri.host.isEmpty || uri.scheme.isEmpty || uri.path.isEmpty)) {
      return AppLocalizations.of(context)!.exampleUrl;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return DefaultDialog(
      scrollable: true,
      title: Text(
        appLocalizations.renameToken,
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: Key('${widget.token.id}_editName'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: nameInputController,
                onChanged: (value) => setState(() => _nameIsValid = _validateName(value) == null),
                decoration: InputDecoration(labelText: appLocalizations.name),
                validator: _validateName,
              ),
              TextFormField(
                key: Key('${widget.token.id}_editImageUrl'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: imageUrlController,
                onChanged: (value) => setState(() => _imageUrlIsValid = _validateImageUrl(value) == null),
                decoration: InputDecoration(labelText: appLocalizations.imageUrl),
                validator: _validateImageUrl,
              ),
              if (widget.additionalChildren != null) ...widget.additionalChildren!,
              TextFormField(
                  initialValue: widget.token.origin?.appName ?? 'appLocalizations.unknown',
                  decoration: const InputDecoration(labelText: 'Origin'),
                  readOnly: true,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).disabledColor)),
              TextFormField(
                initialValue: widget.token.isPrivacyIdeaToken == false ? 'Yes' : 'No',
                decoration: const InputDecoration(labelText: 'Is exportable?'),
                readOnly: true,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).disabledColor),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            appLocalizations.cancel,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: !_canSave
              ? null
              : widget.onSaveButtonPressed != null
                  ? () {
                      widget.onSaveButtonPressed!(
                        newLabel: nameInputController.text,
                        newImageUrl: imageUrlController.text,
                      );
                    }
                  : () async {
                      final newLabel = nameInputController.text;
                      final newImageUrl = imageUrlController.text;
                      if (newLabel.isEmpty) return;
                      final edited = await globalRef
                          ?.read(tokenProvider.notifier)
                          .updateToken(widget.token, (p0) => p0.copyWith(label: newLabel, tokenImage: newImageUrl));
                      if (edited == null) {
                        Logger.error('Token editing failed', name: 'DefaultEditAction#_showDialog');
                        return;
                      }
                      Logger.info(
                        'Token edited: ${widget.token.label} -> ${edited.label}, ${widget.token.tokenImage} -> ${edited.tokenImage}',
                        name: 'DefaultEditAction#_showDialog',
                      );
                      if (context.mounted) Navigator.of(context).pop();
                    },
          child: Text(
            appLocalizations.save,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}
