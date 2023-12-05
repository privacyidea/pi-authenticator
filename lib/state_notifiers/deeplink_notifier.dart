import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_links/uni_links.dart';

import '../utils/logger.dart';

bool _initialUriIsHandled = false;

class DeeplinkNotifier extends StateNotifier<Uri?> {
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
  void _handleIncomingLinks() {
    if (kIsWeb) return;

    for (var source in _sources) {
      _subs.add(source.stream.listen((Uri? uri) {
        Logger.info('Got uri from ${source.name}');
        if (!mounted) return;
        if (uri == null) return;
        state = uri;
      }, onError: (Object err) {
        Logger.warning('Got error on Uri: $err');
      }));
    }
  }

  Future<void> _handleInitialUri() async {
    if (_initialUriIsHandled) return;
    _initialUriIsHandled = true;
    Logger.info('_handleInitialUri called');

    for (var source in _sources) {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        Logger.info('Got initial uri from ${source.name}');
        if (!mounted) return;
        state = initialUri;
        return;
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
