import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:privacyidea_authenticator/model/processors/scheme_processors/home_widget_processor.dart';
import 'package:privacyidea_authenticator/repo/secure_token_repository.dart';
import 'package:privacyidea_authenticator/utils/app_customizer.dart';
import 'package:privacyidea_authenticator/utils/customizations.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/widgets/home_widgets/home_widget_container.dart';

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
  const HomeWidgetUtils();
  // <widgetId, timer>

  static final Map<String, Timer> _hideTimers = {};
  static const _homeWidgetSize = Size(400, 200);
  static Future<ThemeData> get _themeData async {
    print('HOME primaryColor ${jsonDecode(await HomeWidget.getWidgetData<String>('_themeCustomization') ?? '{}')}');
    return ThemeCustomization.fromJson(
      jsonDecode(await HomeWidget.getWidgetData<String>('_themeCustomization') ?? '{}'),
    ).generateTheme();
  }

  static Future<List<String>> get _widgetIds async {
    return (await HomeWidget.getWidgetData<String?>('_widgetIds'))?.split(',') ?? <String>[];
  }

  static Future<String> get _packageName async {
    String packageName = (await PackageInfo.fromPlatform()).packageName;
    if (kDebugMode) {
      packageName = packageName.replaceAll('.debug', '');
    }
    return packageName;
  }

  static Future<List<OTPToken>> get _tokens async => (await const SecureTokenRepository().loadTokens()).whereType<OTPToken>().toList();
  static Future<OTPToken?> _getTokenOfId(String? id) async => id == null ? null : (await _tokens).firstWhereOrNull((element) => element.id == id);
  static Future<List<OTPToken>> _getTokensOfIds(List<String> ids) async =>
      ids.isEmpty ? [] : (await _tokens).where((element) => ids.contains(element.id)).toList();
  static Future<OTPToken?> _getTokenOfWidgetId(String? widgetId) async =>
      widgetId == null ? null : _getTokenOfId(await HomeWidget.getWidgetData<String?>('_tokenId$widgetId'));

  static Future<void> setBrightness(Brightness brightness) async {
    await _updateEverything(brightness);
    await _notifyUpdate();
  }

  static Future<void> setStaticWidgets() async {
    await _updateThemeCustomization();
    await _updateHomeWidgetSettingsIcon();
    await _notifyUpdate();
  }

  static Future<void> link(String widgetId, String tokenId) async {
    Logger.warning('Linking HomeWidget with id $widgetId to token $tokenId');
    await HomeWidget.saveWidgetData('_tokenId$widgetId', tokenId);
    await hideOtp(widgetId, await _getTokenOfId(tokenId));
    await _notifyUpdate();
  }

  static Future<void> showOtp(String widgetId, String tokenId) async {
    Logger.warning('Showing OTP for token $tokenId');
    Logger.warning('widgetId: $widgetId');
    Token? token = await const SecureTokenRepository().loadTokens().then((value) => value.firstWhereOrNull((element) => element.id == tokenId));
    OTPToken otpToken;
    if (token is OTPToken) {
      otpToken = token;
    } else {
      await _unlink(widgetId);
      return;
    }
    if (otpToken.isLocked) {
      await _showLockedOtp(widgetId);
      return;
    }

    await HomeWidget.renderFlutterWidget(
      HomeWidgetContainer(
        otp: (otpToken.otpValue).toString(),
        issuer: otpToken.issuer,
        label: otpToken.label,
        logicalSize: _homeWidgetSize,
        theme: await _themeData,
      ),
      key: '_tokenContainer$widgetId',
      logicalSize: _homeWidgetSize,
    );
    await _notifyUpdate();
    _hideTimers[widgetId]?.cancel();
    _hideTimers[widgetId] = Timer(const Duration(seconds: 5), () async => await hideOtp(widgetId, (await _getTokenOfId(tokenId))));
  }

  static Future<void> hideOtp(String widgetId, OTPToken? token) async {
    if (token == null) {
      await _updateHomeWidgetContainerEmpty();
      await _notifyUpdate();
      return;
    }
    Logger.warning('Hiding OTP for token $widgetId');
    _hideTimers[widgetId]?.cancel();
    await HomeWidget.renderFlutterWidget(
      HomeWidgetContainer(
        otpLength: token.otpValue.length,
        logicalSize: _homeWidgetSize,
        label: token.label,
        issuer: token.issuer,
        theme: await _themeData,
      ),
      key: '_tokenContainer$widgetId',
      logicalSize: _homeWidgetSize,
    );
    await _notifyUpdate();
  }

  static Future<void> homeWidgetInit() async {
    String packageName = await _packageName;
    await HomeWidget.setAppGroupId(packageName);
    setStaticWidgets();
    _updateEmptyContainer();

    HomeWidget.updateWidget(qualifiedAndroidName: '$packageName.AppWidgetProvider', iOSName: 'AppWidgetProvider');
  }

  static Future<void> _showLockedOtp(String widgetId) async {
    Logger.warning('Showing Locked OTP for token $widgetId');
    await HomeWidget.renderFlutterWidget(
      HomeWidgetContainer(
        otp: 'TOKEN LOCKED',
        logicalSize: _homeWidgetSize,
        theme: await _themeData,
      ),
      key: '_tokenContainer$widgetId',
      logicalSize: _homeWidgetSize,
    );
    await _notifyUpdate();
    _hideTimers[widgetId]?.cancel();
    _hideTimers[widgetId] = Timer(const Duration(seconds: 5), () async {
      await hideOtp(widgetId, await _getTokenOfWidgetId(widgetId));
      await _notifyUpdate();
    });
  }

  static Future<void> _unlink(String widgetId) async {
    Logger.warning('Unlinking HomeWidget with id $widgetId');
    await HomeWidget.saveWidgetData('_tokenId$widgetId', null);
    await _notifyUpdate();
  }

  static Future<void> _updateEmptyContainer() async {
    Logger.warning('Updating HomeWidgetContainer with id empty');

    await HomeWidget.renderFlutterWidget(
      HomeWidgetContainer(
        otp: 'No Token Selected',
        logicalSize: _homeWidgetSize,
        theme: await _themeData,
      ),
      key: '_tokenContainerEmpty',
      logicalSize: _homeWidgetSize,
    );
  }

  // =======================================================
  // ====================== RENDERING ======================
  // =======================================================

  static Future<void> _updateEverything(Brightness? brightness) async {
    await _updateThemeCustomization(brightness: brightness);
    await _updateAllHwContainer();
    await _updateEmptyContainer();
    await _updateHomeWidgetSettingsIcon();
  }

  static Future<void> _updateThemeCustomization({Brightness? brightness}) async {
    final customization = PrivacyIDEAAuthenticator.customization;
    brightness ??= Theme.of(globalNavigatorKey.currentContext!).brightness;
    final theme = brightness == Brightness.light ? customization?.lightTheme : customization?.darkTheme;
    if (theme == null) return;
    await HomeWidget.saveWidgetData('_themeCustomization', jsonEncode(theme.toJson()));
  }

  static Future<void> _updateAllHwContainer() async {
    List<String> widgetIds = await _widgetIds;
    for (String widgetId in widgetIds) {
      String? tokenId = await HomeWidget.getWidgetData<String?>('_tokenId$widgetId');
      if (tokenId == null) {
        await _updateHomeWidgetContainerEmpty();
      } else {
        await hideOtp(widgetId, await _getTokenOfId(tokenId));
      }
    }
  }

  static Future<void> _updateHomeWidgetContainer(String otp, String homeWidgetId) async {
    await HomeWidget.renderFlutterWidget(
      HomeWidgetContainer(
        otp: otp,
        theme: await _themeData,
        logicalSize: _homeWidgetSize,
      ),
      key: '_tokenContainer$homeWidgetId',
      logicalSize: _homeWidgetSize,
    );
  }

  static Future<void> _updateHomeWidgetSettingsIcon() async {
    final height = min(_homeWidgetSize.width, _homeWidgetSize.height) / 3;
    final size = Size(height, height);
    await HomeWidget.renderFlutterWidget(
      HomeWidgetSettings(logicalSize: size, theme: await _themeData),
      key: '_settingsIcon',
      logicalSize: size,
    );
  }

  static Future<void> _updateHomeWidgetContainerEmpty() async {
    Logger.warning('Updating HomeWidgetContainer with id empty');

    await HomeWidget.renderFlutterWidget(
      HomeWidgetContainer(
        otp: 'No Token Selected',
        logicalSize: _homeWidgetSize,
        theme: await _themeData,
      ),
      key: '_tokenContainerEmpty',
      logicalSize: _homeWidgetSize,
    );
  }

  static Future<void> _notifyUpdate() async {
    String packageName = await _packageName;
    HomeWidget.updateWidget(qualifiedAndroidName: '$packageName.AppWidgetProvider', iOSName: 'AppWidgetProvider');
  }
}
