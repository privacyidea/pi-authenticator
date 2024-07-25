import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../interfaces/riverpod/state_listeners/notifier_provider_listener.dart';
import '../../interfaces/riverpod/state_listeners/state_notifier_provider_listener.dart';


class StateObserver extends ConsumerWidget {
  final List<AsyncNotifierProviderListener> asyncNotifierProviderListeners;
  final List<StateNotifierProviderListener> stateNotifierProviderListeners;
  final Widget child;

  const StateObserver({super.key, this.asyncNotifierProviderListeners = const [], this.stateNotifierProviderListeners = const [], required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    for (final listener in stateNotifierProviderListeners) {
      listener.buildListen(ref);
    }
    return child;
  }
}
