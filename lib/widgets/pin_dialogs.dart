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

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';

// TODO Allow setting passwords instead of numbers only
// TODO Refactor names accordingly
class EnterNewPINDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EnterNewPINDialogState();
}

class _EnterNewPINDialogState extends State<EnterNewPINDialog> {
  String _title;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _title = 'Please enter a new PIN'; // TODO Translate
  }

  String _newPIN;
  String _confirmPIN;

  // fields needed to manage the widget
  final _confirmPINKey = GlobalKey<FormFieldState>();
  final _newPINKey = GlobalKey<FormFieldState>();
  bool _autoValidatePIN = false;
  bool obscurePIN = true;
  bool obscureConfirm = true;

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
      borderRadius: BorderRadius.circular(2), borderSide: BorderSide(width: 2));
  final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 2, color: Colors.grey));
  final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(2),
      borderSide: BorderSide(width: 2, color: Colors.red));
  final focusedErrorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 2, color: Colors.red));

  Form _buildTextInputForm() {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            obscureText: obscurePIN,
            keyboardType: keyBoardType,
            inputFormatters: inputFormatters,
            key: _newPINKey,
            focusNode: _newPINFocus,
            onFieldSubmitted: (value) => this.setState(() {
              _confirmPINFocus.requestFocus();
            }),
            onChanged: (value) => this.setState(() {
              _newPIN = value;
            }),
            decoration: InputDecoration(
              suffixIcon: GestureDetector(
                child: Icon(
                  Icons.remove_red_eye,
                  color: obscurePIN
                      ? Colors.grey
                      : getHighlightColor(isDarkModeOn(context)),
                ),
                onTap: () {
                  setState(() {
                    obscurePIN = !obscurePIN;
                  });
                },
              ),
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
            obscureText: obscureConfirm,
            keyboardType: keyBoardType,
            inputFormatters: inputFormatters,
            key: _confirmPINKey,
            autovalidate: _autoValidatePIN,
            focusNode: _confirmPINFocus,
            onChanged: (value) => this.setState(() {
              _confirmPIN = value;
            }),
            decoration: InputDecoration(
              labelText: 'Confirm',
              // TODO Translate
              suffixIcon: GestureDetector(
                child: Icon(
                  Icons.remove_red_eye,
                  color: obscureConfirm
                      ? Colors.grey
                      : Theme.of(context).primaryColor,
                ),
                onTap: () {
                  setState(() {
                    obscureConfirm = !obscureConfirm;
                  });
                },
              ),
              border: border,
              focusedBorder: focusBorder,
              errorBorder: errorBorder,
              focusedErrorBorder: focusedErrorBorder,
            ),
            validator: (value) {
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
            child: Text(
              LTen.of(context).cancel,
              style: getDialogTextStyle(isDarkModeOn(context)),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FlatButton(
            child: Text(
              LTen.of(context).accept,
              style: getDialogTextStyle(isDarkModeOn(context)),
            ), // TODO Translate
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

class CheckPINDialog extends StatefulWidget {
  final allowCancel;
  final pin;

  const CheckPINDialog({Key key, this.allowCancel, this.pin}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CheckPINDialogState();
}

// FIXME This does not work in horizontal mode!
// TODO Fix back button
class _CheckPINDialogState extends State<CheckPINDialog> {
  String _title;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _title = 'Please enter the PIN'; // TODO Translate
  }

  String _currentInput;

  // fields needed to manage the widget
  final _enterPINKey = GlobalKey<FormFieldState>();
  bool _autoValidatePIN = false;
  bool obscurePIN = true;
  bool obscureConfirm = true;

  // used to handle focusing certain input fields
  FocusNode _enterPINFocus;

  @override
  void initState() {
    super.initState();

    _enterPINFocus = FocusNode();
  }

  @override
  void dispose() {
    _enterPINFocus.dispose();

    super.dispose();
  }

  final keyBoardType = TextInputType.number;
  final List<TextInputFormatter> inputFormatters = [
    WhitelistingTextInputFormatter.digitsOnly
  ];
  final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(2), borderSide: BorderSide(width: 2));
  final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 2, color: Colors.grey));
  final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(2),
      borderSide: BorderSide(width: 2, color: Colors.red));
  final focusedErrorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 2, color: Colors.red));

  Form _buildTextInputForm() {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            obscureText: obscureConfirm,
            keyboardType: keyBoardType,
            inputFormatters: inputFormatters,
            key: _enterPINKey,
            autovalidate: _autoValidatePIN,
            focusNode: _enterPINFocus,
            onChanged: (value) => this.setState(() => _currentInput = value),
            decoration: InputDecoration(
              labelText: 'Password',
              // TODO Translate
              suffixIcon: GestureDetector(
                child: Icon(
                  Icons.remove_red_eye,
                  color: obscureConfirm
                      ? Colors.grey
                      : Theme.of(context).primaryColor,
                ),
                onTap: () {
                  setState(() {
                    obscureConfirm = !obscureConfirm;
                  });
                },
              ),
              border: border,
              focusedBorder: focusBorder,
              errorBorder: errorBorder,
              focusedErrorBorder: focusedErrorBorder,
            ),
            validator: (value) {
              if (!validateInput()) {
                return 'This is wrong!';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  bool validateInput() {
    return _currentInput == widget.pin;
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        title: Text(_title),
        content: _buildTextInputForm(),
        actions: <Widget>[
          Visibility(
            visible: widget.allowCancel,
            child: FlatButton(
              child: Text(
                LTen.of(context).cancel,
                style: getDialogTextStyle(isDarkModeOn(context)),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          FlatButton(
            child: Text(
              LTen.of(context).accept,
              style: getDialogTextStyle(isDarkModeOn(context)),
            ), // TODO Translate
            onPressed: () {
              // TODO Validate input? Or auto validate input?
              // TODO Only pop on success!

              var value = validateInput();
              _enterPINKey.currentState.validate();

              print('isValid $value');

              if (value) Navigator.of(context).pop(value);
            },
          )
        ],
      ),
    );
  }
}

Future<void> validatePIN(
    {VoidCallback success,
    VoidCallback fail,
    BuildContext context,
    bool allowCancel = false}) async {
  ArgumentError.checkNotNull(context, '[context] must not be null!');
  ArgumentError.checkNotNull(success, '[sucess] callback must not be null!');

  var pin = await StorageUtil.getPIN();

  bool isValid = await showDialog(
    context: context,
    barrierDismissible: allowCancel, // Cancel dialog when tapping outside.
    builder: (BuildContext context) => CheckPINDialog(
      allowCancel: allowCancel,
      pin: pin,
    ),
  );

  if (isValid == null || !isValid) {
    fail?.call();
  } else {
    success.call();
  }
}
