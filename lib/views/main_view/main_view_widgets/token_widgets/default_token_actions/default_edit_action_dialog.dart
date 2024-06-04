import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';

import '../../../../../model/tokens/token.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';

class DefaultEditActionDialog extends ConsumerStatefulWidget {
  final Token token;
  final List<Widget>? additionalChildren;
  final FutureOr<void> Function({required String newLabel, required String? newImageUrl})? onSaveButtonPressed;
  const DefaultEditActionDialog({
    required this.token,
    this.onSaveButtonPressed,
    this.additionalChildren,
    super.key,
  });

  @override
  ConsumerState<DefaultEditActionDialog> createState() => _DefaultEditActionDialogState();
}

class _DefaultEditActionDialogState extends ConsumerState<DefaultEditActionDialog> {
  late TextEditingController nameInputController = TextEditingController(text: widget.token.label);
  late TextEditingController imageUrlController = TextEditingController(text: widget.token.tokenImage);
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
                controller: nameInputController,
                onChanged: (value) {},
                decoration: InputDecoration(labelText: appLocalizations.name),
                validator: (value) {
                  if (value!.isEmpty) {
                    return appLocalizations.name;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: appLocalizations.imageUrl),
                validator: (value) {
                  try {
                    Uri.parse(value!);
                  } catch (e) {
                    return 'appLocalizations.invalidUrl';
                  }
                  return null;
                },
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
          onPressed: widget.onSaveButtonPressed != null
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
                  final edited =
                      await globalRef?.read(tokenProvider.notifier).updateToken(widget.token, (p0) => p0.copyWith(label: newLabel, tokenImage: newImageUrl));
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
