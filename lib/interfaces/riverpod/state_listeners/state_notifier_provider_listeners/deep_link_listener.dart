import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/deeplink.dart';
import '../../../../utils/logger.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/deeplink_provider.dart';

abstract class DeepLinkListener extends StreamNotifierProviderListener<DeeplinkProvider, DeepLink> {
  const DeepLinkListener({
    required StreamNotifierProvider<DeeplinkProvider, DeepLink> deeplinkProvider,
    required super.onNewState,
    required super.listenerName,
  }) : super(provider: deeplinkProvider);
}



abstract class StreamNotifierProviderListener<T extends StreamNotifier<S>, S> {
  final String listenerName;
  final StreamNotifierProvider<T, S> provider;
  final void Function(AsyncValue<S>? previous, AsyncValue<S> next) onNewState;
  const StreamNotifierProviderListener({required this.provider, required this.onNewState, required this.listenerName});
  void buildListen(WidgetRef ref) {
    Logger.debug('("$listenerName") listening to provider ("$provider")', name: 'StateNotifierProviderListener#buildListen');
    ref.listen(provider, (previous, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onNewState(previous, next));
    });
  }
}
