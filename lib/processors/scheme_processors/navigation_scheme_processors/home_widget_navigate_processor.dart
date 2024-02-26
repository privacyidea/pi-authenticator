import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/custom_exceptions.dart';

import '../../../utils/home_widget_utils.dart';
import '../../../utils/logger.dart';
import '../../../utils/riverpod_providers.dart';
import '../../../views/link_home_widget_view/link_home_widget_view.dart';
import '../../../views/splash_screen/splash_screen.dart';
import 'navigation_scheme_processor_interface.dart';

class HomeWidgetNavigateProcessor implements NavigationSchemeProcessor {
  HomeWidgetNavigateProcessor();

  static final Map<String, Future<void> Function(Uri, BuildContext, {bool fromInit})> _processors = {
    'link': _linkHomeWidgetProcessor,
    'showlocked': _showLockedHomeWidgetProcessor,
  };

  @override
  Future<void> processUri(Uri uri, {BuildContext? context, bool fromInit = false}) async {
    if (context == null) {
      Logger.error('HomeWidgetNavigateProcessor: Cannot Navigate without context',
          error: const InvalidConfigException('context is null'), stackTrace: StackTrace.current);
      return;
    }
    Logger.warning('HomeWidgetNavigateProcessor: Processing uri: $uri');
    return _processors[uri.host]?.call(uri, context, fromInit: fromInit);
  }

  @override
  Set<String> get supportedSchemes => {'homewidgetnavigate'};

  static Future<void> _linkHomeWidgetProcessor(Uri uri, BuildContext context, {bool fromInit = false}) async {
    if (uri.host != 'link') {
      Logger.warning('HomeWidgetNavigateProcessor: Invalid host for link: ${uri.host}');
      return;
    }
    if (uri.queryParameters['id'] == null) {
      Logger.warning('HomeWidgetNavigateProcessor: Invalid query parameters for link: ${uri.queryParameters}');
      return;
    }
    if (fromInit) {
      SplashScreen.setInitialView(
        LinkHomeWidgetView(homeWidgetId: uri.queryParameters['id']!),
      );
    } else {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LinkHomeWidgetView(homeWidgetId: uri.queryParameters['id']!),
        ),
      );
    }
  }

  static Future<void> _showLockedHomeWidgetProcessor(Uri uri, BuildContext context, {bool fromInit = false}) async {
    if (uri.host != 'showlocked') {
      Logger.warning('Invalid host for showlocked: ${uri.host}', name: 'home_widget_processor.dart#_showLockedHomeWidgetProcessor');
      return;
    }
    if (uri.queryParameters['id'] == null) {
      Logger.warning('Invalid query parameters for showlocked: ${uri.queryParameters}', name: 'home_widget_processor.dart#_showLockedHomeWidgetProcessor');
      return;
    }
    Logger.info('Showing otp of locked Token of homeWidget: ${uri.queryParameters['id']}', name: 'home_widget_processor.dart#_showLockedHomeWidgetProcessor');
    Navigator.popUntil(context, (route) => route.isFirst);

    final tokenId = await HomeWidgetUtils().getTokenIdOfWidgetId(uri.queryParameters['id']!);
    if (tokenId == null) {
      Logger.warning('Could not find token for widget id: ${uri.queryParameters['id']}', name: 'home_widget_processor.dart#_showLockedHomeWidgetProcessor');
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
    if (globalRef == null) {
      Logger.warning('Could not find globalRef', name: 'home_widget_processor.dart#_showLockedHomeWidgetProcessor');
      return;
    }
    final authenticated = await globalRef!.read(tokenProvider.notifier).showTokenById(tokenId);

    if (authenticated) {
      final folderId = globalRef!.read(tokenProvider).currentOfId(tokenId)?.folderId;
      if (folderId != null) {
        globalRef!.read(tokenFolderProvider.notifier).expandFolderById(folderId);
      }
    }
  }
}
