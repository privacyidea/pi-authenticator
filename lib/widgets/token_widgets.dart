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

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

class TokenWidget extends StatefulWidget {
  final Token _token;
  final VoidCallback _onDeleteClicked;

  TokenWidget({Key key, token, onDeleteClicked})
      : this._token = token,
        this._onDeleteClicked = onDeleteClicked,
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    if (_token is HOTPToken) {
      return _HotpWidgetState(_token, _onDeleteClicked);
    } else if (_token is TOTPToken) {
      return _TotpWidgetState(_token, _onDeleteClicked);
    } else {
      throw ArgumentError.value(_token, "token",
          "The token [$_token] is of unknown type and not supported.");
    }
  }
}

abstract class _TokenWidgetState extends State<TokenWidget> {
  final Token _token;
  static final SlidableController _slidableController = SlidableController();
  String _otpValue;
  String _label;

  final VoidCallback _onDeleteClicked;

  _TokenWidgetState(this._token, this._onDeleteClicked) {
    _otpValue = calculateOtpValue(_token);
    _saveThisToken();
    _label = _token.label;
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(_token.serial),
      // This is used to only let one Slidable be open at a time.
      controller: _slidableController,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Colors.white,
        child: _buildTile(),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: L10n.of(context).delete,
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => _deleteTokenDialog(),
        ),
        IconSlideAction(
          caption: L10n.of(context).rename,
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () => _renameTokenDialog(),
        ),
      ],
    );
  }

  void _renameTokenDialog() {
    final _nameInputKey = GlobalKey<FormFieldState>();
    String _selectedName = _label;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(L10n.of(context).renameDialogTitle),
            titleTextStyle: Theme.of(context).textTheme.subhead,
            content: TextFormField(
              autofocus: true,
              initialValue: _label,
              key: _nameInputKey,
              onChanged: (value) => this.setState(() => _selectedName = value),
              decoration: InputDecoration(labelText: L10n.of(context).nameHint),
              validator: (value) {
                if (value.isEmpty) {
                  return L10n.of(context).nameHint;
                }
                return null;
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(L10n.of(context).rename),
                onPressed: () {
                  if (_nameInputKey.currentState.validate()) {
                    _renameClicked(_selectedName);
                    Navigator.of(context).pop();
                  }
                },
              ),
              FlatButton(
                child: Text(L10n.of(context).cancel),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        });
  }

  void _renameClicked(String newLabel) {
    _token.label = newLabel;
    _saveThisToken();
    log(
      "Renamed token:",
      name: "token_widgets.dart",
      error: "\"${_token.label}\" changed to \"$newLabel\"",
    );

    setState(() {
      _label = _token.label;
    });
  }

  void _deleteTokenDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(L10n.of(context).deleteDialogTitle),
            titleTextStyle: Theme.of(context).textTheme.subhead,
            content: RichText(
              text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: L10n.of(context).areYouSure,
                    ),
                    TextSpan(
                        text: " \'$_label\'?",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ))
                  ]),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  _onDeleteClicked();
                  Navigator.of(context).pop();
                },
                child: Text(L10n.of(context).delete),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(L10n.of(context).cancel),
              ),
            ],
          );
        });
  }

  void _saveThisToken() {
    StorageUtil.saveOrReplaceToken(this._token);
  }

  void _updateOtpValue();

  Widget _buildTile();
}

class _HotpWidgetState extends _TokenWidgetState {
  bool buttonIsDisabled = false;

  _HotpWidgetState(Token token, Function delete) : super(token, delete);

  @override
  void _updateOtpValue() {
    setState(() {
      (_token as HOTPToken).incrementCounter();
      _otpValue = calculateOtpValue(_token);
      _saveThisToken(); // When the app reloads the counter should not be reset.

      _disableButtonForSomeTime();
    });
  }

  void _disableButtonForSomeTime() {
    // Disable the button for 1 s.
    buttonIsDisabled = true;
    Timer(Duration(seconds: 1), () => setState(() => buttonIsDisabled = false));
  }

  @override
  Widget _buildTile() {
    return Stack(
      children: <Widget>[
        ListTile(
          title:
//          Center( child:
              Text(
            insertCharAt(_otpValue, " ", _otpValue.length ~/ 2),
            textScaleFactor: 2.5,
          ),
//          ),
          subtitle:
//    Center(child:
              Text(
            _label,
            textScaleFactor: 2.0,
//            ),
          ),
        ),
        Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: RaisedButton(
                onPressed: buttonIsDisabled ? null : () => _updateOtpValue(),
                child: Text(
                  L10n.of(context).next,
                  textScaleFactor: 1.5,
                ),
              ),
            )),
      ],
    );
  }
}

class _TotpWidgetState extends _TokenWidgetState
    with SingleTickerProviderStateMixin {
  AnimationController
      controller; // Controller for animating the LinearProgressAnimator

  _TotpWidgetState(Token token, Function delete) : super(token, delete);

  @override
  void _updateOtpValue() {
    setState(() {
      _otpValue = calculateOtpValue(_token);
    });
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: (_token as TOTPToken).period),
      // Animate the progress for the duration of the tokens period.
      vsync:
          this, // By extending SingleTickerProviderStateMixin we can use this object as vsync, this prevents offscreen animations.
    )
      ..addListener(() {
        // Adding a listener to update the view for the animation steps.
        setState(() => {
              // The state that has changed here is the animation object’s value.
            });
      })
      ..addStatusListener((status) {
        // Add listener to restart the animation after the period, also updates the otp value.
        if (status == AnimationStatus.completed) {
          controller.forward(from: 0.0);
          _updateOtpValue();
        }
      })
      ..forward(); // Start the animation.

    // Update the otp value when the android app resumes, this prevents outdated otp values
    // ignore: missing_return
    SystemChannels.lifecycle.setMessageHandler((msg) {
      log(
        "SystemChannels:",
        name: "totpwidget.dart",
        error: msg,
      );
      if (msg == AppLifecycleState.resumed.toString()) {
        _updateOtpValue();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose(); // Dispose the controller to prevent memory leak.
    super.dispose();
  }

  @override
  Widget _buildTile() {
    return Column(
      children: <Widget>[
        ListTile(
          title:
//          Center(child:
              Text(
            insertCharAt(_otpValue, " ", _otpValue.length ~/ 2),
            textScaleFactor: 2.5,
//            ),
          ),
          subtitle:
//          Center(child:
              Text(
            _label,
            textScaleFactor: 2.0,
//            ),
          ),
        ),
        LinearProgressIndicator(
          value: controller.value,
        ),
      ],
    );
  }
}
