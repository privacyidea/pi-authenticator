import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:privacyidea_authenticator/model/processors/scheme_processors/home_widget_processor.dart';
import 'package:privacyidea_authenticator/repo/secure_token_repository.dart';
import 'package:privacyidea_authenticator/utils/app_customizer.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/widgets/home_widgets/home_widget_container.dart';

import '../main_netknights.dart';
import '../model/tokens/otp_token.dart';
import '../model/tokens/token.dart';

/// This function is called on any interaction with the HomeWidget
void homeWidgetBackgroundCallback(Uri? uri) {
  if (uri == null) return;
  const HomeWidgetProcessor().process(uri);
}

class HomeWidgetUtils {
  const HomeWidgetUtils();
  // <widgetId, timer>

  static final Map<String, Timer> _hideTimers = {};
  static const _size = Size(400, 200);
  static Future<ThemeData> get _themeData async {
    return ThemeCustomization.fromJson(
      jsonDecode(await HomeWidget.getWidgetData<String>('_themeData') ?? '{}'),
    ).generateTheme();
  }

  static Future<String> get _packageName async {
    String packageName = (await PackageInfo.fromPlatform()).packageName;
    if (kDebugMode) {
      packageName = packageName.replaceAll('.debug', '');
    }
    return packageName;
  }

  static Future<void> setStaticWidgets() async {
    await _setThemeData(PrivacyIDEAAuthenticator.customization);
  }

  static Future<void> link(String widgetId, String tokenId) async {
    Logger.warning('Linking HomeWidget with id $widgetId to token $tokenId');
    await HomeWidget.saveWidgetData('_tokenId$widgetId', tokenId);
    await hideOtp(widgetId);
    await _updateHomeWidgets();
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
      log('Token is locked');
      await _showLockedOtp(widgetId);
      return;
    }

    await HomeWidget.renderFlutterWidget(
      HomeWidgetContainer(
        otp: (otpToken.otpValue).toString(),
        logicalSize: _size,
        theme: await _themeData,
      ),
      key: '_tokenContainer$widgetId',
      logicalSize: _size,
    );
    await _updateHomeWidgets();
    _hideTimers[widgetId]?.cancel();
    _hideTimers[widgetId] = Timer(const Duration(seconds: 5), () async => await hideOtp(widgetId));
  }

  static Future<void> hideOtp(String widgetId) async {
    Logger.warning('Hiding OTP for token $widgetId');
    _hideTimers[widgetId]?.cancel();
    await _setHomeWidgetContainer('- - - - - -', widgetId);
    await _updateHomeWidgets();
  }

  static Future<void> homeWidgetInit() async {
    String packageName = await _packageName;
    await HomeWidget.setAppGroupId(packageName);

    _updateEmptyContainer();

    HomeWidget.updateWidget(qualifiedAndroidName: '$packageName.AppWidgetProvider', iOSName: 'AppWidgetProvider');
  }

  static Future<void> _showLockedOtp(String widgetId) async {
    Logger.warning('Showing Locked OTP for token $widgetId');
    await HomeWidget.renderFlutterWidget(
      HomeWidgetContainer(
        otp: 'TOKEN LOCKED',
        logicalSize: _size,
        theme: await _themeData,
      ),
      key: '_tokenContainer$widgetId',
      logicalSize: _size,
    );
    await _updateHomeWidgets();
    _hideTimers[widgetId]?.cancel();
    _hideTimers[widgetId] = Timer(const Duration(seconds: 5), () async {
      await HomeWidget.renderFlutterWidget(
        HomeWidgetContainer(
          otp: '- - - - - -',
          logicalSize: _size,
          theme: await _themeData,
        ),
        key: '_tokenContainer$widgetId',
        logicalSize: _size,
      );
      await _updateHomeWidgets();
    });
  }

  static Future<void> _unlink(String widgetId) async {
    Logger.warning('Unlinking HomeWidget with id $widgetId');
    await HomeWidget.saveWidgetData('_tokenId$widgetId', null);
    await _updateHomeWidgets();
  }

  static Future<void> _updateEmptyContainer() async {
    Logger.warning('Updating HomeWidgetContainer with id empty');

    await HomeWidget.renderFlutterWidget(
      HomeWidgetContainer(
        otp: 'No Token Selected',
        logicalSize: _size,
        theme: await _themeData,
      ),
      key: '_tokenContainerEmpty',
      logicalSize: _size,
    );
  }

  // =======================================================
  // ====================== RENDERING ======================
  // =======================================================

  static Future<void> _setThemeData(ApplicationCustomization? customization) async {
    var brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final theme = brightness == Brightness.light ? customization?.lightTheme : customization?.darkTheme;
    if (theme == null) return;
    await HomeWidget.saveWidgetData('_themeData', jsonEncode(theme.toJson()));
    await _updateHomeWidgets();
  }

  static Future<void> _setHomeWidgetContainer(String otp, String homeWidgetId) async {
    await HomeWidget.renderFlutterWidget(
      HomeWidgetContainer(otp: otp, theme: await _themeData, logicalSize: _size),
      key: '_tokenContainer$homeWidgetId',
      logicalSize: _size,
    );
  }

  static Future<void> _updateHomeWidgets() async {
    String packageName = await _packageName;
    HomeWidget.updateWidget(qualifiedAndroidName: '$packageName.AppWidgetProvider', iOSName: 'AppWidgetProvider');
  }
}
