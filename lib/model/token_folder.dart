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
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'mixins/sortable_mixin.dart';

part 'token_folder.g.dart';

@immutable
@JsonSerializable()
class TokenFolder with SortableMixin {
  static const LABEL = 'label';
  static const FOLDER_ID = 'folderId';
  static const IS_EXPANDED = 'isExpanded';
  static const IS_LOCKED = 'isLocked';
  static const SORT_INDEX = SortableMixin.SORT_INDEX;

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
    this.isExpanded = false,
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
    if (tokenFolder.isLocked) {
      return tokenFolder.copyWith(isExpanded: false);
    } else {
      return tokenFolder;
    }
  }
  Map<String, dynamic> toJson() => _$TokenFolderToJson(this);
}
