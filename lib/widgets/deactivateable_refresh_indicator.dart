import 'package:flutter/material.dart';

class DeactivateableRefreshIndicator extends StatelessWidget {
  final Widget child;
  final bool allowToRefresh;
  final Future<void> Function() onRefresh;

  const DeactivateableRefreshIndicator({
    super.key,
    required this.child,
    required this.allowToRefresh,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return allowToRefresh
        ? RefreshIndicator(
            onRefresh: () async {
              onRefresh();
            },
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            child: child,
          )
        : child;
  }
}
