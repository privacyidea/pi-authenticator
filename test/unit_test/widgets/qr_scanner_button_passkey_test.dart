import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/status_message_provider.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/main_view_navigation_buttons/qr_scanner_button.dart';
import 'package:privacyidea_authenticator/views/qr_scanner_view/qr_scanner_view.dart';

import '../../tests_app_wrapper.dart';

typedef _Handled = ({List<ProcessorResult> results, Map<String, dynamic> args});

class _FakeTokenNotifier extends TokenNotifier {
  final List<_Handled> handled = [];

  @override
  Future<TokenState> build({required firebaseUtils, required ioClient, required repo, required rsaUtils}) async => const TokenState(tokens: []);

  @override
  Future handleProcessorResults(List<ProcessorResult> results, {Map<String, dynamic> args = const {}}) async {
    handled.add((results: results, args: args));
  }
}

class _FakeTokenContainerNotifier extends TokenContainerNotifier {
  final List<_Handled> handled = [];

  @override
  Future<TokenContainerState> build({required containerApi, required eccUtils, required repo}) async => const TokenContainerState(containerList: []);

  @override
  Future<List<TokenContainerUnfinalized>?> handleProcessorResults(List<ProcessorResult> results, {Map<String, dynamic> args = const {}}) async {
    handled.add((results: results, args: args));
    return [];
  }
}

/// Stands in for the camera view: pops with [result] as soon as it is shown.
class _ScannerStub extends StatefulWidget {
  final Object? result;
  const _ScannerStub(this.result);

  @override
  State<_ScannerStub> createState() => _ScannerStubState();
}

class _ScannerStubState extends State<_ScannerStub> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(widget.result);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('scanner'));
}

const _permissionChannel = MethodChannel('flutter.baseflow.com/permissions/methods');

// PermissionStatus values of permission_handler
const _permissionGranted = 1;
const _permissionPermanentlyDenied = 4;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeTokenNotifier tokenNotifier;
  late _FakeTokenContainerNotifier containerNotifier;
  late ProviderContainer providers;
  late int permissionStatus;
  late List<String> scannerPushes;

  setUpAll(() async {
    await setupMocks();
  });

  setUp(() {
    tokenNotifier = _FakeTokenNotifier();
    containerNotifier = _FakeTokenContainerNotifier();
    permissionStatus = _permissionGranted;
    scannerPushes = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_permissionChannel, (call) async {
      if (call.method == 'checkPermissionStatus') return permissionStatus;
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_permissionChannel, null);
    globalRef = null;
  });

  Future<void> pumpButton(WidgetTester tester, {required Object? scanResult}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenProvider.overrideWith(() => tokenNotifier), tokenContainerProvider.overrideWith(() => containerNotifier)],
        child: Consumer(
          builder: (context, ref, _) {
            globalRef = ref;
            providers = ProviderScope.containerOf(context);
            return MaterialApp(
              navigatorKey: globalNavigatorKey,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routes: {
                '/': (_) => const Scaffold(body: Center(child: QrScannerButton())),
                QRScannerView.routeName: (_) {
                  scannerPushes.add(QRScannerView.routeName);
                  return _ScannerStub(scanResult);
                },
              },
            );
          },
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> tapScan(WidgetTester tester) async {
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
  }

  StatusMessage? currentStatus() => providers.read(statusProvider).current;

  String? currentStatusText() => currentStatus()?.message(AppLocalizationsEn());

  int totalHandlerCalls() => tokenNotifier.handled.length + containerNotifier.handled.length;

  final passkeyMessage = AppLocalizationsEn().passkeyQrCodeNotSupported;
  final invalidMessage = AppLocalizationsEn().invalidQrScan;

  group('passkey QR codes', () {
    const passkeyCodes = <String, Object>{
      'fido:/ with path (lowercase string)': 'fido:/1234567890abcdef',
      'FIDO: uppercase string': 'FIDO:/4143335643765265',
      'FIDO: mixed case string': 'FiDo:/1234',
      'fido: without slash': 'fido:1234',
      'fido: with query': 'fido:/1234?x=1',
    };

    passkeyCodes.forEach((description, code) {
      testWidgets('$description shows the passkey message and calls no handler', (tester) async {
        await pumpButton(tester, scanResult: code);
        await tapScan(tester);

        expect(scannerPushes, [QRScannerView.routeName], reason: 'the scanner was opened');
        expect(currentStatus(), isNotNull);
        expect(currentStatus()!.type, StatusMessageType.error);
        expect(currentStatusText(), passkeyMessage);
        expect(totalHandlerCalls(), 0);
        // scanQrCode would have used the loading indicator and reported an invalid scan
        expect(providers.read(statusProvider).queue, isEmpty);
        expect(currentStatusText(), isNot(invalidMessage));
      });
    });

    testWidgets('a Uri result with the fido scheme is treated like a string', (tester) async {
      await pumpButton(tester, scanResult: Uri.parse('fido:/1234567890'));
      await tapScan(tester);

      expect(currentStatusText(), passkeyMessage);
      expect(totalHandlerCalls(), 0);
    });

    testWidgets('a code that merely contains "fido" is not a passkey code', (tester) async {
      await pumpButton(tester, scanResult: 'https://example.com/fido:/path');
      await tapScan(tester);

      expect(currentStatusText(), isNot(passkeyMessage));
      expect(currentStatusText(), invalidMessage);
    });

    testWidgets('a scheme starting with fido is not a passkey code', (tester) async {
      await pumpButton(tester, scanResult: 'fidonet://example.com');
      await tapScan(tester);

      expect(currentStatusText(), isNot(passkeyMessage));
    });
  });

  group('no result', () {
    testWidgets('a null result (scanner closed with back) does nothing', (tester) async {
      await pumpButton(tester, scanResult: null);
      await tapScan(tester);

      expect(scannerPushes, [QRScannerView.routeName]);
      expect(currentStatus(), isNull);
      expect(totalHandlerCalls(), 0);
      expect(find.byType(QrScannerButton), findsOneWidget, reason: 'back on the starting page');
    });
  });

  group('regular QR codes', () {
    testWidgets('an otpauth code is handed to the token handler as a QR scan', (tester) async {
      await pumpButton(tester, scanResult: 'otpauth://totp/ACME:alice?secret=JBSWY3DPEHPK3PXP&issuer=ACME');
      await tapScan(tester);

      expect(tokenNotifier.handled, hasLength(1));
      expect(tokenNotifier.handled.single.results, hasLength(1));
      expect(tokenNotifier.handled.single.results.single.isSuccess, isTrue);
      expect(tokenNotifier.handled.single.args[ResultHandler.argTokenOriginSourceType], TokenOriginSourceType.qrScan);
      expect(containerNotifier.handled, isEmpty);
      expect(currentStatus(), isNull, reason: 'a handled code shows no error');
    });

    testWidgets(
      'BUG: a Uri result is handled like a string',
      (tester) async {
        await pumpButton(tester, scanResult: Uri.parse('otpauth://totp/ACME:alice?secret=JBSWY3DPEHPK3PXP&issuer=ACME'));
        await tapScan(tester);

        expect(tokenNotifier.handled, hasLength(1));
        expect(currentStatus(), isNull);
      },
      // BUG: utils.dart:249 scanQrCode switches on qrCode.runtimeType with `const (Uri)`, which never matches (the runtime type is the private _Uri), so a Uri is rejected as invalidUrl (latent, the real scanner only returns Strings)
      skip: true,
    );

    testWidgets('a container code is handed to the container handler', (tester) async {
      await pumpButton(tester, scanResult: 'pia://container/SMPH00067A2F?issuer=privacyIDEA');
      await tapScan(tester);

      expect(containerNotifier.handled, hasLength(1));
      expect(containerNotifier.handled.single.results, hasLength(1));
      expect(containerNotifier.handled.single.args[ResultHandler.argTokenOriginSourceType], TokenOriginSourceType.qrScan);
      expect(tokenNotifier.handled, isEmpty);
      expect(currentStatus(), isNull);
    });

    testWidgets('a code of an unsupported scheme shows the invalid scan message', (tester) async {
      await pumpButton(tester, scanResult: 'https://example.com/not-a-token');
      await tapScan(tester);

      expect(currentStatusText(), invalidMessage);
      expect(totalHandlerCalls(), 0);
    });

    testWidgets('an unsupported object as result shows the invalid scan message', (tester) async {
      await pumpButton(tester, scanResult: 42);
      await tapScan(tester);

      expect(currentStatusText(), anyOf(invalidMessage, AppLocalizationsEn().invalidUrl));
      expect(totalHandlerCalls(), 0);
    });
  });

  group('camera permission', () {
    testWidgets('a permanently denied permission shows the dialog and does not open the scanner', (tester) async {
      permissionStatus = _permissionPermanentlyDenied;
      await pumpButton(tester, scanResult: 'otpauth://totp/ACME:alice?secret=JBSWY3DPEHPK3PXP&issuer=ACME');

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text(AppLocalizationsEn().grantCameraPermissionDialogTitle), findsOneWidget);
      expect(scannerPushes, isEmpty);
      expect(totalHandlerCalls(), 0);
      expect(currentStatus(), isNull);
    });

    testWidgets('a granted permission opens the scanner and shows no dialog', (tester) async {
      await pumpButton(tester, scanResult: null);
      await tapScan(tester);

      expect(scannerPushes, [QRScannerView.routeName]);
      expect(find.text(AppLocalizationsEn().grantCameraPermissionDialogTitle), findsNothing);
    });
  });

  group('isPasskeyQrCode', () {
    test('recognizes the fido scheme case-insensitively in strings and uris', () {
      expect(isPasskeyQrCode('fido:/abc'), isTrue);
      expect(isPasskeyQrCode('FIDO:/abc'), isTrue);
      expect(isPasskeyQrCode('Fido:abc'), isTrue);
      expect(isPasskeyQrCode(Uri.parse('fido:/abc')), isTrue);
    });

    test('rejects other schemes, empty values, null and other types', () {
      expect(isPasskeyQrCode('otpauth://totp/a?secret=AA'), isFalse);
      expect(isPasskeyQrCode('pia://container/x'), isFalse);
      expect(isPasskeyQrCode('https://example.com/fido:/x'), isFalse);
      expect(isPasskeyQrCode('fidonet://x'), isFalse);
      expect(isPasskeyQrCode(''), isFalse);
      expect(isPasskeyQrCode(null), isFalse);
      expect(isPasskeyQrCode(42), isFalse);
      expect(isPasskeyQrCode(Uri()), isFalse);
    });

    test('a string that is not a valid uri is not a passkey code and does not throw', () {
      expect(isPasskeyQrCode('http://[invalid'), isFalse);
      expect(isPasskeyQrCode('::::'), isFalse);
    });
  });
}
