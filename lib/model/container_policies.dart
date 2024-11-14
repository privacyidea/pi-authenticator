// ignore_for_file: constant_identifier_names

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

import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/object_validator.dart';

part 'container_policies.freezed.dart';
part 'container_policies.g.dart';

@Freezed(toStringOverride: false, addImplicitFinal: true, toJson: true, fromJson: true)
class ContainerPolicies with _$ContainerPolicies {
  static const ROLLOVER_ALLOWED = 'rollover_allowed';
  static const INITIAL_TOKEN_TRANSFER = 'initial_token_transfer';
  static const TOKENS_DELETABLE = 'tokens_deletable';
  static const UNREGISTER_ALLOWED = 'unregister_allowed';

  const factory ContainerPolicies({
    required bool rolloverAllowed,
    required bool initialTokenTransfer,
    required bool tokensDeletable,
    required bool unregisterAllowed,
  }) = _ContainerPolicies;

  static const ContainerPolicies defaultSetting = ContainerPolicies(
    rolloverAllowed: false,
    initialTokenTransfer: false,
    tokensDeletable: false,
    unregisterAllowed: false,
  );

  static ContainerPolicies fromUriMap(Map<String, dynamic> map) {
    final validated = validateMap(
      map: map,
      validators: {
        ROLLOVER_ALLOWED: stringToBoolValidator,
        INITIAL_TOKEN_TRANSFER: stringToBoolValidator,
        TOKENS_DELETABLE: stringToBoolValidator,
        UNREGISTER_ALLOWED: stringToBoolValidator,
      },
      name: 'ContainerPolicies',
    );
    return ContainerPolicies(
      rolloverAllowed: validated[ROLLOVER_ALLOWED]!,
      initialTokenTransfer: validated[INITIAL_TOKEN_TRANSFER]!,
      tokensDeletable: validated[TOKENS_DELETABLE]!,
      unregisterAllowed: validated[UNREGISTER_ALLOWED]!,
    );
  }

  factory ContainerPolicies.fromJson(Map<String, dynamic> json) => _$ContainerPoliciesFromJson(json);
}
