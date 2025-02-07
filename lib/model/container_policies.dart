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

import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/object_validator.dart';

part 'container_policies.freezed.dart';
part 'container_policies.g.dart';

@Freezed(toStringOverride: false, addImplicitFinal: true, toJson: true, fromJson: true)
class ContainerPolicies with _$ContainerPolicies {
  static const DISABLED_UNREGISTER = 'disable_client_container_unregister';
  static const DISABLED_TOKEN_DELETION = 'disable_client_token_deletion';
  static const ROLLOVER_ALLOWED = 'container_client_rollover';
  static const INITIAL_TOKEN_ASSIGNMENT = 'initially_add_tokens_to_container';

  const ContainerPolicies._();

  const factory ContainerPolicies({
    required bool rolloverAllowed,
    required bool initialTokenAssignment,
    required bool disabledTokenDeletion,
    required bool disabledUnregister,
  }) = _ContainerPolicies;

  static const ContainerPolicies defaultSetting = ContainerPolicies(
    rolloverAllowed: false,
    initialTokenAssignment: false,
    disabledTokenDeletion: false,
    disabledUnregister: false,
  );

  static ContainerPolicies fromUriMap(Map<String, dynamic> map) {
    final validated = validateMap(
      map: map,
      validators: {
        ROLLOVER_ALLOWED: boolValidator,
        INITIAL_TOKEN_ASSIGNMENT: boolValidator,
        DISABLED_TOKEN_DELETION: boolValidator,
        DISABLED_UNREGISTER: boolValidator,
      },
      name: 'ContainerPolicies',
    );
    return ContainerPolicies(
      rolloverAllowed: validated[ROLLOVER_ALLOWED]!,
      initialTokenAssignment: validated[INITIAL_TOKEN_ASSIGNMENT]!,
      disabledTokenDeletion: validated[DISABLED_TOKEN_DELETION]!,
      disabledUnregister: validated[DISABLED_UNREGISTER]!,
    );
  }

  Map<String, dynamic> toUriMap() => {
        ROLLOVER_ALLOWED: rolloverAllowed,
        INITIAL_TOKEN_ASSIGNMENT: initialTokenAssignment,
        DISABLED_TOKEN_DELETION: disabledTokenDeletion,
        DISABLED_UNREGISTER: disabledUnregister,
      };

  factory ContainerPolicies.fromJson(Map<String, dynamic> json) => _$ContainerPoliciesFromJson(json);
}
