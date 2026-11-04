import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';
import 'package:privacyidea_authenticator/model/processor_result.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/home_widget_processor.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/scheme_processor_interface.dart';

/// Tests for [HomeWidgetProcessor].
///
/// Note: the success path ends in `HomeWidgetUtils().showOtp/copyOtp/performAction`.
/// On non-Android hosts `HomeWidgetUtils()` returns `UnsupportedHomeWidgetUtils`
/// (all no-ops), so only the processor's own return value can be asserted here,
/// not that the right `HomeWidgetUtils` method was called with the right id.
void main() {
  const processor = HomeWidgetProcessor();
  final l = AppLocalizationsEn();

  String messageOf(ProcessorResult<dynamic> result) {
    expect(result.isFailed, isTrue, reason: 'expected a failed result');
    return result.asFailed!.message(l);
  }

  group('supportedSchemes', () {
    test('contains exactly the homewidget scheme', () {
      expect(processor.supportedSchemes, {'homewidget'});
    });

    test('is registered in SchemeProcessor.implementations', () {
      expect(
        SchemeProcessor.implementations.whereType<HomeWidgetProcessor>(),
        hasLength(1),
      );
    });
  });

  group('wrong scheme', () {
    for (final uri in [
      'https://show?widgetId=1',
      'otpauth://show?widgetId=1',
      'homewidgetnavigate://show?widgetId=1',
      'homewidgets://show?widgetId=1',
    ]) {
      test('$uri yields an empty list (not handled, not an error)', () async {
        final result = await processor.processUri(Uri.parse(uri));

        expect(result, isNotNull);
        expect(result, isEmpty);
      });
    }
  });

  group('unknown host', () {
    for (final host in ['foo', 'link', 'showlocked', 'SHOW_', 'show2']) {
      test('"$host" yields noProcessorFoundForHost', () async {
        final result = await processor.processUri(
          Uri.parse('homewidget://$host?widgetId=1'),
        );

        expect(result, hasLength(1));
        expect(messageOf(result!.single), l.noProcessorFoundForHost(host.toLowerCase()));
      });
    }

    test('missing host yields noProcessorFoundForHost with an empty host', () async {
      final result = await processor.processUri(Uri.parse('homewidget:///x'));

      expect(result, hasLength(1));
      expect(messageOf(result!.single), l.noProcessorFoundForHost(''));
    });

    test('unknown host is rejected before the widgetId is looked at', () async {
      final result = await processor.processUri(Uri.parse('homewidget://foo'));

      expect(messageOf(result!.single), isNot(l.missingWidgetId));
    });
  });

  group('missing widgetId', () {
    for (final host in ['show', 'copy', 'action']) {
      test('$host without query yields missingWidgetId', () async {
        final result = await processor.processUri(Uri.parse('homewidget://$host'));

        expect(result, hasLength(1));
        expect(messageOf(result!.single), l.missingWidgetId);
      });

      test('$host with a differently named parameter yields missingWidgetId', () async {
        final result = await processor.processUri(
          Uri.parse('homewidget://$host?widget_id=1&id=1&WIDGETID=1'),
        );

        expect(result, hasLength(1));
        expect(messageOf(result!.single), l.missingWidgetId);
      });
    }
  });

  group('success path returns null (handled, nothing to show)', () {
    for (final host in ['show', 'copy', 'action']) {
      test('$host with widgetId', () async {
        final result = await processor.processUri(
          Uri.parse('homewidget://$host?widgetId=32'),
        );

        expect(result, isNull);
      });

      test('$host with widgetId and fromInit=true', () async {
        final result = await processor.processUri(
          Uri.parse('homewidget://$host?widgetId=32'),
          fromInit: true,
        );

        expect(result, isNull);
      });

      test('$host ignores additional query parameters', () async {
        final result = await processor.processUri(
          Uri.parse('homewidget://$host?widgetId=32&foo=bar'),
        );

        expect(result, isNull);
      });
    }

    test('uppercase scheme and host are normalised by Uri and still handled', () async {
      final result = await processor.processUri(
        Uri.parse('HOMEWIDGET://SHOW?widgetId=1'),
      );

      expect(result, isNull);
    });
  });

  group('dispatch via SchemeProcessor.processUriByAny', () {
    test('a valid homewidget uri is consumed by the HomeWidgetProcessor (null result)', () async {
      // HomeWidgetProcessor is the first implementation. Because it returns
      // null, processUriByAny keeps looking and finally reports "unsupported".
      final result = await SchemeProcessor.processUriByAny(
        Uri.parse('homewidget://show?widgetId=1'),
      );

      expect(result, isNull);
    });

    test('an invalid homewidget uri returns the failed result of the processor', () async {
      final result = await SchemeProcessor.processUriByAny(
        Uri.parse('homewidget://foo?widgetId=1'),
      );

      expect(result, hasLength(1));
      expect(messageOf(result!.single), l.noProcessorFoundForHost('foo'));
    });
  });
}
