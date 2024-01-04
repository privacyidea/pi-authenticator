import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/logger.dart';
import '../utils/riverpod_state_listener.dart';

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
      if (source.isSupported != null && await source.isSupported == false) continue;
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
      if (source.isSupported != null && await source.isSupported == false) continue;
      final initialUri = await source.initialUri;
      if (initialUri != null) {
        if (!mounted) return;
        state = DeepLink(initialUri, fromInit: true);
        Logger.info('Got initial uri from ${source.name}');
        return; // There can only be one initial uri
      }
    }
  }
}

class DeeplinkSource {
  final String name;
  final Stream<Uri?> stream;
  final Future<Uri?> initialUri;
  final Future<bool>? isSupported;
  DeeplinkSource({required this.name, required this.stream, required this.initialUri, this.isSupported});
}
