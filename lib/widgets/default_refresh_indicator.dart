/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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

import '../utils/push_provider.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../views/main_view/main_view_widgets/loading_indicator.dart';

class DefaultRefreshIndicator extends ConsumerStatefulWidget {
  final Widget child;
  final GlobalKey? listViewKey;
  final ScrollController? scrollController;

  const DefaultRefreshIndicator({
    super.key,
    this.listViewKey,
    this.scrollController,
    required this.child,
  });

  @override
  ConsumerState<DefaultRefreshIndicator> createState() =>
      _DefaultRefreshIndicatorState();
}

class _DefaultRefreshIndicatorState
    extends ConsumerState<DefaultRefreshIndicator> {
  bool isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final hasRolledOutPushTokens =
        ref.watch(tokenProvider).value?.hasRolledOutPushTokens ?? false;
    final hasFinalizedContainers =
        ref.watch(tokenContainerProvider).value?.hasFinalizedContainers == true;

    final allowToRefresh =
        (hasRolledOutPushTokens || hasFinalizedContainers) && !isRefreshing;

    final content = SingleChildScrollView(
      key: widget.listViewKey,
      physics: _getScrollPhysics(allowToRefresh),
      controller: widget.scrollController,
      child: widget.child,
    );

    if (!allowToRefresh) {
      return content;
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      child: content,
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      isRefreshing = true;
    });

    await LoadingIndicator.show(
      context: context,
      action: () async {
        final tokenState = await ref.read(tokenProvider.future);
        if (!mounted) return Future.value();

        return Future.wait([
          if (PushProvider.instance != null)
            PushProvider.instance!.pollForChallenges(isManually: true),
          ref
              .read(tokenContainerProvider.notifier)
              .syncContainers(tokenState: tokenState, isManually: true),
        ]);
      },
    );

    if (mounted) {
      setState(() => isRefreshing = false);
    }
  }

  ScrollPhysics _getScrollPhysics(bool allowToRefresh) => allowToRefresh
      ? const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics())
      : const ClampingScrollPhysics();
}
