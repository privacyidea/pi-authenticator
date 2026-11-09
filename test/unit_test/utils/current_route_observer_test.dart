import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/utils/current_route_observer.dart';

Route<void> _route(String? name) => MaterialPageRoute<void>(
  settings: RouteSettings(name: name),
  builder: (_) => const SizedBox(),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CurrentRouteObserver', () {
    test('knows no route before the first push', () {
      expect(CurrentRouteObserver().currentRoute, isNull);
    });

    test('names the route pushed last', () {
      final observer = CurrentRouteObserver();
      final home = _route('/');

      observer.didPush(home, null);
      observer.didPush(_route('/qr_scanner'), home);

      expect(observer.currentRoute, '/qr_scanner');
    });

    test('names the route below again after a pop', () {
      final observer = CurrentRouteObserver();
      final home = _route('/');
      final scanner = _route('/qr_scanner');
      observer.didPush(home, null);
      observer.didPush(scanner, home);

      observer.didPop(scanner, home);

      expect(observer.currentRoute, '/');
    });

    test('names an unnamed route, a dialog for example, by its type', () {
      final observer = CurrentRouteObserver();

      observer.didPush(_route(null), null);

      expect(observer.currentRoute, 'MaterialPageRoute<void>');
    });

    test('names the successor of a replaced top route', () {
      final observer = CurrentRouteObserver();
      final splash = _route('/splash');
      observer.didPush(splash, null);

      observer.didReplace(newRoute: _route('/'), oldRoute: splash);

      expect(observer.currentRoute, '/');
    });

    test('keeps the top route when a route below it is removed', () {
      final observer = CurrentRouteObserver();
      final home = _route('/');
      final settings = _route('/settings');
      observer.didPush(home, null);
      observer.didPush(settings, home);

      observer.didRemove(home, null);

      expect(observer.currentRoute, '/settings');
    });
  });
}
