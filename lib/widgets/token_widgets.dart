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

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';
import 'package:http/http.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:local_auth/error_codes.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/appCustomizer.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/network_utils.dart';
import 'package:privacyidea_authenticator/utils/parsing_utils.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

import '../utils/customizations.dart';
import '../utils/logger.dart';
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
      throw ArgumentError.value(_token, 'token', 'The token [$_token] is of unknown type and not supported.');
    }
  }
}

abstract class _TokenWidgetState extends State<TokenWidget> {
  Token _token;

  _TokenWidgetState(this._token) {
    _saveThisToken();
  }

  List<Widget> _getSubtitle() {
    List<Widget> children = [];

    if (_token is PushToken) {
      if (_token.issuer.isNotEmpty) {
        children.add(Text(
          _token.issuer,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.normal),
        ));
      }
      return children;
    }

    if (_token.label.isNotEmpty) {
      children.add(Text(
        _token.label,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.normal),
      ));
    }
    if (_token.issuer.isNotEmpty) {
      children.add(Text(
        _token.issuer,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.normal),
      ));
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions = [
      SlidableAction(
        label: AppLocalizations.of(context)!.delete,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            //? Colors.red.shade400
            //: Colors.red.shade800,
            ? ApplicationCustomizer.deleteColorLight
            : ApplicationCustomizer.deleteColorDark,
        foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
        icon: Icons.delete,
        onPressed: (_) => _deleteTokenDialog(),
      ),
      SlidableAction(
        label: AppLocalizations.of(context)!.rename,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            //? Colors.blue.shade400
            //: Colors.blue.shade800,
            ? ApplicationCustomizer.renameColorLight
            : ApplicationCustomizer.renameColorDark,
        foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
        icon: Icons.edit,
        onPressed: (_) => _renameTokenDialog(),
      ),
    ];

    if ((_token.pin == null || _token.pin == false)) {
      actions.add(SlidableAction(
        label: _token.isLocked ? AppLocalizations.of(context)!.unlock : AppLocalizations.of(context)!.lock,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            //? Colors.yellow.shade400
            //: Colors.yellow.shade800,
            ? ApplicationCustomizer.lockColorLight
            : ApplicationCustomizer.lockColorDark,
        foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
        icon: _token.isLocked ? Icons.lock_open : Icons.lock_outline,
        onPressed: (_) => _falseRelockAndLockStatus(),
      ));
    }

    return Slidable(
      key: ValueKey(_token.id),
      groupTag: 'myTag', // This is used to only let one be open at a time.
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 1,
        children: actions,
      ),
      child: _buildTile(),
    );
  }

  void _falseRelockAndLockStatus() async {
    _changeLockStatus();
    this._token.relock = false;
  }

  void _changeLockStatus() async {
    if (_token.canToggleLock) {
      Logger.info('Changing lock status of token ${_token.label}.', name: 'token_widgets.dart#_changeLockStatus');

      if (await _unlock(localizedReason: AppLocalizations.of(context)!.authenticateToUnLockToken)) {
        _token.isLocked = !_token.isLocked;
        await _saveThisToken();
        setState(() {});
      }
    } else {
      Logger.info('Lock status of token ${_token.label} can not be changed!', name: 'token_widgets.dart#_changeLockStatus');
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
                    style: Theme.of(context).textTheme.titleLarge,
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
      biometricRequiredTitle: AppLocalizations.of(context)!.biometricRequiredTitle,
      biometricHint: AppLocalizations.of(context)!.biometricHint,
      biometricNotRecognized: AppLocalizations.of(context)!.biometricNotRecognized,
      biometricSuccess: AppLocalizations.of(context)!.biometricSuccess,
      deviceCredentialsRequiredTitle: AppLocalizations.of(context)!.deviceCredentialsRequiredTitle,
      deviceCredentialsSetupDescription: AppLocalizations.of(context)!.deviceCredentialsSetupDescription,
      signInTitle: AppLocalizations.of(context)!.signInTitle,
      goToSettingsButton: AppLocalizations.of(context)!.goToSettingsButton,
      goToSettingsDescription: AppLocalizations.of(context)!.goToSettingsDescription,
      cancelButton: AppLocalizations.of(context)!.cancel,
    );

    IOSAuthMessages iOSAuthStrings = IOSAuthMessages(
      lockOut: AppLocalizations.of(context)!.lockOut,
      goToSettingsButton: AppLocalizations.of(context)!.goToSettingsButton,
      goToSettingsDescription: AppLocalizations.of(context)!.goToSettingsDescription,
      cancelButton: AppLocalizations.of(context)!.cancel,
    );

    try {
      didAuthenticate = await localAuth.authenticate(localizedReason: localizedReason, authMessages: [
        androidAuthStrings,
        iOSAuthStrings,
      ]);
    } on PlatformException catch (error) {
      Logger.warning('Error: ${error.code}', name: 'token_widgets.dart#_unlock');
      switch (error.code) {
        //FIXME: Waht are errors and waht are only warnings?
        case notAvailable:
        case passcodeNotSet:
        case permanentlyLockedOut:
        case lockedOut:
          throw error;
        case otherOperatingSystem:
        case notEnrolled:
        // Should fall back to pin itself
        default:
          throw error;
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
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
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
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.rename,
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
    Logger.info(
      'Renamed token:',
      name: 'token_widgets.dart#_renameClicked',
      error: '\'${_token.label}\' changed to \'$newLabel\'',
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
                ),
              ),
              TextButton(
                onPressed: () {
                  _onDeleteClicked();
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizations.of(context)!.delete,
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: Duration(seconds: seconds)));
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
  void onContextReady() {
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

    Logger.info(
        'Push token may have received a request while app was '
        'in background. Updating UI.',
        name: 'token_widgets.dart#_checkForModelUpdate');

    _deleteExpiredRequests(t);
    _token = t;
    await _saveThisToken();

    if (mounted) {
      setState(() {});
    }
  }

  void _deleteExpiredRequests(PushToken t) {
    var f = (PushRequest r) => DateTime.now().isAfter(r.expirationDate);
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

      Logger.info(
        'Setting private key for token',
        name: 'token_widgets.dart#_rollOutToken',
        error: 'Token: $_token, key: ${keyPair.privateKey}',
      );
      _token
        ..setPrivateTokenKey(keyPair.privateKey)
        ..setPublicTokenKey(keyPair.publicKey);
      await _saveThisToken();

      checkNotificationPermission();
    }

    try {
      // TODO What to do with poll only tokens if google-services is used?
      Response response = await postRequest(sslVerify: _token.sslVerify!, url: _token.url!, body: {
        'enrollment_credential': _token.enrollmentCredentials,
        'serial': _token.serial,
        'fbtoken': await PushProvider.getFBToken(),
        'pubkey': serializeRSAPublicKeyPKCS8(_token.getPublicTokenKey()!),
      });

      if (response.statusCode == 200) {
        RSAPublicKey publicServerKey = await _parseRollOutResponse(response);
        _token.setPublicServerKey(publicServerKey);

        Logger.info('Roll out successful', name: 'token_widgets.dart#_rollOutToken', error: _token);

        _token.isRolledOut = true;
        await _saveThisToken();
        if (mounted) {
          setState(() => {}); // Update ui
        }
      } else {
        Logger.warning('Post request on roll out failed.',
            name: 'token_widgets.dart#_rollOutToken',
            error: 'Token: $_token, Status code: ${response.statusCode},'
                ' Body: ${response.body}');

        if (mounted) {
          setState(() => _rollOutFailed = true);
        }

        _showMessage(AppLocalizations.of(context)!.errorRollOutFailed(_token.label, response.statusCode), 3);
      }
    } on PlatformException catch (e) {
      Logger.warning('Roll out push token [$_token] failed.', name: 'token_widgets.dart#_rollOutToken', error: e);

      if (mounted) {
        setState(() => _rollOutFailed = true);
      }

      if (e.code == FIREBASE_TOKEN_ERROR_CODE) {
        _showMessage(AppLocalizations.of(context)?.errorRollOutNoNetworkConnection ?? "No network connection!", 3);
      } else {
        final SnackBar snackBar = SnackBar(content: Text("Token could not be rolled out, try again"));
        snackbarKey.currentState?.showSnackBar(snackBar);
      }
    } on SocketException catch (e) {
      Logger.warning('Roll out push token [$_token] failed.', name: 'token_widgets.dart#_rollOutToken', error: e);

      if (mounted) {
        setState(() => _rollOutFailed = true);
      }

      _showMessage(AppLocalizations.of(context)?.errorRollOutNoNetworkConnection ?? "No network connection!", 3);
    } catch (e) {
      Logger.warning('Roll out push token [$_token] failed.', name: 'token_widgets.dart#_rollOutToken', error: e);

      if (mounted) {
        setState(() => _rollOutFailed = true);
      }
      _showMessage(AppLocalizations.of(context)!.errorRollOutUnknownError(e), 3);
    }
  }

  Future<RSAPublicKey> _parseRollOutResponse(Response response) async {
    Logger.info('Parsing rollout response, try to extract public_key.', name: 'token_widgets.dart#_parseRollOutResponse', error: response.body);

    try {
      String key = json.decode(response.body)['detail']['public_key'];
      key = key.replaceAll('\n', '');

      Logger.info('Extracting public key was successful.', name: 'token_widgets.dart#_parseRollOutResponse', error: key);

      return deserializeRSAPublicKeyPKCS1(key);
    } on FormatException catch (e) {
      throw FormatException('Response body does not contain RSA public key.', e);
    }
  }

  void handlePushRequest(bool accepted) async {
    // Check if PIN/Biometric is required to interact with the token
    if (_token.isLocked) {
      if (await _unlock(localizedReason: AppLocalizations.of(context)!.authenticateToAcceptPush)) {
        if (mounted) {
          setState(() => _acceptButtonIsEnabled = false);
        }
      }
    } else {
      if (mounted) {
        setState(() => _acceptButtonIsEnabled = false);
      }
    }
    _disableAcceptButtonForSomeTime();

    if (accepted) {
      _showMessage(AppLocalizations.of(context)!.acceptPushAuthRequestFor(_token.label), 2);
    } else {
      _showMessage(AppLocalizations.of(context)!.decliningPushAuthRequestFor(_token.label), 2);
    }

    var pushRequest = _token.pushRequests.peek();
    Logger.info('Push auth request accepted=$accepted, sending response to privacyidea',
        name: 'token_widgets.dart#handlePushRequest', error: 'Url: ${pushRequest.uri}');

    // signature ::=  {nonce}|{serial}[|decline]
    String msg = '${pushRequest.nonce}|${_token.serial}';
    if (!accepted) {
      msg += '|decline';
    }
    String? signature = await trySignWithToken(_token, msg, context);
    if (signature == null) {
      return;
    }

    //    POST https://privacyideaserver/validate/check
    //    nonce=<nonce_from_request>
    //    serial=<serial>
    //    signature=<signature>
    //    decline=1 (optional)
    final Map<String, String> body = {
      'nonce': pushRequest.nonce,
      'serial': _token.serial,
      'signature': signature,
    };
    if (!accepted) {
      body["decline"] = "1";
    }

    print("sending push request response...");
    bool success = true;
    try {
      Response response = await postRequest(sslVerify: pushRequest.sslVerify, url: pushRequest.uri, body: body);
      if (response.statusCode == 200) {
        updateTokenStatus();
      } else {
        Logger.warning('Sending push request response failed.',
            name: 'token_widgets.dart#handlePushRequest',
            error: 'Token: $_token, Status code: ${response.statusCode}, '
                'Body: ${response.body}');

        _showMessage(AppLocalizations.of(context)!.errorPushAuthRequestFailedFor(_token.label, response.statusCode), 3);
        success = false;
      }
    } on SocketException catch (e) {
      Logger.warning('Push auth request for [$_token] failed, accept=$accepted.', name: 'token_widgets.dart#handlePushRequest', error: e);

      _showMessage(AppLocalizations.of(context)!.errorAuthenticationNotPossibleWithoutNetworkAccess, 3);
      success = false;
    } catch (e) {
      Logger.warning('Push auth request for [$_token] failed, accept=$accepted.', name: 'token_widgets.dart#handlePushRequest', error: e);

      _showMessage(AppLocalizations.of(context)!.errorAuthenticationFailedUnknownError(e), 5);
      success = false;
    }

    if (!success && mounted) {
      setState(() => _acceptFailed = true);
    }
  }

  /// Reset the token status after push auth request was handled by the user.
  void updateTokenStatus() async {
    PushRequest request = _token.pushRequests.pop();
    await _saveThisToken();

    _token.pushRequests.forEach((r) {
      if (r == request) {
        _token.pushRequests.remove(r);
      }
    });

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
    Image? tokenImage;
    if (_token.tokenImage is String) {
      try {
        tokenImage = Image.network(_token.tokenImage!, errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
          return const Text('Error loading image');
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Unable to retrieve token image from ${_token.tokenImage!}."),
        ));
      }
    }

    return ClipRect(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              ListTile(
                leading: _token.tokenImage != null
                    ? Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: double.infinity,
                        child: Align(
                          alignment: Alignment.center,
                          child: tokenImage,
                        ))
                    : null,
                horizontalTitleGap: 8.0,
                title: Text(
                  _token.label,
                  textScaleFactor: 1.9,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _getSubtitle(),
                ),
                trailing: Container(
                    padding: EdgeInsets.only(right: 36.0, top: 8),
                    child: Icon(
                      Icons.notifications,
                      size: 26,
                    )),
              ),
              Visibility(
                // Accept / decline push auth request.
                visible: _token.pushRequests.isNotEmpty,
                child: Column(
                  children: <Widget>[
                    _token.pushRequests.isNotEmpty
                        ? Text(_token.pushRequests.peek().title) // TODO Style this?
                        : Placeholder(),
                    _token.pushRequests.isNotEmpty
                        ? Text(_token.pushRequests.peek().question) // TODO Style this?
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
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Icon(Icons.replay),
                                  ],
                                )
                              : Row(
                                  children: <Widget>[
                                    Text(
                                      AppLocalizations.of(context)!.accept,
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    Icon(Icons.check),
                                  ],
                                ),
                          onPressed: _acceptButtonIsEnabled
                              ? () async {
                                  handlePushRequest(true);
                                }
                              : null,
                        ),
                        ElevatedButton(
                          child: Row(
                            children: <Widget>[
                              Text(
                                AppLocalizations.of(context)!.decline,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Icon(Icons.clear),
                            ],
                          ),
                          onPressed: _acceptButtonIsEnabled
                              ? () {
                                  handlePushRequest(false);
                                  //declineRequest();
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
                        style: Theme.of(context).textTheme.titleLarge,
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
              Divider(
                thickness: 1.5,
                indent: 8,
                endIndent: 8,
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
  bool _isHidden = true;

  @override
  void initState() {
    super.initState();
    _hideableController.listen((isShown) {
      setState(() {
        _isHidden = !isShown;
      });
    });
  }

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
    return _buildClickableTile();
  }

  Widget _buildClickableTile();
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
  Widget _buildClickableTile() {
    return Column(
      children: [
        ListTile(
          leading: _token.imageUrl != null
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: double.infinity,
                  child: Align(alignment: Alignment.center, child: Image.network(_token.imageUrl!)),
                )
              : null,
          horizontalTitleGap: 8.0,
          title: HideableText(
            key: Key(_token.hashCode.toString()),
            controller: _hideableController,
            text: insertCharAt(_otpValue, ' ', _token.digits ~/ 2),
            textScaleFactor: 1.9,
            enabled: _token.isLocked,
            showDuration: Duration(seconds: 30),
            textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _getSubtitle(),
          ),
          trailing: Container(
              padding: const EdgeInsets.only(right: 24.0),
              child: _token.isLocked && _isHidden
                  ? IconButton(
                      iconSize: 32,
                      onPressed: buttonIsDisabled
                          ? null
                          : () async {
                              if (await _unlock(localizedReason: AppLocalizations.of(context)!.authenticateToShowOtp)) {
                                _hideableController.show();
                              }
                            },
                      icon: Icon(
                        Icons.remove_red_eye_outlined,
                      ),
                    )
                  : IconButton(
                      iconSize: 32,
                      onPressed: buttonIsDisabled ? null : () => _updateOtpValue(),
                      icon: Icon(
                        Icons.replay,
                      ),
                    )),
          onTap: _token.isLocked
              ? () async {
                  if (await _unlock(localizedReason: AppLocalizations.of(context)!.authenticateToShowOtp)) {
                    _hideableController.show();
                  }
                }
              : () {
                  Clipboard.setData(ClipboardData(text: _otpValue));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(context)!.otpValueCopiedMessage(_otpValue)),
                  ));
                },
        ),
        Divider(
          thickness: 1.5,
          indent: 8,
          endIndent: 8,
        )
      ],
    );
  }
}

class _TotpWidgetState extends _OTPTokenWidgetState with SingleTickerProviderStateMixin, LifecycleMixin {
  late AnimationController _controller; // Controller for animating the LinearProgressAnimator
  bool _isHidden = true;

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

    _hideableController.listen((isShown) {
      if (mounted) {
        setState(() {
          _isHidden = !isShown;
        });
      }
    });
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

  int? calculateRemainingTotpDuration() {
    return _token.period - (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) % _token.period;
  }

  double calculateRemainingTotpDurationPercent() {
    return (DateTime.now().toUtc().millisecondsSinceEpoch / 1000) % _token.period / _token.period;
  }

  @override
  Widget _buildClickableTile() {
    return Column(
      children: <Widget>[
        ListTile(
          leading: _token.imageUrl != null
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: double.infinity,
                  child: Align(alignment: Alignment.center, child: Image.network(_token.imageUrl!)),
                )
              : null,
          horizontalTitleGap: 8.0,
          title: HideableText(
            controller: _hideableController,
            text: insertCharAt(_otpValue, ' ', _token.digits ~/ 2),
            textScaleFactor: 2.0,
            enabled: _token.isLocked,
            showDuration: Duration(seconds: 30),
            textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _getSubtitle(),
          ),
          trailing: Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.15,
              height: MediaQuery.of(context).size.width * 0.15,
              child: _token.isLocked && _isHidden
                  ? IconButton(
                      onPressed: () async {
                        if (await _unlock(localizedReason: AppLocalizations.of(context)!.authenticateToShowOtp)) {
                          setState(() {
                            _hideableController.show();
                          });
                        }
                      },
                      icon: Icon(Icons.remove_red_eye_outlined),
                    )
                  : Stack(
                      children: [
                        Center(child: Text('${calculateRemainingTotpDuration()}')),
                        Center(
                          child: CircularProgressIndicator(
                            value: calculateRemainingTotpDurationPercent(),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          onTap: _token.isLocked
              ? () async {
                  if (await _unlock(localizedReason: AppLocalizations.of(context)!.authenticateToShowOtp)) {
                    setState(() {
                      _hideableController.show();
                    });
                  }
                }
              : () {
                  Clipboard.setData(ClipboardData(text: _otpValue));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(context)!.otpValueCopiedMessage(_otpValue)),
                  ));
                },
        ),
        Divider(
          thickness: 1.5,
          indent: 8,
          endIndent: 8,
        )
      ],
    );
  }
}
