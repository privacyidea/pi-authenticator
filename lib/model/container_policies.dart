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
  static const UNREGISTER_ALLOWED = 'client_container_unregister';
  static const TOKENS_DELETABLE = 'client_token_deletable';
  static const ROLLOVER_ALLOWED = 'container_client_rollover';
  static const INITIAL_TOKEN_TRANSFER = 'container_initial_token_transfer';

  const ContainerPolicies._();

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
        ROLLOVER_ALLOWED: boolValidator,
        INITIAL_TOKEN_TRANSFER: boolValidator,
        TOKENS_DELETABLE: boolValidator,
        UNREGISTER_ALLOWED: boolValidator,
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

  Map<String, dynamic> toUriMap() => {
        ROLLOVER_ALLOWED: rolloverAllowed,
        INITIAL_TOKEN_TRANSFER: initialTokenTransfer,
        TOKENS_DELETABLE: tokensDeletable,
        UNREGISTER_ALLOWED: unregisterAllowed,
      };

  factory ContainerPolicies.fromJson(Map<String, dynamic> json) => _$ContainerPoliciesFromJson(json);
}
