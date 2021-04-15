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

import 'package:base32/base32.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
import 'package:privacyidea_authenticator/model/firebase_config.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/screens/add_manually_screen.dart';
import 'package:privacyidea_authenticator/screens/changelog_screen.dart';
import 'package:privacyidea_authenticator/screens/guide_screen.dart';
import 'package:privacyidea_authenticator/screens/scanner_screen.dart';
import 'package:privacyidea_authenticator/screens/settings_screen.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/license_utils.dart';
import 'package:privacyidea_authenticator/utils/network_utils.dart';
import 'package:privacyidea_authenticator/utils/parsing_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/widgets/token_widgets.dart';
import 'package:privacyidea_authenticator/widgets/two_step_dialog.dart';
import 'package:uuid/uuid.dart';

import 'custom_about_screen.dart';

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
            _pollForRequests();
          } else {
            log('Polling is disabled.', name: 'main_screen.dart');
            _pollTimer?.cancel();
            _pollTimer = null;
          }
        },
        cancelOnError: false,
        onError: (error) => log('$error', name: 'polling timer'),
      );
    });

    // Load UI elements
    SchedulerBinding.instance.addPostFrameCallback((_) => _loadEverything());

    // Attempt to automatically update firebase tokens if the token was changed.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      String newToken = await StorageUtil.getNewFirebaseToken();

      if ((await StorageUtil.getCurrentFirebaseToken()) != newToken &&
          newToken != null) {
        _updateFirebaseToken();
      }
    });

    // Show changelog and welcome screen
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // Do not show these info when running driver tests
      if (!AppSettings.of(context).isTestMode) {
        PackageInfo info = await PackageInfo.fromPlatform();

        // Check if the app was updated
        if (info.version != await StorageUtil.getCurrentVersion()) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChangelogScreen()),
          );
          StorageUtil.setCurrentVersion(info.version);
        }

        // Show the guide screen in front of the changelog -> load it last
        if (AppSettings.of(context).showGuideOnStart) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GuideScreen()),
          );
        }
      }
    });
  }

  _pollForRequests() async {
    // Get all push tokens
    List<PushToken> pushTokens = (await StorageUtil.loadAllTokens())
        .whereType<PushToken>()
        .where((t) =>
            t.isRolledOut &&
            t.url !=
                null) // Legacy tokens can not poll, because the url is missing!
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
          // Error messages can only be distinguished by their text content, not by their error code. This would make error handling complex.
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
    await _loadTokenList();
    await _loadFirebase();
  }

  _loadFirebase() async {
    // If no push tokens exist, the firebase config is deleted here.
    if (!(await StorageUtil.loadAllTokens())
        .any((element) => element is PushToken)) {
      StorageUtil.deleteGlobalFirebaseConfig();
      return;
    }

    if (await StorageUtil.globalFirebaseConfigExists()) {
      _initFirebase(await StorageUtil.loadGlobalFirebaseConfig());
    }
  }

  _loadTokenList() async {
    List<Token> l1 = await StorageUtil.loadAllTokens();
    // Prevent the list items from skipping around on ui updates
    l1.sort((a, b) => a.id.hashCode.compareTo(b.id.hashCode));
    this._tokenList = l1;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis, // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
        ),
        actions: _buildActionMenu(),
        leading: SvgPicture.asset('res/logo/app_logo_light.svg'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scanQRCode(),
        tooltip: AppLocalizations.of(context).scanQrCode,
        child: Icon(Icons.add),
      ),
    );
  }

  _scanQRCode() async {
    String barcode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScannerScreen()),
    );

    if (barcode == null) {
      // User canceled scanning.
      return;
    }

    log(
      "Barcode scanned:",
      name: "main_screen.dart",
      error: barcode,
    );

    try {
      // TODO get crash report recipients from map and set in settings
      //  and for Catcher.
      Map<String, dynamic> barcodeMap = parseQRCodeToMap(barcode);
      // AppSetting.of(context).add...
//      Catcher.instance.updateConfig();

      Token newToken = await _buildTokenFromMap(barcodeMap, Uri.parse(barcode));

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

      if (mounted) {
        setState(() {});
      }
    } on ArgumentError catch (e) {
      // Error while parsing qr code.
      _showMessage(
          "${e.message}\n Please inform the creator of this qr code about the problem.",
          Duration(seconds: 8));
      log(
        "Malformed QR code:",
        name: "main_screen.dart",
        error: e.stackTrace,
      );
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

        _showMessage(AppLocalizations.of(context).firebaseConfigCorrupted,
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
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        // Used by Android and iOS
        log("onMessage: ");
        _handleIncomingAuthRequest(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        // Does not seem to be used by Android or iOS
        log("onLaunch: ");
        _handleIncomingAuthRequest(message);
      },
      onResume: (Map<String, dynamic> message) async {
        // Used by iOS only (?)
        log("onResume: ");
        _handleIncomingAuthRequest(message);
      },
      onBackgroundMessage: Platform.isIOS
          ? null
          : // iOS does not support this.
          myBackgroundMessageHandler,
    );

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

    if (await StorageUtil.getCurrentFirebaseToken() == null) {
      // This is the initial setup
      await StorageUtil.setCurrentFirebaseToken(firebaseToken);
    }

    firebaseMessaging.onTokenRefresh.listen((newToken) async {
      if ((await StorageUtil.getCurrentFirebaseToken()) != newToken) {
        log("New firebase token generated: $newToken",
            name: 'main_screen.dart');
        await StorageUtil.setNewFirebaseToken(newToken);
        _updateFirebaseToken();
      }
    });

    return firebaseToken;
  }

  /// This method attempts to update the fbToken for all PushTokens that can be
  /// updated. I.e. all tokens that know the url of their respective privacyIDEA
  /// server. If the update fails for one or all tokens, this method does *not*
  /// give any feedback!.
  ///
  /// This should only be used to attempt to update the fbToken automatically,
  /// as this can not be guaranteed to work, there is a manual option available
  /// through the settings also.
  void _updateFirebaseToken() async {
    String newToken = await StorageUtil.getNewFirebaseToken();

    if (newToken == null) {
      // Nothing to update here!
      return;
    }

    List<PushToken> tokenList = (await StorageUtil.loadAllTokens())
        .whereType<PushToken>()
        .where((t) => t.url != null)
        .toList();

    bool allUpdated = true;

    for (PushToken p in tokenList) {
      // POST /ttype/push HTTP/1.1
      //Host: example.com
      //
      //new_fb_token=<new firebase token>
      //serial=<tokenserial>element
      //timestamp=<timestamp>
      //signature=SIGNATURE(<new firebase token>|<tokenserial>|<timestamp>)

      String timestamp = DateTime.now().toUtc().toIso8601String();

      String message = '$newToken|${p.serial}|$timestamp';

      String signature = p.privateTokenKey == null
          ? await Legacy.sign(p.serial, message)
          : createBase32Signature(p.getPrivateTokenKey(), utf8.encode(message));

      Response response =
          await doPost(sslVerify: p.sslVerify, url: p.url, body: {
        'new_fb_token': newToken,
        'serial': p.serial,
        'timestamp': timestamp,
        'signature': signature
      });

      if (response.statusCode == 200) {
        log('Updating firebase token for push token: ${p.serial} succeeded!',
            name: 'main_screen.dart');
      } else {
        log('Updating firebase token for push token: ${p.serial} failed!',
            name: 'main_screen.dart');
        allUpdated = false;
      }
    }

    if (allUpdated) {
      StorageUtil.setCurrentFirebaseToken(newToken);
    }
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
    _loadTokenList(); // Update UI
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
          _showNotification(token, pushRequest, false);
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

  /// Builds the body of the screen. If any tokens supports polling,
  /// returns a list wrapped in a RefreshIndicator to manually poll.
  /// If not returns the list only.
  Widget _buildBody() {
    ListView list = ListView.separated(
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

    bool allowManualRefresh =
        _tokenList.any((t) => t is PushToken && t.url != null);

    return allowManualRefresh
        ? RefreshIndicator(
            child: list,
            onRefresh: () async {
              _showMessage(AppLocalizations.of(context).pollingChallenges,
                  Duration(seconds: 1));
              await _pollForRequests();
            },
          )
        : list;
  }

  void _removeToken(Token token) async {
    log("Remove: $token");
    await StorageUtil.deleteToken(token);

    if (!(await StorageUtil.loadAllTokens())
        .any((element) => element is PushToken)) {
      StorageUtil.deleteGlobalFirebaseConfig();
    }

    await _loadTokenList();
  }

  List<Widget> _buildActionMenu() {
    return <Widget>[
      PopupMenuButton<String>(
        onSelected: (String value) async {
          if (value == "about") {
//              clearLicenses(), // This is used for testing purposes only.
            addAllLicenses();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomLicenseScreen(),
              ),
            );
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
                  builder: (context) => SettingsScreen(),
                )).then((value) => _loadTokenList());
          } else if (value == 'guide') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GuideScreen(),
              ),
            );
          }
        },
        elevation: 5.0,
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: "add_manually",
            child: Text(AppLocalizations.of(context).addToken),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: "settings",
            child: Text(AppLocalizations.of(context).settings),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: "about",
            child: Text(AppLocalizations.of(context).about),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: "guide",
            child: Text(AppLocalizations.of(context).guide),
          ),
        ],
      ),
    ];
  }

  _addToken(Token newToken) {
    log("Adding new token:", name: "main_screen.dart", error: newToken);
    if (newToken != null) {
      _tokenList.add(newToken);

      if (mounted) {
        setState(() {});
      }
    }
  }

  _showMessage(String message, Duration duration) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: duration,
    ));
  }
}
