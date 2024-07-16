import 'package:flutter/material.dart';

import '../../../interfaces/riverpod/state_listeners/state_notifier_provider_listeners/deep_link_listener.dart';
import '../../../model/deeplink.dart';
import '../../../processors/scheme_processors/navigation_scheme_processors/navigation_scheme_processor_interface.dart';

class NavigationDeepLinkListener extends DeepLinkListener {
  static BuildContext? _context;
  NavigationDeepLinkListener({required super.deeplinkProvider, BuildContext? context})
      : super(
          onNewState: (DeepLink? previous, DeepLink? next) {
            _onNewState(previous, next);
          },
        ) {
    _context = context;
  }

  static void _onNewState(DeepLink? previous, DeepLink? next) {
    if (next == null) return;
    NavigationSchemeProcessor.processUriByAny(next.uri, context: _context, fromInit: next.fromInit);
  }
}
