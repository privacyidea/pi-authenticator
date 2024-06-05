import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'mixins/sortable_mixin.dart';

part 'token_folder.g.dart';

@immutable
@JsonSerializable()
class TokenFolder with SortableMixin {
  final String label;
  final int folderId;
  final bool isExpanded;
  final bool isLocked;
  @override
  final int? sortIndex;
  @override
  const TokenFolder({
    required this.label,
    required this.folderId,
    this.isExpanded = true,
    this.isLocked = false,
    this.sortIndex,
  });

  @override
  TokenFolder copyWith({
    String? label,
    int? folderId,
    bool? isExpanded,
    bool? isLocked,
    int? sortIndex,
  }) {
    return TokenFolder(
      label: label ?? this.label,
      folderId: folderId ?? this.folderId,
      sortIndex: sortIndex ?? this.sortIndex,
      isLocked: isLocked ?? this.isLocked,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is TokenFolder && folderId == other.folderId;

  @override
  int get hashCode => (folderId.hashCode + runtimeType.hashCode).hashCode;

  @override
  String toString() => 'TokenFolder{label: $label, folderId: $folderId, isExpanded: $isExpanded, isLocked: $isLocked, sortIndex: $sortIndex}';

  factory TokenFolder.fromJson(Map<String, dynamic> json) {
    var tokenFolder = _$TokenFolderFromJson(json);
    if (tokenFolder.isLocked) tokenFolder = tokenFolder.copyWith(isExpanded: false);
    return tokenFolder;
  }
  Map<String, dynamic> toJson() => _$TokenFolderToJson(this);
}
