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

part 'progress_state.freezed.dart';

@freezed
class ProgressState with _$ProgressState {
  double get progress => value / max;

  const ProgressState._();

  const factory ProgressState.uninitialized({
    @Default(0) int max,
    @Default(0) int value,
  }) = ProgressStateUninitialized;

  @Assert('max >= 0', 'max must be greater than or equal to 0')
  @Assert('value >= max', 'value must be less than or equal to max')
  const factory ProgressState({
    required int max,
    required int value,
  }) = _ProgressState;
}
