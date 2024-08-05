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
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../tokens/container_credentials.dart';

part 'credentials_state.freezed.dart';
part 'credentials_state.g.dart';

@Freezed()
@JsonSerializable(explicitToJson: true)
class CredentialsState with _$CredentialsState {
  const CredentialsState._();
  const factory CredentialsState({
    required List<ContainerCredential> credentials,
  }) = _CredentialsState;

  @override
  String toString() {
    return 'CredentialsState{credentials: $credentials}';
  }

  ContainerCredential? credentialsOf(String containerSerial) => credentials.firstWhereOrNull((credential) => credential.serial == containerSerial);
  static CredentialsState fromJsonStringList(List<String> jsonStrings) {
    final credentials = jsonStrings.map((jsonString) => ContainerCredential.fromJson(jsonDecode(jsonString))).toList();
    return CredentialsState(credentials: credentials);
  }
}
