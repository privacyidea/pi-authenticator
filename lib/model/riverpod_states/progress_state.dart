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
class ProgressState {
  final int max;
  final int value;

  double get progress => value / max;

  ProgressState(
    this.max,
    this.value,
  )   : assert(max >= 0),
        assert(value >= 0);

  ProgressState copyWith({int? max, int? value, bool? inProgress}) => ProgressState(max ?? this.max, value ?? this.value);
}
