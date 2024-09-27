import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';

import '../utils/push_provider.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../views/main_view/main_view_widgets/loading_indicator.dart';
import 'deactivateable_refresh_indicator.dart';

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
  ConsumerState<DefaultRefreshIndicator> createState() => _DefaultRefreshIndicatorState();
}

class _DefaultRefreshIndicatorState extends ConsumerState<DefaultRefreshIndicator> {
  bool isRefreshing = false;
  @override
  Widget build(BuildContext context) {
    final allowToRefresh = ref.watch(tokenProvider).hasRolledOutPushTokens || ref.watch(tokenContainerProvider).value?.hasFinalizedContainers == true;
    return DeactivateableRefreshIndicator(
      onRefresh: () async {
        setState(() {
          isRefreshing = true;
        });
        final future = LoadingIndicator.show(context, () async {
          final pushProviderInstance = PushProvider.instance;
          final tokenState = ref.read(tokenProvider);
          await Future.wait([
            if (pushProviderInstance != null) pushProviderInstance.pollForChallenges(isManually: true),
            ref.read(tokenContainerProvider.notifier).syncTokens(tokenState),
          ]);
        });
        await future;
        if (mounted) setState(() => isRefreshing = false);
      },
      allowToRefresh: allowToRefresh && !isRefreshing,
      child: SingleChildScrollView(
        key: widget.listViewKey,
        physics: _getScrollPhysics(allowToRefresh),
        controller: widget.scrollController,
        child: widget.child,
      ),
    );
  }

  ScrollPhysics _getScrollPhysics(bool allowToRefresh) =>
      allowToRefresh ? const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()) : const BouncingScrollPhysics();
}
