import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../interfaces/riverpod/state_listeners/state_notifier_provider_listeners/deep_link_listener.dart';
import '../../../model/deeplink.dart';
import '../../../processors/scheme_processors/home_widget_processor.dart';

class HomeWidgetDeepLinkListener extends DeepLinkListener {
  const HomeWidgetDeepLinkListener({
    required super.deeplinkProvider,
  }) : super(
          onNewState: _onNewState,
          listenerName: 'HomeWidgetProcessor().processUri',
        );

  static void _onNewState(AsyncValue<DeepLink>? previous, AsyncValue<DeepLink> next) {
    next.whenData((next) {
      const HomeWidgetProcessor().processUri(next.uri, fromInit: next.fromInit);
    });
  }
}
