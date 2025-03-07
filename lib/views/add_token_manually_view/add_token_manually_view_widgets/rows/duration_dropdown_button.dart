/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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
import 'package:flutter/material.dart';

import '../../../../../../../model/extensions/enums/duration_unit_extension.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../model/enums/duration_unit.dart';
import '../labeled_dropdown_button.dart';

class DurationDropdownButton extends StatelessWidget {
  final bool enabled;
  final ValueNotifier<Duration?>? periodNotifier;
  final List<Duration> values;
  final DurationUnit unit;
  const DurationDropdownButton({
    super.key,
    this.periodNotifier,
    required this.values,
    required this.unit,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) => LabeledDropdownButton<Duration>(
        label: AppLocalizations.of(context)!.period,
        enabled: enabled,
        valueNotifier: periodNotifier,
        values: values,
        valueLabels: [for (final value in values) unit.durationToUnitInt(value).toString()],
        postFix: unit.postfix,
      );
}
