import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mutex/mutex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:privacyidea_authenticator/widgets/home_widgets/home_widget_copied.dart';
import 'package:privacyidea_authenticator/widgets/home_widgets/home_widget_unlinked.dart';

import '../interfaces/repo/token_repository.dart';
import '../main_netknights.dart';
import '../model/processors/scheme_processors/home_widget_processor.dart';
import '../model/tokens/day_password_token.dart';
import '../model/tokens/hotp_token.dart';
import '../model/tokens/otp_token.dart';
import '../model/tokens/token.dart';
import '../model/tokens/totp_token.dart';
import '../repo/secure_token_repository.dart';
import '../widgets/home_widgets/home_widget_action.dart';
import '../widgets/home_widgets/home_widget_background.dart';
import '../widgets/home_widgets/home_widget_configure.dart';
import '../widgets/home_widgets/home_widget_hidden.dart';
import '../widgets/home_widgets/home_widget_otp.dart';
import 'app_customizer.dart';
import 'logger.dart';

/// This function is called on any interaction with the HomeWidget
@pragma('vm:entry-point')
void homeWidgetBackgroundCallback(Uri? uri) {
  if (uri == null) return;
  const HomeWidgetProcessor().process(uri);
}

class HomeWidgetUtils {
  HomeWidgetUtils._();
  static HomeWidgetUtils? _instance;

  /// Check widget_layout.xml for the sizes. Double it for better quality
  static const _widgetBackgroundSize = Size(130 * 2, 65 * 2);

  /// Check widget_layout.xml for the sizes. Double it for better quality
  static const _widgetOtpSize = Size(98 * 2, 40 * 2);

  /// Check widget_layout.xml for the sizes. Double it for better quality
  static const _widgetSettingsSize = Size(14 * 2, 14 * 2);

  /// Check widget_layout.xml for the sizes. Double it for better quality
  static const _widgetActionSize = Size(24 * 2, 24 * 2);

  /// Default duration for showing the OTP
  static const _showDuration = Duration(seconds: 30);

  factory HomeWidgetUtils({TokenRepository? repository}) {
    _instance ??= HomeWidgetUtils._();
    _tokenRepository = repository ?? const SecureTokenRepository();
    return _instance!;
  }

  final _mapTokenAction = <String, FutureOr<void> Function(String)>{
    HOTPToken.tokenType: (widgetId) => _instance?._hotpTokenAction(widgetId),
    // TOTPToken.tokenType: (_) {},
    // DayPasswordToken.tokenType: (_) {},
  };

  /////////////////////////////////////
  /////////// Repository  /////////////
  /////////////////////////////////////
  static TokenRepository? _tokenRepository;
  static final Mutex _repoMutex = Mutex();
  static Future<List<OTPToken>> get _otpTokens async => (await _loadTokensFromRepo()).whereType<OTPToken>().toList();
  static Future<OTPToken?> _getTokenOfTokenId(String? tokenId) async {
    await _repoMutex.acquire();
    final token = (await _loadTokensFromRepo()).firstWhereOrNull((token) => token.id == tokenId);
    _repoMutex.release();
    return token;
  }

  //////////////////////////////////////
  /////// Keys for HomeWidgets /////////
  //////////////////////////////////////
  final keyTokenOtp = '_tokenOtp';
  final keyTokenBackground = '_tokenBackground';
  final keyTokenContainerEmpty = '_tokenContainerEmpty';
  final keySettingsIcon = '_settingsIcon';
  final keyTokenAction = '_tokenAction';
  final keyTokenCopy = '_tokenCopy';

  //////////////////////////////////////
  //// Suffixes for HomeWidgetKeys /////
  //////////////////////////////////////
  final keySuffixHidden = '_hidden'; // first _hidden, then _light or _dark
  final keySuffixLight = '_light'; // example: _hidden_light (if dark mode is disabled and hidden) or _light (if dark mode is disabled and shown)
  final keySuffixDark = '_dark'; // example: _hidden_dark (if dark mode is enabled and hidden) or _dark (if dark mode is enabled and shown)
  final keySuffixActive = '_active'; // first _active, then _light or _dark
  final keySuffixInactive = '_inactive'; // first _inactive, then _light or _dark

  ////////////////////////////////////////
  ////// Keys for Shared Variables ///////
  ////////////////////////////////////////
  final keyWidgetIds = '_widgetIds'; // recive the all widgetIds of linked tokens, seperated by ','
  final keyShowToken = '_showWidget'; // recive a bool if the token of the linked widget should be shown. true = show, false = hide. Example: _showWidget32
  final keyTokenId = '_tokenId'; //  recive the tokenId of a linked token. Example: _tokenId32
  final keyThemeCustomization = '_themeCustomization';
  final keyCurrentThemeMode = '_currentThemeMode';
  final keyTokenType = '_tokenType';
  final keyTotpToken = '_${TOTPToken.tokenType}';
  final keyHotpToken = '_${HOTPToken.tokenType}';
  final keyDayPasswordToken = '_${DayPasswordToken.tokenType}';
  final keyCopyText = '_copyText';
  final keyTokenLocked =
      '_tokenLocked'; // recive a bool if the token of the linked widget is locked. true = locked, false = not locked. Example: _tokenLocked32
  final keyWidgetIsRebuilding = '_widgetIsRebuilding';
  final keyActionBlocked =
      '_actionBlocked'; // recive a bool if the action of the linked widget is blocked. true = blocked, false = not blocked. _actionBlocked${token.id}
  final keyCopyBlocked =
      '_copyBlocked'; // recive a bool if the copy of the linked widget is blocked. true = blocked, false = not blocked. _copyBlocked${widgetId} Example: _copyBlocked32
  final keyRebuildingWidgetIds =
      '_rebuildingWidgetIds'; // recive the widgetIds that should be updated after the HomeWidget is ready. each widgetId is seperated by ',' Example value: "32,33,35"

  ////////////////////////////////////////
  /////// Getter & Getterfunctions ///////
  ////////////////////////////////////////
  Future<List<String>> get _widgetIds async => (await HomeWidget.getWidgetData<String?>(keyWidgetIds))?.split(',') ?? <String>[];
  static Future<String> get _packageName async =>
      kDebugMode ? (await PackageInfo.fromPlatform()).packageName.replaceAll('.debug', '') : (await PackageInfo.fromPlatform()).packageName;
  static Future<List<OTPToken>> _loadTokensFromRepo() async => (await _tokenRepository?.loadTokens())?.whereType<OTPToken>().toList() ?? [];
  static Future<void>? _saveTokensToRepo(List<OTPToken> tokens) => _tokenRepository?.saveOrReplaceTokens(tokens);

  // static Future<List<OTPToken>> _getTokensOfTokenIds(List<String> tokenIds) async {
  //   await _repoMutex.acquire();
  //   final tokens = tokenIds.isEmpty ? <OTPToken>[] : (await _loadTokensFromRepo()).where((token) => tokenIds.contains(token.id)).toList();
  //   _repoMutex.release();
  //   return tokens;
  // }

  Future<String?> getTokenIdOfWidgetId(String widgetId) async => await HomeWidget.getWidgetData<String?>('$keyTokenId$widgetId');

  Future<OTPToken?> getTokenOfWidgetId(String? widgetId) async => widgetId == null ? null : _getTokenOfTokenId(await getTokenIdOfWidgetId(widgetId));

  Future<Map<String, OTPToken?>> _getTokensOfWidgetIds(List<String> widgetIds) async {
    final tokenMap = <String, OTPToken?>{};
    final allTokens = await _otpTokens;
    for (String widgetId in widgetIds) {
      final tokenId = await HomeWidget.getWidgetData<String?>('$keyTokenId$widgetId');
      final token = allTokens.firstWhereOrNull((element) => element.id == tokenId);
      tokenMap[widgetId] = token;
    }
    return tokenMap;
  }

  Future<List<String>> _getWidgetIdsOfTokens(List<String> tokenIds) async {
    final widgetIds = <String>[];
    for (String widgetId in (await _widgetIds)) {
      if (tokenIds.contains(await getTokenIdOfWidgetId(widgetId))) {
        widgetIds.add(widgetId);
      }
    }
    return widgetIds;
  }

  ThemeData? _themeDataDark;
  ThemeData? _themeDataLight;
  Future<ThemeData> _getThemeData({bool dark = false}) async {
    if (dark) {
      return _themeDataDark ??=
          ThemeCustomization.fromJson(jsonDecode(await HomeWidget.getWidgetData<String>('$keyThemeCustomization$keySuffixDark') ?? '{}')).generateTheme();
    } else {
      return _themeDataLight ??=
          ThemeCustomization.fromJson(jsonDecode(await HomeWidget.getWidgetData<String>('$keyThemeCustomization$keySuffixLight') ?? '{}')).generateTheme();
    }
  }

  Future<bool> get _widgetIsRebuilding async => await HomeWidget.getWidgetData<bool>(keyWidgetIsRebuilding) ?? false;

  ////////////////////////////////////////
  /////////// Public Methods /////////////
  ////////////////////////////////////////
  /// Note: Prefer to call private methods inside of Public Methods to avoid unnecessary rendering ///

  /// This method has to be called at least once before any other method is called
  Future<void> homeWidgetInit({TokenRepository? repository}) async {
    if (repository != null) _tokenRepository = repository;
    await HomeWidget.setAppGroupId(await _packageName);
    await _setThemeCustomization();
    await _updateStaticWidgets();
    await _resetAllTokens();
    await _notifyUpdate(await _widgetIds);
  }

  Future<void> _resetAllTokens() async {
    final widgetIds = await _widgetIds;
    final futures = <Future>[];
    for (String widgetId in widgetIds) {
      final tokenId = await getTokenIdOfWidgetId(widgetId);
      futures.add(HomeWidget.saveWidgetData('$keyShowToken$widgetId', false));
      futures.add(HomeWidget.saveWidgetData('$keyCopyBlocked$widgetId', false));
      futures.add(HomeWidget.saveWidgetData('$keyActionBlocked$tokenId', false));
    }
    await Future.wait(futures);
  }

  Future<void> setCurrentThemeMode(ThemeMode themeMode) async {
    await _setCurrentThemeMode(themeMode);
    await _notifyUpdate(await _widgetIds);
  }

  // Call AFTER saving to the repository
  Future<void> updateTokenIfLinked(Token token) async {
    final updatedIds = await _updateTokenIfLinked(token);
    await _notifyUpdate(updatedIds);
  }

  // Call AFTER saving to the repository
  Future<void> updateTokensIfLinked(List<Token> tokens) async {
    // Map<widgetId, tokenId>
    Map<String, OTPToken?> widgetIdTokenIdMap = {};
    final hotpTokens = tokens.whereType<HOTPToken>().toList();
    final hotpTokenIds = hotpTokens.map((e) => e.id).toList();
    final linkedWidgetIds = await _getWidgetIdsOfTokens(hotpTokenIds);
    for (String widgetId in linkedWidgetIds) {
      final tokenId = await getTokenIdOfWidgetId(widgetId);
      final hotpToken = hotpTokens.firstWhereOrNull((element) => element.id == tokenId);
      if (tokenId != null) {
        widgetIdTokenIdMap[widgetId] = hotpToken;
      }
    }
    for (String widgetId in widgetIdTokenIdMap.keys) {
      final hotpToken = widgetIdTokenIdMap[widgetId];
      if (hotpToken == null) continue;
      await _updateHomeWidgetHideOtp(hotpToken, widgetId);
    }
    await _notifyUpdate(widgetIdTokenIdMap.keys);
  }

  Future<void> link(String widgetId, String tokenId) async {
    Logger.info('Linking HomeWidget with id $widgetId to token $tokenId');
    final token = await _getTokenOfTokenId(tokenId);
    if (token == null) {
      await unlink(widgetId);
      return;
    }
    await HomeWidget.saveWidgetData('$keyTokenId$widgetId', tokenId);
    await HomeWidget.saveWidgetData('$keyTokenLocked$widgetId', token.isLocked);
    await _updateHomeWidgetHideOtp(token, widgetId);
    await _setTokenType(widgetId, token.type);
    await _notifyUpdate([widgetId]);
  }

  Future<void> unlink(String widgetId) async {
    await _unlink(widgetId);
    await _notifyUpdate([widgetId]);
  }

  Future<void> showOtp(String widgetId) async {
    OTPToken? otpToken = await getTokenOfWidgetId(widgetId);

    if (otpToken == null) {
      await unlink(widgetId);
      return;
    }
    if (otpToken.isLocked) return;

    await _updateHomeWidgetShowOtp(otpToken, widgetId);
    await HomeWidget.saveWidgetData('$keyShowToken$widgetId', true);

    await _notifyUpdate([widgetId]);
    _hideOtpDelayed(widgetId, otpToken.otpValue.length);
  }

  Future<void> handleChangedTokenState() async {
    final idTokenPairs = await _getTokensOfWidgetIds(await _widgetIds);
    final homeWidgetChanges = <Future>[];
    for (String widgetId in idTokenPairs.keys) {
      final token = idTokenPairs[widgetId];
      if (token == null) {
        homeWidgetChanges.add(_unlink(widgetId));
        continue;
      }
      homeWidgetChanges.add(HomeWidget.saveWidgetData('$keyTokenLocked$widgetId', token.isLocked));
      homeWidgetChanges.add(HomeWidget.saveWidgetData('$keyShowToken$widgetId', false));
      homeWidgetChanges.add(_updateHomeWidgetHideOtp(token, widgetId));
    }
    await Future.wait(homeWidgetChanges);
    await _notifyUpdate(idTokenPairs.keys);
  }

  /// widgetId,Timer
  final Map<String, Timer?> _copyTimers = {};
  static const _copyDelay = Duration(seconds: 2);
  Future<void> copyOtp(String widgetId) async {
    final copyTimer = _copyTimers[widgetId];
    if (copyTimer != null && copyTimer.isActive) {
      Logger.info('Copy blocked');
      return;
    }
    final token = await getTokenOfWidgetId(widgetId);
    if (token == null) {
      await unlink(widgetId);
      return;
    }

    HomeWidget.saveWidgetData('$keyCopyBlocked$widgetId', true);

    _copyTimers[widgetId] = Timer(_copyDelay, () async {
      Logger.info('Unblocked copy');
      await HomeWidget.saveWidgetData('$keyCopyBlocked$widgetId', false);
      await showOtp(widgetId);
    });

    _hideOtpDelayed(widgetId, token.otpValue.length);
    await _setCopyText(token.otpValue);
    await _notifyUpdate([widgetId]);
  }

  /// tokenId,Timer
  final Map<String, Timer?> _actionTimers = {};
  Future<void> performAction(String widgetId) async {
    final token = await getTokenOfWidgetId(widgetId);
    final tokenId = token?.id;
    if (tokenId == null) {
      await unlink(widgetId);
      return;
    }
    final tokenAction = _mapTokenAction[token!.type];
    if (tokenAction == null) return;
    final actionTimer = _actionTimers[tokenId];
    if (actionTimer != null && actionTimer.isActive) {
      Logger.info('Action blocked');
      return;
    }
    HomeWidget.saveWidgetData('$keyActionBlocked$tokenId', true);
    final widgetIds = await _getWidgetIdsOfTokens([token.id]);
    _actionTimers[tokenId] = Timer(const Duration(seconds: 1), () async {
      Logger.info('Unblocked action');
      await HomeWidget.saveWidgetData('$keyActionBlocked$tokenId', false);
      await _notifyUpdate(widgetIds);
    });

    await _mapTokenAction[token.type]?.call(widgetId);
    Logger.info('Performing action');
    await _notifyUpdate(widgetIds);
  }

  ////////////////////////////////////////
  ////////// Private Methods /////////////
  ////////////////////////////////////////
  Future<void> _updateStaticWidgets() async {
    await _updateHomeWidgetUnlinked();
    await _updateHomeWidgetCopied();
    await _updateHwackground();
    await _updateHwConfigIcon();
    await _updateHwActionIcons();
  }

  Future<void> _updateHwActionIcons() async {
    await _updateHotpActionIcon();
    await _updateTotpActionIcon();
    await _updateDayPasswordActionIcon();
  }

  //   Map<widgetId, timer> _hideTimers
  final Map<String, Timer> _hideTimers = {};
  void _hideOtpDelayed(String widgetId, int otpLength) {
    _hideTimers[widgetId]?.cancel();
    _hideTimers[widgetId] = Timer(_showDuration, () async {
      await HomeWidget.saveWidgetData('$keyShowToken$widgetId', false);
      await _notifyUpdate([widgetId]);
    });
  }

  Future<void> _unlink(String widgetId) async {
    Logger.info('Unlinking HomeWidget with id $widgetId');
    await HomeWidget.saveWidgetData('$keyTokenId$widgetId', null);
    await _updateHomeWidgetUnlinked();
    await _removeTokenType(widgetId);
  }

  Future<void> _hotpTokenAction(String widgetId) async {
    var token = await getTokenOfWidgetId(widgetId);
    if (token == null) {
      await unlink(widgetId);
      return;
    }
    if (token is! HOTPToken) return;
    token = token.copyWith(counter: token.counter + 1);

    await _repoMutex.acquire();
    final allTokens = await _loadTokensFromRepo();
    allTokens[allTokens.indexWhere((t) => t.id == token!.id)] = token;
    await _saveTokensToRepo(allTokens);
    _repoMutex.release();
    await _updateTokenIfLinked(token);
    // await showOtp(widgetId);
  }

  // Call AFTER saving to the repository
  Future<List<String>> _updateTokenIfLinked(Token token) async {
    if (token is! OTPToken) return [];
    final widgetIds = await _getWidgetIdsOfTokens([token.id]);
    final futures = <Future>[];
    for (String widgetId in widgetIds) {
      futures.add(_updateHomeWidgetHideOtp(token, widgetId));
      futures.add(_updateHomeWidgetShowOtp(token, widgetId));
    }
    await Future.wait(futures);
    return widgetIds;
  }

  ////////////////////////////////////////
  ////////////// Rendering ///////////////
  ////////////////////////////////////////
  Future<dynamic> renderFlutterWidget(Widget widget, {required String key, required Size logicalSize}) => HomeWidget.renderFlutterWidget(
        widget,
        key: '$key',
        logicalSize: logicalSize,
      );

  Future<void> _updateHwackground() async => await HomeWidgetBackgroundBuilder(
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(dark: true),
        logicalSize: _widgetBackgroundSize,
        homeWidgetKey: keyTokenBackground,
        utils: this,
      ).renderFlutterWidgets();

  Future<void> _updateHotpActionIcon() async => await HomeWidgetActionBuilder(
        icon: Icons.replay,
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(dark: true),
        logicalSize: _widgetActionSize,
        homeWidgetKey: '$keyTokenAction$keyHotpToken',
        utils: this,
      ).renderFlutterWidgets(); //  1. Action 2. type 3. active/inactive 4. dark/light Example:   _tokenAction_hotp_active_light or _tokenAction_hotp_inactive_dark

  Future<void> _updateTotpActionIcon() async => await HomeWidgetActionBuilder(
        icon: Icons.timer_outlined,
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(dark: true),
        logicalSize: _widgetActionSize,
        homeWidgetKey: '$keyTokenAction$keyTotpToken',
        utils: this,
      ).renderFlutterWidgets();

  Future<void> _updateDayPasswordActionIcon() async => await HomeWidgetActionBuilder(
        icon: Icons.calendar_today_outlined,
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(dark: true),
        logicalSize: _widgetActionSize,
        homeWidgetKey: '$keyTokenAction$keyDayPasswordToken',
        utils: this,
      ).renderFlutterWidgets();

  Future<void> _updateHomeWidgetShowOtp(OTPToken token, String homeWidgetId) async => await HomeWidgetOtpBuilder(
        otp: token.otpValue,
        label: token.label,
        issuer: token.issuer,
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(dark: true),
        logicalSize: _widgetOtpSize,
        homeWidgetKey: '$keyTokenOtp$homeWidgetId',
        utils: this,
      ).renderFlutterWidgets(); // saved in shared preferences under example: _tokenContainer32_light and _tokenContainer32_dark

  Future<void> _updateHomeWidgetHideOtp(OTPToken token, String homeWidgetId) async => await HomeWidgetHiddenBuilder(
        otpLength: token.otpValue.length,
        label: token.label,
        issuer: token.issuer,
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(dark: true),
        logicalSize: _widgetOtpSize,
        homeWidgetKey: '$keyTokenOtp$homeWidgetId$keySuffixHidden',
        utils: this,
      ).renderFlutterWidgets();

  Future<void> _updateHwConfigIcon() async => await HomeWidgetConfigBuilder(
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(dark: true),
        logicalSize: _widgetSettingsSize,
        homeWidgetKey: keySettingsIcon,
        utils: this,
      ).renderFlutterWidgets();

  Future<void> _updateHomeWidgetUnlinked() async => await HomeWidgetUnlinkedBuilder(
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(dark: true),
        logicalSize: _widgetOtpSize,
        homeWidgetKey: keyTokenContainerEmpty,
        utils: this,
      ).renderFlutterWidgets();

  Future<void> _updateHomeWidgetCopied() async => await HomeWidgetCopiedBuilder(
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(dark: true),
        logicalSize: _widgetOtpSize,
        homeWidgetKey: '$keyTokenCopy',
        utils: this,
      ).renderFlutterWidgets();

  ////////////////////////////////////////
  //////// Saving to SharedPrefs /////////
  ////////////////////////////////////////
  Future<void> _setCurrentThemeMode(ThemeMode themeMode) async => await HomeWidget.saveWidgetData(keyCurrentThemeMode, themeMode.name);

  Future<void> _setTokenType(String widgetId, String tokenType) async =>
      await HomeWidget.saveWidgetData('$keyTokenType$widgetId', tokenType); // _tokenType$widgetId Example: _tokenType32

  Future<void> _removeTokenType(String widgetId) async => await HomeWidget.saveWidgetData('$keyTokenType$widgetId', null);

  Future<void> _setThemeCustomization() async {
    final customization = PrivacyIDEAAuthenticator.customization;
    await HomeWidget.saveWidgetData('$keyThemeCustomization$keySuffixDark', jsonEncode(customization?.darkTheme));
    _themeDataDark = customization?.darkTheme.generateTheme();
    await HomeWidget.saveWidgetData('$keyThemeCustomization$keySuffixLight', jsonEncode(customization?.lightTheme));
    _themeDataLight = customization?.lightTheme.generateTheme();
  }

  Future<void> _setCopyText(String copyText) async => await HomeWidget.saveWidgetData('$keyCopyText', copyText);

  ////////////////////////////////////////
  /////////// Notifiy Update /////////////
  ////////////////////////////////////////

  /// widgetIds that should be updated after the de
  final Set<String> _updatedWidgetIds = {};
  // Used to wait for the HomeWidget to be ready
  Timer? _updateTimer;
  DateTime? _lastUpdate;
  static const _updateDelay = Duration(milliseconds: 250);

  /// This method has to be called after change to the HomeWidget to notify the HomeWidget to update
  Future<void> _notifyUpdate(Iterable<String> updatedWidgetIds) async {
    Logger.info('Update requested for: $updatedWidgetIds');
    if (await _widgetIsRebuilding || _lastUpdate != null && DateTime.now().difference(_lastUpdate!) < _updateDelay) {
      Logger.info('Update delayed: $updatedWidgetIds');
      _updatedWidgetIds.addAll(updatedWidgetIds);
      _updateTimer?.cancel();
      final nextDelayInMs = _updateDelay.inMilliseconds - DateTime.now().difference(_lastUpdate!).inMilliseconds;
      _updateTimer = Timer(nextDelayInMs < 1 ? _updateDelay : Duration(milliseconds: nextDelayInMs), () async {
        Logger.info('Call Update from Timer');
        await _notifyUpdate(_updatedWidgetIds.toList());
      });
      return;
    }
    Logger.info('Notify Update: $updatedWidgetIds');
    _lastUpdate = DateTime.now();
    HomeWidget.saveWidgetData(keyRebuildingWidgetIds, updatedWidgetIds.join(','));
    String packageName = await _packageName;
    await HomeWidget.updateWidget(qualifiedAndroidName: '$packageName.AppWidgetProvider', iOSName: 'AppWidgetProvider');
  }
}
