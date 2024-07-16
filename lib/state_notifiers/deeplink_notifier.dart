import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/deeplink.dart';
import '../utils/logger.dart';

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
        if (!_initialUriIsHandled) return;
        Logger.info('Got uri from ${source.name} (incoming)');
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
        Logger.info('Got uri from ${source.name} (initial)');
        state = DeepLink(initialUri, fromInit: true);
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
