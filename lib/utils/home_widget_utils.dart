import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mutex/mutex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../interfaces/repo/token_repository.dart';
import '../model/tokens/hotp_token.dart';
import '../model/tokens/totp_token.dart';
import '../repo/secure_token_repository.dart';
import '../model/processors/scheme_processors/home_widget_processor.dart';
import '../model/tokens/day_password_token.dart';
import 'app_customizer.dart';
import 'logger.dart';
import '../widgets/home_widgets/home_widget_container.dart';

import '../main_netknights.dart';
import '../model/tokens/otp_token.dart';
import '../model/tokens/token.dart';

/// This function is called on any interaction with the HomeWidget
@pragma('vm:entry-point')
void homeWidgetBackgroundCallback(Uri? uri) {
  if (uri == null) return;
  const HomeWidgetProcessor().process(uri);
}

class HomeWidgetUtils {
  HomeWidgetUtils._();
  static HomeWidgetUtils? _instance;
  //          Map<widgetId, timer> _hideTimers
  static final Map<String, Timer> _hideTimers = {};
  static const _widgetBackgroundSize = Size(400, 200);
  static const _widgetOtpSize = Size(290, 132);
  static const _widgetSettingsSize = Size(50, 50);
  static const _widgetActionSize = Size(80, 80);

  static const _showDuration = Duration(seconds: 5); // TODO change to 30 seconds

  factory HomeWidgetUtils({TokenRepository? repository}) {
    _instance ??= HomeWidgetUtils._();
    _tokenRepository = repository ?? const SecureTokenRepository();
    return _instance!;
  }

  final _mapTokenAction = <String, FutureOr<void> Function(String)>{
    HOTPToken.tokenType: (widgetId) => _instance?._hotpTokenAction(widgetId),
    TOTPToken.tokenType: (_) {},
    DayPasswordToken.tokenType: (_) {},
  };

  /////////////////////////////////////
  /////////// Repository  /////////////
  /////////////////////////////////////
  static TokenRepository? _tokenRepository;
  static final Mutex _repoMutex = Mutex();
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

  //////////////////////////////////////
  //// Suffixes for HomeWidgetKeys /////
  //////////////////////////////////////
  final keySuffixHidden = '_hidden'; // first _hidden, then _light or _dark
  final keySuffixLight = '_light'; // example: _hidden_light (if dark mode is disabled and hidden) or _light (if dark mode is disabled and shown)
  final keySuffixDark = '_dark'; // example: _hidden_dark (if dark mode is enabled and hidden) or _dark (if dark mode is enabled and shown)
  final keySuffixActive = '_active'; // first _active, then _light or _dark
  final keySuffixInactive = '_inactive'; // first _inactive, then _light or _dark

  ////////////////////////////////////////
  /////// Keys for Shared Strings ////////
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

  ////////////////////////////////////////
  /////// Getter & Getterfunctions ///////
  ////////////////////////////////////////
  Future<List<String>> get _widgetIds async => (await HomeWidget.getWidgetData<String?>(keyWidgetIds))?.split(',') ?? <String>[];
  static Future<String> get _packageName async =>
      kDebugMode ? (await PackageInfo.fromPlatform()).packageName.replaceAll('.debug', '') : (await PackageInfo.fromPlatform()).packageName;
  static Future<List<OTPToken>> _loadTokensFromRepo() async => (await _tokenRepository?.loadTokens())?.whereType<OTPToken>().toList() ?? [];
  static Future<void>? _saveTokensToRepo(List<OTPToken> tokens) => _tokenRepository?.saveOrReplaceTokens(tokens);

  static Future<List<OTPToken>> _getTokensOfTokenIds(List<String> widgetIds) async {
    await _repoMutex.acquire();
    final tokens = widgetIds.isEmpty ? <OTPToken>[] : (await _loadTokensFromRepo()).where((token) => widgetIds.contains(token.id)).toList();
    _repoMutex.release();
    return tokens;
  }

  Future<OTPToken?> _getTokenOfWidgetId(String? widgetId) async {
    final tokenId = await HomeWidget.getWidgetData<String?>('$keyTokenId$widgetId');
    Logger.info('_getTokenOfWidgetId: $tokenId');
    return widgetId == null ? null : _getTokenOfTokenId(await HomeWidget.getWidgetData<String?>('$keyTokenId$widgetId'));
  }

  Future<String?> _getWidgetIdOfTokenId(String tokenId) async {
    for (String widgetId in (await _widgetIds)) {
      if (await HomeWidget.getWidgetData<String?>('$keyTokenId$widgetId') == tokenId) {
        return widgetId;
      }
    }
    return null;
  }

  Future<List<String>> _getWidgetIdsOfTokens(List<String> tokenIds) async {
    final widgetIds = <String>[];
    for (String widgetId in (await _widgetIds)) {
      if (tokenIds.contains(await HomeWidget.getWidgetData<String?>('$keyTokenId$widgetId'))) {
        widgetIds.add(widgetId);
      }
    }
    return widgetIds;
  }

  Future<ThemeData> _getThemeData({bool isDark = false}) async => isDark
      ? ThemeCustomization.fromJson(jsonDecode(await HomeWidget.getWidgetData<String>('$keyThemeCustomization$keySuffixDark') ?? '{}')).generateTheme()
      : ThemeCustomization.fromJson(jsonDecode(await HomeWidget.getWidgetData<String>('$keyThemeCustomization$keySuffixLight') ?? '{}')).generateTheme();

  ////////////////////////////////////////
  /////////// Public Methods /////////////
  ////////////////////////////////////////
  /// Note: Prefer to call private methods inside of Public Methods to avoid unnecessary rendering ///

  /// This method has to be called at least once before any other method is called
  Future<void> homeWidgetInit({TokenRepository? repository}) async {
    if (repository != null) _tokenRepository = repository;
    await HomeWidget.setAppGroupId(await _packageName);
    await _updateStaticWidgets();
    await _setThemeCustomization();
    await _notifyUpdate();
  }

  Future<void> setCurrentThemeMode(ThemeMode themeMode) async {
    await _setCurrentThemeMode(themeMode);
    await _notifyUpdate();
  }

  // Call AFTER saving to the repository
  Future<void> updateTokenIfLinked(Token token) async {
    if (token is! OTPToken) return;
    final widgetId = await _getWidgetIdOfTokenId(token.id);
    if (widgetId == null) return;
    await _updateHwContainerHideOtp(token, widgetId);
    await _notifyUpdate();
  }

  // Call AFTER saving to the repository
  Future<void> updateTokensIfLinked(List<Token> tokens) async {
    // Map<widgetId, tokenId>
    Map<String, OTPToken> widgetIdTokenIdMap = {};
    final hotpTokens = tokens.whereType<HOTPToken>().toList();
    final hotpTokenIds = hotpTokens.map((e) => e.id).toList();
    final linkedWidgetIds = await _getWidgetIdsOfTokens(hotpTokenIds);
    for (String widgetId in linkedWidgetIds) {
      final tokenId = await HomeWidget.getWidgetData<String?>('$keyTokenId$widgetId');
      final hotpToken = hotpTokens.firstWhereOrNull((element) => element.id == tokenId);
      if (tokenId != null && hotpToken != null) {
        widgetIdTokenIdMap[widgetId] = hotpToken;
      }
    }
    for (String widgetId in widgetIdTokenIdMap.keys) {
      final hotpToken = widgetIdTokenIdMap[widgetId];
      if (hotpToken == null) continue;
      await _updateHwContainerHideOtp(hotpToken, widgetId);
    }
    await _notifyUpdate();
  }

  Future<void> link(String widgetId, String tokenId) async {
    Logger.info('Linking HomeWidget with id $widgetId to token $tokenId');
    final token = await _getTokenOfTokenId(tokenId);
    if (token == null) {
      await unlink(widgetId);
      return;
    }
    await HomeWidget.saveWidgetData('$keyTokenId$widgetId', tokenId);
    await _updateHwContainerHideOtp(token, widgetId);
    await _setTokenType(widgetId, token.type);
    await _notifyUpdate();
  }

  Future<void> unlink(String widgetId) async {
    Logger.info('Unlinking HomeWidget with id $widgetId');
    _hideTimers[widgetId]?.cancel();
    await HomeWidget.saveWidgetData('$keyTokenId$widgetId', null);
    await _updateHwContainerEmpty();
    await _removeTokenType(widgetId);
    await _notifyUpdate();
  }

  Future<void> showOtp(String widgetId) async {
    Logger.warning('widgetId: $widgetId');
    OTPToken? otpToken = await _getTokenOfWidgetId(widgetId);

    if (otpToken == null) {
      await unlink(widgetId);
      return;
    }
    if (otpToken.isLocked) {
      await _updateHwContainerLocked(widgetId);
      return;
    }
    await _updateHwContainerShowOtp(otpToken, widgetId);
    await HomeWidget.saveWidgetData('$keyShowToken$widgetId', true);

    await _notifyUpdate();
    _hideOtpDelayed(widgetId, otpToken.otpValue.length);
  }

  Future<void> hideOtp(String widgetId) async {
    final token = await _getTokenOfWidgetId(widgetId);
    if (token == null) {
      await unlink(widgetId);
      return;
    }
    await _updateHwContainerHideOtp(token, widgetId);
    await _notifyUpdate();
  }

  Future<void> copyOtp(String widgetId) async {
    Logger.warning('widgetId: $widgetId');
    final token = await _getTokenOfWidgetId(widgetId);
    if (token == null) {
      await unlink(widgetId);
      return;
    }
    _hideOtpDelayed(widgetId, token.otpValue.length);
    await _setCopyText(token.otpValue);
    await _notifyUpdate();
  }

  Future<void> performAction(String widgetId) async {
    Logger.warning('widgetId: $widgetId');
    final token = await _getTokenOfWidgetId(widgetId);
    if (token == null) {
      await unlink(widgetId);
      return;
    }
    await _mapTokenAction[token.type]?.call(widgetId);
    await _notifyUpdate();
  }

  Future<void> _hotpTokenAction(String widgetId) async {
    var token = await _getTokenOfWidgetId(widgetId);
    Logger.warning('widgetId: $widgetId');
    Logger.warning('token: $token');
    if (token == null) {
      await unlink(widgetId);
      return;
    }
    if (token is! HOTPToken) return;
    token = token.copyWith(counter: token.counter + 1);

    await _repoMutex.acquire();
    final allTokens = await _loadTokensFromRepo();
    allTokens[allTokens.indexWhere((t) => t.id == token!.id)] = token;
    _saveTokensToRepo(allTokens);
    _repoMutex.release();
    await showOtp(widgetId);
  }

  ////////////////////////////////////////
  ////////// Private Methods /////////////
  ////////////////////////////////////////
  Future<void> _updateStaticWidgets() async {
    await _updateHwContainerEmpty();

    await _updateHwackground();
    await _updateHwSettingsIcon();
    await _updateHwActionIcons();
  }

  Future<void> _updateHwActionIcons() async {
    await _updateHotpActionIcon();
    await _updateTotpActionIcon();
    await _updateDayPasswordActionIcon();
  }

  void _hideOtpDelayed(String widgetId, int otpLength) {
    _hideTimers[widgetId]?.cancel();
    _hideTimers[widgetId] = Timer(_showDuration, () async {
      await HomeWidget.saveWidgetData('$keyShowToken$widgetId', false);
      await _notifyUpdate();
    });
  }

  ////////////////////////////////////////
  ////////////// Rendering ///////////////
  ////////////////////////////////////////
  Future<dynamic> renderFlutterWidget(Widget widget, {required String key, required Size logicalSize}) => HomeWidget.renderFlutterWidget(
        widget,
        key: '$key',
        logicalSize: logicalSize,
      );

  Future<void> _updateHwackground() async => await HwBackgroundModul(
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(isDark: true),
        logicalSize: _widgetBackgroundSize,
        homeWidgetKey: keyTokenBackground,
        utils: this,
      ).renderFlutterWidgets();

  Future<void> _updateHotpActionIcon() async => await HwActionModul(
        icon: Icons.replay,
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(isDark: true),
        logicalSize: _widgetActionSize,
        homeWidgetKey: '$keyTokenAction$keyHotpToken',
        utils: this,
      ).renderFlutterWidgets(); //  1. Action 2. type 3. active/inactive 4. dark/light Example:   _tokenAction_hotp_active_light or _tokenAction_hotp_inactive_dark

  Future<void> _updateTotpActionIcon() async => await HwActionModul(
        icon: Icons.timer_outlined,
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(isDark: true),
        logicalSize: _widgetActionSize,
        homeWidgetKey: '$keyTokenAction$keyTotpToken',
        utils: this,
      ).renderFlutterWidgets();

  Future<void> _updateDayPasswordActionIcon() async => await HwActionModul(
        icon: Icons.calendar_today_outlined,
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(isDark: true),
        logicalSize: _widgetActionSize,
        homeWidgetKey: '$keyTokenAction$keyDayPasswordToken',
        utils: this,
      ).renderFlutterWidgets();

  Future<void> _updateHwContainerShowOtp(OTPToken token, String homeWidgetId) async => await HwOtpModul(
        otp: token.otpValue,
        label: token.label,
        issuer: token.issuer,
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(isDark: true),
        logicalSize: _widgetOtpSize,
        homeWidgetKey: '$keyTokenOtp$homeWidgetId',
        utils: this,
      ).renderFlutterWidgets(); // saved in shared preferences under example: _tokenContainer32_light and _tokenContainer32_dark

  Future<void> _updateHwContainerHideOtp(OTPToken token, String homeWidgetId) async => await HwOtpModul(
        otpLength: token.otpValue.length,
        label: token.label,
        issuer: token.issuer,
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(isDark: true),
        logicalSize: _widgetOtpSize,
        homeWidgetKey: '$keyTokenOtp$homeWidgetId$keySuffixHidden',
        utils: this,
      ).renderFlutterWidgets();

  Future<void> _updateHwContainerLocked(String homeWidgetId) async => await HwOtpModul(
        otp: 'TOKEN LOCKED',
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(isDark: true),
        logicalSize: _widgetOtpSize,
        homeWidgetKey: '$keyTokenOtp$homeWidgetId',
        utils: this,
      ).renderFlutterWidgets();

  Future<void> _updateHwSettingsIcon() async => await HwIconModul(
        icon: Icons.settings,
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(isDark: true),
        logicalSize: _widgetSettingsSize,
        homeWidgetKey: keySettingsIcon,
        utils: this,
      ).renderFlutterWidgets();

  Future<void> _updateHwContainerEmpty() async => await HwOtpModul(
        otp: 'No Token Selected',
        lightTheme: await _getThemeData(),
        darkTheme: await _getThemeData(isDark: true),
        logicalSize: _widgetBackgroundSize,
        homeWidgetKey: keyTokenContainerEmpty,
        utils: this,
      ).renderFlutterWidgets();

  ////////////////////////////////////////
  //////// Saving to SharedPrefs /////////
  ////////////////////////////////////////
  Future<void> _setCurrentThemeMode(ThemeMode themeMode) async => await HomeWidget.saveWidgetData(keyCurrentThemeMode, themeMode.name);

  Future<void> _setTokenType(String widgetId, String tokenType) async {
    Logger.warning('Saving tokenType $tokenType for widgetId $widgetId. Key: $keyTokenType$widgetId Value: $tokenType');
    await HomeWidget.saveWidgetData('$keyTokenType$widgetId', tokenType);
  } // _tokenType$widgetId Example: _tokenType32

  Future<void> _removeTokenType(String widgetId) async => await HomeWidget.saveWidgetData('$keyTokenType$widgetId', null);

  Future<void> _setThemeCustomization() async {
    final customization = PrivacyIDEAAuthenticator.customization;
    await HomeWidget.saveWidgetData('$keyThemeCustomization$keySuffixDark', jsonEncode(customization?.darkTheme));
    await HomeWidget.saveWidgetData('$keyThemeCustomization$keySuffixLight', jsonEncode(customization?.lightTheme));
  }

  Future<void> _setCopyText(String copyText) async => await HomeWidget.saveWidgetData('$keyCopyText', copyText);

  ////////////////////////////////////////
  /////////// Notifiy Update /////////////
  ////////////////////////////////////////
  static Future<void> _notifyUpdate() async {
    String packageName = await _packageName;
    HomeWidget.updateWidget(qualifiedAndroidName: '$packageName.AppWidgetProvider', iOSName: 'AppWidgetProvider');
  }
}
