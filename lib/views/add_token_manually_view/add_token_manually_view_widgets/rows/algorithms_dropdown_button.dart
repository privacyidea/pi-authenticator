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

import '../../../../l10n/app_localizations.dart';
import '../../../../model/enums/algorithms.dart';
import '../labeled_dropdown_button.dart';

class AlgorithmsDropdownButton extends StatelessWidget {
  final ValueNotifier<Algorithms>? algorithmsNotifier;
  final List<Algorithms> allowedAlgorithms;
  final bool enabled;
  const AlgorithmsDropdownButton({
    super.key,
    this.algorithmsNotifier,
    this.allowedAlgorithms = Algorithms.values,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) => LabeledDropdownButton<Algorithms>(
        label: AppLocalizations.of(context)!.algorithm,
        enabled: enabled,
        valueNotifier: algorithmsNotifier,
        values: allowedAlgorithms,
        valueLabels: [for (final value in allowedAlgorithms) value.name],
      );
}
