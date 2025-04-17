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
import 'package:archive/archive.dart' show ArchiveFile;

/// Mixin to provide file-related functionality.</br>
/// This mixin defines methods for getting the file name and converting the object to a file format.</br>
/// To use this mixin, there should be an fromFile factory method in the class that implements it.</br>
/// <br>
/// You should also implement the following static methods for consistency:</br>
/// ```dart
/// factory FileableMixin.fromFile(ArchiveFile file)
/// ```
mixin FileableMixin {
  ArchiveFile toFile();

  /// factory FileablesMixin.fromFile(ArchiveFile file)
}
