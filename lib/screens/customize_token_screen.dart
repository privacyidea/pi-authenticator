/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:io';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';

class CustomizeTokenScreen extends StatefulWidget {
  final Token _token;

  CustomizeTokenScreen(this._token);

  @override
  State createState() => _CustomizeTokenScreenState(this._token);
}

class _CustomizeTokenScreenState extends State<CustomizeTokenScreen> {
  final Token _token;
  String _selectedLabel;
  String? _selectedAvatarImagePath;
  Color? _selectedAvatarColor;
  final _labelInputKey = GlobalKey<FormFieldState>();
  late final FocusNode _labelFieldFocus;

  @override
  void initState() {
    super.initState();

    _labelFieldFocus = FocusNode();
  }

  @override
  void dispose() {
    _labelFieldFocus.dispose();

    super.dispose();
  }

  _CustomizeTokenScreenState(this._token)
      : _selectedLabel = _token.label,
        _selectedAvatarImagePath = _token.avatarPath,
        _selectedAvatarColor =
            _token.avatarColor == null ? null : Color(_token.avatarColor!);

  void _pickImage() async {
    try {
      XFile? image = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 10);
      _selectedAvatarImagePath = image?.path;
      setState(() {});
    } on PlatformException {
      // Permission was denied
      return;
    }
  }

  void _pickColor() async {
    _selectedAvatarColor = await showColorPickerDialog(
      context,
      _selectedAvatarColor ?? Theme.of(context).colorScheme.secondary,
      title: Text('ColorPicker', style: Theme.of(context).textTheme.headline6),
      enableOpacity: false,
      showColorCode: false,
      colorCodeHasColor: false,
      showRecentColors: false,
      enableShadesSelection: false,
      pickersEnabled: <ColorPickerType, bool>{
        ColorPickerType.wheel: true,
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
      },
      copyPasteBehavior: ColorPickerCopyPasteBehavior(
        copyButton: false,
        pasteButton: false,
        longPressMenu: false,
      ),
      actionButtons: ColorPickerActionButtons(
        okButton: false,
        closeButton: false,
        dialogOkButtonLabel: AppLocalizations.of(context)!.accept,
        dialogCancelButtonLabel: AppLocalizations.of(context)!.cancel,
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.customizeTokenTitle),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () async {
          if (_labelInputKey.currentState!.validate()) {
            _token.label = _selectedLabel;
          } else {
            _labelFieldFocus.requestFocus();
            return;
          }

          if (_selectedAvatarImagePath != null) {
            // Save a copy of the image
            String documentsPath =
                (await getApplicationDocumentsDirectory()).path;
            File imageCopy = await File(_selectedAvatarImagePath!)
                .copy('$documentsPath/${_token.id}');
            _token.avatarPath = imageCopy.path;
          }

          _token.avatarColor = _selectedAvatarColor?.value;
          StorageUtil.saveOrReplaceToken(_token);
          Navigator.of(context).pop(_token);
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                    ),
                    backgroundImage: _selectedAvatarImagePath == null
                        ? null
                        : FileImage(File(_selectedAvatarImagePath!)),
                    backgroundColor: _selectedAvatarColor,
                    radius: 80,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    border: Border.all(color: Colors.grey.shade500, width: 1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.brush),
                    onPressed: _pickColor,
                  ),
                ),
              ],
            ),
            TextFormField(
              autofocus: false,
              focusNode: _labelFieldFocus,
              initialValue: _selectedLabel,
              key: _labelInputKey,
              onChanged: (value) {
                if (mounted) {
                  setState(() => _selectedLabel = value);
                }
              },
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.label),
              validator: (value) {
                if (value!.isEmpty) {
                  return AppLocalizations.of(context)!
                      .pleaseEnterALabelForThisToken;
                }
                return null;
              },
            )
          ],
        ),
      ),
    );
  }
}
