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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';

class CustomizeTokenScreen extends StatefulWidget {
  final Token _token;

  CustomizeTokenScreen(this._token);

  @override
  State createState() => _CustomizeTokenScreenState(this._token);
}

class _CustomizeTokenScreenState extends State<CustomizeTokenScreen> {
  final Token _token;
  String _selectedName;

  _CustomizeTokenScreenState(this._token) : _selectedName = _token.label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customize token'), // TODO Translate
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: null,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: () => print("edit image"), // TODO
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: null,
                        radius: 80,
                      ),
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                      ),
                    ],
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
                    onPressed: () => print("edit background"), // TODO
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
