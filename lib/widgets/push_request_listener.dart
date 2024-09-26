import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/riverpod_providers.dart';
import '../utils/push_provider.dart';
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
    final pushRequest = ref.watch(pushRequestProvider).pushRequests.firstOrNull;
    return Stack(
      children: [
        widget.child,
        if (pushRequest != null)
          PushRequestDialog(
            pushRequest: pushRequest,
            key: Key('${pushRequest.hashCode.toString()}#PushRequestDialog'),
          ),
      ],
    );
  }
}
