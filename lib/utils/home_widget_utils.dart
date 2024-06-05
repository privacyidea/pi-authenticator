import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/utils/customization/theme_customization.dart';

import '../interfaces/repo/token_folder_repository.dart';
import '../interfaces/repo/token_repository.dart';
import '../mains/main_netknights.dart';
import '../model/token_folder.dart';
import '../model/tokens/day_password_token.dart';
import '../model/tokens/hotp_token.dart';
import '../model/tokens/otp_token.dart';
import '../model/tokens/token.dart';
import '../model/tokens/totp_token.dart';
import '../processors/scheme_processors/home_widget_processor.dart';
import '../repo/preference_token_folder_repository.dart';
import '../repo/secure_token_repository.dart';
import '../widgets/home_widgets/home_widget_action.dart';
import '../widgets/home_widgets/home_widget_background.dart';
import '../widgets/home_widgets/home_widget_configure.dart';
import '../widgets/home_widgets/home_widget_copied.dart';
import '../widgets/home_widgets/home_widget_hidden.dart';
import '../widgets/home_widgets/home_widget_otp.dart';
import '../widgets/home_widgets/home_widget_unlinked.dart';
import 'logger.dart';
import 'riverpod_providers.dart';

const appGroupId = 'group.authenticator_home_widget_group';

/// This function is called on any interaction with the HomeWidget
@pragma('vm:entry-point')
void homeWidgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;
  const HomeWidgetProcessor().processUri(uri);
}

class HomeWidgetUtils {
  HomeWidgetUtils._();
  static HomeWidgetUtils? _instance;

  /// Check android/app/src/main/res/layout/widget_layout.xml for the sizes. Double it for better quality
  static const _widgetBackgroundSize = Size(130 * 2, 65 * 2);

  /// Check android/app/src/main/res/layout/widget_layout.xml for the sizes. Double it for better quality
  static const _widgetOtpSize = Size(98 * 2, 40 * 2);

  /// Check android/app/src/main/res/layout/widget_layout.xml for the sizes. Double it for better quality
  static const _widgetSettingsSize = Size(14 * 2, 14 * 2);

  /// Check android/app/src/main/res/layout/widget_layout.xml for the sizes. Double it for better quality
  static const _widgetActionSize = Size(24 * 2, 24 * 2);

  /// Default duration for showing the OTP
  static const _showDuration = Duration(seconds: 15);

  factory HomeWidgetUtils({TokenRepository? tokenRepository, TokenFolderRepository? tokenFolderRepository}) {
    if (Platform.isIOS) return UnsupportedHomeWidgetUtils(); // Not supported on iOS
    _instance ??= HomeWidgetUtils._();
    _tokenRepository = tokenRepository ?? const SecureTokenRepository();
    _folderRepository = tokenFolderRepository ?? PreferenceTokenFolderRepository();
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
  static TokenFolderRepository? _folderRepository;
  static final Mutex _repoMutex = Mutex();
  static Future<List<OTPToken>> get _otpTokens async {
    final tokens = globalRef?.read(tokenProvider).tokens;
    return tokens?.whereType<OTPToken>().toList() ?? (await _loadTokensFromRepo()).whereType<OTPToken>().toList();
  }

  static Future<OTPToken?> _getTokenOfTokenId(String? tokenId) async {
    await _repoMutex.acquire();
    final token = (await _loadTokensFromRepo()).firstWhereOrNull((token) => token.id == tokenId);
    _repoMutex.release();
    return token;
  }

  //////////////////////////////////////
  /////// Keys for HomeWidgets /////////
  //////////////////////////////////////
  static const keyTokenOtp = '_tokenOtp';
  static const keyTokenBackground = '_tokenBackground';
  static const keyTokenContainerEmpty = '_tokenContainerEmpty';
  static const keySettingsIcon = '_settingsIcon';
  static const keyTokenAction = '_tokenAction';
  static const keyTokenCopy = '_tokenCopy';

  //////////////////////////////////////
  //// Suffixes for HomeWidgetKeys /////
  //////////////////////////////////////
  static const keySuffixHidden = '_hidden'; // first _hidden, then _light or _dark
  static const keySuffixLight = '_light'; // example: _hidden_light (if dark mode is disabled and hidden) or _light (if dark mode is disabled and shown)
  static const keySuffixDark = '_dark'; // example: _hidden_dark (if dark mode is enabled and hidden) or _dark (if dark mode is enabled and shown)
  static const keySuffixActive = '_active'; // first _active, then _light or _dark
  static const keySuffixInactive = '_inactive'; // first _inactive, then _light or _dark

  ////////////////////////////////////////
  ////// Keys for Shared Variables ///////
  ////////////////////////////////////////
  static const keyWidgetIds = '_widgetIds'; // recive the all widgetIds of linked tokens, seperated by ','
  static const keyShowToken =
      '_showWidget'; // recive a bool if the token of the linked widget should be shown. true = show, false = hide. Example: _showWidget32
  static const keyTokenId = '_tokenId'; //  recive the tokenId of a linked token. Example: _tokenId32
  static const keyThemeCustomization = '_themeCustomization';
  static const keyCurrentThemeMode = '_currentThemeMode';
  static const keyTokenType = '_tokenType';
  static String get keyTotpToken => '_${TOTPToken.tokenType}';
  static String get keyHotpToken => '_${HOTPToken.tokenType}';
  static String get keyDayPasswordToken => '_${DayPasswordToken.tokenType}';
  static const keyCopyText = '_copyText';
  static const keyTokenLocked =
      '_tokenLocked'; // recive a bool if the token of the linked widget is locked. true = locked, false = not locked. Example: _tokenLocked32
  static const keyWidgetIsRebuilding = '_widgetIsRebuilding';
  static const keyActionBlocked =
      '_actionBlocked'; // recive a bool if the action of the linked widget is blocked. true = blocked, false = not blocked. _actionBlocked${token.id}
  static const keyCopyBlocked =
      '_copyBlocked'; // recive a bool if the copy of the linked widget is blocked. true = blocked, false = not blocked. _copyBlocked${widgetId} Example: _copyBlocked32
  static const keyRebuildingWidgetIds =
      '_rebuildingWidgetIds'; // recive the widgetIds that should be updated after the HomeWidget is ready. each widgetId is seperated by ',' Example value: "32,33,35"

  ////////////////////////////////////////
  /////// Getter & Getterfunctions ///////
  ////////////////////////////////////////

  Stream<Uri?> get widgetClicked => HomeWidget.widgetClicked;
  Future<Uri?> initiallyLaunchedFromHomeWidget() => HomeWidget.initiallyLaunchedFromHomeWidget();

  static bool? _isHomeWidgetSupported;
  static Future<bool> get isHomeWidgetSupported async {
    if (_isHomeWidgetSupported != null) return _isHomeWidgetSupported!;
    if (kIsWeb || Platform.isIOS) {
      _isHomeWidgetSupported = false;
      return _isHomeWidgetSupported!;
    }
    _isHomeWidgetSupported = true;
    return _isHomeWidgetSupported!;
  }

  Future<List<String>> get _widgetIds async => (await HomeWidget.getWidgetData<String?>(keyWidgetIds))?.split(',') ?? <String>[];

  // _packageId must be the exact id of the package variable in "AndroidManifest.xml" !! NOT the applicationId of the flavor !!
  static const String _packageId = "it.netknights.piauthenticator";
  static Future<List<OTPToken>> _loadTokensFromRepo() async => (await _tokenRepository?.loadTokens())?.whereType<OTPToken>().toList() ?? [];
  static Future<void>? _saveTokensToRepo(List<OTPToken> tokens) => _tokenRepository?.saveOrReplaceTokens(tokens);

  static Future<List<TokenFolder>> _loadFoldersFromRepo() async {
    return (await _folderRepository?.loadFolders()) ?? [];
  }

  Future<String?> getTokenIdOfWidgetId(String widgetId) async {
    return await HomeWidget.getWidgetData<String?>('$keyTokenId$widgetId');
  }

  Future<OTPToken?> getTokenOfWidgetId(String? widgetId) async {
    return widgetId == null ? null : _getTokenOfTokenId(await getTokenIdOfWidgetId(widgetId));
  }

  /// <widgetId, tokenId> a token can be linked to multiple widgets but widgetIs can only be linked to one token
  Future<Map<String, String>> _getWidgetIdsOfTokens(List<String> tokenIds) async {
    final tokenWigetPairs = <String, String>{};
    for (final widgetId in (await _widgetIds)) {
      for (final tokenId in tokenIds) {
        if (tokenId == await getTokenIdOfWidgetId(widgetId)) {
          tokenWigetPairs[widgetId] = tokenId;
        }
      }
    }
    Logger.info('Found ${tokenWigetPairs.length} linked Widgets', name: 'home_widget_utils.dart#_getWidgetIdsOfTokens');
    return tokenWigetPairs;
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

  Future<bool?> registerInteractivityCallback(void Function(Uri? uri) homeWidgetBackgroundCallback) =>
      HomeWidget.registerInteractivityCallback(homeWidgetBackgroundCallback);

  Future<bool?> setAppGroupId(String appGroupId) => HomeWidget.setAppGroupId(appGroupId);

  /// This method has to be called at least once before any other method is called
  Future<void> homeWidgetInit({TokenRepository? repository}) async {
    if (repository != null) _tokenRepository = repository;
    await _setThemeCustomization();
    await _updateStaticWidgets();
    await _resetAllTokens();
    await _notifyUpdate(await _widgetIds);
  }

  Future<void> setCurrentThemeMode(ThemeMode themeMode) async {
    await _setCurrentThemeMode(themeMode);
    await _notifyUpdate(await _widgetIds);
  }

  Future<bool> hideAllOtps() async {
    final widgetIds = await _widgetIds;
    final futures = <Future>[];
    for (String widgetId in widgetIds) {
      futures.add(HomeWidget.saveWidgetData('$keyShowToken$widgetId', false));
    }
    if (futures.isEmpty) return false;
    await Future.wait(futures);
    await _notifyUpdate(widgetIds);
    return true;
  }

  // Call AFTER saving to the repository
  Future<void> updateTokenIfLinked(Token token) async {
    final updatedIds = await _updateTokenIfLinked(token);
    await _notifyUpdate(updatedIds);
  }

  // Call AFTER saving to the repository
  Future<void> updateTokensIfLinked(List<Token> tokens) async {
    // Map<widgetId, tokenId>
    final hotpTokens = tokens.whereType<HOTPToken>().toList();
    final hotpTokenIds = hotpTokens.map((e) => e.id).toList();
    final linkedWidgetIds = await _getWidgetIdsOfTokens(hotpTokenIds);
    final futures = <Future>[];
    for (String widgetId in linkedWidgetIds.keys) {
      final hotpToken = hotpTokens.firstWhereOrNull((element) => element.id == linkedWidgetIds[widgetId]);
      if (hotpToken == null) continue;
      futures.addAll([
        _updateHomeWidgetHideOtp(hotpToken, widgetId),
        _updateHomeWidgetShowOtp(hotpToken, widgetId),
      ]);
    }
    await Future.wait(futures);
    await _notifyUpdate(linkedWidgetIds.keys);
  }

  Future<void> link(String widgetId, String tokenId) async {
    Logger.info('Linking HomeWidget with id $widgetId to token $tokenId');
    final token = await _getTokenOfTokenId(tokenId);
    if (token == null) {
      await unlink(widgetId);
      return;
    }
    await _link(widgetId, token);
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

  // Future<void> handleChangedTokenState() async {
  //   final idTokenPairs = await _getTokensOfWidgetIds(await _widgetIds);
  //   final homeWidgetChanges = <Future>[];
  //   for (String widgetId in idTokenPairs.keys) {
  //     final token = idTokenPairs[widgetId];
  //     if (token == null) {
  //       homeWidgetChanges.add(_unlink(widgetId));
  //       continue;
  //     }
  //     homeWidgetChanges.add(HomeWidget.saveWidgetData('$keyTokenLocked$widgetId', token.isLocked || ((await _folderOf(token))?.isLocked ?? false)));
  //     homeWidgetChanges.add(HomeWidget.saveWidgetData('$keyShowToken$widgetId', false));
  //     homeWidgetChanges.add(_updateHomeWidgetHideOtp(token, widgetId));
  //   }
  //   await Future.wait(homeWidgetChanges);
  //   await _notifyUpdate(idTokenPairs.keys);
  // }

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
      Logger.info('Action blocked', name: 'home_widget_utils.dart#performAction');
      return;
    }
    HomeWidget.saveWidgetData('$keyActionBlocked$tokenId', true);
    final widgetIds = (await _getWidgetIdsOfTokens([token.id])).keys.toList();
    _actionTimers[tokenId] = Timer(const Duration(seconds: 1), () async {
      Logger.info('Unblocked action', name: 'home_widget_utils.dart#performAction');
      await HomeWidget.saveWidgetData('$keyActionBlocked$tokenId', false);
      await _notifyUpdate(widgetIds);
    });

    await _mapTokenAction[token.type]?.call(widgetId);
    Logger.info('Performing action', name: 'home_widget_utils.dart#performAction');
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

  Future<void> _updateHwActionIcons() async {
    await _updateHotpActionIcon();
    await _updateTotpActionIcon();
    await _updateDayPasswordActionIcon();
  }

  //   Map<widgetId, timer> _hideTimers
  final Map<String, Timer> _hideTimers = {};
  void _hideOtpDelayed(String widgetId, int otpLength) {
    _hideTimers[widgetId]?.cancel();
    _hideTimers[widgetId] = Timer(_showDuration, () => _hideOtp(widgetId, otpLength));
  }

  Future<void> _hideOtp(String widgetId, int otpLength) async {
    await HomeWidget.saveWidgetData('$keyShowToken$widgetId', false);
    await _notifyUpdate([widgetId]);
  }

  Future<void> _link(String widgetId, OTPToken token) async {
    await HomeWidget.saveWidgetData('$keyTokenId$widgetId', token.id);
    await HomeWidget.saveWidgetData('$keyTokenLocked$widgetId', token.isLocked || ((await _folderOf(token))?.isLocked ?? false));
    await _updateHomeWidgetHideOtp(token, widgetId);
    await _setTokenType(widgetId, token.type);
    await _notifyUpdate([widgetId]);
    var state = globalRef?.read(homeWidgetProvider.notifier).state;
    if (state != null) {
      state[widgetId] = token;
      globalRef?.read(homeWidgetProvider.notifier).state = state;
    }
  }

  Future<void> _unlink(String widgetId) async {
    Logger.info('Unlinking HomeWidget with id $widgetId', name: 'home_widget_utils.dart#_unlink');
    await HomeWidget.saveWidgetData('$keyTokenId$widgetId', null);
    await _updateHomeWidgetUnlinked();
    await _removeTokenType(widgetId);
    var state = globalRef?.read(homeWidgetProvider.notifier).state;
    if (state != null) {
      state.remove(widgetId);
      globalRef?.read(homeWidgetProvider.notifier).state = state;
    }
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
    final widgetIds = (await _getWidgetIdsOfTokens([token.id])).keys.toList();
    final futures = <Future>[];
    for (String widgetId in widgetIds) {
      futures.add(_updateHomeWidgetHideOtp(token, widgetId));
      futures.add(_updateHomeWidgetShowOtp(token, widgetId));
    }
    await Future.wait(futures);
    return widgetIds;
  }

  Future<TokenFolder?> _folderOf(Token token) async {
    final folderId = token.folderId;
    final allFolders = await _loadFoldersFromRepo();
    return allFolders.firstWhereOrNull((token) => token.folderId == folderId);
  }

  ////////////////////////////////////////
  ////////////// Rendering ///////////////
  ////////////////////////////////////////
  Future<dynamic> renderFlutterWidget(Widget widget, {required String key, required Size logicalSize}) async {
    return HomeWidget.renderFlutterWidget(
      widget,
      key: '$key',
      logicalSize: logicalSize,
    );
  }

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
    final customization = PrivacyIDEAAuthenticator.currentCustomization;
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
    if (updatedWidgetIds.isEmpty) return;
    Logger.info('Update requested for: $updatedWidgetIds', name: 'home_widget_utils.dart#_notifyUpdate', stackTrace: StackTrace.current);
    if (await _widgetIsRebuilding || _lastUpdate != null && DateTime.now().difference(_lastUpdate!) < _updateDelay) {
      Logger.info('Update delayed: $updatedWidgetIds', name: 'home_widget_utils.dart#_notifyUpdate');
      _updatedWidgetIds.addAll(updatedWidgetIds);
      _updateTimer?.cancel();
      final nextDelayInMs = _updateDelay.inMilliseconds - DateTime.now().difference(_lastUpdate!).inMilliseconds;
      _updateTimer = Timer(nextDelayInMs < 1 ? _updateDelay : Duration(milliseconds: nextDelayInMs), () async {
        Logger.info('Call Update from Timer', name: 'home_widget_utils.dart#_notifyUpdate');
        await _notifyUpdate(_updatedWidgetIds.toList());
      });
      return;
    }
    Logger.info('Notify Update: $updatedWidgetIds', name: 'home_widget_utils.dart#_notifyUpdate');
    _lastUpdate = DateTime.now();
    await HomeWidget.saveWidgetData(keyRebuildingWidgetIds, updatedWidgetIds.join(','));
    await HomeWidget.updateWidget(qualifiedAndroidName: '$_packageId.AppWidgetProvider', iOSName: 'AppWidgetProvider');
  }
}

class UnsupportedHomeWidgetUtils implements HomeWidgetUtils {
  @override
  DateTime? _lastUpdate;
  @override
  ThemeData? _themeDataDark;
  @override
  ThemeData? _themeDataLight;
  @override
  Timer? _updateTimer;
  @override
  Map<String, Timer?> get _actionTimers => {};
  @override
  Map<String, Timer?> get _copyTimers => {};
  @override
  Future<TokenFolder?> _folderOf(Token token) => Future.value(null);
  @override
  Future<ThemeData> _getThemeData({bool dark = false}) => Future.value(ThemeData.light());
  @override
  Future<Map<String, String>> _getWidgetIdsOfTokens(List<String> tokenIds) => Future.value({});
  @override
  void _hideOtpDelayed(String widgetId, int otpLength) {}
  @override
  Map<String, Timer> get _hideTimers => {};
  @override
  Future<void> _hotpTokenAction(String widgetId) => Future.value(null);
  @override
  Future<void> _link(String widgetId, OTPToken token) => Future.value(null);
  @override
  Map<String, FutureOr<void> Function(String p1)> get _mapTokenAction => {};
  @override
  Future<void> _notifyUpdate(Iterable<String> updatedWidgetIds) async {}
  @override
  Future<void> _removeTokenType(String widgetId) async {}
  @override
  Future<void> _resetAllTokens() async {}
  @override
  Future<void> _setCopyText(String copyText) async {}
  @override
  Future<void> _setCurrentThemeMode(ThemeMode themeMode) async {}
  @override
  Future<void> _setThemeCustomization() async {}
  @override
  Future<void> _setTokenType(String widgetId, String tokenType) async {}
  @override
  Future<void> _unlink(String widgetId) async {}
  @override
  Future<void> _updateDayPasswordActionIcon() async {}
  @override
  Future<void> _updateHomeWidgetCopied() async {}
  @override
  Future<void> _updateHomeWidgetHideOtp(OTPToken token, String homeWidgetId) async {}
  @override
  Future<void> _updateHomeWidgetShowOtp(OTPToken token, String homeWidgetId) async {}
  @override
  Future<void> _updateHomeWidgetUnlinked() async {}
  @override
  Future<void> _updateHotpActionIcon() async {}
  @override
  Future<void> _updateHwActionIcons() async {}
  @override
  Future<void> _updateHwConfigIcon() async {}
  @override
  Future<void> _updateHwackground() async {}
  @override
  Future<void> _updateStaticWidgets() async {}
  @override
  Future<List<String>> _updateTokenIfLinked(Token token) => Future.value([]);
  @override
  Future<void> _updateTotpActionIcon() async {}
  @override
  Set<String> get _updatedWidgetIds => {};
  @override
  Future<List<String>> get _widgetIds => Future.value([]);
  @override
  Future<bool> get _widgetIsRebuilding => Future.value(false);
  @override
  Future<void> copyOtp(String widgetId) async {}
  @override
  Future<String?> getTokenIdOfWidgetId(String widgetId) => Future.value(null);
  @override
  Future<OTPToken?> getTokenOfWidgetId(String? widgetId) => Future.value(null);
  @override
  Future<void> homeWidgetInit({TokenRepository? repository}) async {}
  @override
  Future<void> link(String widgetId, String tokenId) async {}
  @override
  Future<void> performAction(String widgetId) async {}
  @override
  Future renderFlutterWidget(Widget widget, {required String key, required Size logicalSize}) async {}
  @override
  Future<void> setCurrentThemeMode(ThemeMode themeMode) async {}
  @override
  Future<void> showOtp(String widgetId) async {}
  @override
  Future<void> unlink(String widgetId) async {}
  @override
  Future<void> updateTokenIfLinked(Token token) async {}
  @override
  Future<void> updateTokensIfLinked(List<Token> tokens) async {}
  @override
  Future<Uri?> initiallyLaunchedFromHomeWidget() => Future.value(null);
  @override
  Stream<Uri?> get widgetClicked => const Stream.empty();
  @override
  Future<bool?> registerInteractivityCallback(void Function(Uri? uri) homeWidgetBackgroundCallback) => Future.value(null);
  @override
  Future<bool?> setAppGroupId(String appGroupId) => Future.value(null);
  @override
  Future<void> _hideOtp(String widgetId, int otpLength) async {}
  @override
  Future<bool> hideAllOtps() async => false;
}
