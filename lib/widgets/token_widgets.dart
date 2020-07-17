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
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';
import 'package:http/http.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/model/firebase_config.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/screens/main_screen.dart';
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:privacyidea_authenticator/utils/parsing_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/widgets/custom_texts.dart';

typedef GetFBTokenCallback = Future<String> Function(FirebaseConfig);

class TokenWidget extends StatefulWidget {
  final Token _token;
  final VoidCallback _onDeleteClicked;
  final GetFBTokenCallback _getFirebaseToken;

  TokenWidget(Token token, {onDeleteClicked, getFirebaseToken})
      : this._token = token,
        this._onDeleteClicked = onDeleteClicked,
        this._getFirebaseToken = getFirebaseToken,
        super(key: ObjectKey(token));

  @override
  State<StatefulWidget> createState() {
    if (_token is HOTPToken) {
      return _HotpWidgetState(_token);
    } else if (_token is TOTPToken) {
      return _TotpWidgetState(_token);
    } else if (_token is PushToken) {
      return _PushWidgetState(_token);
    } else {
      throw ArgumentError.value(_token, "token",
          "The token [$_token] is of unknown type and not supported.");
    }
  }
}

abstract class _TokenWidgetState extends State<TokenWidget> {
  Token _token;
  static final SlidableController _slidableController = SlidableController();
  String _label;

  _TokenWidgetState(this._token) {
    _saveThisToken();
    _label = _token.label;
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(_token.id),
      // This is used to only let one Slidable be open at a time.
      controller: _slidableController,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: _buildTile(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: Localization.of(context).delete,
          color: getTonedColor(Colors.red, isDarkModeOn(context)),
          icon: Icons.delete,
          onTap: () => _deleteTokenDialog(),
        ),
        IconSlideAction(
          caption: Localization.of(context).rename,
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
            title: Text(Localization.of(context).renameDialogTitle),
            content: TextFormField(
              autofocus: true,
              initialValue: _label,
              key: _nameInputKey,
              onChanged: (value) => this.setState(() => _selectedName = value),
              decoration:
                  InputDecoration(labelText: Localization.of(context).name),
              validator: (value) {
                if (value.isEmpty) {
                  return Localization.of(context).name;
                }
                return null;
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  Localization.of(context).cancel,
                  style: getDialogTextStyle(isDarkModeOn(context)),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text(
                  Localization.of(context).rename,
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
            title: Text(Localization.of(context).deleteDialogTitle),
            content: RichText(
              text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: Localization.of(context).areYouSure,
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
                  Localization.of(context).cancel,
                  style: getDialogTextStyle(isDarkModeOn(context)),
                ),
              ),
              FlatButton(
                onPressed: () {
                  widget._onDeleteClicked();
                  Navigator.of(context).pop();
                },
                child: Text(
                  Localization.of(context).delete,
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

class _PushWidgetState extends _TokenWidgetState with LifecycleMixin {
  _PushWidgetState(Token token) : super(token);

  PushToken get _token => super._token as PushToken;

  bool _rollOutFailed = false;
  bool _retryButtonIsEnabled = true;
  bool _acceptButtonIsEnabled = true;
  bool _acceptFailed = false;

  Timer _deleteTimer; // Timer that deletes expired requests periodically.

  @override
  void onPause() {
    // Nothing to right now
  }

  @override
  void onResume() async {
    PushToken t = await StorageUtil.loadToken(_token.id);

    log(
        "Push token may have received a request while app was "
        "in background. Updating UI.",
        name: "token_widgets.dart");

    // TODO Check this behaviour!
    if (t.pushRequests.isNotEmpty) {
      setState(() {
        _token = t;
        _saveThisToken();
      });
    }
  }

  @override
  void afterFirstRender() {
    // super.afterFirstRender();
    if (!_token.isRolledOut) _rollOutToken();
  }

  @override
  void initState() {
    super.initState();

//    if (!_token.isRolledOut) {
//      SchedulerBinding.instance.addPostFrameCallback((_) => _rollOutToken());
//    }
//
//    // Push requests that were received in background can only be saved to
//    // the storage, the ui must be updated here.
//    // ignore: missing_return
//    SystemChannels.lifecycle.setMessageHandler((msg) async {
//      PushToken t = await StorageUtil.loadToken(_token.id);
//
//      // FIXME This throws errors because the token [t] is null, why?
//
//      if (msg == "AppLifecycleState.resumed" && t.pushRequests.isNotEmpty) {
//        log(
//            "Push token may have received a request while app was "
//            "in background. Updating UI.",
//            name: "token_widgets.dart");
//
//        setState(() {
//          _token = t;
//          _saveThisToken();
//        });
//      }
//    });

    // Delete expired push requests periodically.
    _deleteTimer = Timer.periodic(Duration(seconds: 30), (_) {
      // Function determines if a request is expired
      var f = (PushRequest r) => DateTime.now().isAfter(r.expirationDate);

      if (_token.pushRequests != null && _token.pushRequests.isNotEmpty) {
        // Remove requests from queue and remove their notifications.
        _token.pushRequests
            .where(f)
            .forEach((r) => flutterLocalNotificationsPlugin.cancel(r.id));
        _token.pushRequests.removeWhere(f);

        setState(() {
          _saveThisToken();
        });
      }
    });
  }

  @override
  void dispose() {
    // FIXME Delete all pending push requests also, and remove the notifications! --> But why? Is this supposed to be in delete()?
    _deleteTimer.cancel();
    super.dispose();
  }

  void _rollOutToken() async {
    setState(() {
      _rollOutFailed = false;
    });

    if (await StorageUtil.globalFirebaseConfigExists() &&
        await StorageUtil.loadFirebaseConfig(_token) !=
            await StorageUtil.loadGlobalFirebaseConfig()) {
      // The firebase config of this token is different to the existing
      // firebase config in this app.
      log("Token has different firebase config than existing.",
          name: "token_widgets.dart");

      _showMessage(
          Localization.of(context)
              .errorOnlyOneFirebaseProjectIsSupported(_token.label),
          5);

      setState(() {
        _rollOutFailed = true;
      });

      return;
    }

    if (DateTime.now().isAfter(_token.expirationDate)) {
      log("Token is expired, abort rollout and delte it.",
          name: "token_widgets.dart",
          error: "Now: ${DateTime.now()}, Token expires at ${[
            _token.expirationDate
          ]}, Token: $_token");

      setState(() {
        _rollOutFailed = true;
      });

      _showMessage(Localization.of(context).errorTokenExpired(_token.label), 3);
      return;
    }

    if (_token.privateTokenKey == null) {
      final keyPair = await generateRSAKeyPair();

      log(
        "Setting private key for token",
        name: "token_widgets.dart",
        error: "Token: $_token, key: ${keyPair.privateKey}",
      );
      _token.setPrivateTokenKey(keyPair.privateKey);
      _token..setPublicTokenKey(keyPair.publicKey);
      _saveThisToken();
    }

    try {
      Response response =
          await doPost(sslVerify: _token.sslVerify, url: _token.url, body: {
        'enrollment_credential': _token.enrollmentCredentials,
        'serial': _token.serial,
        'fbtoken': await widget
            ._getFirebaseToken(await StorageUtil.loadFirebaseConfig(_token)),
        'pubkey': serializeRSAPublicKeyPKCS8(_token.getPublicTokenKey()),
      });

      if (response.statusCode == 200) {
        RSAPublicKey publicServerKey = await _parseRollOutResponse(response);
        _token.setPublicServerKey(publicServerKey);

        log('Roll out successful', name: 'token_widgets.dart', error: _token);

        setState(() {
          _token.isRolledOut = true;
          _saveThisToken();
        });
      } else {
        log("Post request on roll out failed.",
            name: "token_widgets.dart",
            error: "Token: $_token, Status code: ${response.statusCode},"
                " Body: ${response.body}");

        setState(() {
          _rollOutFailed = true;
        });

        _showMessage(
            Localization.of(context)
                .errorRollOutFailed(_token.label, response.statusCode),
            3);
      }
    } on SocketException catch (e) {
      log("Roll out push token [$_token] failed.",
          name: "token_widgets.dart", error: e);

      setState(() {
        _rollOutFailed = true;
      });

      _showMessage(Localization.of(context).errorRollOutNoNetworkConnection, 3);
    } on Exception catch (e) {
      log("Roll out push token [$_token] failed.",
          name: "token_widgets.dart", error: e);

      setState(() {
        _rollOutFailed = true;
      });

      _showMessage(Localization.of(context).errorRollOutUnknownError(e), 5);
    }
  }

  Future<RSAPublicKey> _parseRollOutResponse(Response response) async {
    log("Parsing rollout response, try to extract public_key.",
        name: "token_widgets.dart", error: response.body);

    try {
      String key = json.decode(response.body)['detail']['public_key'];
      key = key.replaceAll('\n', '');

      log("Extracting public key was successful.",
          name: "token_widgets.dart", error: key);

      return deserializeRSAPublicKeyPKCS1(key);
    } on FormatException catch (e) {
      throw FormatException(
          "Response body does not contain RSA public key.", e);
    }
  }

  void acceptRequest() async {
    var pushRequest = _token.pushRequests.peek();

    log('Push auth request accepted, sending message',
        name: 'token_widgets.dart', error: 'Url: ${pushRequest.uri}');

    // signature ::=  {nonce}|{serial}

    //    POST https://privacyideaserver/validate/check
    //    nonce=<nonce_from_request>
    //    serial=<serial>
    //    signature=<signature>
    Map<String, String> body = {
      'nonce': pushRequest.nonce,
      'serial': _token.serial,
      'signature': createBase32Signature(_token.getPrivateTokenKey(),
          utf8.encode('${pushRequest.nonce}|${_token.serial}')),
    };

    try {
      Response response = await doPost(
          sslVerify: pushRequest.sslVerify, url: pushRequest.uri, body: body);

      if (response.statusCode == 200) {
        _showMessage(
            Localization.of(context).acceptPushAuthRequestFor(_token.label), 2);
        removeRequest(_token.pushRequests.pop());
      } else {
        log("Accepting push auth request failed.",
            name: "token_widgets.dart",
            error: "Token: $_token, Status code: ${response.statusCode}, "
                "Body: ${response.body}");
        setState(() => _acceptFailed = true);

        _showMessage(
            Localization.of(context).errorPushAuthRequestFailedFor(
                _token.label, response.statusCode),
            3);
      }
    } on SocketException catch (e) {
      log("Accept push auth request for [$_token] failed.",
          name: "token_widgets.dart", error: e);
      setState(() => _acceptFailed = true);

      _showMessage(
          Localization.of(context)
              .errorAuthenticationNotPossibleWithoutNetworkAccess,
          3);
    } on Exception catch (e) {
      log("Accept push auth request for [$_token] failed.",
          name: "token_widgets.dart", error: e);
      setState(() => _acceptFailed = true);

      _showMessage(
          Localization.of(context).errorAuthenticationFailedUnknownError(e), 5);
    }
  }

  void declineRequest() async {
    _showMessage(
        Localization.of(context).decliningPushAuthRequestFor(_token.label), 2);
    removeRequest(_token.pushRequests.pop());
  }

  /// Reset the token status after push auth request was handled by the user.
  void removeRequest(PushRequest request) {
    setState(() {
      _acceptFailed = false;
      flutterLocalNotificationsPlugin.cancel(request.id);
      _saveThisToken();
    });
  }

  void _disableRetryButtonForSomeTime() {
    setState(() => _retryButtonIsEnabled = false);
    Timer(Duration(seconds: 3),
        () => setState(() => _retryButtonIsEnabled = true));
  }

  void _disableAcceptButtonForSomeTime() {
    setState(() => _acceptButtonIsEnabled = false);
    Timer(Duration(seconds: 1),
        () => setState(() => _acceptButtonIsEnabled = true));
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
//                  '$_label, ${_token.pushRequests.length}',
                  textScaleFactor: 2.0,
                ),
                trailing: Icon(Icons.message),
              ),
              Visibility(
                // Accept / decline push auth request.
                visible: _token.pushRequests.isNotEmpty,
                child: Column(
                  children: <Widget>[
                    _token.pushRequests.isNotEmpty
                        ? Text(_token.pushRequests
                            .peek()
                            .title) // TODO Style this?
                        : Placeholder(),
                    _token.pushRequests.isNotEmpty
                        ? Text(_token.pushRequests
                            .peek()
                            .question) // TODO Style this?
                        : Placeholder(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        RaisedButton(
                          child: _acceptFailed
                              ? Row(
                                  children: <Widget>[
                                    Text(Localization.of(context).retry),
                                    Icon(Icons.replay),
                                  ],
                                )
                              : Row(
                                  children: <Widget>[
                                    Text(Localization.of(context).accept),
                                    Icon(Icons.check),
                                  ],
                                ),
                          onPressed: _acceptButtonIsEnabled
                              ? () {
                                  acceptRequest();
                                  _disableAcceptButtonForSomeTime();
                                }
                              : null,
                        ),
                        RaisedButton(
                          child: Row(
                            children: <Widget>[
                              Text(Localization.of(context).decline),
                              Icon(Icons.clear),
                            ],
                          ),
                          onPressed: _acceptButtonIsEnabled
                              ? () {
                                  declineRequest();
                                  _disableAcceptButtonForSomeTime();
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Visibility(
                // Retry roll out.
                visible: _rollOutFailed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      child: Text(Localization.of(context).retryRollOut),
                      onPressed: _retryButtonIsEnabled
                          ? () {
                              _rollOutToken();
                              _disableRetryButtonForSomeTime();
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Show that the token is rolling out.
          Visibility(
            visible: !_token.isRolledOut && !_rollOutFailed,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: ListTile(
                title: Column(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text(Localization.of(context).rollingOut),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, int seconds) {
    ArgumentError.checkNotNull(message, "message");
    ArgumentError.checkNotNull(seconds, "seconds");

    Scaffold.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: Duration(seconds: seconds)));
  }
}

abstract class _OTPTokenWidgetState extends _TokenWidgetState {
  String _otpValue;

  _OTPTokenWidgetState(OTPToken token)
      : _otpValue = calculateOtpValue(token),
        super(token);

  // This gets overridden in subclasses.
  void _updateOtpValue();

  @override
  Widget _buildTile() {
    return InkWell(
      splashColor: Theme.of(context).primaryColor,
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: _otpValue));
        Scaffold.of(context).showSnackBar(SnackBar(
          content:
              Text(Localization.of(context).otpValueCopiedMessage(_otpValue)),
        ));
      },
      child: _buildNonClickableTile(),
    );
  }

  Widget _buildNonClickableTile();
}

class _HotpWidgetState extends _OTPTokenWidgetState {
  bool buttonIsDisabled = false;

  HOTPToken get _token => super._token as HOTPToken;

  _HotpWidgetState(OTPToken token) : super(token);

  @override
  void _updateOtpValue() {
    setState(() {
      _token.incrementCounter();
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
          title: HideableText(
            text: insertCharAt(_otpValue, " ", _token.digits ~/ 2),
            hiddenText:
                insertCharAt("*" * _token.digits, " ", _token.digits ~/ 2),
            textScaleFactor: 2.2,
            hideDuration: Duration(seconds: 4),
            textStyle: TextStyle(fontFamily: "monospace"),
            enabled: true, // TODO Change from settings
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
                Localization.of(context).next,
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
    with SingleTickerProviderStateMixin, LifecycleMixin {
  AnimationController
      controller; // Controller for animating the LinearProgressAnimator

  TOTPToken get _token => super._token as TOTPToken;

  _TotpWidgetState(OTPToken token) : super(token);

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
      duration: Duration(seconds: _token.period),
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
  }

  @override
  void onPause() {
// Nothing to do right now
  }

  @override
  void onResume() {
    _updateOtpValue();
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
          title: HideableText(
            text: insertCharAt(_otpValue, " ", _token.digits ~/ 2),
            hiddenText:
                insertCharAt("*" * _token.digits, " ", _token.digits ~/ 2),
            textScaleFactor: 2.2,
            hideDuration: Duration(seconds: 4),
            textStyle: TextStyle(fontFamily: "monospace"),
            enabled: true, // TODO Change from settings
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
