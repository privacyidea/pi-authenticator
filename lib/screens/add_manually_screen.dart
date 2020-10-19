/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2020 NetKnights GmbH

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

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:uuid/uuid.dart';

class AddTokenManuallyScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddTokenManuallyScreenState();
}

class AddTokenManuallyScreenState extends State<AddTokenManuallyScreen> {
  static final List<int> allowedDigits = [6, 8];
  static final List<int> allowedPeriods = [30, 60];

  // fields needed to build a token
  String _selectedName;
  String _selectedSecret;

  _Wrapper<Encodings> _selectedEncoding = _Wrapper(Encodings.none);
  _Wrapper<Algorithms> _selectedAlgorithm = _Wrapper(Algorithms.SHA1);
  _Wrapper<TokenTypes> _selectedType = _Wrapper(TokenTypes.HOTP);
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
          LTen.of(context).addManuallyTitle,
          textScaleFactor: screenTitleScaleFactor,
        ),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              _buildTextInputForm(),
              _buildDropdownButtonWithLabel(LTen.of(context).encoding,
                  _selectedEncoding, Encodings.values),
              _buildDropdownButtonWithLabel(LTen.of(context).algorithm,
                  _selectedAlgorithm, Algorithms.values),
              _buildDropdownButtonWithLabel(
                  LTen.of(context).digits, _selectedDigits, allowedDigits),
              _buildDropdownButtonWithLabel(
                  LTen.of(context).type,
                  _selectedType,
                  List.from(TokenTypes.values)..remove(TokenTypes.PIPUSH)),
              Visibility(
//               the period is only used by TOTP tokens
                visible: _selectedType.value == TokenTypes.TOTP,
                child: _buildDropdownButtonWithLabel(
                    LTen.of(context).period, _selectedPeriod, allowedPeriods,
                    postFix: 's'),
              ),
              SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  child: Text(LTen.of(context).addToken),
                  onPressed: () => _returnTokenIfValid(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _returnTokenIfValid() {
    if (!inputIsValid()) return;

    String uuid = Uuid().v4();
    List<int> secretByte =
        decodeSecretToUint8(_selectedSecret, _selectedEncoding.value);
    String secretBase32 = encodeSecretAs(secretByte, Encodings.base32);
    OTPToken newToken;
    if (_selectedType.value == TokenTypes.HOTP) {
      newToken = HOTPToken(
        label: _selectedName,
        issuer: null,
        id: uuid,
        algorithm: _selectedAlgorithm.value,
        digits: _selectedDigits.value,
        secret: secretBase32,
      );
    } else if (_selectedType.value == TokenTypes.TOTP) {
      newToken = TOTPToken(
        label: _selectedName,
        issuer: null,
        id: uuid,
        algorithm: _selectedAlgorithm.value,
        digits: _selectedDigits.value,
        secret: secretBase32,
        period: _selectedPeriod.value,
      );
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
      {String postFix = ''}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.body1),
        Container(
          width: 100,
          child: DropdownButton<T>(
            isExpanded: true,
            value: reference.value,
            items: values.map<DropdownMenuItem<T>>((T value) {
              return DropdownMenuItem<T>(
                value: value,
                child: Text(
                  "${value is String || value is int || value is double ? value : enumAsString(value)}"
                  "$postFix",
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
            decoration: InputDecoration(labelText: LTen.of(context).name),
            validator: (value) {
              if (value.isEmpty) {
                return LTen.of(context).hintEmptyName;
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
              labelText: LTen.of(context).secret,
            ),
            validator: (value) {
              if (value.isEmpty) {
//                FocusScope.of(context).requestFocus(_secretFieldFocus);
                return LTen.of(context).hintEmptySecret;
              } else if (!isValidEncoding(value, _selectedEncoding.value)) {
                return LTen.of(context).hintInvalidSecret;
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
