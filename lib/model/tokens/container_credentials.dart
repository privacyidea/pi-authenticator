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
import 'package:json_annotation/json_annotation.dart';

import 'push_token.dart';

part 'container_credentials.g.dart';

@JsonSerializable()
class ContainerCredential extends PushToken {
  ContainerCredential({required super.serial, required super.id});

  factory ContainerCredential.fromUriMap(Map<String, dynamic> uriMap) => throw UnimplementedError(); // PushToken.fromUriMap(uriMap);

  factory ContainerCredential.fromJson(Map<String, dynamic> json) => _$ContainerCredentialFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ContainerCredentialToJson(this);

  @override
  String toString() => 'ContainerCredential{serial: $serial, id: $id}';
}
