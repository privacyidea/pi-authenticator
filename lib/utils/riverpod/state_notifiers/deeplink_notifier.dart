/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/deeplink.dart';
import '../../logger.dart';

bool _initialUriIsHandled = false;

class DeeplinkNotifier extends StateNotifier<DeepLink?> {
  final List<StreamSubscription> _subs = [];
  final List<DeeplinkSource> _sources;
  DeeplinkNotifier({required List<DeeplinkSource> sources})
      : _sources = sources,
        super(null) {
    _handleInitialUri();
    _handleIncomingLinks();
  }

  @override
  void dispose() {
    for (var sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }

  /// Handle incoming links - the ones that the app will recieve from the OS
  /// while already started.
  void _handleIncomingLinks() async {
    if (kIsWeb) return;

    for (var source in _sources) {
      _subs.add(source.stream.listen((Uri? uri) {
        Logger.info('Got uri from ${source.name}');
        if (!mounted) return;
        if (uri == null) return;
        state = DeepLink(uri);
      }, onError: (Object err) {
        Logger.error('Error getting uri from ${source.name}', error: err, stackTrace: StackTrace.current);
      }));
    }
  }

  Future<void> _handleInitialUri() async {
    if (_initialUriIsHandled) return;
    _initialUriIsHandled = true;
    Logger.info('_handleInitialUri called');

    for (var source in _sources) {
      final initialUri = await source.initialUri;
      if (initialUri != null) {
        if (!mounted) return;
        state = DeepLink(initialUri, fromInit: true);
        Logger.info('Got initial uri from ${source.name}');
        return; // There should be only one initial uri
      }
    }
  }
}

class DeeplinkSource {
  final String name;
  final Stream<Uri?> stream;
  final Future<Uri?> initialUri;
  DeeplinkSource({required this.name, required this.stream, required this.initialUri});
}
