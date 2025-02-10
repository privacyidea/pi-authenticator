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

import '../../../../../../../widgets/pi_text_field.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';

class DefaultEditActionDialog extends ConsumerStatefulWidget {
  final Token token;
  final List<Widget> additionalChildren;

  /// Should return false if an input is invalid. Name and image URL are validated regardless of whether the function is set or not.
  final bool additionalSaveValidation;
  final FutureOr<void> Function({required String newLabel, required String? newImageUrl})? onSaveButtonPressed;
  const DefaultEditActionDialog({
    required this.token,
    this.onSaveButtonPressed,
    this.additionalChildren = const [],
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

  late final token = widget.token;

  String? _validateName(String? value) {
    if (value == null || value.isNotEmpty) return null;
    return AppLocalizations.of(context)!.mustNotBeEmpty(AppLocalizations.of(context)!.name);
  }

  String? _validateImageUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    if (urlRegExp.hasMatch(value)) return null;
    return AppLocalizations.of(context)!.exampleUrl;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final origin = token.origin;
    return DefaultDialog(
      scrollable: true,
      title: Text(
        appLocalizations.renameToken,
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            PiTextField(
              key: Key('${widget.token.id}_editName'),
              controller: nameInputController,
              onChanged: (value) => setState(() => _nameIsValid = _validateName(value) == null),
              labelText: appLocalizations.name,
              validator: _validateName,
            ),
            PiTextField(
              key: Key('${widget.token.id}_editImageUrl'),
              controller: imageUrlController,
              onChanged: (value) => setState(() => _imageUrlIsValid = _validateImageUrl(value) == null),
              labelText: appLocalizations.imageUrl,
              validator: _validateImageUrl,
            ),
            EditActionExpansionTile(
              title: appLocalizations.tokenDetails,
              children: [
                if (token.serial != null)
                  ReadOnlyTextFormField(
                    text: token.serial!,
                    labelText: appLocalizations.tokenSerial,
                  ),
                ReadOnlyTextFormField(
                  labelText: appLocalizations.isExpotableQuestion,
                  text: token.isExportable ? appLocalizations.yes : appLocalizations.no,
                ),
                if (widget.token.containerSerial != null)
                  ReadOnlyTextFormField(
                    text: token.containerSerial!,
                    labelText: appLocalizations.linkedContainer,
                  ),
                ...widget.additionalChildren,
              ],
            ),
            if (origin != null)
              EditActionExpansionTile(
                title: appLocalizations.originDetails,
                children: [
                  ReadOnlyTextFormField(
                    labelText: appLocalizations.originApp,
                    text: origin.appName,
                  ),
                  if (origin.creator != null)
                    ReadOnlyTextFormField(
                      labelText: appLocalizations.creator,
                      text: origin.creator!,
                    ),
                  ReadOnlyTextFormField(
                    labelText: appLocalizations.createdAt,
                    text: origin.createdAt.toString().split('.').first,
                  ),
                  ReadOnlyTextFormField(
                      labelText: appLocalizations.isPiTokenQuestion, //'Is privacyIDEA Token?',
                      text: origin.isPrivacyIdeaToken == null
                          ? appLocalizations.unknown
                          : origin.isPrivacyIdeaToken!
                              ? appLocalizations.yes
                              : appLocalizations.no),
                  ReadOnlyTextFormField(
                    text: origin.source.name,
                    labelText: appLocalizations.importedVia, //'Imported via',
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
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
                      final edited =
                          await globalRef?.read(tokenProvider.notifier).updateToken(token, (p0) => p0.copyWith(label: newLabel, tokenImage: newImageUrl));
                      if (edited == null) {
                        Logger.error('Token editing failed');
                        return;
                      }
                      Logger.info('Token edited: ${token.label} -> ${edited.label}, ${token.tokenImage} -> ${edited.tokenImage}');
                      if (context.mounted) Navigator.of(context).pop();
                    },
          child: Text(
            appLocalizations.saveButton,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

class ReadOnlyTextFormField extends StatelessWidget {
  final String text;
  final String labelText;
  final void Function()? onTap;

  const ReadOnlyTextFormField({
    required this.text,
    required this.labelText,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        initialValue: text,
        decoration: InputDecoration(
          labelText: labelText,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).disabledColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).disabledColor),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).disabledColor),
          ),
        ),
        readOnly: true,
        onTap: onTap,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).disabledColor),
      );
}

class EditActionExpansionTile extends StatefulWidget {
  final List<Widget> children;
  final String title;

  const EditActionExpansionTile({
    required this.children,
    required this.title,
    super.key,
  });

  @override
  State<EditActionExpansionTile> createState() => _EditActionExpansionTileState();
}

class _EditActionExpansionTileState extends State<EditActionExpansionTile> with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation<double>? animation;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (animation == null) {
      controller = AnimationController(
        duration: ExpansionTileTheme.of(context).expansionAnimationStyle?.duration ?? const Duration(milliseconds: 200),
        vsync: this,
      );
      animation = CurvedAnimation(parent: controller!, curve: Curves.fastOutSlowIn);
    }
    return AnimatedBuilder(
      animation: animation!,
      builder: (buildContext, _) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.only(bottom: animation!.value * 16.0, right: 0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 5.0,
              offset: const Offset(0, 3.0),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.only(left: 8.0, right: 16.0),
            title: Row(
              children: [
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.25).animate(animation!),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(widget.title, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            showTrailingIcon: false,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                controller!.forward();
              } else {
                controller!.reverse();
              }
            },
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: widget.children,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
