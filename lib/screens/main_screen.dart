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
import 'dart:developer';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:collection/collection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/screens/add_manually_screen.dart';
import 'package:privacyidea_authenticator/screens/onboarding_screen.dart';
import 'package:privacyidea_authenticator/screens/scanner_screen.dart';
import 'package:privacyidea_authenticator/screens/settings_screen.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/license_utils.dart';
import 'package:privacyidea_authenticator/utils/parsing_utils.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/widgets/app_bar_item.dart';
import 'package:privacyidea_authenticator/widgets/no_token_screen.dart';
import 'package:privacyidea_authenticator/widgets/token_widgets.dart';
import 'package:privacyidea_authenticator/widgets/two_step_dialog.dart';
import 'package:uni_links/uni_links.dart';
import 'package:uuid/uuid.dart';

import '../widgets/custom_paint_app_bar.dart';
import 'custom_about_screen.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MainScreenState createState() => _MainScreenState();
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class _MainScreenState extends State<MainScreen> with LifecycleMixin {
  List<Token> _tokenList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Used for periodically polling for push challenges
  Timer? _pollTimer;

  // Used for handling links the app is registered to handle.
  StreamSubscription? _uniLinkStream;

  void _startPollingIfEnabled() {
    AppSettings.of(context).streamEnablePolling().listen(
      (bool event) {
        if (event) {
          log('Polling is enabled.',
              name: 'main_screen.dart#_startPollingIfEnabled');

          _pollTimer = Timer.periodic(Duration(seconds: 3),
              (_) => PushProvider.pollForChallenges(context));
          PushProvider.pollForChallenges(context);
        } else {
          log('Polling is disabled.',
              name: 'main_screen.dart#_startPollingIfEnabled');
          _pollTimer?.cancel();
          _pollTimer = null;
        }
      },
      cancelOnError: false,
      onError: (error) =>
          log('$error', name: 'main_screen.dart#_startPollingIfEnabled'),
    );
  }

  /// Handles incoming push requests by verifying the challenge and adding it
  /// to the token. This should be guarded by a lock.
  static Future<void> _handleIncomingRequest(
      RemoteMessage message, List<Token> tokenList, bool inBackground) async {
    var data = message.data;

    Uri requestUri = Uri.parse(data['url']);
    String requestedSerial = data['serial'];

    log('Incoming push challenge for token with serial.',
        name: 'main_screen.dart#_handleIncomingChallenge',
        error: requestedSerial);

    PushToken? token = tokenList
        .whereType<PushToken>()
        .firstWhereOrNull((t) => t.serial == requestedSerial && t.isRolledOut);

    if (token == null) {
      log('The requested token does not exist or is not rolled out.',
          name: 'main_screen.dart#_handleIncomingChallenge',
          error: requestedSerial);
    } else {
      log('Token matched requested token',
          name: 'main_screen.dart#_handleIncomingChallenge', error: token);
      String signature = data['signature'];
      String signedData = '${data['nonce']}|'
          '$requestUri|'
          '${data['serial']}|'
          '${data['question']}|'
          '${data['title']}|'
          '${data['sslverify']}';

      bool sslVerify = (int.tryParse(data['sslverify']) ?? 0) == 1;

      // Re-add url and sslverify to android legacy tokens:
      token.url ??= requestUri;
      token.sslVerify ??= sslVerify;

      bool isVerified = token.privateTokenKey == null
          ? await Legacy.verify(token.serial, signedData, signature)
          : verifyRSASignature(token.getPublicServerKey()!,
              utf8.encode(signedData) as Uint8List, base32.decode(signature));

      if (isVerified) {
        log('Validating incoming message was successful.',
            name: 'main_screen.dart#_handleIncomingChallenge');

        PushRequest pushRequest = PushRequest(
            title: data['title'],
            question: data['question'],
            uri: requestUri,
            nonce: data['nonce'],
            sslVerify: sslVerify,
            id: data['nonce'].hashCode,
            // FIXME This is not guaranteed to not lead to collisions, but they might be unlikely in this case.
            expirationDate: DateTime.now().add(
              Duration(minutes: 2),
            )); // Push requests expire after 2 minutes.

        if (!token.knowsRequestWithId(pushRequest.id)) {
          token.pushRequests.add(pushRequest);
          token.knownPushRequests.put(pushRequest.id);

          StorageUtil.saveOrReplaceToken(token); // Save the pending request.
          PushProvider.showNotification(token, pushRequest, false);
        } else {
          log(
              'The push request $pushRequest already exists '
              'for the token with serial ${token.serial}',
              name: 'main_screen.dart#_handleIncomingChallenge');
        }
      } else {
        log('Validating incoming message failed.',
            name: 'main_screen.dart#_handleIncomingChallenge',
            error:
                'Signature $signature does not match signed data: $signedData');
      }
    }
  }

  Future<void> _handleIncomingAuthRequest(RemoteMessage message) async {
    log('Foreground message received.',
        name: 'main_screen.dart#_handleIncomingAuthRequest', error: message);
    await StorageUtil.protect(() async => _handleIncomingRequest(
        message, await StorageUtil.loadAllTokens(), false));
    await _loadTokenList(); // Update UI
  }

  Future<void> _initLinkHandling() async {
    _uniLinkStream = linkStream.listen((String? link) {
      _handleOtpAuth(link);
    }, onError: (err) {
      _showMessage(AppLocalizations.of(context)!.handlingOtpAuthLinkFailed,
          Duration(seconds: 4));
    });

    try {
      String? link = await getInitialLink();
      if (link == null) {
        return; // Do not cause an Exception here if no link exists.
      }
      _handleOtpAuth(link);
    } on PlatformException {
      _showMessage(AppLocalizations.of(context)!.handlingOtpAuthLinkFailed,
          Duration(seconds: 4));
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    log('Background message received.',
        name: 'main_screen.dart#_firebaseMessagingBackgroundHandler',
        error: message);
    await StorageUtil.protect(() async => _handleIncomingRequest(
        message, await StorageUtil.loadAllTokens(), true));
  }

  @override
  void initState() {
    super.initState();
    _initLinkHandling();
    _initStateAsync();
  }

  /// Handles asynchronous calls that should be triggered by `initState`.
  void _initStateAsync() async {
    await PushProvider.initialize(
      handleIncomingMessage: (RemoteMessage message) =>
          _handleIncomingAuthRequest(message),
      backgroundMessageHandler: _firebaseMessagingBackgroundHandler,
    );
    _startPollingIfEnabled();
  }

  @override
  void afterFirstRender() {
    _loadTokenList();
  }

  @override
  void onPause() {
    for (Token token in _tokenList) {
      if (token.relock) {
        token.isLocked = true;
      }
    }
    setState(() {});
  }

  @override
  void onResume() {
    if (_isPushTokenAvaiable()) {
      PushProvider.pollForChallenges(context);
    }
    setState(() {});
  }

  @override
  void onDetached() {
    for (Token token in _tokenList) {
      if (token.relock) {
        token.isLocked = true;
      }
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _uniLinkStream?.cancel();
    for (Token token in _tokenList) {
      if (token.relock) {
        token.isLocked = true;
      }
    }
    super.dispose();
  }

  Future<void> _loadTokenList() async {
    List<Token> l1 = await StorageUtil.loadAllTokens();
    // Sort the list by the sortIndex stored in localStorage
    l1.sort((a, b) {
      if (a.sortIndex != null && b.sortIndex != null) {
        return a.sortIndex!.compareTo(b.sortIndex as int);
      }
      return a.id.hashCode.compareTo(b.id.hashCode);
    });
    this._tokenList = l1;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
          // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
        ),
        leading: SvgPicture.asset('res/logo/app_logo_light.svg'),
      ),
      extendBodyBehindAppBar: false,
      body: Container(
        width: size.width,
        height: size.height,
        child: Stack(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          children: [
            _tokenList.isEmpty ? NoTokenScreen() : _buildBody(),
            Positioned(
              child: Container(
                width: size.width,
                height: 80,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(size.width, 80),
                      painter: CustomPaintAppBar(buildContext: context),
                    ),
                    Center(
                      heightFactor: 0.6,
                      child: FloatingActionButton(
                        onPressed: () => _scanQRCode(),
                        tooltip: AppLocalizations.of(context)!.scanQrCode,
                        child: Icon(Icons.qr_code_scanner_outlined),
                      ),
                    ),
                    Container(
                      width: size.width,
                      height: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AppBarItem(
                            onPressed: () {
                              addAllLicenses();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomLicenseScreen(),
                                ),
                              );
                            },
                            icon: Icons.info_outline,
                          ),
                          AppBarItem(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddTokenManuallyScreen(),
                                  )).then((newToken) => _addToken(newToken));
                            },
                            icon: Icons.add_moderator,
                          ),
                          Container(
                            width: size.width * 0.20,
                          ),
                          AppBarItem(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SettingsScreen(),
                                    )).then((_) => _loadTokenList());
                              },
                              icon: Icons.settings),
                          AppBarItem(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OnboardingScreen(),
                                ),
                              );
                            },
                            icon: Icons.help_outline,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              bottom: 0,
              left: 0,
            ),
          ],
        ),
      ),
    );
  }

  /// Handles an otpauth link by parsing it and building a token. The token
  /// is then automatically added to the `_tokenList`. If an error occurs,
  /// a message is shown to the user.
  Future<void> _handleOtpAuth(String? otpAuth) async {
    if (otpAuth == null) {
      return;
    }

    log(
      'Try to handle otpAuth:',
      name: 'main_screen.dart#_handleOtpAuth',
      error: otpAuth,
    );

    try {
      // TODO get crash report recipients from map and set in settings
      //  and for Catcher.
      Map<String, dynamic> barcodeMap = parseQRCodeToMap(otpAuth);
      // AppSetting.of(context).add...
//      Catcher.instance.updateConfig();

      Token newToken = await _buildTokenFromMap(barcodeMap, Uri.parse(otpAuth));
      
      if (newToken.pin != null && newToken.pin != false) {
        newToken.isLocked = true;
      }

      log(
        'Adding new token from qr-code:',
        name: 'main_screen.dart#_handleOtpAuth',
        error: newToken,
      );

      if (newToken is PushToken && _tokenList.contains(newToken)) {
        _showMessage(
            'A token with the serial ${newToken.serial} already exists!',
            Duration(seconds: 2));
        return;
      }

      await StorageUtil.saveOrReplaceToken(newToken);
      await PushProvider.initNotifications();

      //enable polling on push token added
      if (newToken is PushToken) {
        AppSettings.of(context).enablePolling = true;
      }

      _tokenList.add(newToken);

      if (mounted) {
        setState(() {});
      }
    } on ArgumentError catch (e) {
      // Error while parsing qr code.
      log(
        'Malformed QR code:',
        name: 'main_screen.dart#_handleOtpAuth',
        error: e.stackTrace,
      );

      _showMessage(
          '${e.message}\n Please inform the creator of this qr code about the problem.',
          Duration(seconds: 8));
    }
  }

  /// Open the QR-code scanner and call `_handleOtpAuth`, with the scanned
  /// code as the argument.
  void _scanQRCode() async {
    String? barcode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScannerScreen()),
    );
    await _handleOtpAuth(barcode);
  }

  /// Builds and returns a token from a given map, that contains all necessary
  /// fields.
  Future<Token> _buildTokenFromMap(Map<String, dynamic> uriMap, Uri uri) async {
    String uuid = Uuid().v4();
    String type = uriMap[URI_TYPE];

    // Push token do not need any of the other parameters.
    if (equalsIgnoreCase(type, enumAsString(TokenTypes.PIPUSH))) {
      return PushToken(
        serial: uriMap[URI_SERIAL],
        label: uriMap[URI_LABEL],
        issuer: uriMap[URI_ISSUER],
        id: uuid,
        sslVerify: uriMap[URI_SSL_VERIFY],
        expirationDate: DateTime.now().add(Duration(minutes: uriMap[URI_TTL])),
        enrollmentCredentials: uriMap[URI_ENROLLMENT_CREDENTIAL],
        url: uriMap[URI_ROLLOUT_URL],
      );
    }

    String label = uriMap[URI_LABEL];
    String algorithm = uriMap[URI_ALGORITHM];
    int digits = uriMap[URI_DIGITS];
    Uint8List secret = uriMap[URI_SECRET];
    String issuer = uriMap[URI_ISSUER];
    bool? pin = uriMap[URI_PIN];

    if (is2StepURI(uri)) {
      // Calculate the whole secret.
      secret = (await showDialog<Uint8List>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => TwoStepDialog(
          iterations: uriMap[URI_ITERATIONS],
          keyLength: uriMap[URI_OUTPUT_LENGTH_IN_BYTES],
          saltLength: uriMap[URI_SALT_LENGTH],
          password: secret,
        ),
      ))!;
    }

    // uri.host -> totp or hotp
    if (type == 'hotp') {
      return HOTPToken(
          label: label,
          issuer: issuer,
          id: uuid,
          algorithm: mapStringToAlgorithm(algorithm),
          digits: digits,
          secret: encodeSecretAs(secret, Encodings.base32),
          counter: uriMap[URI_COUNTER],
          pin: pin);
    } else if (type == 'totp') {
      return TOTPToken(
          label: label,
          issuer: issuer,
          id: uuid,
          algorithm: mapStringToAlgorithm(algorithm),
          digits: digits,
          secret: encodeSecretAs(secret, Encodings.base32),
          period: uriMap[URI_PERIOD],
          pin: pin);
    } else {
      throw ArgumentError.value(
          uri,
          'uri',
          'Building the token type '
              '[$type] is not a supported right now.');
    }
  }

  /// Builds the body of the screen. If any tokens supports polling,
  /// returns a list wrapped in a RefreshIndicator to manually poll.
  /// If not returns the list only.
  Widget _buildBody() {
    Widget child = SlidableAutoCloseBehavior(
      child: ReorderableListView.builder(
        itemBuilder: (context, index) {
          if (_tokenList[index].sortIndex == null) {
            _tokenList[index].sortIndex = index;
          }
          Token token = _tokenList[index];
          return TokenWidget(token, onDeleteClicked: () => _removeToken(token));
        },
        // add padding for floating action button
        padding: EdgeInsets.only(bottom: 80),
        itemCount: _tokenList.length,
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
            final token = _tokenList.removeAt(oldIndex);
            _tokenList.insert(index, token);
            _updateSortIndex();
          });
        },
      ),
    );

    bool allowManualRefresh =
        _tokenList.any((t) => t is PushToken && t.url != null);

    return allowManualRefresh
        ? RefreshIndicator(
            child: child,
            onRefresh: () async {
              _showMessage(AppLocalizations.of(context)!.pollingChallenges,
                  Duration(seconds: 1));
              bool success = await PushProvider.pollForChallenges(context);
              if (!success) {
                _showMessage(
                  AppLocalizations.of(context)!.pollingFailNoNetworkConnection,
                  Duration(seconds: 3),
                );
              }
            },
          )
        : child;
  }

  Future<void> _removeToken(Token token) async {
    log('Remove: $token');
    await StorageUtil.deleteToken(token);
    await _loadTokenList();
  }

  void _addToken(Token? newToken) {
    log('Adding new token:',
        name: 'main_screen.dart#_addToken', error: newToken);
    if (newToken != null) {
      // add last index
      newToken.sortIndex = _tokenList.length;

      _tokenList.add(newToken);

      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Shows a message to the user for a given `Duration`.
  _showMessage(String message, Duration duration) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: duration,
    ));
  }

  // on reorder list, update sortIndex of every element
  _updateSortIndex() {
    for (int i = 0; i < _tokenList.length; i++) {
      if (_tokenList[i].sortIndex != null) {
        _tokenList[i].sortIndex = i;
        StorageUtil.saveOrReplaceToken(_tokenList[i]);
      }
    }
  }

  bool _isPushTokenAvaiable() {
    for (Token token in _tokenList) {
      if (token is PushToken) {
        return true;
      }
    }
    return false;
  }
}
