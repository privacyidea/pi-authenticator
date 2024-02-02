import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/states/token_filter.dart';
import '../../../model/token_folder.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/riverpod_providers.dart';
import 'folder_widgets/token_folder_expandable.dart';
import 'token_widgets/token_widget_builder.dart';

class MainViewTokensListFiltered extends ConsumerWidget {
  const MainViewTokensListFiltered({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ..._mapTokensToWidgets(ref: ref),
        ],
      ),
    );
  }

  List<Widget> _mapTokensToWidgets({required WidgetRef ref}) {
    final filter = ref.watch(tokenFilterProvider);
    if (filter == null) return [];
    final tokenFolders = ref.watch(tokenFolderProvider).folders;
    final tokensInNoFolder = filter.filterTokens(ref.watch(tokenProvider).tokensWithoutFolder());
    List<SortableMixin> sortables = [...tokenFolders, ...tokensInNoFolder];

    sortables.sort((a, b) => a.compareTo(b));
    final List<Widget> widgets = [];
    for (int i = 0; i < sortables.length; i++) {
      final sortable = sortables[i];
      if (sortable is Token) {
        widgets.add(TokenWidgetBuilder.fromToken(sortable));
        if (i != sortables.length - 1) {
          widgets.add(const Divider());
        }
      } else if (sortable is TokenFolder) {
        widgets.addAll(_buildFilteredFolder(ref: ref, folder: sortable, filter: filter));
      }
    }
    return widgets;
  }

  List<Widget> _buildFilteredFolder({required WidgetRef ref, required TokenFolder folder, required TokenFilter filter}) {
    if (filter.filterTokens(ref.watch(tokenProvider).tokensInFolder(folder)).isEmpty) return [];
    final expanded = filter.searchQuery.isNotEmpty && !folder.isLocked ? true : null; // Auto expand if search query is not empty and folder is not locked.
    final List<Widget> widgets = [];
    widgets.add(
      TokenFolderExpandable(folder: folder, filter: filter, expanded: expanded, key: ValueKey('${folder.label}$expanded')),
    );
    widgets.add(const Divider());
    return widgets;
  }
}
