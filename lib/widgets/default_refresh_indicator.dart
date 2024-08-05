import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'deactivateable_refresh_indicator.dart';

import '../utils/logger.dart';
import '../utils/push_provider.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/credential_nofitier.dart';
import '../views/main_view/main_view_widgets/loading_indicator.dart';

class DefaultRefreshIndicator extends ConsumerStatefulWidget {
  final Widget child;
  final bool allowToRefresh;

  const DefaultRefreshIndicator({
    super.key,
    required this.child,
    required this.allowToRefresh,
  });

  @override
  ConsumerState<DefaultRefreshIndicator> createState() => _DefaultRefreshIndicatorState();
}

class _DefaultRefreshIndicatorState extends ConsumerState<DefaultRefreshIndicator> {
  bool isRefreshing = false;
  @override
  Widget build(BuildContext context) => DeactivateableRefreshIndicator(
        onRefresh: () async {
          setState(() {
            isRefreshing = true;
          });
          final future = LoadingIndicator.show(context, () async {
            final pushProviderInstance = PushProvider.instance;
            final credentials = (await ref.read(credentialsNotifierProvider.future)).credentials;
            Logger.debug('Refreshing container with ${credentials.length} credentials');
            await Future.wait([
              if (pushProviderInstance != null) pushProviderInstance.pollForChallenges(isManually: true),
              for (var credential in credentials) (ref.read(tokenContainerNotifierProviderOf(credential: credential).notifier).sync()),
            ]);
          });
          await future;
          if (mounted) setState(() => isRefreshing = false);
        },
        allowToRefresh: widget.allowToRefresh && !isRefreshing,
        child: widget.child,
      );
}
