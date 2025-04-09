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
/// You should also implement the following factory method for consistency:</br>
/// ```dart
/// factory FileablesMixin.fromFiles(Map<String, InputStream> files)
/// ```
mixin FileablesMixin {
  /// The path where the file should be stored.
  /// This is typically a directory path, e.g. '/path/to/directory/'.
  String get filePath;

  /// The file name without extension.
  List<String> get fileNames;

  /// The extension of the file, e.g. 'txt', 'json', etc.
  Map<String, String> get fileExtensions;

  /// The file name with extension and path.
  List<String> get fullFileNames {
    final fullFileNames = <String>[];
    for (var fileName in fileNames) {
      final fileExtension = fileExtensions[fileName] ?? 'txt';
      if (filePath.isEmpty || !filePath.endsWith('/')) {
        fullFileNames.add('$filePath$fileName.$fileExtension');
      } else {
        fullFileNames.add('$filePath/$fileName.$fileExtension');
      }
    }
    return fullFileNames;
  }

  List<ArchiveFile> toFiles(String folderName);
  List<String> getFileNames();

  bool isFileName(String fileName);

  static List<ArchiveFile> filesFromFolder(String folderName, List<ArchiveFile> files) {
    final archiveFiles = <ArchiveFile>[];
    for (var file in files) {
      if (file.name.startsWith('$folderName/')) {
        final newFile = ArchiveFile(file.name.replaceFirst('$folderName/', ''), file.size, file.content);
        archiveFiles.add(newFile);
      }
    }
    return archiveFiles;
  }

  static List<ArchiveFile> filesFromFolders(String folderPrefix, List<ArchiveFile> files) {
    final archiveFiles = <ArchiveFile>[];
    final regex = RegExp('$folderPrefix' r'[A-Za-z0-9_-]+[/]');
    for (var file in files) {
      if (file.name.startsWith(regex)) {
        final newFile = ArchiveFile(file.name.replaceFirst(regex, ''), file.size, file.content);
        archiveFiles.add(newFile);
      }
    }
    return archiveFiles;
  }

  /// factory FileablesMixin.fromFiles(Map<String, InputStream> files)
}
