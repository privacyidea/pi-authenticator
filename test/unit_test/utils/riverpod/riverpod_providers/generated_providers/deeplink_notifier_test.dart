import 'dart:async';

import 'package:app_links_platform_interface/app_links_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/deeplink.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/deeplink_notifier.dart';

/// Tests for [DeeplinkNotifier]: incoming links, initial link handling, errors on a
/// source stream and the duplicate filter.
///
/// The notifier reads the global `sources`, which are created lazily on the
/// first access (and evaluate `AppLinks().getInitialLink()` exactly once), so the
/// platform has to be replaced before the provider is first read. Every test
/// file runs in its own isolate, so this does not leak into other files.
/// Because of that there is exactly one fake (with an initial link) for all groups of this file.

final _initialUri = Uri.parse('otpauth://hotp/initial?secret=AA');

class _FakeAppLinksPlatform extends AppLinksPlatform {
  final controller = StreamController<Uri>.broadcast();
  int getInitialLinkCalls = 0;

  @override
  Future<Uri?> getInitialLink() async {
    getInitialLinkCalls++;
    return _initialUri;
  }

  @override
  Stream<Uri> get uriLinkStream => controller.stream;
}

final fake = _FakeAppLinksPlatform();

/// Everything a listener of the provider observed, in order.
class _Recorder {
  final List<AsyncValue<DeepLink>> states = [];
  final List<Object> thrown = [];

  /// Only the real deliveries. A state that carries the previous value because
  /// of an error or a reload is not a delivery, so every [DeepLink] instance is
  /// counted once (each instance represents one event, see [DeepLink]).
  List<DeepLink> get deliveries {
    final result = <DeepLink>[];
    for (final state in states) {
      final value = state.value;
      if (value == null) continue;
      if (result.isNotEmpty && identical(result.last, value)) continue;
      result.add(value);
    }
    return result;
  }

  List<Uri> get uris => deliveries.map((e) => e.uri).toList();

  bool get sawError => states.any((s) => s.hasError) || thrown.isNotEmpty;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLinksPlatform.instance = fake;

  _testIncomingLinks();
  _testStreamRobustness();
}

void _testIncomingLinks() {
  group('incoming links', () {
    late ProviderContainer container;
    late List<DeepLink> received;

    setUp(() async {
      received = [];
      container = ProviderContainer();
      container.listen(deeplinkProvider, (_, next) {
        final v = next.value;
        // the initial link of the shared fake is covered by the robustness group
        if (v != null && !v.fromInit) received.add(v);
      });
      // let build() finish handling the initial uri and subscribe
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() async {
      container.dispose();
      await pumpEventQueue();
      // let the disposed generator finish, see the robustness group
      fake.controller.add(Uri.parse('otpauth://hotp/flush?secret=ZZ'));
      await pumpEventQueue();
    });

    Future<void> emit(Uri uri) async {
      fake.controller.add(uri);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    test('forwards an incoming uri', () async {
      await emit(Uri.parse('otpauth://hotp/a?secret=AA'));
      expect(received.map((e) => e.uri), [
        Uri.parse('otpauth://hotp/a?secret=AA'),
      ]);
      expect(received.single.fromInit, isFalse);
    });

    test(
      'drops the same uri arriving again within 2 seconds, keeps different uris',
      () async {
        final u1 = Uri.parse('otpauth://hotp/dup?secret=AA');
        final u2 = Uri.parse('otpauth://hotp/other?secret=BB');
        await emit(u1);
        await emit(u1);
        expect(received.map((e) => e.uri), [u1]);
        await emit(u2);
        expect(received.map((e) => e.uri), [u1, u2]);
      },
    );

    test('delivers the same uri again after 2 seconds', () async {
      final u = Uri.parse('otpauth://hotp/later?secret=CC');
      await emit(u);
      await Future<void>.delayed(const Duration(milliseconds: 2100));
      await emit(u);
      expect(received.map((e) => e.uri), [u, u]);
    });
  });
}

void _testStreamRobustness() {
  group('stream robustness', () {
    late ProviderContainer container;
    late _Recorder recorder;

    _Recorder listenTo(ProviderContainer c) {
      final r = _Recorder();
      c.listen<AsyncValue<DeepLink>>(
        deeplinkProvider,
        (_, next) => r.states.add(next),
        onError: (error, _) => r.thrown.add(error),
      );
      return r;
    }

    setUp(() async {
      container = ProviderContainer();
      recorder = listenTo(container);
      // let build() handle the initial uri and subscribe to the incoming links
      await pumpEventQueue();
    });

    tearDown(() async {
      container.dispose();
      await pumpEventQueue();
      // An async* generator only notices a cancelled subscription at its next
      // yield, so the disposed container is still subscribed to the platform
      // stream. One harmless link lets it finish, otherwise the error events of
      // a later test would surface as unhandled errors of this finished test.
      fake.controller.add(Uri.parse('otpauth://hotp/flush?secret=ZZ'));
      await pumpEventQueue();
    });

    Future<void> emit(Uri uri) async {
      fake.controller.add(uri);
      await pumpEventQueue();
    }

    Future<void> emitError([Object? error]) async {
      fake.controller.addError(error ?? StateError('platform stream failed'));
      await pumpEventQueue();
    }

    group('initial link', () {
      test('is delivered exactly once with fromInit true', () {
        expect(recorder.deliveries, hasLength(1));
        expect(recorder.deliveries.single.uri, _initialUri);
        expect(recorder.deliveries.single.fromInit, isTrue);
      });

      test(
        'is not delivered again when a later link arrives, which is not fromInit',
        () async {
          final later = Uri.parse('otpauth://hotp/later?secret=BB');
          await emit(later);

          expect(recorder.uris, [_initialUri, later]);
          expect(recorder.deliveries.map((e) => e.fromInit), [true, false]);
        },
      );

      test(
        'is not delivered to a second listener of the same provider',
        () async {
          final second = listenTo(container);
          await pumpEventQueue();
          expect(
            second.deliveries,
            isEmpty,
            reason: 'a second listener must not trigger a rebuild',
          );
          expect(recorder.deliveries, hasLength(1));

          final next = Uri.parse('otpauth://hotp/shared?secret=CC');
          await emit(next);
          expect(second.uris, [
            next,
          ], reason: 'later links reach both listeners');
          expect(recorder.uris, [_initialUri, next]);
        },
      );

      test('is asked from the platform only once per process', () {
        expect(fake.getInitialLinkCalls, 1);
      });

      test(
        'is not delivered again when the provider is rebuilt',
        () async {
          expect(recorder.deliveries.where((d) => d.fromInit), hasLength(1));

          container.invalidate(deeplinkProvider);
          await pumpEventQueue();

          expect(
            recorder.deliveries.where((d) => d.fromInit),
            hasLength(1),
            reason:
                'processing the launch link a second time would e.g. import the same token twice',
          );
        },
        skip:
            'BUG: deeplink_notifier.dart:52 DeeplinkNotifier.build re-awaits the cached initialUri future of the global sources, so every rebuild re-delivers the launch link with fromInit true',
      );
    });

    group('duplicate filter', () {
      test(
        'only compares with the last uri: A, B, A within 2 seconds delivers all three',
        () async {
          // Characterization: the filter drops the *immediately repeated* uri, not
          // every uri it has seen during the last 2 seconds.
          final a = Uri.parse('otpauth://hotp/a?secret=AA');
          final b = Uri.parse('otpauth://hotp/b?secret=BB');
          await emit(a);
          await emit(b);
          await emit(a);

          expect(recorder.uris, [_initialUri, a, b, a]);
        },
      );

      test('A, A, A within 2 seconds delivers only the first', () async {
        final a = Uri.parse('otpauth://hotp/a?secret=AA');
        await emit(a);
        await emit(a);
        await emit(a);

        expect(recorder.uris, [_initialUri, a]);
      });

      test(
        'a link equal to the initial link is not treated as a duplicate of it',
        () async {
          // The filter state lives in _handleIncomingLinks, the initial link is
          // handled before and does not take part in it.
          await emit(_initialUri);

          expect(recorder.uris, [_initialUri, _initialUri]);
          expect(recorder.deliveries.map((e) => e.fromInit), [true, false]);
        },
      );

      test('the same uri with a different query is not a duplicate', () async {
        final a1 = Uri.parse('otpauth://hotp/a?secret=AA');
        final a2 = Uri.parse('otpauth://hotp/a?secret=AB');
        await emit(a1);
        await emit(a2);

        expect(recorder.uris, [_initialUri, a1, a2]);
      });
    });

    group('error on a source stream', () {
      test('surfaces as an error state of the provider', () async {
        await emitError(StateError('platform stream failed'));

        expect(recorder.sawError, isTrue);
        expect(container.read(deeplinkProvider).hasError, isTrue);
        expect(container.read(deeplinkProvider).error, isA<StateError>());
      });

      test('does not deliver anything by itself', () async {
        final before = recorder.deliveries.length;
        await emitError(StateError('platform stream failed'));

        expect(recorder.deliveries.length, before);
      });

      test(
        'a valid link after an error is still delivered',
        () async {
          final valid = Uri.parse('otpauth://hotp/after-error?secret=DD');
          await emitError(StateError('platform stream failed'));
          await emit(valid);

          expect(recorder.uris, contains(valid));
        },
        skip:
            'BUG: deeplink_notifier.dart:68 an error event on a source stream ends the merged await-for, so no further deep link is delivered until restart (riverpod never retries an Error such as StateError)',
      );

      test(
        'several links after repeated errors are all delivered',
        () async {
          final first = Uri.parse('otpauth://hotp/first?secret=EE');
          final second = Uri.parse('otpauth://hotp/second?secret=FF');
          await emitError(StateError('platform stream failed'));
          await emit(first);
          await emitError(StateError('platform stream failed'));
          await emit(second);

          expect(recorder.uris, containsAllInOrder([first, second]));
        },
        skip:
            'BUG: deeplink_notifier.dart:68 an error event on a source stream ends the merged await-for, so no further deep link is delivered until restart (riverpod never retries an Error such as StateError)',
      );

      test(
        'an Exception (as a platform channel throws it) is recovered by the default riverpod retry after 200 ms',
        () async {
          // Characterization of the mitigation: the provider has `retry: null`, so
          // riverpod's default retry rebuilds it 200 ms after an Exception. That
          // re-subscribes to the stream, but it also re-delivers the launch link
          // (see the skipped rebuild test above).
          // Real time is needed: the cached initial uri future of the global sources
          // belongs to the real zone, so fakeAsync cannot drive the rebuild.
          await emitError(PlatformException(code: 'boom'));
          expect(recorder.sawError, isTrue);

          final tooEarly = Uri.parse('otpauth://hotp/too-early?secret=GG');
          await emit(tooEarly);
          expect(
            recorder.uris,
            isNot(contains(tooEarly)),
            reason: 'the stream is not subscribed until the retry fires',
          );

          await Future<void>.delayed(const Duration(milliseconds: 350));
          await pumpEventQueue();
          expect(container.read(deeplinkProvider).hasError, isFalse);

          final recovered = Uri.parse('otpauth://hotp/recovered?secret=HH');
          await emit(recovered);
          expect(recorder.uris, contains(recovered));
        },
      );
    });

    group('lifecycle', () {
      test(
        'a link arriving after the container was disposed is not delivered and releases the stream',
        () async {
          container.dispose();
          await pumpEventQueue();
          // Characterization: an async* generator only notices that its
          // subscription was cancelled when it reaches the next yield, so the
          // platform stream stays subscribed until one more link arrives.
          await emit(Uri.parse('otpauth://hotp/late?secret=GG'));

          expect(recorder.uris, [_initialUri]);
          expect(fake.controller.hasListener, isFalse);

          // the tearDown disposes once more, which must be harmless
          container = ProviderContainer();
          recorder = listenTo(container);
          await pumpEventQueue();
        },
      );

      test(
        'a new container subscribes to the stream again and receives new links',
        () async {
          container.dispose();
          await pumpEventQueue();

          container = ProviderContainer();
          recorder = listenTo(container);
          await pumpEventQueue();
          final fresh = Uri.parse('otpauth://hotp/fresh?secret=HH');
          await emit(fresh);

          expect(recorder.uris, [_initialUri, fresh]);
        },
      );
    });
  });
}
