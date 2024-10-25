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
import 'package:uuid/uuid.dart';

import '../../../../../../../model/extensions/enums/token_origin_source_type.dart';
import '../../../../model/enums/algorithms.dart';
import '../../../../model/enums/duration_unit.dart';
import '../../../../model/enums/encodings.dart';
import '../../../../model/enums/token_origin_source_type.dart';
import '../../../../model/enums/token_types.dart';
import '../../../../model/tokens/steam_token.dart';
import '../../../../utils/logger.dart';
import '../rows/add_token_button.dart';
import '../rows/algorithms_dropdown_button.dart';
import '../rows/digits_dropdown_button.dart';
import '../rows/duration_dropdown_button.dart';
import '../rows/encoding_dropdown_button.dart';
import '../rows/label_input_field.dart';
import '../rows/secret_input_field.dart';
import '../rows/token_type_dropdown_button.dart';
import 'add_token_manually_interface.dart';

class AddSteamManually extends AddTokenManually {
  final TextEditingController labelController;

  final TextEditingController secretController;

  final ValueNotifier<bool> autoValidateLabel;
  final ValueNotifier<bool> autoValidateSecret;
  final ValueNotifier<TokenTypes> typeNotifier;

  const AddSteamManually(
      {required this.labelController,
      required this.secretController,
      required this.autoValidateLabel,
      required this.autoValidateSecret,
      required this.typeNotifier,
      super.key});

  SteamToken? _tokenBuilder() {
    if (LabelInputField.validator(labelController.text) != null) {
      autoValidateLabel.value = true;
      return null;
    }
    if (SecretInputField.validator(secretController.text, Encodings.none) != null) {
      autoValidateSecret.value = true;
      return null;
    }
    Logger.info('Input is valid, building Steam token');
    return SteamToken(
      id: const Uuid().v4(),
      type: TokenTypes.STEAM.name,
      origin: TokenOriginSourceType.manually.toTokenOrigin(),
      label: labelController.text,
      secret: secretController.text,
    );
  }

  // int? period, // unused steam tokens always have 30 seconds period
  // int? digits, // unused steam tokens always have 5 digits
  // Algorithms? algorithm, // unused steam tokens always have SHA1 algorithm
  @override
  Column build(BuildContext context) => Column(
        children: [
          LabelInputField(
            controller: labelController,
            autoValidate: autoValidateLabel,
          ),
          SecretInputField(
            controller: secretController,
            autoValidate: autoValidateSecret,
            encodingNotifier: ValueNotifier(Encodings.none),
          ),
          TokenTypeDropdownButton(typeNotifier: typeNotifier),
          const EncodingsDropdownButton(
            enabled: false,
            values: [Encodings.none],
          ),
          const AlgorithmsDropdownButton(
            enabled: false,
            allowedAlgorithms: [Algorithms.SHA1],
          ),
          const DigitsDropdownButton(
            enabled: false,
            allowedDigits: [5],
          ),
          const DurationDropdownButton(
            enabled: false,
            unit: DurationUnit.seconds,
            values: [Duration(seconds: 30)],
          ),
          AddTokenButton(
            autoValidateLabel: autoValidateLabel,
            autoValidateSecret: autoValidateSecret,
            tokenBuilder: _tokenBuilder,
          ),
        ],
      );
}
