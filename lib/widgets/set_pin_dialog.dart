/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

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

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';

class SetPINDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SetPINDialogState();
}

class _SetPINDialogState extends State<SetPINDialog> {
  String _title;

//  Widget _content = Row(
//    mainAxisAlignment: MainAxisAlignment.center,
//    children: <Widget>[
//      _buildTextInputForm(), // TODO Add a form here
//    ],
//  );
  FlatButton _button;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

//    _title = Localization.of(context).twoStepDialogTitleGenerate;
    _title = 'Please enter a new PIN';
  }

  String _newPIN;
  String _confirmedPIN;

  // fields needed to manage the widget
  final _confirmPINKey = GlobalKey<FormFieldState>();
  final _newPINKey = GlobalKey<FormFieldState>();
  bool _autoValidateSecret = false;

  // used to handle focusing certain input fields
  FocusNode _newPINFocus;
  FocusNode _confirmPINFocus;

  @override
  void initState() {
    super.initState();

    _newPINFocus = FocusNode();
    _confirmPINFocus = FocusNode();
  }

  @override
  void dispose() {
    _newPINFocus.dispose();
    _confirmPINFocus.dispose();

    super.dispose();
  }

  Form _buildTextInputForm() {
    return Form(
      child: Column(
        children: <Widget>[
          TextFormField(
            key: _newPINKey,
            focusNode: _newPINFocus,
            onSaved: (value) => this.setState(() => _newPIN = value),
            decoration: InputDecoration(labelText: 'new PIN'),
            // TODO Translate
            validator: (value) {
              if (value.isEmpty) {
                return Localization.of(context).hintEmptyName;
              }
              return null;
            },
          ),
          TextFormField(
            key: _confirmPINKey,
            autovalidate: _autoValidateSecret,
            focusNode: _confirmPINFocus,
            onSaved: (value) => this.setState(() => _confirmedPIN = value),
            decoration: InputDecoration(labelText: 'confirm PIN'),
            // TODO Translate
            validator: (value) {
              if (value.isEmpty) {
//                FocusScope.of(context).requestFocus(_secretFieldFocus);
                return Localization.of(context).hintEmptySecret;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        title: Text(_title),
        content: _buildTextInputForm(),
        actions: <Widget>[_button],
      ),
    );
  }
}
