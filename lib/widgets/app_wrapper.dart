import 'dart:ui';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/home_widget_utils.dart';
import '../utils/logger.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/deeplink_notifier.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../utils/riverpod/state_listeners/home_widget_deep_link_listener.dart';
import '../utils/riverpod/state_listeners/home_widget_token_state_listener.dart';
import '../utils/riverpod/state_listeners/navigation_deep_link_listener.dart';
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
        await ref.read(tokenProvider.notifier).loadStateFromRepo();
        Logger.info('Refreshed tokens on resume');
        final prProvider = ref.read(pushRequestProvider.notifier);
        await prProvider.loadStateFromRepo();
        await prProvider.pollForChallenges(isManually: false);
        Logger.info('Polled for challenges on resume');
        final hidden = await HomeWidgetUtils().hideAllOtps();
        if (hidden) Logger.info('Hid all HomeWidget OTPs on resume');
      },
      // onInactive: () => log('App inactive'),
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
      //     onShow: () => log('App shown'),
      //     onPause: () => log('App paused'),
      //     onRestart: () => log('App restarted'),
      //     onDetach: () => log('App detached'),
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
    final container = ref.watch(tokenContainerProvider).value?.containerList ?? [];
    Logger.debug('Credentials: $container');
    return SingleTouchRecognizer(
      child: StateObserver(
        stateNotifierProviderListeners: const [],
        buildlessProviderListener: [
          HomeWidgetTokenStateListener(provider: tokenProvider),
          // ContainerListensToTokenState(provider: tokenProvider, ref: ref),
        ],
        streamNotifierProviderListeners: [
          NavigationDeepLinkListener(deeplinkProvider: deeplinkNotifierProvider),
          HomeWidgetDeepLinkListener(deeplinkProvider: deeplinkNotifierProvider), // TODO: Nochmal anschauen
        ],
        // asyncNotifierProviderListeners: [
        //   ...container.map(
        //     (container) {
        //       return TokenStateListensToContainer(
        //         containerProvider: tokenContainerNotifierProviderOf(container: container),
        //         ref: ref,
        //       );
        //     },
        //   ),
        // ],
        child: EasyDynamicThemeWidget(
          child: widget.child,
        ),
      ),
    );
  }
}

// class TokenStateListensToContainer extends AsyncContainerListener {
//   final WidgetRef ref;
//   TokenStateListensToContainer({
//     required super.containerProvider,
//     required this.ref,
//   }) : super(onNewState: (previous, next) => _onNewState(previous, next, ref));

//   static Future<void> _onNewState(AsyncValue<TokenContainer?>? previous, AsyncValue<TokenContainer?> next, WidgetRef ref) async {
//     Logger.info('TokenState got new container state', name: 'TokenStateListensToContainer');
//     final value = next.value;
//     if (value == null) return;
//     final provider = ref.read(tokenProvider.notifier);
//     provider.updateContainerTokens(value);
//   }
// }

// abstract class AsyncContainerListener extends AsyncNotifierProviderListener<TokenContainerNotifier, TokenContainer?> {
//   const AsyncContainerListener({
//     required TokenContainerNotifierProvider containerProvider,
//     required super.onNewState,
//   }) : super(provider: containerProvider);
// }
