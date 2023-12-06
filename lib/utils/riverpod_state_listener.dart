import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/processors/scheme_processors/home_widget_processor.dart';
import '../model/processors/scheme_processors/navigation_scheme_processor.dart';
import '../state_notifiers/deeplink_notifier.dart';
import 'customizations.dart';

class StateObserver extends ConsumerWidget {
  final List<StateNotifierProivderListener> listeners;
  final Widget child;

  const StateObserver({super.key, required this.listeners, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    for (final listener in listeners) {
      listener.buildListen(ref);
    }
    return child;
  }
}

abstract class StateNotifierProivderListener<T extends StateNotifier<S>, S> {
  final StateNotifierProvider<T, S> provider;
  final void Function(S? previous, S next) onNewState;
  const StateNotifierProivderListener({required this.provider, required this.onNewState});
  void buildListen(WidgetRef ref) {
    ref.listen(provider, onNewState);
  }
}

abstract class DeepLinkListener extends StateNotifierProivderListener<DeeplinkNotifier, Uri?> {
  const DeepLinkListener({
    required StateNotifierProvider<DeeplinkNotifier, Uri?> deeplinkProvider,
    required super.onNewState,
  }) : super(provider: deeplinkProvider);
}

class NavigationDeepLinkListener extends DeepLinkListener {
  const NavigationDeepLinkListener({
    required StateNotifierProvider<DeeplinkNotifier, Uri?> provider,
  }) : super(
          deeplinkProvider: provider,
          onNewState: _onNewState,
        );

  static void _onNewState(Uri? previous, Uri? next) {
    if (next == null) return;
    NavigationSchemeProcessor.processUri(next, context: globalNavigatorKey.currentState?.context);
  }
}

class HomeWidgetDeepLinkListener extends DeepLinkListener {
  const HomeWidgetDeepLinkListener({
    required StateNotifierProvider<DeeplinkNotifier, Uri?> provider,
  }) : super(
          deeplinkProvider: provider,
          onNewState: _onNewState,
        );

  static void _onNewState(Uri? previous, Uri? next) {
    if (next == null) return;
    const HomeWidgetProcessor().process(next);
  }
}
