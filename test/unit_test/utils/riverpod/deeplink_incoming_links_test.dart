import 'dart:async';

import 'package:app_links_platform_interface/app_links_platform_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/deeplink.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/deeplink_notifier.dart';

class _FakeAppLinksPlatform extends AppLinksPlatform {
  final controller = StreamController<Uri>.broadcast();
  @override
  Future<Uri?> getInitialLink() async => null;
  @override
  Stream<Uri> get uriLinkStream => controller.stream;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The notifier reads the global `sources`, which are created lazily on first access,
  // so the platform must be replaced before the provider is first read.
  final fake = _FakeAppLinksPlatform();
  AppLinksPlatform.instance = fake;

  late ProviderContainer container;
  late List<DeepLink> received;

  setUp(() async {
    received = [];
    container = ProviderContainer();
    container.listen(deeplinkProvider, (_, next) {
      final v = next.value;
      if (v != null) received.add(v);
    });
    // let build() finish handling the initial uri and subscribe
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });

  tearDown(() => container.dispose());

  Future<void> emit(Uri uri) async {
    fake.controller.add(uri);
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  test('forwards an incoming uri', () async {
    await emit(Uri.parse('otpauth://hotp/a?secret=AA'));
    expect(received.map((e) => e.uri), [Uri.parse('otpauth://hotp/a?secret=AA')]);
    expect(received.single.fromInit, isFalse);
  });

  test('drops the same uri arriving again within 2 seconds, keeps different uris', () async {
    final u1 = Uri.parse('otpauth://hotp/dup?secret=AA');
    final u2 = Uri.parse('otpauth://hotp/other?secret=BB');
    await emit(u1);
    await emit(u1);
    expect(received.map((e) => e.uri), [u1]);
    await emit(u2);
    expect(received.map((e) => e.uri), [u1, u2]);
  });

  test('delivers the same uri again after 2 seconds', () async {
    final u = Uri.parse('otpauth://hotp/later?secret=CC');
    await emit(u);
    await Future<void>.delayed(const Duration(milliseconds: 2100));
    await emit(u);
    expect(received.map((e) => e.uri), [u, u]);
  });
}
