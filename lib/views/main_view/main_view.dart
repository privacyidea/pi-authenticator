import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';

import '../../model/states/app_state.dart';
import '../../utils/app_customizer.dart';
import '../../utils/riverpod_providers.dart';
import 'main_view_widgets/main_view_navigation_buttons.dart';
import 'main_view_widgets/main_view_tokens_list.dart';
import 'main_view_widgets/no_token_screen.dart';

class MainView extends ConsumerStatefulWidget {
  static const routeName = '/';

  final String _title;

  const MainView({Key? key, required String title})
      : _title = title,
        super(key: key);

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> with LifecycleMixin {
  @override
  void onResume() {
    globalRef?.read(appStateProvider.notifier).setAppState(AppState.resume);
  }

  @override
  void onPause() {
    globalRef?.read(appStateProvider.notifier).setAppState(AppState.pause);
  }

  @override
  Widget build(BuildContext context) {
    final tokenList = ref.watch(tokenProvider).tokens;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget._title,
          overflow: TextOverflow.ellipsis,
          // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
        ),
        leading: Image.asset(ApplicationCustomizer.appIcon),
      ),
      extendBodyBehindAppBar: false,
      body: Stack(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          tokenList.isEmpty ? const NoTokenScreen() : MainViewTokensList(tokenList),
          const MainViewNavigationButtions(),
        ],
      ),
    );
  }
}
