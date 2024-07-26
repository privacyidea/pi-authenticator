import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../../../model/extensions/sortable_list.dart';
import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/token_folder.dart';
import '../../../model/tokens/token.dart';
import '../riverpod_providers/state_notifier_providers/token_folder_provider.dart';
import '../riverpod_providers/state_notifier_providers/token_provider.dart';
import '../riverpod_providers/state_providers/dragging_sortable_provider.dart';

class SortableNotifier extends StateNotifier<List<SortableMixin>> {
  final StateNotifierProviderRef _ref;
  Future<List<SortableMixin>>? initState;
  SortableNotifier({
    required StateNotifierProviderRef ref,
    List<SortableMixin> initState = const [],
  })  : _ref = ref,
        super(initState);
  Future<void> _waitInit<List>() async {
    if (initState != null) {
      await initState;
      return;
    }
    initState = Future(() async {
      final newSortables = <SortableMixin>[];
      newSortables.addAll((await _ref.read(tokenProvider.notifier).initState).tokens.cast<SortableMixin>());
      newSortables.addAll((await _ref.read(tokenFolderProvider.notifier).initState).folders.cast<SortableMixin>());
      state = newSortables.sorted.fillNullIndices();
      return state;
    });
    await initState;
  }

  /// Handles a new list of [T].
  /// First removes all elements of type [T] from the current state and then adds the new list.
  Future<List<SortableMixin>> handleNewStateList<T extends SortableMixin>(List<T> newList) async {
    Logger.info('Handling new state list of type $T', name: 'SortableNotifier#handleNewStateList');
    await _waitInit();
    var newState = List<SortableMixin>.from(state);
    newState.removeWhere((element) => element is T);
    newState.addAll(newList);
    final listWithNulls = newState.toList();
    newState = newState.sorted.fillNullIndices();
    state = newState;
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 50)),
      if (listWithNulls.any((e) => e is Token) && listWithNulls.any((element) => element.sortIndex == null))
        _ref.read(tokenProvider.notifier).addOrReplaceTokens(state.whereType<Token>().toList()),
      if (listWithNulls.any((e) => e is TokenFolder) && listWithNulls.any((element) => element.sortIndex == null))
        _ref.read(tokenFolderProvider.notifier).addOrReplaceFolders(state.whereType<TokenFolder>().toList()),
    ]);

    _ref.read(draggingSortableProvider.notifier).state = null;
    return newState;
  }
}
