import 'package:flutter/material.dart';

class DeactivateableRefreshIndicator extends StatelessWidget {
  final Widget child;
  final bool allowToRefresh;
  final Future<void> Function() onRefresh;

  const DeactivateableRefreshIndicator({
    Key? key,
    required this.child,
    required this.allowToRefresh,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return allowToRefresh
        ? RefreshIndicator(
            onRefresh: onRefresh,
            child: child,
          )
        : child;
  }
}
