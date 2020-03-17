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

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
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
    // TODO:
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
//    url=https%3A//XX.XX.XX.XX/ttype/push ## for 2. enrollment step
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
//
    // TODO save firebaseconfig
    String token = await _initFirebase(firebaseConfig);

    print('Generating RSA');
    final pair = generateRSAkeyPair();

    print('Sending message to ${uriMap[URI_ROLLOUT_URL]}');
    print('Verify? ${uriMap[URI_SSL_VERIFY]}');
    var url = uriMap[URI_ROLLOUT_URL];
//    var response = await http.post(url, body: {
//      'enrollment_credential': uriMap[URI_ENROLLMENT_CREDENTIAL],
//      'serial': uriMap[URI_SERIAL],
//      'fbtoken': token,
//      'pubkey': pair.publicKey.toString(),
//    });
//    print('Response status: ${response.statusCode}');
//    print('Response body: ${response.body}');

    // TODO wrap this
    IOClient ioClient = IOClient(HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) =>
              !uriMap[URI_SSL_VERIFY]));

    var response = await ioClient.post(url, body: {
      'enrollment_credential': uriMap[URI_ENROLLMENT_CREDENTIAL],
      'serial': uriMap[URI_SERIAL],
      'fbtoken': token,
      'pubkey': pair.publicKey.toString(),
    });

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    ioClient.close();

    return PushToken(
      label: uriMap[URI_LABEL],
      issuer: uriMap[URI_ISSUER],
      uuid: uuid,
      sslVerify: uriMap[URI_SSL_VERIFY],
      timeToDie: DateTime.now().add(Duration(minutes: uriMap[URI_TTL])),
      enrollmentCredentials: uriMap[URI_ENROLLMENT_CREDENTIAL],
      url: uriMap[URI_ROLLOUT_URL],
    );
  }

  // FIXME initializing firebase messaging this way is not possible
  Future<String> _initFirebase(FirebaseConfig config) async {
    String name = "privacyIDEA Authenticator";

    FirebaseOptions options = FirebaseOptions(
      googleAppID: config.appID,
      apiKey: config.apiKey,
      databaseURL: "https://" + config.projectID + ".firebaseio.com",
      storageBucket: config.projectID + ".appspot.com",
      projectID: config.projectID,
      gcmSenderID: config.projectNumber,
    );

    // FirebaseApp
    // {name=[DEFAULT],
    // options=FirebaseOptions
    // {applicationId=1:978796356794:android:62b1e07b007e368ec98e83,
    // apiKey=AIzaSyBkOGSo8JuVcLIDYD1zMUX-fxsHy8Inf5U,
    // databaseUrl=https://test-3bdba.firebaseio.com,
    // gcmSenderId=978796356794,
    // storageBucket=test-3bdba.appspot.com,
    // projectId=test-3bdba}}]

//    FirebaseOptions options = FirebaseOptions(
//      googleAppID: "1:978796356794:android:62b1e07b007e368ec98e83",
//      apiKey: "AIzaSyBkOGSo8JuVcLIDYD1zMUX-fxsHy8Inf5U",
//      databaseURL: "https://" + "test-3bdba" + ".firebaseio.com",
//      storageBucket: "test-3bdba" + ".appspot.com",
//      projectID: "test-3bdba",
//      gcmSenderID: "978796356794",
//    );

    await FirebaseApp.configure(
      name: name,
      options: options,
    );

    FirebaseMessaging firebaseMessaging = FirebaseMessaging();

    firebaseMessaging.setApplicationName(name);

    await firebaseMessaging.requestNotificationPermissions();

    // FIXME: onResume and onLaunch is not configured see
    //  https://pub.dev/packages/firebase_messaging#-readme-tab-
    //  but the solution there does not seem to work?
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
      // FIXME this leads to errors
//      onBackgroundMessage: myBackgroundMessageHandler,
    );

    firebaseMessaging.getToken().then((token) {
      print("FCM token: $token");
    });

    return await firebaseMessaging.getToken();
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
