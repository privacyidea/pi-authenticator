import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/navigation_scheme_processors/home_widget_navigate_processor.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/navigation_scheme_processors/navigation_scheme_processor_interface.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/scheme_processor_interface.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/globals.dart';
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';
import 'package:privacyidea_authenticator/views/link_home_widget_view/link_home_widget_view.dart';

/// Token notifier with an empty, repository free state so that the pushed
/// [LinkHomeWidgetView] can be built.
class _EmptyTokenNotifier extends TokenNotifier {
  @override
  Future<TokenState> build({
    required TokenRepository repo,
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required FirebaseUtils firebaseUtils,
  }) async => const TokenState(tokens: []);
}

/// Tests for [HomeWidgetNavigateProcessor].
///
/// `HomeWidgetUtils()` returns `UnsupportedHomeWidgetUtils` on non-Android
/// hosts, whose `getTokenIdOfWidgetId` always yields `null`. Consequently the
/// "showlocked" branches behind a found token id (globalRef == null,
/// showTokenById, folder expansion) cannot be reached from a unit test without
/// a seam in `HomeWidgetUtils`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final l = AppLocalizationsEn();
  late HomeWidgetNavigateProcessor processor;

  setUp(() {
    processor = HomeWidgetNavigateProcessor();
  });

  String messageOf(ProcessorResult<dynamic> result) {
    expect(result.isFailed, isTrue, reason: 'expected a failed result');
    return result.asFailed!.message(l);
  }

  /// Pumps an app and returns a [BuildContext] that sits below a [Navigator].
  Future<BuildContext> pumpApp(WidgetTester tester) async {
    late BuildContext captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenProvider.overrideWith(_EmptyTokenNotifier.new)],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) {
              captured = context;
              return const Scaffold(body: Text('first route'));
            },
          ),
        ),
      ),
    );
    return captured;
  }

  test('supportedSchemes is exactly homewidgetnavigate', () {
    expect(processor.supportedSchemes, {'homewidgetnavigate'});
  });

  test('is registered in NavigationSchemeProcessor.implementations', () {
    expect(
      NavigationSchemeProcessor.implementations
          .whereType<HomeWidgetNavigateProcessor>(),
      hasLength(1),
    );
    expect(
      SchemeProcessor.implementations.whereType<HomeWidgetNavigateProcessor>(),
      hasLength(1),
    );
  });

  group('context is null', () {
    for (final uri in [
      'homewidgetnavigate://link?id=1',
      'homewidgetnavigate://showlocked?id=1',
      'homewidgetnavigate://unknown',
    ]) {
      test('$uri fails with cannotNavigateWithoutContext', () async {
        final result = await processor.processUri(Uri.parse(uri));

        expect(result, hasLength(1));
        expect(messageOf(result!.single), l.cannotNavigateWithoutContext);
        expect(
          result.single.asFailed!.resultHandlerType,
          HomeWidgetNavigateProcessor.resultHandlerType,
        );
      });
    }

    test('is checked before the host: even an unknown host reports the missing context', () async {
      final result = await processor.processUri(
        Uri.parse('homewidgetnavigate://nope'),
        fromInit: true,
      );

      expect(messageOf(result!.single), l.cannotNavigateWithoutContext);
    });
  });

  group('unknown host', () {
    for (final host in ['foo', 'show', 'copy', 'LINKS', 'link2']) {
      testWidgets('"$host" fails with noProcessorFoundForHost', (tester) async {
        final context = await pumpApp(tester);

        final result = await processor.processUri(
          Uri.parse('homewidgetnavigate://$host?id=1'),
          context: context,
        );

        expect(result, hasLength(1));
        expect(
          messageOf(result!.single),
          l.noProcessorFoundForHost(host.toLowerCase()),
        );
        expect(find.byType(LinkHomeWidgetView), findsNothing);
      });
    }
  });

  group('link', () {
    testWidgets('missing id fails with missingWidgetId and pushes nothing', (tester) async {
      final context = await pumpApp(tester);

      final result = await processor.processUri(
        Uri.parse('homewidgetnavigate://link'),
        context: context,
      );
      await tester.pumpAndSettle();

      expect(result, hasLength(1));
      expect(messageOf(result!.single), l.missingWidgetId);
      expect(find.byType(LinkHomeWidgetView), findsNothing);
    });

    testWidgets('wrong query parameter name fails with missingWidgetId', (tester) async {
      final context = await pumpApp(tester);

      final result = await processor.processUri(
        Uri.parse('homewidgetnavigate://link?widgetId=1'),
        context: context,
      );

      expect(messageOf(result!.single), l.missingWidgetId);
    });

    testWidgets('empty id is accepted (only null is rejected) and pushes the view', (tester) async {
      final context = await pumpApp(tester);

      final result = await processor.processUri(
        Uri.parse('homewidgetnavigate://link?id='),
        context: context,
      );
      await tester.pumpAndSettle();

      expect(result, isNull);
      final view = tester.widget<LinkHomeWidgetView>(
        find.byType(LinkHomeWidgetView),
      );
      expect(view.homeWidgetId, '');
    });

    testWidgets('fromInit pushes LinkHomeWidgetView with the widget id on top of the existing route', (tester) async {
      final context = await pumpApp(tester);

      final result = await processor.processUri(
        Uri.parse('homewidgetnavigate://link?id=42'),
        context: context,
        fromInit: true,
      );
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(
        tester.widget<LinkHomeWidgetView>(find.byType(LinkHomeWidgetView)).homeWidgetId,
        '42',
      );
      // first route is still below: popping the view returns to it
      Navigator.of(context).pop();
      await tester.pumpAndSettle();
      expect(find.byType(LinkHomeWidgetView), findsNothing);
      expect(find.text('first route'), findsOneWidget);
    });

    testWidgets('not fromInit first pops back to the first route, then pushes the view', (tester) async {
      final context = await pumpApp(tester);
      // Build a stack: first -> intermediate
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('intermediate route')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('intermediate route'), findsOneWidget);

      final result = await processor.processUri(
        Uri.parse('homewidgetnavigate://link?id=7'),
        context: context,
      );
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(find.byType(LinkHomeWidgetView), findsOneWidget);
      expect(find.text('intermediate route'), findsNothing);

      // Only first + view remain on the stack.
      Navigator.of(context).pop();
      await tester.pumpAndSettle();
      expect(find.text('first route'), findsOneWidget);
      expect(find.text('intermediate route'), findsNothing);
    });
  });

  group('showlocked', () {
    testWidgets('missing id fails with missingWidgetId and does not pop routes', (tester) async {
      final context = await pumpApp(tester);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('intermediate route')),
        ),
      );
      await tester.pumpAndSettle();

      final result = await processor.processUri(
        Uri.parse('homewidgetnavigate://showlocked'),
        context: context,
      );
      await tester.pumpAndSettle();

      expect(result, hasLength(1));
      expect(messageOf(result!.single), l.missingWidgetId);
      expect(find.text('intermediate route'), findsOneWidget);
    });

    testWidgets('widget without linked token (tokenId null) fails with couldNotFindTokenForWidgetId and pops to the first route', (tester) async {
      final context = await pumpApp(tester);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('intermediate route')),
        ),
      );
      await tester.pumpAndSettle();

      final result = await processor.processUri(
        Uri.parse('homewidgetnavigate://showlocked?id=99'),
        context: context,
      );
      await tester.pumpAndSettle();

      expect(result, hasLength(1));
      expect(messageOf(result!.single), l.couldNotFindTokenForWidgetId('99'));
      expect(
        result.single.asFailed!.resultHandlerType,
        HomeWidgetNavigateProcessor.resultHandlerType,
      );
      expect(find.text('intermediate route'), findsNothing);
      expect(find.text('first route'), findsOneWidget);
    });

    testWidgets('does not crash when globalRef is null', (tester) async {
      final context = await pumpApp(tester);
      globalRef = null;

      final result = await processor.processUri(
        Uri.parse('homewidgetnavigate://showlocked?id=5'),
        context: context,
      );

      expect(result, hasLength(1));
      expect(result!.single.isFailed, isTrue);
      expect(messageOf(result.single), l.couldNotFindTokenForWidgetId('5'));
    });
  });

  group('NavigationHandler', () {
    final handler = NavigationHandler<dynamic>();

    Future<T> nav<T>(BuildContext context) async => null as T;

    test('handleProcessorResult ignores failed results', () async {
      final result = await handler.handleProcessorResult(
        ProcessorResult<Navigation>.failed((l) => l.missingWidgetId),
      );

      expect(result, isNull);
    });

    test('handleProcessorResult ignores results of another type', () async {
      final result = await handler.handleProcessorResult(
        const ProcessorResult<String>.success('x'),
      );

      expect(result, isNull);
    });

    testWidgets('handleProcessorResult runs the navigation with the given context', (tester) async {
      final context = await pumpApp(tester);
      BuildContext? received;
      Future<R> navigation<R>(BuildContext c) async {
        received = c;
        return 'done' as R;
      }

      final result = await handler.handleProcessorResult(
        ProcessorResult<Navigation>.success(navigation),
        args: {'context': context},
      );

      expect(result, 'done');
      expect(received, same(context));
    });

    test('handleProcessorResults returns null when there is no success result', () async {
      final result = await handler.handleProcessorResults([
        ProcessorResult<Navigation>.failed((l) => l.missingWidgetId),
      ]);

      expect(result, isNull);
    });

    test('handleProcessorResults returns null (no throw) when context is missing', () async {
      final result = await handler.handleProcessorResults([
        ProcessorResult<Navigation>.success(nav),
      ]);

      expect(result, isNull);
    });

    testWidgets('handleProcessorResults runs every navigation in order', (tester) async {
      final context = await pumpApp(tester);
      final order = <int>[];
      Future<R> first<R>(BuildContext c) async {
        order.add(1);
        return 1 as R;
      }

      Future<R> second<R>(BuildContext c) async {
        order.add(2);
        return 2 as R;
      }

      final result = await handler.handleProcessorResults([
        ProcessorResult<Navigation>.success(first),
        ProcessorResult<Navigation>.failed((l) => l.missingWidgetId),
        ProcessorResult<Navigation>.success(second),
      ], args: {'context': context});

      expect(order, [1, 2]);
      expect(result, [1, 2]);
    });
  });

  group('NavigationSchemeProcessor.processUriByAny', () {
    testWidgets('routes a homewidgetnavigate uri to the processor and pushes the view', (tester) async {
      final context = await pumpApp(tester);

      await NavigationSchemeProcessor.processUriByAny(
        Uri.parse('homewidgetnavigate://link?id=3'),
        context: context,
        fromInit: true,
      );
      await tester.pumpAndSettle();

      expect(
        tester.widget<LinkHomeWidgetView>(find.byType(LinkHomeWidgetView)).homeWidgetId,
        '3',
      );
    });

    testWidgets('a uri with a foreign scheme is ignored', (tester) async {
      final context = await pumpApp(tester);

      await NavigationSchemeProcessor.processUriByAny(
        Uri.parse('homewidget://link?id=3'),
        context: context,
        fromInit: true,
      );
      await tester.pumpAndSettle();

      expect(find.byType(LinkHomeWidgetView), findsNothing);
    });
  });
}
