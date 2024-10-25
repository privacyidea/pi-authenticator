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

import '../../../../../../../model/extensions/enums/encodings_extension.dart';
import '../../../../../../../model/extensions/enums/token_origin_source_type.dart';
import '../../../../model/enums/algorithms.dart';
import '../../../../model/enums/duration_unit.dart';
import '../../../../model/enums/encodings.dart';
import '../../../../model/enums/token_origin_source_type.dart';
import '../../../../model/enums/token_types.dart';
import '../../../../model/tokens/totp_token.dart';
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

class AddTotpManually extends AddTokenManually {
  static final allowedPeriodsTOTP = [const Duration(seconds: 30), const Duration(seconds: 60)];

  final TextEditingController labelController;

  final TextEditingController secretController;

  final ValueNotifier<bool> autoValidateLabel;
  final ValueNotifier<bool> autoValidateSecret;
  final ValueNotifier<Encodings> encodingNofitier;
  final ValueNotifier<Algorithms> algorithmsNotifier;
  final ValueNotifier<int?> digitsNotifier;
  final ValueNotifier<Duration?> periodNotifier;
  final ValueNotifier<TokenTypes> typeNotifier;

  const AddTotpManually({
    required this.labelController,
    required this.secretController,
    required this.autoValidateLabel,
    required this.autoValidateSecret,
    required this.encodingNofitier,
    required this.algorithmsNotifier,
    required this.digitsNotifier,
    required this.periodNotifier,
    required this.typeNotifier,
    super.key,
  });

  TOTPToken? _tryBuildToken() {
    if (LabelInputField.validator(labelController.text) != null) {
      autoValidateLabel.value = true;
      return null;
    }
    if (SecretInputField.validator(secretController.text, encodingNofitier.value) != null) {
      autoValidateSecret.value = true;
      return null;
    }
    if (digitsNotifier.value == null || periodNotifier.value == null) {
      return null;
    }
    Logger.info('Input is valid, building token');
    return TOTPToken(
      id: const Uuid().v4(),
      algorithm: algorithmsNotifier.value,
      digits: digitsNotifier.value!,
      secret: encodingNofitier.value.encodeStringTo(Encodings.base32, secretController.text),
      type: TokenTypes.TOTP.name,
      origin: TokenOriginSourceType.manually.toTokenOrigin(),
      label: labelController.text,
      period: periodNotifier.value!.inSeconds,
    );
  }

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
            encodingNotifier: encodingNofitier,
          ),
          TokenTypeDropdownButton(typeNotifier: typeNotifier),
          EncodingsDropdownButton(encodingNotifier: encodingNofitier),
          AlgorithmsDropdownButton(algorithmsNotifier: algorithmsNotifier),
          DigitsDropdownButton(digitsNotifier: digitsNotifier),
          DurationDropdownButton(
            periodNotifier: periodNotifier,
            values: allowedPeriodsTOTP,
            unit: DurationUnit.seconds,
          ),
          AddTokenButton(
            autoValidateLabel: autoValidateLabel,
            autoValidateSecret: autoValidateSecret,
            tokenBuilder: _tryBuildToken,
          ),
        ],
      );
}
