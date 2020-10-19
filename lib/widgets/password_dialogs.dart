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
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/widgets/custom_texts.dart';

class EnterNewPasswordDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EnterNewPasswordDialogState();
}

class _EnterNewPasswordDialogState extends State<EnterNewPasswordDialog> {
  String _title;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _title = 'Enter new password:'; // TODO Translate
  }

  String _newPassword;
  String _confirmedPassword;

  // fields needed to manage the widget
  final _confirmPasswordKey = GlobalKey<FormFieldState>();
  final _newPasswordKey = GlobalKey<FormFieldState>();

  // used to handle focusing certain input fields
  FocusNode _newPasswordFocus;
  FocusNode _confirmPasswordFocus;

  @override
  void initState() {
    super.initState();

    _newPasswordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();
  }

  @override
  void dispose() {
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }

  Form _buildTextInputForm() {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PasswordInputFormField(
            formKey: _newPasswordKey,
            focusNode: _newPasswordFocus,
            onFieldSubmitted: (value) => this.setState(() {
              _confirmPasswordFocus.requestFocus();
            }),
            onChanged: (value) => this.setState(() {
              _newPassword = value;
            }),
            labelText: 'Password', // TODO Translate
          ),
          Padding(
            padding: EdgeInsets.all(5),
          ),
          PasswordInputFormField(
            formKey: _confirmPasswordKey,
            focusNode: _confirmPasswordFocus,
            onChanged: (value) => this.setState(() {
              _confirmedPassword = value;
            }),
            labelText: 'Confirm',
            // TODO Translate
            validator: (value) {
              if (value != _newPassword) {
                return 'The Passwords are not equal'; // TODO Translate
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  bool validatePassword(String password) => password == _newPassword;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        title: Text(_title),
        scrollable: true,

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
              if (_newPasswordKey.currentState.validate()) {
                if (_confirmPasswordKey.currentState.validate()) {
                  if (_newPassword == _confirmedPassword &&
                      _newPassword.isNotEmpty) {
                    Navigator.of(context).pop(_newPassword);
                  }
                } else {
                  _confirmPasswordFocus.requestFocus();
                }
              } else {
                _newPasswordFocus.requestFocus();
              }
            },
          )
        ],
      ),
    );
  }
}

class CheckPasswordDialog extends StatefulWidget {
  final allowCancel;
  final password;

  const CheckPasswordDialog({Key key, this.allowCancel, this.password})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CheckPasswordDialogState();
}

class _CheckPasswordDialogState extends State<CheckPasswordDialog> {
  String _title;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _title = 'Enter password to unlock:'; // TODO Translate
  }

  String _currentInput;

  // fields needed to manage the widget
  final _enterPasswordKey = GlobalKey<FormFieldState>();
  bool obscurePassword = true;
  bool obscureConfirm = true;

  // used to handle focusing certain input fields
  FocusNode _enterPasswordFocus;

  @override
  void initState() {
    super.initState();
    _enterPasswordFocus = FocusNode();
  }

  @override
  void dispose() {
    _enterPasswordFocus.dispose();
    super.dispose();
  }

  Form _buildTextInputForm() {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PasswordInputFormField(
            formKey: _enterPasswordKey,
            focusNode: _enterPasswordFocus,
            onChanged: (value) => this.setState(() => _currentInput = value),
            labelText: 'Password',
            // TODO Translate
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
    return _currentInput == widget.password;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => widget.allowCancel,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          title: Text(_title),
          scrollable: true,
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
              ),
              onPressed: () {
                var value = validateInput();
                _enterPasswordKey.currentState.validate();
                if (value) Navigator.of(context).pop(value);
              },
            )
          ],
        ),
      ),
    );
  }
}

Future<void> validatePassword(
    {VoidCallback success,
    VoidCallback fail,
    BuildContext context,
    bool allowCancel = false}) async {
  ArgumentError.checkNotNull(context, '[context] must not be null!');
  ArgumentError.checkNotNull(success, '[success] callback must not be null!');

  String password = await StorageUtil.getPassword();

  bool isValid = await showDialog(
    context: context,
    barrierDismissible: allowCancel, // Cancel dialog when tapping outside.
    builder: (BuildContext context) => CheckPasswordDialog(
      allowCancel: allowCancel,
      password: password,
    ),
  );

  if (isValid == null || !isValid) {
    fail?.call();
  } else {
    success.call();
  }
}
