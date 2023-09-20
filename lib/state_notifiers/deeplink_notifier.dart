import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:uni_links/uni_links.dart';

StreamSubscription? _sub;
bool _initialUriIsHandled = false;

class DeeplinkNotifier extends StateNotifier<Uri?> {
  DeeplinkNotifier() : super(null) {
    _handleInitialUri();
    _handleIncomingLinks();
  }

  /// Handle incoming links - the ones that the app will recieve from the OS
  /// while already started.
  void _handleIncomingLinks() {
    if (_sub != null) {
      _sub?.cancel();
      _sub = null;
    }
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        Logger.info('Got uri from listening: $uri');
        if (!mounted) return;
        if (uri == null) return;
        state = uri;
      }, onError: (Object err) {
        if (!mounted) return;
        Logger.warning('Got error on Uri: $err');
      });
    }
  }

  Future<void> _handleInitialUri() async {
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      Logger.info('_handleInitialUri called');
      try {
        final uri = await getInitialUri();
        if (uri == null) return;
        Logger.info('Got initial uri: $uri');
        if (!mounted) return;
        state = uri;
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        Logger.warning('falied to get initial uri');
      } on FormatException catch (_) {
        if (!mounted) return;
        Logger.warning('malformed initial uri');
      }
    }
  }
}
