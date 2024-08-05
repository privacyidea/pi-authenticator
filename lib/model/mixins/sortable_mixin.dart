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
mixin SortableMixin {
  int? get sortIndex;
  SortableMixin copyWith({int? sortIndex});

  /// Compares the sortIndex of two SortableMixin objects.
  /// Null values are considered to be the highest index.
  int compareTo(SortableMixin other) {
    if (sortIndex == null) {
      if (other.sortIndex == null) return 0;
      return 1;
    }
    if (other.sortIndex == null) return -1;

    return sortIndex!.compareTo(other.sortIndex!);
  }
}
