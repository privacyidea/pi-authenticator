import 'dart:ui';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/home_widget_utils.dart';
import '../utils/logger.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/deeplink_notifier.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../utils/riverpod/state_listeners/home_widget_deep_link_listener.dart';
import '../utils/riverpod/state_listeners/home_widget_token_state_listener.dart';
import '../utils/riverpod/state_listeners/navigation_deep_link_listener.dart';
import '../utils/riverpod/state_listeners/token_container_deep_link_listener.dart';
import '../utils/riverpod/state_listeners/token_deep_link_listener.dart';
import 'app_wrappers/single_touch_recognizer.dart';
import 'app_wrappers/state_observer.dart';

class AppWrapper extends StatelessWidget {
  final Widget child;

  const AppWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) => ProviderScope(child: _AppWrapper(key: key, child: child));
}

class _AppWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const _AppWrapper({required this.child, super.key});

  @override
  ConsumerState<_AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends ConsumerState<_AppWrapper> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onResume: () async {
        final state = await ref.read(tokenProvider.notifier).loadStateFromRepo();
        Logger.info('Refreshed tokens on resume');
        final hasPushToken = state?.hasPushTokens == true;
        if (hasPushToken) {
          final prProvider = ref.read(pushRequestProvider.notifier);
          await prProvider.loadStateFromRepo();
          await prProvider.pollForChallenges(isManually: false);
          Logger.info('Polled for challenges on resume');
        }
        final hidden = await HomeWidgetUtils().hideAllOtps();
        if (hidden) Logger.info('Hid all HomeWidget OTPs on resume');
      },
      onHide: () async {
        if (await ref.read(tokenProvider.notifier).onMinimizeApp() == false) {
          Logger.error('Failed to save tokens on Hide');
        }
        if ((await ref.read(tokenFolderProvider.notifier).collapseLockedFolders()).folders.any((folder) => folder.isLocked && folder.isExpanded)) {
          Logger.error('Failed to collapse locked folders on Hide');
        }
        await FlutterLocalNotificationsPlugin().cancelAll();
        Logger.info('Collapsed locked folders on Hide');
      },
      onExitRequested: () async {
        Logger.info('Exit requested');
        return AppExitResponse.exit;
      },
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleTouchRecognizer(
      child: StateObserver(
        stateNotifierProviderListeners: const [],
        buildlessProviderListener: [
          HomeWidgetTokenStateListener(provider: tokenProvider),
        ],
        streamNotifierProviderListeners: [
          NavigationDeepLinkListener(deeplinkProvider: deeplinkNotifierProvider),
          HomeWidgetDeepLinkListener(deeplinkProvider: deeplinkNotifierProvider),
          TokenImportDeepLinkListener(deeplinkProvider: deeplinkNotifierProvider),
          TokenContainerDeepLinkListener(deeplinkProvider: deeplinkNotifierProvider),
        ],
        asyncNotifierProviderListeners: [],
        child: EasyDynamicThemeWidget(
          child: widget.child,
        ),
      ),
    );
  }
}
