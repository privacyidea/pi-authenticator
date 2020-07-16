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
import 'package:flutter/services.dart';

class SetPINDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SetPINDialogState();
}

class _SetPINDialogState extends State<SetPINDialog> {
  String _title;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

//    _title = Localization.of(context).twoStepDialogTitleGenerate;
    _title = 'Please enter a new PIN';
  }

  String _newPIN;
  String _confirmPIN;

  // fields needed to manage the widget
  final _confirmPINKey = GlobalKey<FormFieldState>();
  final _newPINKey = GlobalKey<FormFieldState>();
  bool _autoValidatePIN = false;

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

  final keyBoardType = TextInputType.number;
  final List<TextInputFormatter> inputFormatters = [
    WhitelistingTextInputFormatter.digitsOnly
  ];
  final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(2),
      borderSide: BorderSide(width: 2, color: Colors.green));
  final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 2, color: Colors.green));
  final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(2),
      borderSide: BorderSide(width: 2, color: Colors.red));
  final focusedErrorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 2, color: Colors.red));

  Form _buildTextInputForm() {
    return Form(
      child: Column(
        children: <Widget>[
          TextFormField(
            keyboardType: keyBoardType,
            inputFormatters: inputFormatters,
            key: _newPINKey,
            focusNode: _newPINFocus,
            onFieldSubmitted: (value) => this.setState(() {
//              print('Setting new PIN: $_newPIN from $value');
//              setState(() => _autoValidatePIN = true);
//              _newPINKey.currentState.validate();
              _confirmPINFocus.requestFocus();
            }),
            onChanged: (value) => this.setState(() {
//              print('Setting new PIN: $_newPIN from $value');
//              setState(() => _autoValidatePIN = true);
//              _newPINKey.currentState.validate();
              _newPIN = value;
            }),
            decoration: InputDecoration(
              labelText: 'PIN',
              // TODO Translate
              border: border,
              focusedBorder: focusBorder,
              errorBorder: errorBorder,
              focusedErrorBorder: focusedErrorBorder,
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a PIN.'; // TODO Translate
              }
              return null;
            },
          ),
          Padding(
            padding: EdgeInsets.all(5),
          ),
          TextFormField(
            keyboardType: keyBoardType,
            inputFormatters: inputFormatters,
            key: _confirmPINKey,
            autovalidate: _autoValidatePIN,
            focusNode: _confirmPINFocus,
//            onSaved: (value) =>
//                this.setState(() => _confirmPINKey.currentState.validate()),
            onChanged: (value) => this.setState(() {
//              print('Setting new PIN: $_newPIN from $value');
//              setState(() => _autoValidatePIN = true);
//              _newPINKey.currentState.validate();
              _confirmPIN = value;
            }),
            decoration: InputDecoration(
              labelText: 'Confirm',
              // TODO Translate
              border: border,
              focusedBorder: focusBorder,
              errorBorder: errorBorder,
              focusedErrorBorder: focusedErrorBorder,
            ),
            validator: (value) {
//              if (value.isEmpty) {
////                FocusScope.of(context).requestFocus(_secretFieldFocus);
//                return Localization.of(context).hintEmptySecret;
//              }
              if (value != _newPIN) {
                return 'The PINs are not equal'; // TODO Translate
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  bool validatePIN(String pin) {
    return pin == _newPIN;
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        title: Text(_title),
        content: _buildTextInputForm(),
        actions: <Widget>[
          FlatButton(
            child: Text('Push me!'), // TODO Translate
            onPressed: () {
              if (_newPINKey.currentState.validate()) {
                if (_confirmPINKey.currentState.validate()) {
                  if (_newPIN == _confirmPIN && _newPIN.isNotEmpty) {
                    Navigator.of(context).pop(_newPIN);
                  }
                } else {
                  _confirmPINFocus.requestFocus();
                }
              } else {
                _newPINFocus.requestFocus();
              }
            },
          )
        ],
      ),
    );
  }
}