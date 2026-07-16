/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../model/deeplink.dart';
import '../../../home_widget_utils.dart';
import '../../../logger.dart';
import '../../state_notifiers/deeplink_notifier.dart';

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
    Logger.info('New DeeplinkNotifier created');
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
    final groupedStream = StreamGroup.merge(
      sources.map((source) => source.stream),
    );
    Uri? lastUri;
    DateTime? lastUriTime;
    await for (var uri in groupedStream) {
      if (uri == null) return;
      final now = DateTime.now();
      // Some platform event channels (e.g. the home_widget plugin) can redeliver
      // the same click event twice in quick succession, e.g. on app resume.
      // Drop exact duplicates that arrive within a short window to avoid
      // processing the same navigation twice.
      if (uri == lastUri &&
          lastUriTime != null &&
          now.difference(lastUriTime) < const Duration(seconds: 2)) {
        Logger.info('DeeplinkNotifier dropped duplicate incoming uri: $uri');
        continue;
      }
      lastUri = uri;
      lastUriTime = now;
      Logger.info('DeeplinkNotifier got new incoming uri: $uri');
      yield DeepLink(uri);
    }
  }

  Future<DeepLink?> _handleInitialUri(List<DeeplinkSource> sources) async {
    Logger.info('_handleInitialUri called');

    for (var source in sources) {
      final initialUri = await source.initialUri;
      if (initialUri != null) {
        final initial = DeepLink(initialUri, fromInit: true);
        Logger.info('Got initial uri from ${source.name}: $initialUri');
        return initial; // There should be only one initial uri
      }
    }
    return null;
  }
}
