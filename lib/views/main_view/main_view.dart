import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';

import '../../model/states/app_state.dart';
import '../../model/states/token_filter.dart';
import '../../utils/logger.dart';
import '../../utils/riverpod_providers.dart';
import '../../widgets/status_bar.dart';
import 'main_view_widgets/app_bar_item.dart';
import 'main_view_widgets/connectivity_listener.dart';
import 'main_view_widgets/expandable_appbar.dart';
import 'main_view_widgets/main_view_navigation_bar.dart';
import 'main_view_widgets/main_view_tokens_list.dart';
import 'main_view_widgets/main_view_tokens_list_filtered.dart';

export 'package:privacyidea_authenticator/views/main_view/main_view.dart';

class MainView extends ConsumerStatefulWidget {
  static const routeName = '/mainView';

  final Widget appIcon;
  final String appName;

  const MainView({required this.appIcon, required this.appName, super.key});

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
  Widget build(BuildContext context) {
    final hasFilter = ref.watch(tokenFilterProvider) != null;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ExpandableAppBar(
        startExpand: hasFilter,
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
            hasFilter
                ? AppBarItem(
                    onPressed: () {
                      ref.read(tokenFilterProvider.notifier).state = null;
                    },
                    icon: const Icon(Icons.close),
                  )
                : AppBarItem(
                    onPressed: () {
                      ref.read(tokenFilterProvider.notifier).state = TokenFilter(
                        // filterCategory: TokenFilterCategory.issuer,
                        searchQuery: '',
                      );
                    },
                    icon: const Icon(Icons.search),
                  ),
          ],
        ),
        body: ConnectivityListener(
          child: StatusBar(
            child: !hasFilter
                ? Stack(
                    children: [
                      MainViewTokensList(nestedScrollViewKey: globalKey),
                      const MainViewNavigationBar(),
                    ],
                  )
                : const MainViewTokensListFiltered(),
          ),
        ),
      ),
    );
  }
}
