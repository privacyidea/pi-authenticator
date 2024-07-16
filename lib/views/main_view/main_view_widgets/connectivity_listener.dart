import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/logger.dart';
import '../../../utils/riverpod/riverpod_providers/state_notifier_providers/token_provider.dart';
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
          ref.read(statusMessageProvider.notifier).state = (AppLocalizations.of(context)!.noNetworkConnection, null);
        }
      });
    }
    return child;
  }
}
