import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/state_notifiers/deeplink_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod_state_listener.dart';

void main() {
  _testDeeplinkNotifier();
}

void _testDeeplinkNotifier() {
  group('Deeplink Notifier Test', () {
    test('initUri', () {
      final container = ProviderContainer();
      final initUri = Uri.parse('otpauth://hotp/issuer?secret=secret&counter=0&digits=6&algorithm=SHA1');
      final deeplinkProvider = StateNotifierProvider<DeeplinkNotifier, DeepLink?>(
        (ref) => DeeplinkNotifier(sources: [DeeplinkSource(name: 'test', stream: const Stream.empty(), initialUri: Future.value(initUri))]),
      );
      container.listen(deeplinkProvider, (prev, next) {
        expect(prev, isNull);
        expect(next, isNotNull);
        expect(next!.uri, equals(initUri));
      });
    });
    test('initUri multible', () async {
      final container = ProviderContainer();
      final initUri = Uri.parse('otpauth://hotp/issuer?secret=secret&counter=0&digits=6&algorithm=SHA1');
      final initUri2 = Uri.parse('otpauth://totp/issuer?secret=secret&period=30&digits=6&algorithm=SHA1');
      final deeplinkProvider = StateNotifierProvider<DeeplinkNotifier, DeepLink?>(
        (ref) => DeeplinkNotifier(sources: [
          DeeplinkSource(name: 'test', stream: const Stream.empty(), initialUri: Future.value(initUri)),
          DeeplinkSource(name: 'test2', stream: const Stream.empty(), initialUri: Future.value(initUri2)),
        ]),
      );
      container.listen(deeplinkProvider, (prev, next) {
        // There should be only one initial uri, others will be ignored
        expect(prev, isNull);
        expect(next, isNotNull);
        expect(next!.uri, equals(initUri));
      });
    });
    test('stream uri', () {
      final container = ProviderContainer();
      final uri1 = Uri.parse('otpauth://hotp/issuer?secret=secret&counter=0&digits=6&algorithm=SHA1');
      final uri2 = Uri.parse('otpauth://totp/issuer?secret=secret&period=30&digits=6&algorithm=SHA1');
      final uri3 = Uri.parse('otpauth://totp/issuer?secret=secret&period=60&digits=6&algorithm=SHA1');
      final uri4 = Uri.parse('otpauth://totp/issuer?secret=secret&period=90&digits=6&algorithm=SHA1');
      final list = [uri1, uri2, uri3, uri4];
      Stream<Uri?> stream = Stream.fromIterable([...list]);
      final deeplinkProvider = StateNotifierProvider<DeeplinkNotifier, DeepLink?>(
        (ref) => DeeplinkNotifier(sources: [
          DeeplinkSource(name: 'test', stream: stream, initialUri: Future.value(null)),
        ]),
      );
      container.listen(deeplinkProvider, (prev, next) {
        print('prev: $prev, next: $next');
        expect(next?.uri, equals(list.removeAt(0)));
        expect(next?.fromInit, isFalse);
      });
    });
    test('stream uri multible', () {
      final container = ProviderContainer();
      final hotp1 = Uri.parse('otpauth://hotp/issuer?secret=secret&counter=1&digits=6&algorithm=SHA1');
      final hotp2 = Uri.parse('otpauth://hotp/issuer?secret=secret&counter=2&digits=6&algorithm=SHA1');
      final hotp3 = Uri.parse('otpauth://hotp/issuer?secret=secret&counter=3&digits=6&algorithm=SHA1');
      final hotp4 = Uri.parse('otpauth://hotp/issuer?secret=secret&counter=4&digits=6&algorithm=SHA1');
      final totp1 = Uri.parse('otpauth://totp/issuer?secret=secret&period=15&digits=6&algorithm=SHA1');
      final totp2 = Uri.parse('otpauth://totp/issuer?secret=secret&period=30&digits=6&algorithm=SHA1');
      final totp3 = Uri.parse('otpauth://totp/issuer?secret=secret&period=60&digits=6&algorithm=SHA1');
      final totp4 = Uri.parse('otpauth://totp/issuer?secret=secret&period=90&digits=6&algorithm=SHA1');
      final hotpList = [hotp1, hotp2, hotp3, hotp4];
      final totpList = [totp1, totp2, totp3, totp4];

      Stream<Uri?> hotpStream = Stream.fromIterable([...hotpList]);
      Stream<Uri?> totpStream = Stream.fromIterable([...totpList]);
      final deeplinkProvider = StateNotifierProvider<DeeplinkNotifier, DeepLink?>(
        (ref) => DeeplinkNotifier(sources: [
          DeeplinkSource(name: 'HOTPs', stream: hotpStream, initialUri: Future.value(null)),
          DeeplinkSource(name: 'TOTPs', stream: totpStream, initialUri: Future.value(null)),
        ]),
      );
      container.listen(deeplinkProvider, (prev, next) {
        if (hotpList.length == totpList.length) {
          expect(next?.uri, equals(hotpList.removeAt(0)));
        } else {
          expect(next?.uri, equals(totpList.removeAt(0)));
        }
        expect(next?.fromInit, isFalse);
      });
    });
  });
}
