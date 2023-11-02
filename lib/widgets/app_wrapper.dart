import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../utils/riverpod_providers.dart';

class AppWrapper extends StatelessWidget {
  final Widget child;

  const AppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: EasyDynamicThemeWidget(child: child),
    );
  }
}

class ConnectivityListener extends ConsumerWidget {
  final Widget child;
  const ConnectivityListener({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider).asData?.value;
    final hasConnection = connectivity != null && connectivity != ConnectivityResult.none;
    ref.read(tokenProvider.notifier).loadingRepo.then(
      (value) {
        final hasPushTokens = ref.read(tokenProvider).hasPushTokens;
        if (!hasConnection && hasPushTokens) {
          ref.read(statusMessageProvider.notifier).state = (AppLocalizations.of(context)!.noNetworkConnection, null);
        }
      },
    );
    return child;
  }
}
