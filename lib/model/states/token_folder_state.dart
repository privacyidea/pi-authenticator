import 'dart:math';

import 'package:flutter/material.dart';

import '../token_folder.dart';

@immutable
class TokenFolderState {
  final List<TokenFolder> folders;

  const TokenFolderState({required this.folders});

  TokenFolderState copyWith({List<TokenFolder>? folders}) {
    return TokenFolderState(
      folders: folders ?? this.folders,
    );
  }

  TokenFolderState withFolder(String name) {
    final newFolders = List<TokenFolder>.from(folders);
    newFolders.add(TokenFolder(label: name, folderId: newFolderId));
    return copyWith(folders: newFolders);
  }

  // replace all folders where the folderid is the same
  // if the folderid is none, add it to the list
  TokenFolderState withUpdated({List<TokenFolder>? folders}) {
    final newFolders = List<TokenFolder>.from(this.folders);
    folders?.forEach((newFolder) {
      final index = newFolders.indexWhere((oldFolder) => oldFolder.folderId == newFolder.folderId);
      if (index != -1) {
        newFolders[index] = newFolder;
      }
    });
    return copyWith(folders: newFolders);
  }

  TokenFolderState withoutFolder(TokenFolder folder) {
    final newFolders = List<TokenFolder>.from(folders);
    newFolders.removeWhere((element) => element.folderId == folder.folderId);
    return copyWith(folders: newFolders);
  }

  get newFolderId => folders.fold(0, (previousValue, element) => max(previousValue, element.folderId)) + 1;
}
