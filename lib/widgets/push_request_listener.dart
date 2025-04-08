import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';

import '../utils/push_provider.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import 'dialog_widgets/push_request_dialog/push_request_dialog.dart';

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
      PushProvider.instance?.pollForChallenges(isManually: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasPushToken = ref.watch(tokenProvider).valueOrNull?.hasPushTokens ?? false;
    if (!hasPushToken) return widget.child;
    final pushRequest = ref.watch(pushRequestProvider).whenOrNull(data: (data) => data.pushRequests.firstOrNull);
    if (pushRequest == null) return widget.child;
    return Stack(
      children: [
        widget.child,
        PushRequestDialog(
          pushRequest: pushRequest,
          key: Key('${pushRequest.hashCode.toString()}#PushRequestDialog'),
        ),
      ],
    );
  }
}
