import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/mains/app_routes.dart';
import 'package:privacyidea_authenticator/model/enums/app_feature.dart';
import 'package:privacyidea_authenticator/model/enums/image_format.dart';
import 'package:privacyidea_authenticator/model/widget_image.dart';
import 'package:privacyidea_authenticator/utils/customization/application_customization.dart';
import 'package:privacyidea_authenticator/views/add_token_manually_view/add_token_manually_view.dart';
import 'package:privacyidea_authenticator/views/container_view/container_view.dart';
import 'package:privacyidea_authenticator/views/feedback_view/feedback_view.dart';
import 'package:privacyidea_authenticator/views/import_tokens_view/import_tokens_view.dart';
import 'package:privacyidea_authenticator/views/license_view/license_view.dart';
import 'package:privacyidea_authenticator/views/link_home_widget_view/link_home_widget_view.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view.dart';
import 'package:privacyidea_authenticator/views/push_token_view/push_tokens_view.dart';
import 'package:privacyidea_authenticator/views/qr_scanner_view/qr_scanner_view.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_view.dart';
import 'package:privacyidea_authenticator/views/splash_screen/splash_screen.dart';
import 'package:privacyidea_authenticator/views/view_interface.dart';


/// Builds the route builders' widgets without mounting them. Calling a builder
/// only constructs the widget, which is enough to prove that the builder
/// does not throw and wires the customization into the right place.
Future<BuildContext> _pumpContext(WidgetTester tester) async {
  late BuildContext context;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (c) {
          context = c;
          return const SizedBox();
        },
      ),
    ),
  );
  return context;
}


WidgetImage _image(String name) => WidgetImage(fileName: name, imageFormat: ImageFormat.png, imageData: ApplicationCustomization.defaultCustomization.appbarIcon.imageData);

void main() {
  final customization = ApplicationCustomization.defaultCustomization;

  const baseKeys = {
    AddTokenManuallyView.routeName,
    FeedbackView.routeName,
    ImportTokensView.routeName,
    LicenseView.routeName,
    MainView.routeName,
    PushTokensView.routeName,
    SettingsView.routeName,
    SplashScreen.routeName,
    QRScannerView.routeName,
  };

  group('buildAppRoutes keys', () {
    test('without the container view: exactly the base routes', () {
      expect(buildAppRoutes(customization).keys.toSet(), baseKeys);
    });

    test('includeContainerView defaults to false', () {
      expect(buildAppRoutes(customization).containsKey(ContainerView.routeName), isFalse);
      expect(buildAppRoutes(customization).containsKey(ContainerView.routeName), isFalse);
    });

    test('with the container view: the base routes plus the container route', () {
      expect(buildAppRoutes(customization, includeContainerView: true).keys.toSet(), {...baseKeys, ContainerView.routeName});
    });

    test('the route names are the documented ones', () {
      expect(buildAppRoutes(customization, includeContainerView: true).keys.toSet(), {
        '/add_token_manually',
        '/feedback',
        '/import_tokens',
        '/license',
        '/mainView',
        '/push_tokens',
        '/settings',
        '/',
        '/qr_scanner',
        '/container',
      });
    });

    test('the route names are unique', () {
      const names = [
        AddTokenManuallyView.routeName,
        FeedbackView.routeName,
        ImportTokensView.routeName,
        LicenseView.routeName,
        MainView.routeName,
        PushTokensView.routeName,
        SettingsView.routeName,
        SplashScreen.routeName,
        QRScannerView.routeName,
        ContainerView.routeName,
      ];
      expect(names.toSet(), hasLength(names.length));
    });

    test('LinkHomeWidgetView is not a named route, it needs an argument and is pushed directly', () {
      expect(buildAppRoutes(customization, includeContainerView: true).containsKey(LinkHomeWidgetView.routeName), isFalse);
    });

    test('the routes are rebuilt per call and independent of each other', () {
      final first = buildAppRoutes(customization);
      final second = buildAppRoutes(customization, includeContainerView: true);
      expect(first.containsKey(ContainerView.routeName), isFalse);
      expect(second.containsKey(ContainerView.routeName), isTrue);
    });
  });

  group('buildAppRoutes builders', () {
    testWidgets('every builder returns a widget of the matching view', (tester) async {
      final context = await _pumpContext(tester);
      final routes = buildAppRoutes(customization, includeContainerView: true);

      expect(routes[AddTokenManuallyView.routeName]!(context), isA<AddTokenManuallyView>());
      expect(routes[FeedbackView.routeName]!(context), isA<FeedbackView>());
      expect(routes[ImportTokensView.routeName]!(context), isA<ImportTokensView>());
      expect(routes[LicenseView.routeName]!(context), isA<LicenseView>());
      expect(routes[MainView.routeName]!(context), isA<MainView>());
      expect(routes[PushTokensView.routeName]!(context), isA<PushTokensView>());
      expect(routes[SettingsView.routeName]!(context), isA<SettingsView>());
      expect(routes[SplashScreen.routeName]!(context), isA<SplashScreen>());
      expect(routes[QRScannerView.routeName]!(context), isA<QRScannerView>());
      expect(routes[ContainerView.routeName]!(context), isA<ContainerView>());
    });

    testWidgets('the route settings of every built view carry the name it is registered under', (tester) async {
      final context = await _pumpContext(tester);
      final routes = buildAppRoutes(customization, includeContainerView: true);

      for (final entry in routes.entries) {
        final widget = entry.value(context);
        if (widget is! ViewWidget) continue;
        expect(widget.routeSettings.name, entry.key, reason: '${widget.runtimeType} is registered under ${entry.key}');
      }
      // the splash screen is not a view, check the ones that are
      expect(routes.entries.where((e) => e.value(context) is ViewWidget), hasLength(greaterThanOrEqualTo(7)));
    });

    testWidgets('a builder builds a fresh widget on every call', (tester) async {
      final context = await _pumpContext(tester);
      final routes = buildAppRoutes(customization);

      expect(identical(routes[MainView.routeName]!(context), routes[MainView.routeName]!(context)), isFalse);
    });

    testWidgets('the splash screen gets the customization it was built with', (tester) async {
      final context = await _pumpContext(tester);
      final custom = customization.copyWith(appName: 'Custom Name');

      final splash = buildAppRoutes(custom)[SplashScreen.routeName]!(context) as SplashScreen;

      expect(splash.customization, same(custom));
    });

    testWidgets('the main view gets icon, background, name and the patch notes flag from the customization', (tester) async {
      final context = await _pumpContext(tester);
      final custom = customization.copyWith(appName: 'Custom Name', backgroundImage: () => _image('background'));

      final main = buildAppRoutes(custom)[MainView.routeName]!(context) as MainView;

      expect(main.appName, 'Custom Name');
      expect(main.appbarIcon, same(custom.appbarIcon.getWidget));
      expect(main.backgroundImage, same(custom.backgroundImage!.getWidget));
      expect(main.disablePatchNotes, isFalse);
    });

    testWidgets('the main view has no background image when the customization has none', (tester) async {
      final context = await _pumpContext(tester);
      final custom = customization.copyWith(backgroundImage: () => null);

      final main = buildAppRoutes(custom)[MainView.routeName]!(context) as MainView;

      expect(main.backgroundImage, isNull);
    });

    testWidgets('the main view disables the patch notes only when the feature is disabled', (tester) async {
      final context = await _pumpContext(tester);

      MainView buildMain(Set<AppFeature> disabled) {
        return buildAppRoutes(customization.copyWith(disabledFeatures: disabled))[MainView.routeName]!(context) as MainView;
      }

      expect(buildMain({AppFeature.patchNotes}).disablePatchNotes, isTrue);
      expect(buildMain({AppFeature.introductions}).disablePatchNotes, isFalse);
      expect(buildMain({}).disablePatchNotes, isFalse);
      expect(buildMain(AppFeature.values.toSet()).disablePatchNotes, isTrue);
    });

    testWidgets('the license view uses its own image when the customization has one', (tester) async {
      final context = await _pumpContext(tester);
      final custom = customization.copyWith(appName: 'Custom Name', websiteLink: 'https://example.com/', licensesViewImage: () => _image('licenses'));

      final license = buildAppRoutes(custom)[LicenseView.routeName]!(context) as LicenseView;

      expect(license.appName, 'Custom Name');
      expect(license.websiteLink, 'https://example.com/');
      expect(license.appImage, same(custom.licensesViewImage!.getWidget));
    });

    testWidgets('the license view falls back to the splash screen image', (tester) async {
      final context = await _pumpContext(tester);
      final custom = customization.copyWith(licensesViewImage: () => null, splashScreenImage: _image('splash'));
      expect(custom.licensesViewImage, isNull);

      final license = buildAppRoutes(custom)[LicenseView.routeName]!(context) as LicenseView;

      expect(license.appImage, same(custom.splashScreenImage.getWidget));
    });
  });
}
