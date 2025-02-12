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
import 'package:uuid/uuid.dart';

import '../../../../../../../model/extensions/enums/encodings_extension.dart';
import '../../../../../../../model/extensions/enums/token_origin_source_type.dart';
import '../../../../model/enums/algorithms.dart';
import '../../../../model/enums/encodings.dart';
import '../../../../model/enums/token_origin_source_type.dart';
import '../../../../model/enums/token_types.dart';
import '../../../../model/tokens/hotp_token.dart';
import '../../../../utils/logger.dart';
import '../rows/add_token_button.dart';
import '../rows/algorithms_dropdown_button.dart';
import '../rows/counter_input_field.dart';
import '../rows/digits_dropdown_button.dart';
import '../rows/encoding_dropdown_button.dart';
import '../rows/label_input_field.dart';
import '../rows/secret_input_field.dart';
import '../rows/token_type_dropdown_button.dart';
import 'add_token_manually_interface.dart';

class AddHotpManually extends AddTokenManuallyPage {
  final TextEditingController labelController;
  final TextEditingController secretController;

  final ValueNotifier<bool> autoValidateLabel;
  final ValueNotifier<bool> autoValidateSecret;
  final ValueNotifier<Encodings> encodingNofitier;
  final ValueNotifier<Algorithms> algorithmsNotifier;
  final ValueNotifier<int?> digitsNotifier;
  final ValueNotifier<int?> counterNotifier;
  final ValueNotifier<TokenTypes> typeNotifier;

  const AddHotpManually({
    super.key,
    required this.labelController,
    required this.secretController,
    required this.autoValidateLabel,
    required this.autoValidateSecret,
    required this.encodingNofitier,
    required this.algorithmsNotifier,
    required this.digitsNotifier,
    required this.counterNotifier,
    required this.typeNotifier,
  });

  HOTPToken? _tryBuildToken() {
    if (LabelInputField.validator(labelController.text) != null) {
      autoValidateLabel.value = true;
      return null;
    }
    if (SecretInputField.validator(secretController.text, encodingNofitier.value) != null) {
      autoValidateSecret.value = true;
      return null;
    }
    if (CounterInputField.validator(counterNotifier.value?.toString()) != null) {
      return null;
    }
    Logger.info('Input is valid, building token');
    return HOTPToken(
      id: const Uuid().v4(),
      type: TokenTypes.HOTP.name,
      label: labelController.text,
      algorithm: algorithmsNotifier.value,
      secret: encodingNofitier.value.encodeStringTo(Encodings.base32, secretController.text),
      digits: digitsNotifier.value!,
      counter: counterNotifier.value!,
      origin: TokenOriginSourceType.manually.toTokenOrigin(),
    );
  }

  @override
  AddTokenManually build(BuildContext context) => AddTokenManually(
        fields: [
          LabelInputField(
            controller: labelController,
            autoValidate: autoValidateLabel,
          ),
          SecretInputField(
            controller: secretController,
            autoValidate: autoValidateSecret,
            encodingNotifier: encodingNofitier,
          ),
          TokenTypeDropdownButton(typeNotifier: typeNotifier),
          EncodingsDropdownButton(encodingNotifier: encodingNofitier),
          AlgorithmsDropdownButton(algorithmsNotifier: algorithmsNotifier),
          DigitsDropdownButton(digitsNotifier: digitsNotifier),
          CounterInputField(counterNotifier: counterNotifier),
        ],
        button: AddTokenButton(
          autoValidateLabel: autoValidateLabel,
          autoValidateSecret: autoValidateSecret,
          tokenBuilder: _tryBuildToken,
        ),
      );
}
