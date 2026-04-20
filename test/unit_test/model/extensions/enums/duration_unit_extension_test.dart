import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/duration_unit.dart';
import 'package:privacyidea_authenticator/model/extensions/enums/duration_unit_extension.dart';

void main() {
  group('DurationUnit extension', () {
    test('postfix returns correct values', () {
      expect(DurationUnit.microseconds.postfix, 'µs');
      expect(DurationUnit.milliseconds.postfix, 'ms');
      expect(DurationUnit.seconds.postfix, 's');
      expect(DurationUnit.minutes.postfix, 'm');
      expect(DurationUnit.hours.postfix, 'h');
      expect(DurationUnit.days.postfix, 'd');
      expect(DurationUnit.weeks.postfix, 'w');
      expect(DurationUnit.months.postfix, 'M');
      expect(DurationUnit.years.postfix, 'y');
      expect(DurationUnit.decades.postfix, 'dec');
      expect(DurationUnit.centuries.postfix, 'c');
    });

    test('durationToUnitInt converts correctly', () {
      const duration = Duration(hours: 2, minutes: 30);
      expect(DurationUnit.hours.durationToUnitInt(duration), 2);
      expect(DurationUnit.minutes.durationToUnitInt(duration), 150);
      expect(DurationUnit.seconds.durationToUnitInt(duration), 9000);
    });

    test('durationToUnitInt for days', () {
      const duration = Duration(days: 14);
      expect(DurationUnit.days.durationToUnitInt(duration), 14);
      expect(DurationUnit.weeks.durationToUnitInt(duration), 2);
    });

    test('durationToUnitDouble returns fractional values', () {
      const duration = Duration(hours: 1, minutes: 30);
      final hours = DurationUnit.hours.durationToUnitDouble(duration);
      expect(hours, closeTo(1.5, 0.001));
    });

    test('durationToUnitDouble for days', () {
      const duration = Duration(days: 10);
      final weeks = DurationUnit.weeks.durationToUnitDouble(duration);
      expect(weeks, closeTo(10 / 7, 0.01));
    });

    test('all units have non-empty postfix', () {
      for (final unit in DurationUnit.values) {
        expect(unit.postfix.isNotEmpty, isTrue, reason: '$unit');
      }
    });
  });
}
