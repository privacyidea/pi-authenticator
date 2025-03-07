/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/logger.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import '../../../utils/riverpod/riverpod_providers/stream_providers/connectivity_provider.dart';

class ConnectivityListener extends ConsumerWidget {
  final Widget child;
  const ConnectivityListener({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider).asData?.value;
    if (connectivity != null && connectivity.contains(ConnectivityResult.none)) {
      ref.read(tokenProvider.notifier).initState.then((newState) {
        if (newState.hasPushTokens) {
          Logger.info("Connectivity changed: $connectivity");
          if (!context.mounted) return;
          ref.read(statusMessageProvider.notifier).state = StatusMessage(message: (localization) => AppLocalizations.of(context)!.noNetworkConnection);
        }
      });
    }
    return child;
  }
}
