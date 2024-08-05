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
