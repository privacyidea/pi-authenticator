import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../token_folder.dart';

@immutable
class TokenFolderState {
  final List<TokenFolder> folders;

  const TokenFolderState({required this.folders});

  /// Add a new folder with the given name
  /// Returns a new TokenFolderState with the new folder
  /// The original List is not modified
  TokenFolderState addNewFolder(String name) {
    final newFolders = List<TokenFolder>.from(folders);
    newFolders.add(TokenFolder(label: name, folderId: newFolderId));
    return TokenFolderState(folders: newFolders);
  }

  /// Add or replace the folders with the same folderId
  /// Returns a new TokenFolderState with the new folders
  /// The original List is not modified
  TokenFolderState addOrReplaceFolders(List<TokenFolder> folders) {
    final newFolders = List<TokenFolder>.from(this.folders);
    for (var newFolder in folders) {
      final index = newFolders.indexWhere((oldFolder) => oldFolder.folderId == newFolder.folderId);
      if (index != -1) {
        newFolders[index] = newFolder;
      }
    }
    return TokenFolderState(folders: newFolders);
  }

  TokenFolderState addOrReplaceFolder(TokenFolder newFolder) {
    final newFolders = List<TokenFolder>.from(folders);
    final index = newFolders.indexWhere((element) => element.folderId == newFolder.folderId);
    if (index != -1) {
      newFolders[index] = newFolder;
    }
    return TokenFolderState(folders: newFolders);
  }

  /// Remove the folder with the same folderId
  /// Returns a new TokenFolderState without the folder
  /// The original List is not modified
  TokenFolderState removeFolder(TokenFolder folder) {
    final newFolders = List<TokenFolder>.from(folders);
    newFolders.removeWhere((element) => element.folderId == folder.folderId);
    return TokenFolderState(folders: newFolders);
  }

  /// Remove the folders with the same folderId
  /// Returns a new TokenFolderState without the folders
  /// The original List is not modified
  TokenFolderState removeFolders(List<TokenFolder> folders) {
    final newFolders = List<TokenFolder>.from(this.folders);
    newFolders.removeWhere((element) => folders.any((folder) => folder.folderId == element.folderId));
    return TokenFolderState(folders: newFolders);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TokenFolderState && runtimeType == other.runtimeType && listEquals(folders, other.folders);

  @override
  int get hashCode => (folders.hashCode + runtimeType.hashCode).hashCode;

  @override
  String toString() => 'TokenFolderState{folders: $folders}';

  get newFolderId => folders.fold(0, (previousValue, element) => max(previousValue, element.folderId)) + 1;

  /// Get the folder by the given id, or null if the folder does not exist
  TokenFolder? currentById(int? id) => id == null ? null : folders.firstWhereOrNull((element) => element.folderId == id);

  /// Returns the current folder of the given folder, or null if the folder does not exist
  TokenFolder? currentOf(TokenFolder folder) => folders.firstWhereOrNull((element) => element.folderId == folder.folderId);
}
