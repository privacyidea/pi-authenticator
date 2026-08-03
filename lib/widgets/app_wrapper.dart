import 'dart:ui';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/enums/introduction.dart';
import '../utils/home_widget_utils.dart';
import '../utils/logger.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/deeplink_notifier.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../utils/riverpod/riverpod_providers/state_providers/battery_optimization_provider.dart';
import '../utils/riverpod/state_listeners/home_widget_deep_link_listener.dart';
import '../utils/riverpod/state_listeners/home_widget_token_state_listener.dart';
import '../utils/riverpod/state_listeners/navigation_deep_link_listener.dart';
import '../utils/riverpod/state_listeners/push_token_state_listener.dart';
import '../utils/riverpod/state_listeners/token_container_deep_link_listener.dart';
import '../utils/riverpod/state_listeners/token_deep_link_listener.dart';
import 'app_wrappers/single_touch_recognizer.dart';
import 'app_wrappers/state_observer.dart';
import 'dialog_widgets/battery_optimization_dialog.dart';

class AppWrapper extends StatelessWidget {
  final Widget child;

  const AppWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) => ProviderScope(
    child: _AppWrapper(key: key, child: child),
  );
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
        await Future.wait([
          _clearNotifications(),
          _refreshTokens(),
          _hideHomeWidgetOtps(),
        ]);
        await _showBatteryOptimizationHintIfPending();
      },
      onHide: () async {
        await Future.wait([
          _saveTokensOnHide(),
          _collapseLockedFoldersOnHide(),
        ]);
      },
      onExitRequested: () async {
        Logger.info('Exit requested');
        return AppExitResponse.exit;
      },
    );
  }

  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////////// On Resume ////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  Future<void> _clearNotifications() async {
    try {
      await FlutterLocalNotificationsPlugin().cancelAll();
      Logger.info('Cleared all notifications on resume');
    } catch (e) {
      Logger.error('Failed to clear notifications', error: e);
    }
  }

  Future<void> _refreshTokens() async {
    try {
      var state = await ref.read(tokenProvider.notifier).loadStateFromRepo();
      Logger.info('Refreshed tokens on resume');
      if (state != null) {
        await ref
            .read(tokenContainerProvider.notifier)
            .syncContainers(tokenState: state, isManually: false);
        state = await ref.read(tokenProvider.future);
        Logger.info('Synchronized containers on resume');
      }
      final hasPushToken = state?.hasPushTokens == true;
      if (hasPushToken) {
        final prProvider = ref.read(pushRequestProvider.notifier);
        await prProvider.loadStateFromRepo();
        await prProvider.pollForChallenges(isManually: false);
        Logger.info('Polled for challenges on resume');
      }
    } catch (e) {
      Logger.error('Failed to refresh tokens on resume', error: e);
    }
  }

  Future<void> _hideHomeWidgetOtps() async {
    try {
      final hidden = await HomeWidgetUtils().hideAllOtps();
      if (hidden) Logger.info('Hid all HomeWidget OTPs on resume');
    } catch (e) {
      Logger.error('Failed to hide HomeWidget OTPs', error: e);
    }
  }

  /// Shows the battery optimization hint at most once, if the user has linked
  /// a home widget and has not yet been prompted about battery optimization.
  Future<void> _showBatteryOptimizationHintIfPending() async {
    ref.invalidate(batteryOptimizationsIsDisabledProvider);
    final isDisabled = await ref.read(
      batteryOptimizationsIsDisabledProvider.future,
    );
    if (isDisabled) return;
    final introductions = await ref.read(introductionNotifierProvider.future);
    if (!introductions.isCompleted(Introduction.homeWidgetSetUp) ||
        !introductions.isUncompleted(
          Introduction.homeWidgetBatteryOptimization,
        )) {
      return;
    }
    await BatteryOptimizationDialog.showDialog();
    await ref
        .read(introductionNotifierProvider.notifier)
        .complete(Introduction.homeWidgetBatteryOptimization);
  }

  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////// On Hide /////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////

  Future<void> _saveTokensOnHide() async {
    try {
      if (await ref.read(tokenProvider.notifier).onMinimizeApp() == false) {
        Logger.error('Failed to save tokens on Hide');
      }
    } catch (e) {
      Logger.error('Failed to save tokens on Hide', error: e);
    }
  }

  Future<void> _collapseLockedFoldersOnHide() async {
    try {
      final folders = await ref
          .read(tokenFolderProvider.notifier)
          .collapseLockedFolders();
      if (folders.folders.any(
        (folder) => folder.isLocked && folder.isExpanded,
      )) {
        Logger.error('Failed to collapse locked folders on Hide');
      } else {
        Logger.info('Collapsed locked folders on Hide');
      }
    } catch (e) {
      Logger.error('Failed to collapse locked folders on Hide', error: e);
    }
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
        buildlessProviderListener: [],
        streamNotifierProviderListeners: [
          NavigationDeepLinkListener(provider: deeplinkProvider),
          HomeWidgetDeepLinkListener(provider: deeplinkProvider),
          TokenImportDeepLinkListener(provider: deeplinkProvider),
          TokenContainerDeepLinkListener(provider: deeplinkProvider),
        ],
        asyncNotifierProviderListeners: [
          PushProviderTokenStateListener(provider: tokenProvider),
          HomeWidgetTokenStateListener(provider: tokenProvider),
        ],
        child: EasyDynamicThemeWidget(child: widget.child),
      ),
    );
  }
}
