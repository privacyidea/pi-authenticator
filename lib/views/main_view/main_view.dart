import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';
import 'package:privacyidea_authenticator/views/push_token_view/push_tokens_view.dart';

import '../../model/states/app_state.dart';
import '../../utils/logger.dart';
import '../../utils/riverpod_providers.dart';
import 'main_view_widgets/main_view_navigation_buttons.dart';
import 'main_view_widgets/main_view_tokens_list.dart';
export 'package:privacyidea_authenticator/views/main_view/main_view.dart';

class MainView extends ConsumerStatefulWidget {
  static const routeName = '/mainView';

  final Widget appIcon;
  final String appName;

  const MainView({required this.appIcon, required this.appName, Key? key}) : super(key: key);

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> with LifecycleMixin {
  final globalKey = GlobalKey<NestedScrollViewState>();

  @override
  void onAppResume() {
    Logger.info('MainView Resume', name: 'main_view.dart#onAppResume');
    globalRef?.read(appStateProvider.notifier).setAppState(AppState.resume);
    WidgetsBinding.instance.addPostFrameCallback((_) => globalRef?.read(appStateProvider.notifier).setAppState(AppState.running));
  }

  @override
  void onAppPause() {
    Logger.info('MainView Pause', name: 'main_view.dart#onAppPause');
    globalRef?.read(appStateProvider.notifier).setAppState(AppState.pause);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            widget.appName,
            overflow: TextOverflow.ellipsis,
            // maxLines: 2 only works like this.
            maxLines: 2, // Title can be shown on small screens too.
          ),
          leading: Padding(
            padding: const EdgeInsets.all(4),
            child: widget.appIcon,
          ),
          actions: [
            if (ref.watch(tokenProvider).hasPushTokens && ref.watch(settingsProvider).hidePushTokens)
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () => Navigator.pushNamed(context, PushTokensView.routeName),
              )
          ],
        ),
        body: Stack(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          children: [
            MainViewTokensList(nestedScrollViewKey: globalKey),
            const MainViewNavigationButtions(),
          ],
        ),
      );
}
