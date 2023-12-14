import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/processors/scheme_processors/home_widget_processor.dart';
import '../model/processors/scheme_processors/navigation_scheme_processor.dart';
import '../state_notifiers/deeplink_notifier.dart';

abstract class StateNotifierProivderListener<T extends StateNotifier<S>, S> {
  final StateNotifierProvider<T, S> provider;
  final void Function(S? previous, S next) onNewState;
  const StateNotifierProivderListener({required this.provider, required this.onNewState});
  void buildListen(WidgetRef ref) {
    ref.listen(provider, onNewState);
  }
}

abstract class DeepLinkListener extends StateNotifierProivderListener<DeeplinkNotifier, DeepLink?> {
  const DeepLinkListener({
    required StateNotifierProvider<DeeplinkNotifier, DeepLink?> deeplinkProvider,
    required super.onNewState,
  }) : super(provider: deeplinkProvider);
}

class NavigationDeepLinkListener extends DeepLinkListener {
  static BuildContext? _context;
  NavigationDeepLinkListener({
    required StateNotifierProvider<DeeplinkNotifier, DeepLink?> provider,
    BuildContext? context,
  }) : super(
          deeplinkProvider: provider,
          onNewState: (DeepLink? previous, DeepLink? next) {
            _onNewState(previous, next);
          },
        ) {
    _context = context;
  }

  static void _onNewState(DeepLink? previous, DeepLink? next) {
    if (next == null) return;
    NavigationSchemeProcessor.processUri(next.uri, context: _context, fromInit: next.fromInit);
  }
}

class HomeWidgetDeepLinkListener extends DeepLinkListener {
  const HomeWidgetDeepLinkListener({
    required StateNotifierProvider<DeeplinkNotifier, DeepLink?> provider,
  }) : super(
          deeplinkProvider: provider,
          onNewState: _onNewState,
        );

  static void _onNewState(DeepLink? previous, DeepLink? next) {
    if (next == null) return;
    const HomeWidgetProcessor().process(next.uri, fromInit: next.fromInit);
  }
}

class DeepLink {
  final Uri uri;
  final bool fromInit;
  const DeepLink(this.uri, {this.fromInit = false});
}
