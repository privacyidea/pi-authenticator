import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart' as printer;
import 'package:privacyidea_authenticator/interfaces/riverpod/state_listeners/base_listeners/stream_notifier_listener.dart';
import 'package:privacyidea_authenticator/model/deeplink.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/deeplink_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';

// Shared test doubles and the host harness of the deep link listener tests
// (DeepLinkListener and its concrete listeners). Not a test file itself.

class CapturingOutput extends printer.LogOutput {
  final List<printer.OutputEvent> events = [];

  @override
  void output(printer.OutputEvent event) => events.add(event);

  bool contains(printer.Level level, String text) => events.any(
    (event) => event.level == level && event.lines.any((l) => l.contains(text)),
  );

  int count(printer.Level level, String text) => events
      .where(
        (event) =>
            event.level == level && event.lines.any((l) => l.contains(text)),
      )
      .length;
}

class PlainPrinter extends printer.LogPrinter {
  @override
  List<String> log(printer.LogEvent event) => [event.message.toString()];
}

/// A [DeeplinkNotifier] that exposes whatever is pushed into the controller.
class FakeDeeplinkNotifier extends DeeplinkNotifier {
  final Stream<DeepLink> _stream;
  FakeDeeplinkNotifier(this._stream);

  @override
  Stream<DeepLink> build() => _stream;
}

/// Records [handleLink]; throws for uris whose host is `boom`.
class FakeTokenNotifier extends TokenNotifier {
  final List<Uri> handled = [];

  @override
  Future<TokenState> build({
    required firebaseUtils,
    required ioClient,
    required repo,
    required rsaUtils,
  }) async => const TokenState(tokens: []);

  @override
  Future<bool> handleLink(Uri uri) async {
    handled.add(uri);
    if (uri.host == 'boom') throw StateError('handleLink failed');
    return true;
  }
}

/// Records [handleProcessorResults]; throws when [throwOnHandle] is set.
class FakeTokenContainerNotifier extends TokenContainerNotifier {
  final List<List<ProcessorResult>> handled = [];
  bool throwOnHandle = false;

  @override
  Future<TokenContainerState> build({
    required containerApi,
    required eccUtils,
    required repo,
  }) async => const TokenContainerState(containerList: []);

  @override
  Future<List<TokenContainerUnfinalized>?> handleProcessorResults(
    List<ProcessorResult> results, {
    Map<String, dynamic> args = const {},
  }) async {
    handled.add(results);
    if (throwOnHandle) throw StateError('handleProcessorResults failed');
    return [];
  }
}

/// Mounts listeners in a host widget and feeds deep links through a fake [DeeplinkNotifier].
///
/// Register [setUp] and [tearDown] with the test framework in the `main` of the test file.
class DeepLinkListenerHarness {
  late StreamController<DeepLink> links;
  late CapturingOutput logOutput;
  late printer.Logger originalPrinter;
  late FakeTokenNotifier tokenNotifier;
  late FakeTokenContainerNotifier containerNotifier;
  late WidgetRef lastRef;

  void setUp() {
    links = StreamController<DeepLink>.broadcast();
    tokenNotifier = FakeTokenNotifier();
    containerNotifier = FakeTokenContainerNotifier();
    originalPrinter = Logger.print;
    logOutput = CapturingOutput();
    Logger.print = printer.Logger(
      filter: printer.ProductionFilter(),
      printer: PlainPrinter(),
      output: logOutput,
      level: printer.Level.all,
    );
  }

  Future<void> tearDown() async {
    Logger.print = originalPrinter;
    await links.close();
  }

  /// Mounts [listeners] the way `StateObserver` does: `buildListen` is called in `build`.
  Future<void> pumpHost(
    WidgetTester tester,
    List<BuildlessStreamNotifierListener> Function(BuildContext context)
    listeners,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deeplinkProvider.overrideWith(
            () => FakeDeeplinkNotifier(links.stream),
          ),
          tokenProvider.overrideWith(() => tokenNotifier),
          tokenContainerProvider.overrideWith(() => containerNotifier),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              lastRef = ref;
              for (final listener in listeners(context)) {
                listener.buildListen(ref);
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// Pushes [link], lets the provider notify and runs the post frame callback.
  Future<void> deliver(
    WidgetTester tester,
    Uri uri, {
    bool fromInit = false,
  }) async {
    links.add(DeepLink(uri, fromInit: fromInit));
    await tester.pump();
    await tester.pump();
  }

  Future<void> deliverError(WidgetTester tester) async {
    links.addError(StateError('stream failed'));
    await tester.pump();
    await tester.pump();
  }
}
