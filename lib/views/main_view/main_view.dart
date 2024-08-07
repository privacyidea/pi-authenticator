/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../model/states/token_filter.dart';
import '../../utils/logger.dart';
import '../../utils/patch_notes_utils.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../../utils/riverpod/riverpod_providers/state_providers/token_filter_provider.dart';
import '../../widgets/push_request_listener.dart';
import '../../widgets/status_bar.dart';
import '../view_interface.dart';
import 'main_view_widgets/app_bar_item.dart';
import 'main_view_widgets/connectivity_listener.dart';
import 'main_view_widgets/expandable_appbar.dart';
import 'main_view_widgets/main_view_navigation_bar.dart';
import 'main_view_widgets/main_view_tokens_list.dart';
import 'main_view_widgets/main_view_tokens_list_filtered.dart';

export '../../views/main_view/main_view.dart';

class MainView extends ConsumerStatefulView {
  static const routeName = '/mainView';

  @override
  RouteSettings get routeSettings => const RouteSettings(name: routeName);

  final Widget appIcon;
  final String appName;
  final bool disablePatchNotes;

  const MainView({required this.appIcon, required this.appName, required this.disablePatchNotes, super.key});

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  final globalKey = GlobalKey<NestedScrollViewState>();

  @override
  void initState() {
    super.initState();
    final latestStartedVersion = globalRef?.read(settingsProvider).latestStartedVersion;
    Logger.warning('Latest started version: $latestStartedVersion', name: 'main_view.dart#initState');
    if (latestStartedVersion == null || widget.disablePatchNotes) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PatchNotesUtils.showPatchNotesIfNeeded(context, latestStartedVersion);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = ref.watch(tokenFilterProvider) != null;
    return PushRequestListener(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: ExpandableAppBar(
          startExpand: hasFilter,
          appBar: AppBar(
              titleSpacing: 6,
              title: Text(
                widget.appName,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
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
                        tooltip: AppLocalizations.of(context)!.closeSearchTokens,
                        onPressed: () {
                          ref.read(tokenFilterProvider.notifier).state = null;
                        },
                        icon: const Icon(Icons.close),
                      )
                    : AppBarItem(
                        tooltip: AppLocalizations.of(context)!.searchTokens,
                        onPressed: () {
                          ref.read(tokenFilterProvider.notifier).state = TokenFilter(
                            searchQuery: '',
                          );
                        },
                        icon: const Icon(Icons.search),
                      ),
              ]),
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
      ),
    );
  }
}
