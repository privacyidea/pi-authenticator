import 'package:flutter/widgets.dart';
import 'package:privacyidea_authenticator/model/extensions/token_list_extension.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../../model/extensions/sortable_list.dart';
import '../../../../model/mixins/sortable_mixin.dart';
import '../../../../model/token_folder.dart';
import '../../../../model/tokens/token.dart';
import 'token_folder_notifier.dart';
import 'token_notifier.dart';

part 'sortable_notifier.g.dart';

@riverpod
Future<List<SortableMixin>> sortables(Ref ref) async {
  final tokenFolders = ref.watch(tokenFolderProvider).folders;
  final tokens = await ref.watch(
    tokenProvider.selectAsync((state) => state.tokens.filterDuplicates()),
  );

  final sortablesList = <SortableMixin>[...tokens, ...tokenFolders];
  final sortedList = sortablesList.sorted.fillNullIndices();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!ref.mounted) return;
    _handleSortIndexUpdates(ref, sortablesList, sortedList);
  });

  return sortedList;
}

void _handleSortIndexUpdates(
  Ref ref,
  List<SortableMixin> original,
  List<SortableMixin> sorted,
) {
  final hasUnsortedItems = original.any((e) => e.sortIndex == null);
  if (!hasUnsortedItems) return;

  final hasTokens = original.any((e) => e is Token);
  final hasFolders = original.any((e) => e is TokenFolder);

  if (hasTokens) {
    ref
        .read(tokenProvider.notifier)
        .addOrReplaceTokens(sorted.whereType<Token>().toList());
  }

  if (hasFolders) {
    ref
        .read(tokenFolderProvider.notifier)
        .addOrReplaceFolders(sorted.whereType<TokenFolder>().toList());
  }
}
