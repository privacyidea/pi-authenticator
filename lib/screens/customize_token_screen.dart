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
  String _selectedName;
  String? _selectedPath;

  _CustomizeTokenScreenState(this._token)
      : _selectedName = _token.label,
        _selectedPath = _token.imagePath;

  void _pickImage() async {
    try {
      XFile? image = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 10);
      if (image != null) {
        // Save a copy of the image
        String path = (await getApplicationDocumentsDirectory()).path;
        File imageCopy = await File(image.path).copy('$path/${_token.id}');
        _selectedPath = imageCopy.path;
      } else {
        _selectedPath = null;
      }

      setState(() {});
    } on PlatformException {
      // Permission was denied
      return;
    }
  }

  void _pickColor() {
    print("pick color");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customize token'), // TODO Translate
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          // TODO Delete the image if aborting and also delete the image if the token is deleted
          // TODO Validate token name
          // TODO Set the name on the token

          _token.imagePath = _selectedPath;
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
                    backgroundImage: _selectedPath == null
                        ? null
                        : FileImage(File(_selectedPath!)),
                    backgroundColor: null,
                    radius: 80,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
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
              initialValue: _selectedName,
              // key: _nameInputKey,
              onChanged: (value) {
                if (mounted) {
                  setState(() => _selectedName = value);
                }
              },
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.name),
              validator: (value) {
                if (value!.isEmpty) {
                  return AppLocalizations.of(context)!.name;
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
