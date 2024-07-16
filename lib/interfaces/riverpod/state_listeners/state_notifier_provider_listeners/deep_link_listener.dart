import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/deeplink.dart';
import '../../../../state_notifiers/deeplink_notifier.dart';
import '../state_notifier_provider_listener.dart';

abstract class DeepLinkListener extends StateNotifierProviderListener<DeeplinkNotifier, DeepLink?> {
  const DeepLinkListener({
    required StateNotifierProvider<DeeplinkNotifier, DeepLink?> deeplinkProvider,
    required super.onNewState,
  }) : super(provider: deeplinkProvider);
}
