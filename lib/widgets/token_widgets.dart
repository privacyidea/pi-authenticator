/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

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
import 'dart:typed_data';
import 'dart:ui';

import 'package:catcher/catcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';
import 'package:http/http.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/error_codes.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/screens/main_screen.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/network_utils.dart';
import 'package:privacyidea_authenticator/utils/parsing_utils.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

import 'custom_texts.dart';

class TokenWidget extends StatefulWidget {
  final Token _token;
  final VoidCallback _onDeleteClicked;

  TokenWidget(Token token, {required onDeleteClicked})
      : this._token = token,
        this._onDeleteClicked = onDeleteClicked,
        super(key: ObjectKey(token));

  @override
  State<StatefulWidget> createState() {
    if (_token is HOTPToken) {
      return _HotpWidgetState(_token as OTPToken);
    } else if (_token is TOTPToken) {
      return _TotpWidgetState(_token as OTPToken);
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

  _TokenWidgetState(this._token) {
    _saveThisToken();
  }

  List<Widget> _getSubtitle() {
    List<Widget> children = [];
    if (_token.label.isNotEmpty) {
      children.add(Text(
        _token.label,
        style: Theme.of(context).textTheme.headline5,
      ));
    }
    if (_token.issuer.isNotEmpty) {
      children.add(Text(
        _token.issuer,
        style: Theme.of(context)
            .textTheme
            .headline6!
            .copyWith(fontWeight: FontWeight.normal),
      ));
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> secondaryActions = [
      IconSlideAction(
        caption: AppLocalizations.of(context)!.delete,
        color: Colors.red,
        icon: Icons.delete,
        onTap: () => _deleteTokenDialog(),
      ),
      IconSlideAction(
        caption: AppLocalizations.of(context)!.rename,
        color: Colors.blue,
        icon: Icons.edit,
        onTap: () => _renameTokenDialog(),
      ),
    ];

    if (_token.canToggleLock) {
      secondaryActions.add(IconSlideAction(
        caption: _token.isLocked ? "Unlock" : "Lock", // TODO Translate
        color: Colors.yellow,
        icon: _token.isLocked ? Icons.lock_open : Icons.lock_outline,
        onTap: () => _changeLockStatus(),
      ));
    }

    return Slidable(
      key: ValueKey(_token.id),
      // This is used to only let one Slidable be open at a time.
      controller: _slidableController,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: _buildTile(),
      secondaryActions: secondaryActions,
    );
  }

  void _changeLockStatus() async {
    if (_token.canToggleLock) {
      log('Changing lock status of token ${_token.label}.',
          name: 'token_widgets.dart');

      if (await _unlock(
          localizedReason:
              AppLocalizations.of(context)!.authenticateToUnLockToken)) {
        _token.isLocked = !_token.isLocked;
        await _saveThisToken();
        setState(() {});
      }
    } else {
      log('Lock status of token ${_token.label} can not be changed!',
          name: 'token_widgets.dart');
    }
  }

  Future<bool> _unlock({required String localizedReason}) async {
    bool didAuthenticate = false;
    LocalAuthentication localAuth = LocalAuthentication();

    if (!(await localAuth.isDeviceSupported())) {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: ListTile(
                title: Center(
                  child: Text(
                    AppLocalizations.of(context)!.authNotSupportedTitle,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                leading: Icon(Icons.lock),
                trailing: Icon(Icons.lock),
              ),
              content: Text(AppLocalizations.of(context)!.authNotSupportedBody),
            );
          });
      return didAuthenticate;
    }

    AndroidAuthMessages androidAuthStrings = AndroidAuthMessages(
      biometricRequiredTitle:
          AppLocalizations.of(context)!.biometricRequiredTitle,
      biometricHint: AppLocalizations.of(context)!.biometricHint,
      biometricNotRecognized:
          AppLocalizations.of(context)!.biometricNotRecognized,
      biometricSuccess: AppLocalizations.of(context)!.biometricSuccess,
      deviceCredentialsRequiredTitle:
          AppLocalizations.of(context)!.deviceCredentialsRequiredTitle,
      deviceCredentialsSetupDescription:
          AppLocalizations.of(context)!.deviceCredentialsSetupDescription,
      signInTitle: AppLocalizations.of(context)!.signInTitle,
      goToSettingsButton: AppLocalizations.of(context)!.goToSettingsButton,
      goToSettingsDescription:
          AppLocalizations.of(context)!.goToSettingsDescription,
      cancelButton: AppLocalizations.of(context)!.cancel,
    );

    IOSAuthMessages iOSAuthStrings = IOSAuthMessages(
      lockOut: AppLocalizations.of(context)!.lockOut,
      goToSettingsButton: AppLocalizations.of(context)!.goToSettingsButton,
      goToSettingsDescription:
          AppLocalizations.of(context)!.goToSettingsDescription,
      cancelButton: AppLocalizations.of(context)!.cancel,
    );

    try {
      didAuthenticate = await localAuth.authenticate(
        localizedReason: localizedReason,
        androidAuthStrings: androidAuthStrings,
        iOSAuthStrings: iOSAuthStrings,
      );
    } on PlatformException catch (error, stacktrace) {
      log('Error: ${error.code}', name: 'token_widgets.dart');
      switch (error.code) {
        case notAvailable:
        case passcodeNotSet:
        case permanentlyLockedOut:
        case lockedOut:
          break;
        case otherOperatingSystem:
        case notEnrolled:
        // Should fall back to pin itself
        default:
          Catcher.reportCheckedError(error, stacktrace);
      }
    }
    return didAuthenticate;
  }

  void _renameTokenDialog() {
    final _nameInputKey = GlobalKey<FormFieldState>();
    String _selectedName = _token.label;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.renameToken),
            content: TextFormField(
              autofocus: true,
              initialValue: _selectedName,
              key: _nameInputKey,
              onChanged: (value) {
                if (mounted) {
                  setState(() => _selectedName = value);
                }
              },
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.name),
              validator: (value) {
                if (value!.isEmpty) {
                  return AppLocalizations.of(context)!.name;
                }
                return null;
              },
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: Theme.of(context).textTheme.headline6,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.rename,
                  style: Theme.of(context).textTheme.headline6,
                ),
                onPressed: () {
                  if (_nameInputKey.currentState!.validate()) {
                    _renameClicked(_selectedName);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
  }

  void _renameClicked(String newLabel) async {
    _token.label = newLabel;
    await _saveThisToken();
    log(
      "Renamed token:",
      name: "token_widgets.dart",
      error: "\"${_token.label}\" changed to \"$newLabel\"",
    );

    if (mounted) {
      setState(() {});
    }
  }

  void _deleteTokenDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDeletion),
            content: Text(
              AppLocalizations.of(context)!.confirmDeletionOf(_token.label),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              TextButton(
                onPressed: () {
                  _onDeleteClicked();
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizations.of(context)!.delete,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ],
          );
        });
  }

  // Allows overriding the callback.
  void _onDeleteClicked() => widget._onDeleteClicked();

  Future<void> _saveThisToken() async {
    return StorageUtil.saveOrReplaceToken(this._token);
  }

  Widget _buildTile();

  void _showMessage(String message, int seconds) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: Duration(seconds: seconds)));
  }
}

class _PushWidgetState extends _TokenWidgetState with LifecycleMixin {
  _PushWidgetState(Token token) : super(token);

  PushToken get _token => super._token as PushToken;

  bool _rollOutFailed = false;
  bool _acceptFailed = false;

  bool _retryButtonIsEnabled = true;
  bool _acceptButtonIsEnabled = true;

  late Timer _deleteTimer; // Timer that deletes expired requests periodically.

  @override
  void _onDeleteClicked() {
    // Delete all push notifications for a when the token is deleted.
    _token.pushRequests.forEach(
        (element) => flutterLocalNotificationsPlugin.cancel(element.id));

    super._onDeleteClicked();
  }

  @override
  void initState() {
    super.initState();

    // Delete expired push requests periodically.
    _deleteTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (_token.pushRequests.isNotEmpty) {
        _deleteExpiredRequests(_token);
        _saveThisToken();

        if (mounted) {
          setState(() {}); // Update ui
        }
      }
    });

    // Delete expired tokens, because the timer may not run the function
    // immediately.
    _deleteExpiredRequests(_token);
  }

  @override
  void afterFirstRender() {
    if (!_token.isRolledOut) {
      _rollOutToken();
    }
  }

  @override
  void onPause() {}

  @override
  void onResume() {
    _checkForModelUpdate();
  }

  void _checkForModelUpdate() async {
    PushToken? t = (await StorageUtil.loadToken(_token.id)) as PushToken?;

    // TODO Maybe we should simply reload all tokens on resume?
    // This throws errors because the token [t] is null, why?
    // The error does not seem to break anything
    // It indicates that this method is executed after the token was removed.
    if (t == null) return;

    log(
        "Push token may have received a request while app was "
        "in background. Updating UI.",
        name: "token_widgets.dart");

    _deleteExpiredRequests(t);
    _token = t;
    await _saveThisToken();

    if (mounted) {
      setState(() {});
    }
  }

  void _deleteExpiredRequests(PushToken t) {
    var f = (PushRequest r) => DateTime.now().isAfter(r.expirationDate);

    // Remove requests from queue and remove their notifications.
    t.pushRequests
        .where(f)
        .forEach((r) => flutterLocalNotificationsPlugin.cancel(r.id));
    t.pushRequests.removeWhere(f);
  }

  @override
  void dispose() {
    _deleteTimer.cancel();
    super.dispose();
  }

  void _rollOutToken() async {
    if (mounted) {
      setState(() => _rollOutFailed = false);
    }

    if (Platform.isIOS) {
      await dummyRequest(url: _token.url!, sslVerify: _token.sslVerify!);
    }

    if (_token.privateTokenKey == null) {
      final keyPair = await generateRSAKeyPair();

      log(
        "Setting private key for token",
        name: "token_widgets.dart",
        error: "Token: $_token, key: ${keyPair.privateKey}",
      );
      _token
        ..setPrivateTokenKey(keyPair.privateKey)
        ..setPublicTokenKey(keyPair.publicKey);
      await _saveThisToken();
    }

    try {
      // TODO What to do with poll only tokens if google-services is used?
      Response response =
          await doPost(sslVerify: _token.sslVerify!, url: _token.url!, body: {
        'enrollment_credential': _token.enrollmentCredentials,
        'serial': _token.serial,
        'fbtoken': await PushProvider.getFBToken(),
        'pubkey': serializeRSAPublicKeyPKCS8(_token.getPublicTokenKey()!),
      });

      if (response.statusCode == 200) {
        RSAPublicKey publicServerKey = await _parseRollOutResponse(response);
        _token.setPublicServerKey(publicServerKey);

        log('Roll out successful', name: 'token_widgets.dart', error: _token);

        _token.isRolledOut = true;
        await _saveThisToken();
        if (mounted) {
          setState(() => {}); // Update ui
        }
      } else {
        log("Post request on roll out failed.",
            name: "token_widgets.dart",
            error: "Token: $_token, Status code: ${response.statusCode},"
                " Body: ${response.body}");

        if (mounted) {
          setState(() => _rollOutFailed = true);
        }

        _showMessage(
            AppLocalizations.of(context)!
                .errorRollOutFailed(_token.label, response.statusCode),
            3);
      }
    } on PlatformException catch (e, s) {
      log("Roll out push token [$_token] failed.",
          name: "token_widgets.dart", error: e);

      if (mounted) {
        setState(() => _rollOutFailed = true);
      }

      if (e.code == FIREBASE_TOKEN_ERROR_CODE) {
        _showMessage(
            AppLocalizations.of(context)!.errorRollOutNoNetworkConnection, 3);
      } else {
        Catcher.reportCheckedError(e, s);
      }
    } on SocketException catch (e) {
      log("Roll out push token [$_token] failed.",
          name: "token_widgets.dart", error: e);

      if (mounted) {
        setState(() => _rollOutFailed = true);
      }

      _showMessage(
          AppLocalizations.of(context)!.errorRollOutNoNetworkConnection, 3);
    } on Exception catch (e, stack) {
      log("Roll out push token [$_token] failed.",
          name: "token_widgets.dart", error: e);

      if (mounted) {
        setState(() => _rollOutFailed = true);
      }

//      _showMessage(AppLocalizations.of(context).errorRollOutUnknownError(e), 5);
      Catcher.reportCheckedError(e, stack);
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
    String msg = '${pushRequest.nonce}|${_token.serial}';
    String signature = _token.privateTokenKey == null
        ? await Legacy.sign(_token.serial, msg)
        : createBase32Signature(
            _token.getPrivateTokenKey()!, utf8.encode(msg) as Uint8List);

    //    POST https://privacyideaserver/validate/check
    //    nonce=<nonce_from_request>
    //    serial=<serial>
    //    signature=<signature>
    Map<String, String> body = {
      'nonce': pushRequest.nonce,
      'serial': _token.serial,
      'signature': signature,
    };

    try {
      Response response = await doPost(
          sslVerify: pushRequest.sslVerify, url: pushRequest.uri, body: body);

      if (response.statusCode == 200) {
        _showMessage(
            AppLocalizations.of(context)!
                .acceptPushAuthRequestFor(_token.label),
            2);
        removeCurrentRequest();
      } else {
        log("Accepting push auth request failed.",
            name: "token_widgets.dart",
            error: "Token: $_token, Status code: ${response.statusCode}, "
                "Body: ${response.body}");

        if (mounted) {
          setState(() => _acceptFailed = true);
        }

        _showMessage(
            AppLocalizations.of(context)!.errorPushAuthRequestFailedFor(
                _token.label, response.statusCode),
            3);
      }
    } on SocketException catch (e) {
      log("Accept push auth request for [$_token] failed.",
          name: "token_widgets.dart", error: e);

      if (mounted) {
        setState(() => _acceptFailed = true);
      }

      _showMessage(
          AppLocalizations.of(context)!
              .errorAuthenticationNotPossibleWithoutNetworkAccess,
          3);
    } catch (e) {
      log("Accept push auth request for [$_token] failed.",
          name: "token_widgets.dart", error: e);

      if (mounted) {
        setState(() => _acceptFailed = true);
      }

      _showMessage(
          AppLocalizations.of(context)!
              .errorAuthenticationFailedUnknownError(e),
          5);
    }
  }

  void declineRequest() async {
    _showMessage(
        AppLocalizations.of(context)!.decliningPushAuthRequestFor(_token.label),
        2);
    removeCurrentRequest();
  }

  /// Reset the token status after push auth request was handled by the user.
  void removeCurrentRequest() async {
    PushRequest request = _token.pushRequests.pop();

    flutterLocalNotificationsPlugin.cancel(request.id);
    await _saveThisToken();

    if (mounted) {
      setState(() => _acceptFailed = false);
    }
  }

  void _disableRetryButtonForSomeTime() {
    if (mounted) {
      setState(() => _retryButtonIsEnabled = false);
    }

    Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _retryButtonIsEnabled = true);
      }
    });
  }

  void _disableAcceptButtonForSomeTime() {
    if (mounted) {
      setState(() => _acceptButtonIsEnabled = false);
    }

    Timer(Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _acceptButtonIsEnabled = true);
      }
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
                  style: Theme.of(context).textTheme.headline4,
                ),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _getSubtitle(),
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
                        ElevatedButton(
                          child: _acceptFailed
                              ? Row(
                                  children: <Widget>[
                                    Text(
                                      AppLocalizations.of(context)!.retry,
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                    Icon(Icons.replay),
                                  ],
                                )
                              : Row(
                                  children: <Widget>[
                                    Text(
                                      AppLocalizations.of(context)!.accept,
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                    Icon(Icons.check),
                                  ],
                                ),
                          onPressed: _acceptButtonIsEnabled
                              ? () async {
                                  if (await _unlock(
                                      localizedReason:
                                          AppLocalizations.of(context)!
                                              .authenticateToAcceptPush)) {
                                    acceptRequest();
                                  }
                                  _disableAcceptButtonForSomeTime();
                                }
                              : null,
                        ),
                        ElevatedButton(
                          child: Row(
                            children: <Widget>[
                              Text(
                                AppLocalizations.of(context)!.decline,
                                style: Theme.of(context).textTheme.headline6,
                              ),
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
                    ElevatedButton(
                      child: Text(
                        AppLocalizations.of(context)!.retryRollOut,
                        style: Theme.of(context).textTheme.headline6,
                      ),
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
                    Text(AppLocalizations.of(context)!.rollingOut),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

abstract class _OTPTokenWidgetState extends _TokenWidgetState {
  String _otpValue;
  final HideableTextController _hideableController = HideableTextController();

  @override
  void dispose() {
    _hideableController.close();
    super.dispose();
  }

  _OTPTokenWidgetState(OTPToken token)
      : _otpValue = calculateOtpValue(token),
        super(token);

  // ignore: UNUSED_ELEMENT
  void _updateOtpValue();

  @override
  Widget _buildTile() {
    return InkWell(
      splashColor: Theme.of(context).primaryColor,
      onTap: () async {
        if (_token.isLocked &&
            await _unlock(
                localizedReason:
                    AppLocalizations.of(context)!.authenticateToShowOtp)) {
          _hideableController.tap();
        }
      },
      onLongPress: _token.isLocked
          ? null
          : () {
              Clipboard.setData(ClipboardData(text: _otpValue));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context)!
                    .otpValueCopiedMessage(_otpValue)),
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
    _token.incrementCounter();
    _saveThisToken(); // When the app reloads the counter should not be reset.

    if (mounted) {
      setState(() {
        _otpValue = calculateOtpValue(_token);
        // Disable the button for 1 s.
        buttonIsDisabled = true;
      });
    }

    Timer(Duration(seconds: 1), () {
      if (mounted) {
        setState(() => buttonIsDisabled = false);
      }
    });
  }

  @override
  Widget _buildNonClickableTile() {
    return Stack(
      children: <Widget>[
        ListTile(
          title: HideableText(
            controller: _hideableController,
            text: insertCharAt(_otpValue, " ", _token.digits ~/ 2),
            textScaleFactor: 2.0,
            enabled: _token.isLocked,
            hideDuration: Duration(seconds: 6),
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _getSubtitle(),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: ElevatedButton(
              onPressed: buttonIsDisabled ? null : () => _updateOtpValue(),
              child: Text(
                AppLocalizations.of(context)!.next,
                style: Theme.of(context).textTheme.headline6,
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
  late AnimationController
      _controller; // Controller for animating the LinearProgressAnimator

  TOTPToken get _token => super._token as TOTPToken;

  _TotpWidgetState(OTPToken token) : super(token);

  @override
  void _updateOtpValue() {
    if (mounted) {
      setState(() => _otpValue = calculateOtpValue(_token));
    }
  }

  /// Calculate the progress of the LinearProgressIndicator depending on the
  /// current time. The Indicator takes values in [0.0, 1.0].
  double _getCurrentProgress() {
    int unixTime = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

    return (unixTime % (_token.period)) * (1 / _token.period);
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: _token.period),
      // Animate the progress for the duration of the tokens period.
      vsync: this,
    )
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })
      ..addStatusListener((status) {
        // Add listener to restart the animation after the period, also updates the otp value.
        if (status == AnimationStatus.completed) {
          _controller.forward(from: _getCurrentProgress());
          _updateOtpValue();
        }
      })
      ..forward(from: _getCurrentProgress()); // Start the animation.
  }

  @override
  void onPause() {}

  @override
  void onResume() {
    _updateOtpValue();
    _controller.forward(from: _getCurrentProgress());
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller to prevent memory leak.
    super.dispose();
  }

  @override
  Widget _buildNonClickableTile() {
    return Column(
      children: <Widget>[
        ListTile(
          title: HideableText(
            controller: _hideableController,
            text: insertCharAt(_otpValue, " ", _token.digits ~/ 2),
            textScaleFactor: 2.0,
            enabled: _token.isLocked,
            hideDuration: Duration(seconds: 6),
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _getSubtitle(),
          ),
        ),
        LinearProgressIndicator(
          value: _controller.value,
        ),
      ],
    );
  }
}
