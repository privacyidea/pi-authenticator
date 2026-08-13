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
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/push_request/push_request.dart';
import '../model/tokens/push_token.dart';
import '../utils/push_provider.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'dialog_widgets/push_request_dialogs/push_request_dialog.dart';

class PushRequestListener extends ConsumerStatefulWidget {
  final Widget child;
  const PushRequestListener({required this.child, super.key});

  @override
  ConsumerState<PushRequestListener> createState() =>
      _PushRequestListenerState();
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
    final pushTokens = ref.watch(tokenProvider).value?.pushTokens ?? [];

    if (pushTokens.isEmpty) return widget.child;

    final candidate = ref
        .watch(pushRequestProvider)
        .whenOrNull(
          data: (data) => _latestActionableRequest(
            pushRequests: data.pushRequests,
            pushTokens: pushTokens,
          ),
        );

    if (candidate == null) return widget.child;
    final (pushRequest, matchingToken) = candidate;

    return Stack(
      children: [
        widget.child,
        PushRequestDialog(
          pushRequest: pushRequest,
          token: matchingToken,
          key: Key('${pushRequest.hashCode}#PushRequestDialog'),
        ),
      ],
    );
  }

  (PushRequest, PushToken)? _latestActionableRequest({
    required List<PushRequest> pushRequests,
    required List<PushToken> pushTokens,
  }) {
    for (final pushRequest in pushRequests.reversed) {
      final matchingToken = pushTokens.firstWhereOrNull(
        (token) =>
            token.serial == pushRequest.serial &&
            !token.isBiometricKeyInvalidated,
      );
      if (matchingToken != null) return (pushRequest, matchingToken);
    }
    return null;
  }
}
