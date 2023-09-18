import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';

import '../../model/states/app_state.dart';
import '../../utils/logger.dart';
import '../../utils/riverpod_providers.dart';
import 'main_view_widgets/main_view_navigation_buttons.dart';
import 'main_view_widgets/main_view_tokens_list.dart';
import 'main_view_widgets/no_token_screen.dart';

export 'package:privacyidea_authenticator/views/main_view/main_view.dart';

class MainView extends ConsumerStatefulWidget {
  static const routeName = '/mainView';

  const MainView({Key? key}) : super(key: key);

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> with LifecycleMixin {
  final globalKey = GlobalKey<NestedScrollViewState>();
  @override
  void onResume() {
    Logger.info('onResume');
    setState(() {});
    globalRef?.read(appStateProvider.notifier).setAppState(AppState.resume);
  }

  @override
  void onPause() {
    Logger.info('onPause');
    globalRef?.read(appStateProvider.notifier).setAppState(AppState.pause);
  }

  @override
  Widget build(BuildContext context) {
    final tokenList = ref.watch(tokenProvider).tokens;
    final folderList = ref.watch(tokenFolderProvider).folders;
    final applicationCustomizer = ref.watch(applicationCustomizerProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          applicationCustomizer.appName,
          overflow: TextOverflow.ellipsis,
          // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
        ),
        leading: Padding(
          padding: const EdgeInsets.all(4),
          child: applicationCustomizer.appIcon,
        ),
      ),
      body: Stack(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          tokenList.isEmpty && folderList.isEmpty ? const NoTokenScreen() : MainViewTokensList(tokenList, nestedScrollViewKey: globalKey),
          const MainViewNavigationButtions(),
        ],
      ),
    );
  }
}
