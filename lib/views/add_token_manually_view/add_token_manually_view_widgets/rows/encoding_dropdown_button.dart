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
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/enums/encodings.dart';
import '../labeled_dropdown_button.dart';

class EncodingsDropdownButton extends StatelessWidget {
  final ValueNotifier<Encodings>? encodingNotifier;
  final List<Encodings> values;
  final bool enabled;

  const EncodingsDropdownButton({super.key, this.encodingNotifier, this.values = Encodings.values, this.enabled = true});
  @override
  Widget build(BuildContext context) => LabeledDropdownButton<Encodings>(
        label: AppLocalizations.of(context)!.encoding,
        enabled: enabled,
        valueNotifier: encodingNotifier,
        values: values,
        valueLabels: [for (final value in values) value.name],
      );
}
