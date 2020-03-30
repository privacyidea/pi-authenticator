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

import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:base32/base32.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:privacyidea_authenticator/model/firebase_config.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/screens/add_manually_screen.dart';
import 'package:privacyidea_authenticator/screens/settings_screen.dart';
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/license_utils.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/widgets/token_widgets.dart';
import 'package:privacyidea_authenticator/widgets/two_step_dialog.dart';
import 'package:uuid/uuid.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Token> _tokenList = List<Token>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _MainScreenState() {
    _loadAllTokens();
  }

  _loadAllTokens() async {
    List<Token> list = await StorageUtil.loadAllTokens();
    setState(() {
      this._tokenList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.title,
          textScaleFactor: screenTitleScaleFactor,
        ),
        actions: _buildActionMenu(),
        leading: Padding(
          padding: EdgeInsets.all(4.0),
          child: Image.asset('res/logo/app_logo_light.png'),
        ),
      ),
      body: _buildTokenList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scanQRCode(),
        tooltip: L10n.of(context).scanQRTooltip,
        child: Icon(Icons.add),
      ),
    );
  }

  _scanQRCode() async {
    try {
      String barcode = await BarcodeScanner.scan();
      log(
        "Barcode scanned:",
        name: "main_screen.dart",
        error: barcode,
      );

      Token newToken = await _buildTokenFromMap(
          parseQRCodeToMap(barcode), Uri.parse(barcode));
      setState(() {
        log(
          "Adding new token from qr-code:",
          name: "main_screen.dart",
          error: newToken,
        );
        _tokenList.add(newToken);
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        //  Camera access was denied
      } else {
        //  Unknown error
        throw e;
      }
    } on FormatException {
      //  User returned by pressing the back button
    } on ArgumentError catch (e) {
      // Error while parsing qr code.
      // Show the error message to the user.
      _showMessage(
          "${e.message}\n Please inform the creator of this qr code about the problem.",
          Duration(seconds: 8));
      log(
        "Malformed QR code:",
        name: "main_screen.dart",
        error: e.toString(),
      );
    } catch (e) {
      //  Unknown error
      throw e;
    }
  }

  Future<Token> _buildTokenFromMap(Map<String, dynamic> uriMap, Uri uri) async {
    String uuid = Uuid().v4();
    String type = uriMap[URI_TYPE];

    // Push token do not need any of the other parameters.
    if (equalsIgnoreCase(type, enumAsString(TokenTypes.PIPUSH))) {
      return _buildPushToken(uriMap, uuid);
    }

    String label = uriMap[URI_LABEL];
    String algorithm = uriMap[URI_ALGORITHM];
    int digits = uriMap[URI_DIGITS];
    Uint8List secret = uriMap[URI_SECRET];
    int counter = uriMap[URI_COUNTER];
    int period = uriMap[URI_PERIOD];
    String issuer = uriMap[URI_ISSUER];

    if (is2StepURI(uri)) {
      // Calculate the whole secret.
      secret = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => TwoStepDialog(
          iterations: uriMap[URI_ITERATIONS],
          keyLength: uriMap[URI_OUTPUT_LENGTH_IN_BYTES],
          saltLength: uriMap[URI_SALT_LENGTH],
          password: secret,
        ),
      );
    }

    // uri.host -> totp or hotp
    if (type == "hotp") {
      return HOTPToken(
        label: label,
        issuer: issuer,
        uuid: uuid,
        algorithm: mapStringToAlgorithm(algorithm),
        digits: digits,
        secret: secret,
        counter: counter,
      );
    } else if (type == "totp") {
      return TOTPToken(
        label: label,
        issuer: issuer,
        uuid: uuid,
        algorithm: mapStringToAlgorithm(algorithm),
        digits: digits,
        secret: secret,
        period: period,
      );
    } else {
      throw ArgumentError.value(
          uri,
          "uri",
          "Building the token type "
              "[$type] is not a supported right now.");
    }
  }

  Future<PushToken> _buildPushToken(
      Map<String, dynamic> uriMap, String uuid) async {
//    otpauth://
//    pipush/
//        PIPU00028E46 ## for token
//        ?
//
//    &v=1 ## for parsing
//
//    ##### TOKEN
//    &issuer=privacyIDEA ## for token
//    &serial=PIPU00028E46 ## for token
//
//    ##### 2. STEP
//    &sslverify=0 ## for 2. enrollment step
//    &enrollment_credential=9XXXXXXX7 ## for 2. enrollment step
//    &url=https%3A//XX.XX.XX.XX/ttype/push ## for 2. enrollment step
//    &ttl=2 ## for 2. enrollment step
//
//    ##### FCM
//    &projectnumber=6XXXXXX4 ## for fcm init
//    &projectid=XXXXX ## for fcm init
//    &appid=1XXXXXXa9 ## for fcm init
//    &apikey=AIzaXXXXXiRk ## for fcm init
//    &appidios=AIzaSXXXXXvUWdiRk ## for fcm init
//    &apikeyios=AIzXXXXXk ## for fcm init

//    // TODO: Change this to work with ios, or change the parsing
//    //  of the uri directly.
    FirebaseConfig firebaseConfig = FirebaseConfig(
        projectID: uriMap[URI_PROJECT_ID],
        projectNumber: uriMap[URI_PROJECT_NUMBER],
        appID: uriMap[URI_APP_ID],
        apiKey: uriMap[URI_API_KEY]);

    // TODO remove firebase project when no push token exists anymore
    // TODO handle init not working / possible / firebase already initialised
    String firebaseToken = await _initFirebase(firebaseConfig);

    return PushToken(
      serial: uriMap[URI_SERIAL],
      label: uriMap[URI_LABEL],
      issuer: uriMap[URI_ISSUER],
      uuid: uuid,
      sslVerify: uriMap[URI_SSL_VERIFY],
      timeToDie: DateTime.now().add(Duration(minutes: uriMap[URI_TTL])),
      enrollmentCredentials: uriMap[URI_ENROLLMENT_CREDENTIAL],
      url: uriMap[URI_ROLLOUT_URL],
      firebaseToken: firebaseToken,
    );
  }

  Future<String> _initFirebase(FirebaseConfig config) async {
    // TODO save config / load config?

    String name = "privacyIDEA Authenticator";

    await FirebaseApp.configure(
      name: name,
      options: FirebaseOptions(
        googleAppID: config.appID,
        apiKey: config.apiKey,
        databaseURL: "https://" + config.projectID + ".firebaseio.com",
        storageBucket: config.projectID + ".appspot.com",
        projectID: config.projectID,
        gcmSenderID: config.projectNumber,
      ),
    );

    // TODO Fix license
    // TODO implement ios
    FirebaseMessaging firebaseMessaging = FirebaseMessaging()
      ..setApplicationName(name);

    // TODO only ios, handle that
//    await firebaseMessaging.requestNotificationPermissions();

    // FIXME: onResume and onLaunch is not configured see
    //  https://pub.dev/packages/firebase_messaging#-readme-tab-
    //  but the solution there does not seem to work?
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: ");
        _handleIncomingAuthRequest(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
      // FIXME this leads to errors (because of scanner plugin?)
//      onBackgroundMessage: myBackgroundMessageHandler,
    );

    String firebaseToken = await firebaseMessaging.getToken();

    log("Firebase initialized, token added",
        name: "main_screen.dart", error: firebaseToken);

    return firebaseToken;
  }

  void _handleIncomingAuthRequest(Map<String, dynamic> message) {
    // TODO handle message in wrong format
    message['data'].forEach((key, value) => print('$key = $value'));

    print('get data block');

    // FIXME why does it fail with this line?
//    Map<String, dynamic> data = message['data'];

    print('after data');

    // TODO Handle uri error
    String requestedSerial = message['data']['serial'];
    Uri requestUri = Uri.parse(message['data']['url']);

    log('Incoming push auth request for token with serial.',
        name: 'main_screen.dart', error: requestedSerial);

    bool wasHandled = false;

    _tokenList.forEach((token) {
      if (token is PushToken) {
        if (token.serial == requestedSerial && token.isRolledOut) {
          log('Token matched requested token',
              name: 'main_screen.dart', error: token);
          // {nonce}|{url}|{serial}|{question}|{title}|{sslverify} in BASE32
          String signature = message['data']['signature'];
          String signedData = '${message['data']['nonce']}|'
              '${message['data']['url']}|'
              '${message['data']['serial']}|'
              '${message['data']['question']}|'
              '${message['data']['title']}|'
              '${message['data']['sslverify']}';

          if (verifyRSASignature(token.publicServerKey, utf8.encode(signedData),
              base32.decode(signature))) {
            wasHandled = true;

            log('Validating incoming message was successful.',
                name: 'main_screen.dart');
            setState(() {
              token.hasPendingRequest = true;
              token.requestUri = requestUri;
              token.requestNonce = message['data']['nonce'];
              token.requestSSLVerify = message['data']['sslverify'] == '1'
                  ? true
                  : false; // TODO is this the right interpretation?
            });
          } else {
            log('Validating incoming message failed.',
                name: 'main_screen.dart',
                error:
                    'Signature $signature does not match signed data: $signedData');
          }
        }
      }
    });

    if (!wasHandled) {
      log("The requested token does not exist or is not rolled out.",
          name: "main_screen.dart", error: requestedSerial);
    }
  }

//  static Future<dynamic> myBackgroundMessageHandler(
//      Map<String, dynamic> message) {
//    if (message.containsKey('data')) {
//      // Handle data message
//      final dynamic data = message['data'];
//    }
//
//    if (message.containsKey('notification')) {
//      // Handle notification message
//      final dynamic notification = message['notification'];
//    }
//
//    // Or do other work.
//  }

  ListView _buildTokenList() {
    return ListView.separated(
        itemBuilder: (context, index) {
          Token token = _tokenList[index];
          return TokenWidget(
            key: ObjectKey(token),
            token: token,
            onDeleteClicked: () => _deleteClicked(token),
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: _tokenList.length);
  }

  void _deleteClicked(Token token) {
    setState(() {
      print("Remove: $token");
      _tokenList.remove(token);
      StorageUtil.deleteToken(token);
    });
  }

  List<Widget> _buildActionMenu() {
    // TODO maybe a drawer / 'hamburger' menu would be nicer?
    return <Widget>[
      PopupMenuButton<String>(
        onSelected: (String value) async {
          if (value == "about") {
            PackageInfo info = await PackageInfo.fromPlatform();
//              clearLicenses(), // This is used for testing purposes only.
            addAllLicenses();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LicensePage(
                          applicationName: "privacyIDEA Authenticator",
                          applicationVersion: info.version,
                          applicationIcon: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Image.asset('res/logo/app_logo_light.png'),
                          ),
                          applicationLegalese: "Apache License 2.0",
                        )));
          } else if (value == "add_manually") {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTokenManuallyScreen(),
                )).then((newToken) => _addNewToken(newToken));
          } else if (value == "settings") {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen('Settings'),
                ));
          }
        },
        elevation: 5.0,
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: "about",
            child: Text(L10n.of(context).about),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: "add_manually",
            child: Text(L10n.of(context).addManually),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: "settings",
            child: Text(L10n.of(context).settings),
          ),
        ],
      ),
    ];
  }

  _addNewToken(Token newToken) {
    log("Adding new token:", name: "main_screen.dart", error: newToken);
    if (newToken != null) {
      setState(() {
        _tokenList.add(newToken);
      });
    }
  }

  _showMessage(String message, Duration duration) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: duration,
    ));
  }
}
