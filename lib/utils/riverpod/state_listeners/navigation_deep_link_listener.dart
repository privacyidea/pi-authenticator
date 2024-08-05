import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../interfaces/riverpod/state_listeners/state_notifier_provider_listeners/deep_link_listener.dart';
import '../../../model/deeplink.dart';
import '../../../processors/scheme_processors/navigation_scheme_processors/navigation_scheme_processor_interface.dart';

class NavigationDeepLinkListener extends DeepLinkListener {
  static BuildContext? _context;
  NavigationDeepLinkListener({required super.deeplinkProvider, BuildContext? context})
      : super(
          onNewState: (AsyncValue<DeepLink>? previous, AsyncValue<DeepLink> next) {
            _onNewState(previous, next);
          },
          listenerName: 'NavigationSchemeProcessor.processUriByAny',
        ) {
    _context = context;
  }

  static void _onNewState(AsyncValue<DeepLink>? previous, AsyncValue<DeepLink> next) {
    next.whenData((next) {
    NavigationSchemeProcessor.processUriByAny(next.uri, context: _context, fromInit: next.fromInit);
    });
  }
}
