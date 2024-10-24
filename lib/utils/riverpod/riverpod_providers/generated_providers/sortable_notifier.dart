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

import 'package:flutter/widgets.dart';
import 'package:privacyidea_authenticator/model/extensions/sortable_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../model/mixins/sortable_mixin.dart';
import '../../../../model/token_folder.dart';
import '../../../../model/tokens/token.dart';
import 'token_folder_notifier.dart';
import 'token_notifier.dart';

part 'sortable_notifier.g.dart';

@riverpod
List<SortableMixin> sortables(SortablesRef ref) {
  final tokenFolders = ref.watch(tokenFolderProvider).folders;
  final tokens = ref.watch(tokenProvider).tokens;

  var sortablesWithNulls = List<SortableMixin>.from([...tokens, ...tokenFolders]);

  final sortedSortables = sortablesWithNulls.sorted.fillNullIndices();

  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    if (sortablesWithNulls.any((e) => e is Token) && sortablesWithNulls.any((element) => element.sortIndex == null)) {
      ref.read(tokenProvider.notifier).addOrReplaceTokens(sortedSortables.whereType<Token>().toList());
    }
    if (sortablesWithNulls.any((e) => e is TokenFolder) && sortablesWithNulls.any((element) => element.sortIndex == null)) {
      ref.read(tokenFolderProvider.notifier).addOrReplaceFolders(sortedSortables.whereType<TokenFolder>().toList());
    }
  });

  return sortedSortables;
}
