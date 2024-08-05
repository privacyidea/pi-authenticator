import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../model/deeplink.dart';
import '../../state_notifiers/deeplink_notifier.dart';
import '../../../home_widget_utils.dart';
import '../../../logger.dart';

part 'deeplink_notifier.g.dart';

final sources = [
  DeeplinkSource(
    name: 'uni_links',
    stream: AppLinks().uriLinkStream,
    initialUri: AppLinks().getInitialLink(),
  ),
  DeeplinkSource(
    name: 'home_widget',
    stream: HomeWidgetUtils().widgetClicked,
    initialUri: HomeWidgetUtils().initiallyLaunchedFromHomeWidget(),
  ),
];

@Riverpod(keepAlive: true)
class DeeplinkNotifier extends _$DeeplinkNotifier {
  @override
  Stream<DeepLink> build() async* {
    Logger.info('New DeeplinkNotifier created', name: 'DeeplinkNotifier#build');
    final initial = await _handleInitialUri(sources);
    if (initial != null) yield initial;
    await for (var dl in _handleIncomingLinks(sources)) {
      yield dl;
    }
  }

  /// Handle incoming links - the ones that the app will recieve from the OS
  /// while already started.
  Stream<DeepLink> _handleIncomingLinks(List<DeeplinkSource> sources) async* {
    if (kIsWeb) return;
    final groupedStream = StreamGroup.merge(sources.map((source) => source.stream));
    await for (var uri in groupedStream) {
      Logger.info('DeeplinkNotifier got new uri');
      if (uri == null) return;
      yield DeepLink(uri);
    }
  }

  Future<DeepLink?> _handleInitialUri(List<DeeplinkSource> sources) async {
    Logger.info('_handleInitialUri called');

    for (var source in sources) {
      final initialUri = await source.initialUri;
      if (initialUri != null) {
        final initial = DeepLink(initialUri, fromInit: true);
        Logger.info('Got initial uri from ${source.name}');
        return initial; // There should be only one initial uri
      }
    }
    return null;
  }
}
