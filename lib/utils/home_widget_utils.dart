import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:privacyidea_authenticator/model/processors/scheme_processors/home_widget_processor.dart';
import 'package:privacyidea_authenticator/repo/secure_token_repository.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/views/home_widget/home_widget.dart';

import '../model/tokens/otp_token.dart';
import '../model/tokens/token.dart';

// <widgetId, timer>
Map<String, Timer> _timers = {};
const _size = Size(400, 200);

Future<void> _reRenderHomeWidgets() async {
  String packageName = await _getPackageName();
  HomeWidget.updateWidget(qualifiedAndroidName: '$packageName.AppWidgetProvider', iOSName: 'AppWidgetProvider');
}

Future<void> homeWidgetLink(String widgetId, String tokenId) async {
  Logger.warning('Linking HomeWidget with id $widgetId to token $tokenId');
  await HomeWidget.saveWidgetData('_tokenId$widgetId', tokenId);
  await _hideOtp(widgetId);
  await _reRenderHomeWidgets();
}

Future<void> homeWidgetShowOtp(String widgetId, String tokenId) async {
  Logger.warning('Showing OTP for token $tokenId');
  Logger.warning('widgetId: $widgetId');
  Token? token = await const SecureTokenRepository().loadTokens().then((value) => value.firstWhereOrNull((element) => element.id == tokenId));
  OTPToken otpToken;
  if (token is OTPToken) {
    otpToken = token;
  } else {
    await homeWidgetUnlink(widgetId);
    return;
  }
  if (otpToken.isLocked) {
    log('Token is locked');
    await _showLockedOtp(widgetId);
    return;
  }
  // await HomeWidget.saveWidgetData('_tokenId', tokenId);
  const size = Size(400, 200);
  await HomeWidget.renderFlutterWidget(
    HomeWidgetContainer(otp: (otpToken.otpValue).toString(), logicalSize: size),
    key: '_tokenContainer$widgetId',
    logicalSize: size,
  );
  await _reRenderHomeWidgets();
  _timers[widgetId]?.cancel();
  _timers[widgetId] = Timer(const Duration(seconds: 5), () async {
    await HomeWidget.renderFlutterWidget(
      HomeWidgetContainer(otp: '- - - - - -', logicalSize: size),
      key: '_tokenContainer$widgetId',
      logicalSize: size,
    );
    await _reRenderHomeWidgets();
  });
}

Future<void> _showLockedOtp(String widgetId) async {
  Logger.warning('Showing Locked OTP for token $widgetId');
  await HomeWidget.renderFlutterWidget(
    HomeWidgetContainer(otp: 'TOKEN LOCKED', logicalSize: _size),
    key: '_tokenContainer$widgetId',
    logicalSize: _size,
  );
  await _reRenderHomeWidgets();
  _timers[widgetId]?.cancel();
  _timers[widgetId] = Timer(const Duration(seconds: 5), () async {
    await HomeWidget.renderFlutterWidget(
      HomeWidgetContainer(otp: '- - - - - -', logicalSize: _size),
      key: '_tokenContainer$widgetId',
      logicalSize: _size,
    );
    await _reRenderHomeWidgets();
  });
}

Future<void> homeWidgetUnlink(String widgetId) async {
  Logger.warning('Unlinking HomeWidget with id $widgetId');
  await HomeWidget.saveWidgetData('_tokenId$widgetId', null);
  await _reRenderHomeWidgets();
}

Future<void> homeWidgetHideOtp(String tokenId) async {
  Logger.warning('Hiding OTP for token $tokenId');
  _timers[tokenId]?.cancel();
  await HomeWidget.renderFlutterWidget(
    HomeWidgetContainer(otp: '- - - - - -', logicalSize: _size),
    key: '_tokenContainer$tokenId',
    logicalSize: _size,
  );
  await _reRenderHomeWidgets();
}

Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;
  const HomeWidgetProcessor().process(uri);
}

Future<void> homeWidgetInit() async {
  String packageName = await _getPackageName();
  await HomeWidget.setAppGroupId(packageName);

  _updateEmptyContainer();

  HomeWidget.updateWidget(qualifiedAndroidName: '$packageName.AppWidgetProvider', iOSName: 'AppWidgetProvider');
}

// // Called when Doing Background Work initiated from Widget
// Future<void> homeWidgetReloadAllOtp() async {
//   String packageName = await _getPackageName();
//   await HomeWidget.setAppGroupId(packageName);

//   _updateEmptyContainer();

//   if (homeWidgetState != null) {
//     homeWidgetState.linkedHomeWidgets.forEach((widgetId, tokenId) {
//       _updateHomeWidgetContainer(widgetId, tokenId);
//     });
//   }

//   HomeWidget.updateWidget(qualifiedAndroidName: '$packageName.AppWidgetProvider', iOSName: 'AppWidgetProvider');

//   // print('Background Callback: $uri');

//   // print('Getting Password');
//   // // String tokenId = uri?.queryParameters['tokenId'];
//   // tokens ??= await const SecureTokenRepository().loadTokens();
//   // final token = tokens!.first;
//   // String password;
//   // try {
//   //   token as OTPToken;
//   //   password = token.otpValue;
//   // } catch (e) {
//   //   password = 'Not an OTP Token';
//   // }

//   // print('Rendered Widget: ${homeWidgetState.runtimeType}');

//   // final success = await HomeWidget.saveWidgetData<String>('_password', password);
//   // print('Saved Password: $success');
//   // if (kDebugMode) {
//   //   packageName = packageName.replaceAll('.debug', '');
//   // }
//   // final success2 = await HomeWidget.updateWidget(qualifiedAndroidName: '$packageName.AppWidgetProvider', iOSName: 'AppWidgetProvider');

//   // timer?.cancel();
//   // timer = Timer(const Duration(seconds: 5), () async {
//   //   final success = await HomeWidget.saveWidgetData<String>('_password', '- - - - - -');
//   //   print('Saved Password: $success');
//   //   String packageName = (await PackageInfo.fromPlatform()).packageName;
//   //   if (kDebugMode) {
//   //     packageName = packageName.replaceAll('.debug', '');
//   //   }
//   //   final success2 = await HomeWidget.updateWidget(qualifiedAndroidName: '$packageName.AppWidgetProvider', iOSName: 'AppWidgetProvider');
//   // });

//   // print('Updated Widget: $success2');
// }

Future<String> _getPackageName() async {
  String packageName = (await PackageInfo.fromPlatform()).packageName;
  if (kDebugMode) {
    packageName = packageName.replaceAll('.debug', '');
  }
  return packageName;
}

Future<void> _hideOtp(String widgetId) {
  Logger.warning('Hiding OTP for widget: $widgetId');
  return HomeWidget.renderFlutterWidget(
    HomeWidgetContainer(otp: '- - - - - -', logicalSize: _size),
    key: '_tokenContainer$widgetId',
    logicalSize: _size,
  );
}

Future<void> _updateEmptyContainer() async {
  Logger.warning('Updating HomeWidgetContainer with id empty');

  await HomeWidget.renderFlutterWidget(
    HomeWidgetContainer(otp: 'No Token Selected', logicalSize: _size),
    key: '_tokenContainerEmpty',
    logicalSize: _size,
  );
}
