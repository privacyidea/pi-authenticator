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

import '../../../../../../../model/tokens/token.dart';
import '../../utils/logger.dart';
import '../enums/sync_state.dart';
import '../token_container.dart';

part 'token_container_state.freezed.dart';
part 'token_container_state.g.dart';

@freezed
class TokenContainerState with _$TokenContainerState {
  const TokenContainerState._();
  const factory TokenContainerState({
    required List<TokenContainer> containerList,
  }) = _TokenContainerState;

  bool get hasFinalizedContainers => containerList.any((container) => container is TokenContainerFinalized);

  TokenContainer? containerOf(String containerSerial) => containerList.firstWhereOrNull((container) => container.serial == containerSerial);
  static TokenContainerState fromJsonStringList(List<String> jsonStrings) {
    final containerList = jsonStrings.map((jsonString) => TokenContainer.fromJson(jsonDecode(jsonString))).toList();
    return TokenContainerState(containerList: containerList);
  }

  T? currentOf<T extends TokenContainer>(T container) {
    final current = containerOf(container.serial);
    if (current is T) {
      Logger.info('Found current container for ${container.serial}');
      return current;
    }
    Logger.info('Current is not of type $T');
    return null;
  }

  TokenContainer? ofSerial(String serial) => containerList.firstWhereOrNull((container) => container.serial == serial);

  factory TokenContainerState.fromJson(Map<String, dynamic> json) => _$TokenContainerStateFromJson(json);

  SyncState? getSyncState(Token token) {
    if (token.containerSerial == null) return null;
    final container = containerOf(token.containerSerial!);
    if (container == null) return null;
    if (container is TokenContainerFinalized) return container.syncState;
    return null;
  }

  TokenContainer? currentOfSerial(String serial) => containerList.firstWhereOrNull((container) => container.serial == serial);
}
