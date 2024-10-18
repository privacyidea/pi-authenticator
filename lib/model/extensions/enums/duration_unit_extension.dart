/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import '../../enums/duration_unit.dart';

extension DurationUnitX on DurationUnit {
  String get postfix => switch (this) {
        DurationUnit.microseconds => 'µs',
        DurationUnit.milliseconds => 'ms',
        DurationUnit.seconds => 's',
        DurationUnit.minutes => 'm',
        DurationUnit.hours => 'h',
        DurationUnit.days => 'd',
        DurationUnit.weeks => 'w',
        DurationUnit.months => 'M',
        DurationUnit.years => 'y',
        DurationUnit.decades => 'dec',
        DurationUnit.centuries => 'c',
        DurationUnit.millenniums => 'm',
      };

  int durationToUnitInt(Duration duration) => switch (this) {
        DurationUnit.microseconds => duration.inMicroseconds,
        DurationUnit.milliseconds => duration.inMilliseconds,
        DurationUnit.seconds => duration.inSeconds,
        DurationUnit.minutes => duration.inMinutes,
        DurationUnit.hours => duration.inHours,
        DurationUnit.days => duration.inDays,
        DurationUnit.weeks => duration.inDays ~/ 7,
        DurationUnit.months => duration.inDays ~/ 30,
        DurationUnit.years => duration.inDays ~/ 365,
        DurationUnit.decades => duration.inDays ~/ 3650,
        DurationUnit.centuries => duration.inDays ~/ 36500,
        DurationUnit.millenniums => duration.inDays ~/ 365000,
      };

  double durationToUnitDouble(Duration duration) => switch (this) {
        DurationUnit.microseconds => duration.inMicroseconds.toDouble(),
        DurationUnit.milliseconds => duration.inMicroseconds / 1000,
        DurationUnit.seconds => duration.inMicroseconds / 1000000,
        DurationUnit.minutes => duration.inMicroseconds / 60000000,
        DurationUnit.hours => duration.inMicroseconds / 3600000000,
        DurationUnit.days => duration.inMicroseconds / 86400000000,
        DurationUnit.weeks => duration.inMicroseconds / 604800000000,
        DurationUnit.months => duration.inMicroseconds / 2592000000000,
        DurationUnit.years => duration.inMicroseconds / 31536000000000,
        DurationUnit.decades => duration.inMicroseconds / 315360000000000,
        DurationUnit.centuries => duration.inMicroseconds / 3153600000000000,
        DurationUnit.millenniums => duration.inMicroseconds / 31536000000000000,
      };
}
