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
import 'package:catcher/catcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
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
import 'package:uni_links/uni_links.dart';
import 'package:uuid/uuid.dart';

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

  Timer? _pollTimer;

  // Used for handling links the app is registered to handle.
  StreamSubscription? _uniLinkStream;

  void _showChangelogAndGuide() async {
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
  }

  void _updateFbTokenOnChange() async {
    String? newToken = await StorageUtil.getNewFirebaseToken();

    if (newToken != null &&
        (await StorageUtil.getCurrentFirebaseToken()) != newToken) {
      _updateFirebaseToken();
    }
  }

  void _startPollingIfEnabled() {
    AppSettings.of(context).streamEnablePolling().listen(
      (bool event) {
        if (event) {
          log('Polling is enabled.', name: 'main_screen.dart');
          _pollTimer =
              Timer.periodic(Duration(seconds: 3), (_) => _pollForRequests());
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
  }

  @override
  void initState() {
    super.initState();
    _initLinkHandling();
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

  @override
  void afterFirstRender() {
    _showChangelogAndGuide();
    _updateFbTokenOnChange();
    _startPollingIfEnabled();
  }

  @override
  void onPause() {}

  @override
  void onResume() {}

  Future<bool> _pollForRequests() async {
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
      AppSettings.of(context).enablePolling = false;
      return false;
    }

    // Start request for each token
    for (PushToken p in pushTokens) {
      String timestamp = DateTime.now().toUtc().toIso8601String();

      // Legacy android tokens are signed differently
      String message = '${p.serial}|$timestamp';
      String signature = p.privateTokenKey == null
          ? await Legacy.sign(p.serial, message)
          : createBase32Signature(
              p.getPrivateTokenKey()!, utf8.encode(message) as Uint8List);

      Map<String, String> parameters = {
        'serial': p.serial,
        'timestamp': timestamp,
        'signature': signature,
      };

      try {
        Response response = await doGet(
            url: p.url!, parameters: parameters, sslVerify: p.sslVerify);

        if (response.statusCode == 200) {
          // The signature of this message must not be verified as each push
          // request gets verified independently.
          Map<String, dynamic> result = jsonDecode(response.body)['result'];
          List dataList = result['value'];

          for (Map<String, dynamic> data
              in dataList as Iterable<Map<String, dynamic>>) {
            _handleIncomingAuthRequest(RemoteMessage(data: data));
          }
        } else {
          // Error messages can only be distinguished by their text content,
          // not by their error code. This would make error handling complex.
        }
      } on SocketException {
        log(
          'Polling push tokens not working, server can not be reached.',
          name: 'main_screen.dart',
        );
        return false;
      }
    }

    return true;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _uniLinkStream?.cancel();
    super.dispose();
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
          overflow: TextOverflow.ellipsis,
          // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
        ),
        actions: _buildActionMenu(),
        leading: SvgPicture.asset('res/logo/app_logo_light.svg'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scanQRCode(),
        tooltip: AppLocalizations.of(context)!.scanQrCode,
        child: Icon(Icons.add),
      ),
    );
  }

  _handleOtpAuth(String? otpAuth) async {
    if (otpAuth == null) {
      return;
    }

    log(
      "Try to handle otpAuth:",
      name: "main_screen.dart",
      error: otpAuth,
    );

    try {
      // TODO get crash report recipients from map and set in settings
      //  and for Catcher.
      Map<String, dynamic> barcodeMap = parseQRCodeToMap(otpAuth);
      // AppSetting.of(context).add...
//      Catcher.instance.updateConfig();

      Token newToken = await _buildTokenFromMap(barcodeMap, Uri.parse(otpAuth));

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

      await StorageUtil.saveOrReplaceToken(newToken);
      await _initNotifications();
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

  _scanQRCode() async {
    String? barcode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScannerScreen()),
    );
    await _handleOtpAuth(barcode);
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
    String issuer = uriMap[URI_ISSUER];

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
    if (type == "hotp") {
      return HOTPToken(
        label: label,
        issuer: issuer,
        id: uuid,
        algorithm: mapStringToAlgorithm(algorithm),
        digits: digits,
        secret: encodeSecretAs(secret, Encodings.base32),
        counter: uriMap[URI_COUNTER],
      );
    } else if (type == "totp") {
      return TOTPToken(
        label: label,
        issuer: issuer,
        id: uuid,
        algorithm: mapStringToAlgorithm(algorithm),
        digits: digits,
        secret: encodeSecretAs(secret, Encodings.base32),
        period: uriMap[URI_PERIOD],
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

  Future<String?> _initFirebase() async {
    _initNotifications();
    log("Initializing firebase.", name: "main_screen.dart");

    // Delete old / secondary firebase app if it exists.
    try {
      Firebase.app('privacyidea_authenticator').delete();
    } on FirebaseException {
      // ignore if it does not exist
    }

    await Firebase.initializeApp();

    await _initNotifications();

    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onMessage
        .listen((RemoteMessage message) => _handleIncomingAuthRequest(message));
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // TODO Find out if this is necessary on ios (we do not want firebase to
    //  show any notifications itself)
    //Ask user to allow notifications
    //, if declined no notifications are shown
    //for incoming push requests.
    // if (Platform.isIOS) {
    //   await firebaseMessaging.requestNotificationPermissions();
    // }

    String? firebaseToken = await FirebaseMessaging.instance.getToken();
    log("Firebase initialized, token added",
        name: "main_screen.dart", error: firebaseToken);

    // The Firebase Plugin will throw a network exception, but that does not reach
    //  the flutter part of the app. That is why we need to throw our own
    //  exception in this case.
    if (firebaseToken == null) {
      throw PlatformException(
          message:
          "Firebase token could not be retrieved, the only know cause of this is"
              " that the firebase servers could not be reached.",
          code: FIREBASE_TOKEN_ERROR_CODE);
    }

    if (await StorageUtil.getCurrentFirebaseToken() == null) {
      // This is the initial setup
      await StorageUtil.setCurrentFirebaseToken(firebaseToken);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if ((await StorageUtil.getCurrentFirebaseToken()) != newToken) {
        log("New firebase token generated: $newToken",
            name: 'main_screen.dart');
        await StorageUtil.setNewFirebaseToken(newToken);
        _updateFirebaseToken();
      }
    });

    return firebaseToken;
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    log("Background message received.",
        name: "main_screen.dart", error: message);
    await StorageUtil.protect(() async => _handleIncomingRequest(
        message, await StorageUtil.loadAllTokens(), true));
  }

  void _handleIncomingAuthRequest(RemoteMessage message) async {
    log("Foreground message received.",
        name: "main_screen.dart", error: message);
    await StorageUtil.protect(() async => _handleIncomingRequest(
        message, await StorageUtil.loadAllTokens(), false));
    _loadTokenList(); // Update UI
  }

  /// This method attempts to update the fbToken for all PushTokens that can be
  /// updated. I.e. all tokens that know the url of their respective privacyIDEA
  /// server. If the update fails for one or all tokens, this method does *not*
  /// give any feedback!.
  ///
  /// This should only be used to attempt to update the fbToken automatically,
  /// as this can not be guaranteed to work. There is a manual option available
  /// through the settings also.
  void _updateFirebaseToken() async {
    String? newToken = await StorageUtil.getNewFirebaseToken();

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
          : createBase32Signature(
              p.getPrivateTokenKey()!, utf8.encode(message) as Uint8List);

      Response response =
          await doPost(sslVerify: p.sslVerify!, url: p.url!, body: {
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

  /// Handles incoming push requests by verifying the challenge and adding it
  /// to the token. This should be guarded by a lock.
  static Future<void> _handleIncomingRequest(
      RemoteMessage message, List<Token> tokenList, bool inBackground) async {
    // This allows for handling push on ios, android and polling.
    // var data = message['data'] == null ? message : message['data'];
    var data = message.data;

    Uri requestUri = Uri.parse(data['url']);
    String requestedSerial = data['serial'];

    log('Incoming push auth request for token with serial.',
        name: 'main_screen.dart', error: requestedSerial);

    PushToken? token = tokenList
        .whereType<PushToken>()
        .firstWhere((t) => t.serial == requestedSerial && t.isRolledOut);

    // FIXME What if the tokens does not exist? firstWhere cannot handle that
    if (token == null) {
      log("The requested token does not exist or is not rolled out.",
          name: "main_screen.dart", error: requestedSerial);
    } else {
      // Uri requestUri = data['uri'] == null ? token.url : Uri.parse(data['url']);
      Uri requestUri = Uri.parse(data['url']);

      log('Token matched requested token',
          name: 'main_screen.dart', error: token);
      String signature = data['signature'];
      String signedData = '${data['nonce']}|'
          '${data['url']}|'
          '${data['serial']}|'
          '${data['question']}|'
          '${data['title']}|'
          '${data['sslverify']}';

      bool sslVerify = (int.tryParse(data['sslverify']) ?? 0) == 1;

      // Re-add url and sslverify to android legacy tokens:
      token.url ??= Uri.parse(data['url']);
      token.sslVerify ??= sslVerify;

      bool isVerified = token.privateTokenKey == null
          ? await Legacy.verify(token.serial, signedData, signature)
          : verifyRSASignature(token.getPublicServerKey()!,
              utf8.encode(signedData) as Uint8List, base32.decode(signature));

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
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      ),
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
            getFirebaseToken: () => _initFirebase(),
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
              _showMessage(AppLocalizations.of(context)!.pollingChallenges,
                  Duration(seconds: 1));
              bool success = await _pollForRequests();
              if (!success) {
                _showMessage(
                  AppLocalizations.of(context)!.pollingFailNoNetworkConnection,
                  Duration(seconds: 3),
                );
              }
            },
          )
        : list;
  }

  void _removeToken(Token token) async {
    log("Remove: $token");
    await StorageUtil.deleteToken(token);
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
            child: Text(AppLocalizations.of(context)!.addToken),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: "settings",
            child: Text(AppLocalizations.of(context)!.settings),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: "about",
            child: Text(AppLocalizations.of(context)!.about),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: "guide",
            child: Text(AppLocalizations.of(context)!.guide),
          ),
        ],
      ),
    ];
  }

  _addToken(Token? newToken) {
    log("Adding new token:", name: "main_screen.dart", error: newToken);
    if (newToken != null) {
      _tokenList.add(newToken);

      if (mounted) {
        setState(() {});
      }
    }
  }

  _showMessage(String message, Duration duration) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: duration,
    ));
  }

  Future<void> _initNotifications() async {
    // Stop here if no push tokens exist, we do not want to ask for permissions
    // on iOS.
    if (!(await StorageUtil.loadAllTokens())
        .any((element) => element is PushToken)) {
      return;
    }
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}
