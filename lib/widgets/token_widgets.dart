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
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

class TokenWidget extends StatefulWidget {
  final Token _token;
  final VoidCallback _onDeleteClicked;

  TokenWidget({Key key, Token token, onDeleteClicked})
      : this._token = token,
        this._onDeleteClicked = onDeleteClicked,
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    if (_token is HOTPToken) {
      return _HotpWidgetState(_token, _onDeleteClicked);
    } else if (_token is TOTPToken) {
      return _TotpWidgetState(_token, _onDeleteClicked);
    } else if (_token is PushToken) {
      return _PushWidgetState(_token, _onDeleteClicked);
    } else {
      throw ArgumentError.value(_token, "token",
          "The token [$_token] is of unknown type and not supported.");
    }
  }
}

abstract class _TokenWidgetState extends State<TokenWidget> {
  final Token _token;
  static final SlidableController _slidableController = SlidableController();
  String _label;

  final VoidCallback _onDeleteClicked;

  _TokenWidgetState(this._token, this._onDeleteClicked) {
    _saveThisToken();
    _label = _token.label;
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(_token.uuid),
      // This is used to only let one Slidable be open at a time.
      controller: _slidableController,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: _buildTile(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: L10n.of(context).delete,
          color: getTonedColor(Colors.red, isDarkModeOn(context)),
          icon: Icons.delete,
          onTap: () => _deleteTokenDialog(),
        ),
        IconSlideAction(
          caption: L10n.of(context).rename,
          color: getTonedColor(Colors.blue, isDarkModeOn(context)),
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
                child: Text(
                  L10n.of(context).cancel,
                  style: getDialogTextStyle(isDarkModeOn(context)),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text(
                  L10n.of(context).rename,
                  style: getDialogTextStyle(isDarkModeOn(context)),
                ),
                onPressed: () {
                  if (_nameInputKey.currentState.validate()) {
                    _renameClicked(_selectedName);
                    Navigator.of(context).pop();
                  }
                },
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
            content: RichText(
              text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: L10n.of(context).areYouSure,
                      style: getDialogTextStyle(isDarkModeOn(context)),
                    ),
                    TextSpan(
                      text: " \'$_label\'?",
                      style: getDialogTextStyle(isDarkModeOn(context)).copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ]),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  L10n.of(context).cancel,
                  style: getDialogTextStyle(isDarkModeOn(context)),
                ),
              ),
              FlatButton(
                onPressed: () {
                  _onDeleteClicked();
                  Navigator.of(context).pop();
                },
                child: Text(
                  L10n.of(context).delete,
                  style: getDialogTextStyle(isDarkModeOn(context)),
                ),
              ),
            ],
          );
        });
  }

  void _saveThisToken() {
    StorageUtil.saveOrReplaceToken(this._token);
  }

  Widget _buildTile();
}

class _PushWidgetState extends _TokenWidgetState {
  _PushWidgetState(Token token, VoidCallback onDeleteClicked)
      : super(token, onDeleteClicked);

  PushToken get _token => super._token as PushToken;

  @override
  void initState() {
    super.initState();

    if (!_token.isRolledOut) {
      _rollOutToken();
    }
  }

  // TODO check expiration date
  void _rollOutToken() async {
    // TODO make all that 2. rollout step stuff

    final keyPair = await generateRSAKeyPair();

    log(
      "Setting private key for token",
      name: "token_widgets.dart",
      error: "Token: $_token, key: ${keyPair.privateKey}",
    );
    _token.privateTokenKey = keyPair.privateKey;

    Response response =
        await doPost(sslVerify: _token.sslVerify, url: _token.url, body: {
      'enrollment_credential': _token.enrollmentCredentials,
      'serial': _token.serial,
      'fbtoken': _token.firebaseToken,
      'pubkey': keyPair.publicKey.toString(),
      // FIXME Convert this to ASN1.
    });

    // TODO do not do the following part if parsing response failed! <---
    RSAPublicKey publicServerKey = parseResponse(response);
    _token.publicServerKey = publicServerKey;

    log('Roll out successful', name: 'token_widgets.dart', error: _token);

    setState(() {
      _token.isRolledOut = true;
      _saveThisToken();
    });
    // TODO up to here <---
  }

  // TODO throw exception if something does not fit
  RSAPublicKey parseResponse(Response response) {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // TODO check response - show error - etc.

    String key = json.decode(response.body)['detail']['public_key'];
    key = key.replaceAll('\n', ''); // TODO replace other line breaks too?
    log("KEY", error: key);
    return convertDERToPublicKey(base64.decode(key));
  }

  void acceptRequest() {
    // TODO write a message
    // TODO check if url is set, then do something. Or request fails with missing url?

    resetRequest();
  }

  void declineRequest() {
    // TODO write a message

    resetRequest();
  }

  void resetRequest() {
    setState(() {
      _token.hasPendingRequest = false;
      _token.requestUri = null;
    });
  }

  @override
  Widget _buildTile() {
    return ClipRect(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              ListTile(
                title: Text(
                  _token.serial,
                  textScaleFactor: 2.3,
                ),
                subtitle: Text(
                  _label,
                  textScaleFactor: 2.0,
                ),
              ),
              Visibility(
                visible: _token.hasPendingRequest,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      // TODO style and translate
                      child: Text("Yes"),
                      onPressed: acceptRequest,
                    ),
                    RaisedButton(
                      // TODO style and translate
                      child: Text("No"),
                      onPressed: declineRequest,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Visibility(
              visible: !_token.isRolledOut,
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Column(
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Text('Rollingn out'),
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }
}

abstract class _OTPTokenWidgetState extends _TokenWidgetState {
  String _otpValue;

  _OTPTokenWidgetState(OTPToken token, VoidCallback onDeleteClicked)
      : _otpValue = calculateOtpValue(token),
        super(token, onDeleteClicked);

  // This gets overridden in subclasses.
  void _updateOtpValue();

  @override
  Widget _buildTile() {
    return InkWell(
      splashColor: Theme.of(context).primaryColor,
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: _otpValue));
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(L10n.of(context).otpValueCopiedMessage(_otpValue)),
        ));
      },
      child: _buildNonClickableTile(),
    );
  }

  Widget _buildNonClickableTile();
}

class _HotpWidgetState extends _OTPTokenWidgetState {
  bool buttonIsDisabled = false;

  _HotpWidgetState(OTPToken token, Function delete) : super(token, delete);

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
  Widget _buildNonClickableTile() {
    return Stack(
      children: <Widget>[
        ListTile(
          title: Text(
            insertCharAt(_otpValue, " ", (_token as OTPToken).digits ~/ 2),
            textScaleFactor: 2.5,
          ),
          subtitle: Text(
            _label,
            textScaleFactor: 2.0,
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
          ),
        ),
      ],
    );
  }
}

class _TotpWidgetState extends _OTPTokenWidgetState
    with SingleTickerProviderStateMixin {
  AnimationController
      controller; // Controller for animating the LinearProgressAnimator

  _TotpWidgetState(OTPToken token, Function delete) : super(token, delete);

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
  Widget _buildNonClickableTile() {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            insertCharAt(_otpValue, " ", (_token as OTPToken).digits ~/ 2),
            textScaleFactor: 2.5,
          ),
          subtitle: Text(
            _label,
            textScaleFactor: 2.0,
          ),
        ),
        LinearProgressIndicator(
          value: controller.value,
        ),
      ],
    );
  }
}
