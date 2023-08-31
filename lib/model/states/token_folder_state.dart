import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../token_folder.dart';

@immutable
class TokenFolderState {
  final List<TokenFolder> folders;

  const TokenFolderState({required this.folders});

  TokenFolderState withFolder(String name) {
    final newFolders = List<TokenFolder>.from(folders);
    newFolders.add(TokenFolder(label: name, folderId: newFolderId));
    return TokenFolderState(folders: newFolders);
  }

  // replace all folders where the folderid is the same
  // if the folderid is none, add it to the list
  TokenFolderState withUpdated(List<TokenFolder> folders) {
    final newFolders = List<TokenFolder>.from(this.folders);
    for (var newFolder in folders) {
      final index = newFolders.indexWhere((oldFolder) => oldFolder.folderId == newFolder.folderId);
      if (index != -1) {
        newFolders[index] = newFolder;
      }
    }
    return TokenFolderState(folders: newFolders);
  }

  TokenFolderState withoutFolder(TokenFolder folder) {
    final newFolders = List<TokenFolder>.from(folders);
    newFolders.removeWhere((element) => element.folderId == folder.folderId);
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
}
