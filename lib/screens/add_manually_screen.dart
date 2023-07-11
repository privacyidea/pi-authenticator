/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
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
  String _selectedName = '';
  String _selectedSecret = '';

  _Wrapper<Encodings> _selectedEncoding = _Wrapper(Encodings.none);
  _Wrapper<Algorithms> _selectedAlgorithm = _Wrapper(Algorithms.SHA1);
  _Wrapper<TokenTypes> _selectedType = _Wrapper(TokenTypes.HOTP);
  _Wrapper<int> _selectedDigits = _Wrapper(allowedDigits[0]);
  _Wrapper<int> _selectedPeriod = _Wrapper(allowedPeriods[0]);

  // fields needed to manage the widget
  final _secretInputKey = GlobalKey<FormFieldState>();
  final _labelInputKey = GlobalKey<FormFieldState>();
  AutovalidateMode _autoValidateSecret = AutovalidateMode.disabled;

  // used to handle focusing certain input fields
  late final FocusNode _labelFieldFocus;
  late final FocusNode _secretFieldFocus;

  @override
  void initState() {
    super.initState();

    _labelFieldFocus = FocusNode();
    _secretFieldFocus = FocusNode();
  }

  @override
  void dispose() {
    _labelFieldFocus.dispose();
    _secretFieldFocus.dispose();

    super.dispose();
  }

  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.enterDetailsForToken,
          overflow: TextOverflow.ellipsis, // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
        ),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        controller: controller,
        child: SingleChildScrollView(
          controller: controller,
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              _buildTextInputForm(),
              _buildDropdownButtonWithLabel(AppLocalizations.of(context)!.encoding, _selectedEncoding, Encodings.values),
              _buildDropdownButtonWithLabel(AppLocalizations.of(context)!.algorithm, _selectedAlgorithm, Algorithms.values),
              _buildDropdownButtonWithLabel(AppLocalizations.of(context)!.digits, _selectedDigits, allowedDigits),
              _buildDropdownButtonWithLabel(AppLocalizations.of(context)!.type, _selectedType, List.from(TokenTypes.values)..remove(TokenTypes.PIPUSH)),
              Visibility(
                // the period is only used by TOTP tokens
                visible: _selectedType.value == TokenTypes.TOTP,
                child: _buildDropdownButtonWithLabel(AppLocalizations.of(context)!.period, _selectedPeriod, allowedPeriods, postFix: 's' /*seconds*/),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text(
                    AppLocalizations.of(context)!.addToken,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  onPressed: () => _returnTokenIfValid(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Validates the inputs, builds the token instances and returns them by
  /// popping the screen.
  _returnTokenIfValid() {
    if (!_inputIsValid()) return;

    String uuid = Uuid().v4();
    List<int> secretByte = decodeSecretToUint8(_selectedSecret, _selectedEncoding.value);
    String secretBase32 = encodeSecretAs(secretByte as Uint8List, Encodings.base32);
    OTPToken? newToken;
    if (_selectedType.value == TokenTypes.HOTP) {
      newToken = HOTPToken(
        label: _selectedName,
        issuer: '',
        id: uuid,
        algorithm: _selectedAlgorithm.value,
        digits: _selectedDigits.value,
        secret: secretBase32,
      );
    } else if (_selectedType.value == TokenTypes.TOTP) {
      newToken = TOTPToken(
        label: _selectedName,
        issuer: '',
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

  /// Validates the inputs of the label and secret. Returns true if the input
  /// is valid and false if not.
  bool _inputIsValid() {
    if (_labelInputKey.currentState!.validate()) {
      _labelInputKey.currentState!.save();
    } else {
      FocusScope.of(context).requestFocus(_labelFieldFocus);
      return false;
    }

    if (_secretInputKey.currentState!.validate()) {
      _secretInputKey.currentState!.save();
    } else {
      FocusScope.of(context).requestFocus(_secretFieldFocus);
      setState(() => _autoValidateSecret = AutovalidateMode.always);
      return false;
    }

    return true;
  }

  Widget _buildDropdownButtonWithLabel<T>(String label, _Wrapper reference, List<T> values, {String postFix = ''}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Container(
          width: 100,
          child: DropdownButton<T>(
            isExpanded: true,
            value: reference.value,
            items: values.map<DropdownMenuItem<T>>((T value) {
              return DropdownMenuItem<T>(
                value: value,
                child: Text(
                  '${value is String || value is int || value is double ? value : enumAsString(value!)}'
                  '$postFix',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            }).toList(),
            onChanged: (T? newValue) {
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
            key: _labelInputKey,
            focusNode: _labelFieldFocus,
            onSaved: (value) => this.setState(() => _selectedName = value!),
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
            validator: (value) {
              if (value!.isEmpty) {
                return AppLocalizations.of(context)!.pleaseEnterANameForThisToken;
              }
              return null;
            },
          ),
          TextFormField(
            key: _secretInputKey,
            autovalidateMode: _autoValidateSecret,
            focusNode: _secretFieldFocus,
            onSaved: (value) => this.setState(() => _selectedSecret = value!),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.secret,
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return AppLocalizations.of(context)!.pleaseEnterASecretForThisToken;
              } else if (!isValidEncoding(value, _selectedEncoding.value)) {
                return AppLocalizations.of(context)!.theSecretDoesNotFitTheCurrentEncoding;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

/// This is a wrapper class needed for building DropDownButtons of type T.
class _Wrapper<T> {
  _Wrapper(this.value);

  T value;
}
