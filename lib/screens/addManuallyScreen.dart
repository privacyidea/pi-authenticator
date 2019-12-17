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
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/util.dart';
import 'package:uuid/uuid.dart';

class AddTokenManuallyScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddTokenManuallyScreenState();
}

class AddTokenManuallyScreenState extends State<AddTokenManuallyScreen> {
  static final List<String> allowedTypes = [HOTP, TOTP];
  static final List<int> allowedDigits = [6, 8];
  static final List<int> allowedPeriods = [30, 60];

  // fields needed to build a token
  String _selectedName;
  String _selectedSecret;

  _Wrapper<Encodings> _selectedEncoding = _Wrapper(Encodings.none);
  _Wrapper<Algorithms> _selectedAlgorithm = _Wrapper(Algorithms.SHA1);
  _Wrapper<String> _selectedType = _Wrapper(allowedTypes[0]);
  _Wrapper<int> _selectedDigits = _Wrapper(allowedDigits[0]);
  _Wrapper<int> _selectedPeriod = _Wrapper(allowedPeriods[0]);

  // fields needed to manage the widget
  final _secretInputKey = GlobalKey<FormFieldState>();
  final _nameInputKey = GlobalKey<FormFieldState>();
  bool _autoValidateSecret = false;

  // used to handle focusing certain input fields
  FocusNode _nameFieldFocus;
  FocusNode _secretFieldFocus;

  @override
  void initState() {
    super.initState();

    _nameFieldFocus = FocusNode();
    _secretFieldFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameFieldFocus.dispose();
    _secretFieldFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Enter details for token",
          style: Theme.of(context).textTheme.title,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildTextInputForm(),
            _buildDropdownButtonWithLabel(
                'Encoding:', _selectedEncoding, Encodings.values),
            _buildDropdownButtonWithLabel(
                'Algorithm:', _selectedAlgorithm, Algorithms.values),
//            _buildDropdownButtonWithLabel(
//                'Digits:', _selectedDigits, allowedDigits),
//            _buildDropdownButtonWithLabel('Type:', _selectedType, allowedTypes),
//            Visibility(
////               the period is only used by TOTP tokens
//              visible: _selectedType.value == TOTP,
//              child: _buildDropdownButtonWithLabel(
//                  'Period:', _selectedPeriod, allowedPeriods,
//                  postFix: 's'),
//            ),
            SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text("Add token"),
                onPressed: () => _returnTokenIfValid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _returnTokenIfValid() {
    if (!inputIsValid()) return;

    String serial = Uuid().v4();
    Uint8List secretAsUint8 =
        decodeSecretToUint8(_selectedSecret, _selectedEncoding.value);
    Token newToken;
    if (_selectedType.value == HOTP) {
      newToken = HOTPToken(_selectedName, serial, _selectedAlgorithm.value,
          _selectedDigits.value, secretAsUint8);
    } else if (_selectedType.value == TOTP) {
      newToken = TOTPToken(_selectedName, serial, _selectedAlgorithm.value,
          _selectedDigits.value, secretAsUint8, _selectedPeriod.value);
    }

    // Everything should be fine now, and we can return the new token.
    Navigator.pop(
      context,
      newToken,
    );
  }

  bool inputIsValid() {
    if (_nameInputKey.currentState.validate()) {
      _nameInputKey.currentState.save();
    } else {
      FocusScope.of(context).requestFocus(_nameFieldFocus);
      return false;
    }

    if (_secretInputKey.currentState.validate()) {
      _secretInputKey.currentState.save();
    } else {
      FocusScope.of(context).requestFocus(_secretFieldFocus);
      setState(() {
        _autoValidateSecret = true;
      });
      return false;
    }

    return true;
  }

  Widget _buildDropdownButtonWithLabel<T>(
      String label, _Wrapper reference, List<T> values,
      {postFix = ''}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.body1),
        DropdownButton<T>(
          value: reference.value,
          items: values.map<DropdownMenuItem<T>>((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Text(
                "${describeEnum(value)}$postFix",
                style: Theme.of(context).textTheme.subhead,
              ),
            );
          }).toList(),
          onChanged: (T newValue) {
            setState(() {
              reference.value = newValue;
            });
          },
        ),
      ],
    );
  }

  Form _buildTextInputForm() {
    return Form(
      child: Column(
        children: <Widget>[
          TextFormField(
            key: _nameInputKey,
            focusNode: _nameFieldFocus,
            onSaved: (value) => this.setState(() => _selectedName = value),
            decoration: InputDecoration(labelText: "Name"),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a name for this token.';
              }
              return null;
            },
          ),
          TextFormField(
            key: _secretInputKey,
            autovalidate: _autoValidateSecret,
            focusNode: _secretFieldFocus,
            onSaved: (value) => this.setState(() => _selectedSecret = value),
            decoration: InputDecoration(
              labelText: "Secret",
            ),
            validator: (value) {
              if (value.isEmpty) {
//                FocusScope.of(context).requestFocus(_secretFieldFocus);
                return 'Please enter a secret for this token.';
              } else if (!isValidEncoding(value, _selectedEncoding.value)) {
                return 'The secret does not fit current encoding.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _Wrapper<T> {
  _Wrapper(this.value);

  T value;
}
