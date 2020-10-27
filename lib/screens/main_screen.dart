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
import 'dart:typed_data';
import 'dart:ui';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:base32/base32.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
import 'package:privacyidea_authenticator/model/firebase_config.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/screens/add_manually_screen.dart';
import 'package:privacyidea_authenticator/screens/settings_screen.dart';
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/license_utils.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:privacyidea_authenticator/utils/parsing_utils.dart';
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

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class _MainScreenState extends State<MainScreen> {
  List<Token> _tokenList = List<Token>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Timer _pollTimer;

  @override
  void initState() {
    super.initState();

    // Start polling timer
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      AppSettings.of(context).streamEnablePolling().listen(
        (bool event) {
          if (event) {
            log('Polling is enabled.', name: 'main_screen.dart');
            _pollTimer = Timer.periodic(
                Duration(seconds: 10), (_) => _pollForRequests());
          } else {
            log('Polling is disabled.', name: 'main_screen.dart');
            _pollTimer?.cancel();
            _pollTimer == null;
          }
        },
        cancelOnError: false,
        onError: (error) => print('$error'),
      );
    });

    // Load UI elements
    SchedulerBinding.instance.addPostFrameCallback((_) => _loadEverything());
  }

  _pollForRequests() async {
    // Get all push tokens
    List<PushToken> pushTokens = (await StorageUtil.loadAllTokens())
        .whereType<PushToken>()
        .where((t) =>
            t.isRolledOut &&
            t.url !=
                null) // Legacy tokens can not pull, because the url is missing!
        .toList();

    // Disable polling if no push tokens exist
    if (pushTokens.isEmpty) {
      log('No push token is available for polling, polling is disabled.',
          name: 'main_screen.dart');
      AppSettings.of(context).setEnablePolling(false);
      return;
    }

    // Start request for each token
    for (PushToken p in pushTokens) {
      String timestamp = DateTime.now().toUtc().toIso8601String();

      // Legacy android tokens are signed differently
      String message = '${p.serial}|$timestamp';
      String signature = p.privateTokenKey == null
          ? await Legacy.sign(p.serial, message)
          : createBase32Signature(p.getPrivateTokenKey(), utf8.encode(message));

      Map<String, String> parameters = {
        'serial': p.serial,
        'timestamp': timestamp,
        'signature': signature,
      };

      try {
        Response response = await doGet(
            url: p.url, parameters: parameters, sslVerify: p.sslVerify);

        if (response.statusCode == 200) {
          // The signature of this message must not be verified as each push
          // request gets verified independently.
          Map<String, dynamic> result = jsonDecode(response.body)['result'];
          List values = result['value'];

          for (Map<String, dynamic> value in values) {
            _handleIncomingAuthRequest({'data': value});
          }
        } else {
          // Who knows what happened here?
          // TODO Handle this case?
        }
      } on SocketException {
        log(
          'Polling push tokens not working, server can not be reached.',
          name: 'main_screen.dart',
        );
      }
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  _loadEverything() async {
    await _loadAllTokens();
    await _loadFirebase();
  }

  _loadFirebase() async {
    // If no push tokens exist, the firebase config should be deleted here.
    if (!(await StorageUtil.loadAllTokens())
        .any((element) => element is PushToken)) {
      StorageUtil.deleteGlobalFirebaseConfig();
      return;
    }

    if (await StorageUtil.globalFirebaseConfigExists()) {
      _initFirebase(await StorageUtil.loadGlobalFirebaseConfig());
    }
  }

  _loadAllTokens() async {
    AppSettings settings = AppSettings.of(context);

    List<Token> l1 =
        await StorageUtil.loadAllTokens(loadLegacy: settings.getLoadLegacy());
    setState(() => this._tokenList = l1);
    // Because we only want to load legacy tokens once:
    settings.setLoadLegacy(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.title,
          textScaleFactor: screenTitleScaleFactor,
          overflow: TextOverflow.ellipsis, // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
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
        tooltip: Localization.of(context).scanQRTooltip,
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

        if (newToken is PushToken && _tokenList.contains(newToken)) {
          _showMessage(
              "A token with the serial ${newToken.serial} already exists!",
              Duration(seconds: 2));
          return;
        }

        _tokenList.add(newToken);
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        //  Camera access was denied
      } else {
        //  Unknown error
        throw e;
      }
    } on FormatException catch (e) {
      //  User returned by pressing the back button (can have other causes too!)
      throw e;
    } on ArgumentError catch (e) {
      // Error while parsing qr code.
      // Show the error message to the user.
      _showMessage(
          "${e.message}\n Please inform the creator of this qr code about the problem.",
          Duration(seconds: 8));
      log(
        "Malformed QR code:",
        name: "main_screen.dart",
        error: e.stackTrace,
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
        id: uuid,
        algorithm: mapStringToAlgorithm(algorithm),
        digits: digits,
        secret: encodeSecretAs(secret, Encodings.base32),
        counter: counter,
      );
    } else if (type == "totp") {
      return TOTPToken(
        label: label,
        issuer: issuer,
        id: uuid,
        algorithm: mapStringToAlgorithm(algorithm),
        digits: digits,
        secret: encodeSecretAs(secret, Encodings.base32),
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
    FirebaseConfig config = FirebaseConfig(
        projectID: uriMap[URI_PROJECT_ID],
        projectNumber: uriMap[URI_PROJECT_NUMBER],
        appID: Platform.isIOS ? uriMap[URI_APP_ID_IOS] : uriMap[URI_APP_ID],
        apiKey: Platform.isIOS ? uriMap[URI_API_KEY_IOS] : uriMap[URI_API_KEY]);

    PushToken token = PushToken(
      serial: uriMap[URI_SERIAL],
      label: uriMap[URI_LABEL],
      issuer: uriMap[URI_ISSUER],
      id: uuid,
      sslVerify: uriMap[URI_SSL_VERIFY],
      expirationDate: DateTime.now().add(Duration(minutes: uriMap[URI_TTL])),
      enrollmentCredentials: uriMap[URI_ENROLLMENT_CREDENTIAL],
      url: uriMap[URI_ROLLOUT_URL],
    );

    // Save the config for this token to use it when rolling out.
    await StorageUtil.saveOrReplaceFirebaseConfig(token, config);

    return token;
  }

  Future<String> _initFirebase(FirebaseConfig config) async {
    ArgumentError.checkNotNull(config, "config");

    log("Initializing firebase.", name: "main_screen.dart");

    // Used to identify a firebase app, this is nothing more than an id.
    final String name = "privacyidea_authenticator";

    if (!await StorageUtil.globalFirebaseConfigExists() ||
        await StorageUtil.loadGlobalFirebaseConfig() == config) {
      log("Creating firebaseApp from config.",
          name: "main_screen.dart", error: config);

      try {
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
      } on ArgumentError {
        log(
          "Invalid firebase configuration provided.",
          name: "main_screen.dart",
          error: config,
        );

        _showMessage(Localization.of(context).errorFirebaseConfigCorrupted,
            Duration(seconds: 15));
        return null;
      }

      var initializationSettingsAndroid =
          AndroidInitializationSettings('app_icon');
      var initializationSettingsIOS = IOSInitializationSettings();
      var initializationSettings = InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    } else if (await StorageUtil.loadGlobalFirebaseConfig() != config) {
      log("Given firebase config does not equal the existing config.",
          name: "main_screen.dart",
          error: "Existing: ${await StorageUtil.loadGlobalFirebaseConfig()}"
              "\n Given:    $config");

      return null;
    }

    FirebaseMessaging firebaseMessaging = FirebaseMessaging()
      ..setApplicationName(name);

    // Ask user to allow notifications, if declined no notifications are shown
    //  for incoming push requests.
    if (Platform.isIOS) {
      await firebaseMessaging.requestNotificationPermissions();
    }

    // onResume and onLaunch is not configured see:
    //  https://pub.dev/packages/firebase_messaging#-readme-tab-
    //  but the solution there does not seem to work?
    //  These functions do not seem to serve a purpose, as the background
    //  message handling seems to do just that.
    // TODO Enable again, this is just for testing polling!
//    firebaseMessaging.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        // Used by Android and iOS
//        log("onMessage: ");
//        _handleIncomingAuthRequest(message);
//      },
//      onLaunch: (Map<String, dynamic> message) async {
//        // Does not seem to be used by Android or iOS
//        log("onLaunch: ");
//        _handleIncomingAuthRequest(message);
//      },
//      onResume: (Map<String, dynamic> message) async {
//        // Used by iOS only (?)
//        log("onResume: ");
//        _handleIncomingAuthRequest(message);
//      },
//      onBackgroundMessage: Platform.isIOS
//          ? null
//          : // iOS does not support this.
//          myBackgroundMessageHandler,
//    );

    String firebaseToken = await firebaseMessaging.getToken();

    log("Firebase initialized, token added",
        name: "main_screen.dart", error: firebaseToken);

    StorageUtil.saveOrReplaceGlobalFirebaseConfig(config);

    // The Firebase Plugin will throw a network exception, but that does not reach
    //  the flutter part of the app. That is why we need to throw our own socket-
    //  exception in this case.
    if (firebaseToken == null) {
      throw SocketException(
          "Firebase token could not be retrieved, the only know cause of this is"
          " that the firebase servers could not be reached.");
    }

    return firebaseToken;
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    log("Background message received.",
        name: "main_screen.dart", error: message);
    await StorageUtil.protect(() async => _handleIncomingRequest(
        message, await StorageUtil.loadAllTokens(), true));
  }

  void _handleIncomingAuthRequest(Map<String, dynamic> message) async {
    log("Foreground message received.",
        name: "main_screen.dart", error: message);

    await StorageUtil.protect(() async => _handleIncomingRequest(
        message, await StorageUtil.loadAllTokens(), false));
    _loadAllTokens(); // Update UI
  }

  /// Handles incoming push requests by verifying the challenge and adding it
  /// to the token. This should be guarded by a lock.
  static Future<void> _handleIncomingRequest(Map<String, dynamic> message,
      List<Token> tokenList, bool inBackground) async {
    // This allows for handling push on ios, android and polling.
    var data = message['data'] == null ? message : message['data'];

    Uri requestUri = Uri.parse(data['url']);
    String requestedSerial = data['serial'];

    log('Incoming push auth request for token with serial.',
        name: 'main_screen.dart', error: requestedSerial);

    PushToken token = tokenList
        .whereType<PushToken>()
        .firstWhere((t) => t.serial == requestedSerial && t.isRolledOut);

    if (token == null) {
      log("The requested token does not exist or is not rolled out.",
          name: "main_screen.dart", error: requestedSerial);
    } else {
      log('Token matched requested token',
          name: 'main_screen.dart', error: token);
      String signature = data['signature'];
      String signedData = '${data['nonce']}|'
          '${data['url']}|'
          '${data['serial']}|'
          '${data['question']}|'
          '${data['title']}|'
          '${data['sslverify']}';

      bool sslVerify = int.parse(data['sslverify'], onError: (parse) => 1) == 0
          ? false
          : true;

      // Re-add url and sslverify to android legacy tokens:
      token.url ??= Uri.parse(data['url']);
      token.sslVerify ??= sslVerify;

      bool isVerified = token.privateTokenKey == null
          ? await Legacy.verify(token.serial, signedData, signature)
          : verifyRSASignature(token.getPublicServerKey(),
              utf8.encode(signedData), base32.decode(signature));

      if (isVerified) {
        log('Validating incoming message was successful.',
            name: 'main_screen.dart');

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

          if (inBackground) _showNotification(token, pushRequest, false);
        } else {
          log(
              "The push request $pushRequest already exists "
              "for the token with serial ${token.serial}",
              name: "main_screen.dart");
        }
      } else {
        log('Validating incoming message failed.',
            name: 'main_screen.dart',
            error:
                'Signature $signature does not match signed data: $signedData');
      }
    }
  }

  static void _showNotification(
      PushToken token, PushRequest pushRequest, bool silent) async {
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(presentSound: !silent);

    var bigTextStyleInformation = BigTextStyleInformation(pushRequest.question,
        htmlFormatBigText: true,
        contentTitle: pushRequest.title,
        htmlFormatContentTitle: true,
        summaryText: 'Token <i>${token.label}</i>',
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'privacy_idea_authenticator_push',
      'Push challenges',
      'Push challenges are received over firebase, if the app is in background,'
          'a notification for each request is shown.',
      ticker: 'ticker',
      playSound: silent,
      styleInformation: bigTextStyleInformation, // To display token name.
    );

    await flutterLocalNotificationsPlugin.show(
      pushRequest.id.hashCode, // ID of the notification
      pushRequest.title,
      pushRequest.question,
      NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics),
    );
  }

  ListView _buildTokenList() {
    return ListView.separated(
        itemBuilder: (context, index) {
          Token token = _tokenList[index];
          return TokenWidget(
            token,
            onDeleteClicked: () => _removeToken(token),
            getFirebaseToken: (config) => _initFirebase(config),
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: _tokenList.length);
  }

  void _removeToken(Token token) async {
    log("Remove: $token");
    await StorageUtil.deleteToken(token);

    if (!(await StorageUtil.loadAllTokens())
        .any((element) => element is PushToken)) {
      StorageUtil.deleteGlobalFirebaseConfig();
    }

    await _loadAllTokens();
  }

  List<Widget> _buildActionMenu() {
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
                )).then((newToken) => _addToken(newToken));
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
            child: Text(Localization.of(context).about),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: "add_manually",
            child: Text(Localization.of(context).addManually),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: "settings",
            child: Text(Localization.of(context).settings),
          ),
        ],
      ),
    ];
  }

  _addToken(Token newToken) {
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
