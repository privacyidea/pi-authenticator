import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/riverpod_providers.dart';
import '../utils/push_provider.dart';
import 'dialog_widgets/push_request_dialog.dart';

class PushRequestListener extends ConsumerStatefulWidget {
  final Widget child;
  const PushRequestListener({required this.child, super.key});

  @override
  ConsumerState<PushRequestListener> createState() => _PushRequestListenerState();
}

class _PushRequestListenerState extends ConsumerState<PushRequestListener> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PushProvider().pollForChallenges(isManually: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokensWithPushRequest = ref.watch(tokenProvider).pushTokens.where((token) => token.pushRequests.isNotEmpty);
    final tokenWithPushRequest = tokensWithPushRequest.isNotEmpty ? tokensWithPushRequest.first : null;
    return Stack(
      children: [
        widget.child,
        if (tokenWithPushRequest != null)
          PushRequestDialog(
            tokenWithPushRequest,
            key: Key('${tokenWithPushRequest.pushRequests.peek().hashCode.toString()}#PushRequestDialog'),
          ),
      ],
    );
  }
}
