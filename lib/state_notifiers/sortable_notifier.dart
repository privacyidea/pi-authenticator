import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/extensions/sortable_list.dart';

import '../model/mixins/sortable_mixin.dart';
import '../model/token_folder.dart';
import '../model/tokens/token.dart';
import '../utils/riverpod_providers.dart';

class SortableNotifier extends StateNotifier<List<SortableMixin>> {
  final StateNotifierProviderRef ref;
  Future<List<SortableMixin>>? initState;

  SortableNotifier(this.ref, {List<SortableMixin> initState = const []}) : super(initState);

  Future<void> _waitInit<List>() async {
    if (initState != null) {
      await initState;
      return;
    }
    initState = Future(() async {
      final newSortables = <SortableMixin>[];
      newSortables.addAll((await ref.read(tokenProvider.notifier).initState).tokens.cast<SortableMixin>());
      newSortables.addAll((await ref.read(tokenFolderProvider.notifier).initState).folders.cast<SortableMixin>());
      state = newSortables.sorted.fillNullIndices();
      return state;
    });
    await initState;
  }

  /// Handles a new list of [T].
  /// First removes all elements of type [T] from the current state and then adds the new list.
  Future<List<SortableMixin>> handleNewStateList<T extends SortableMixin>(List<T> newList) async {
    await _waitInit();
    var newState = List<SortableMixin>.from(state);
    print('newState 1: ${newState.length}');
    newState.removeWhere((element) => element is T);
    print('newState 2: ${newState.length}');
    newState.addAll(newList);
    print('newState 3: ${newState.length}');
    newState = newState.sorted.fillNullIndices();
    state = newState;
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 50)),
      if (newList.any((e) => e is Token) && newList.any((element) => element.sortIndex == null))
        ref.read(tokenProvider.notifier).addOrReplaceTokens(state.whereType<Token>().toList()),
      if (newList.any((e) => e is TokenFolder) && newList.any((element) => element.sortIndex == null))
        ref.read(tokenFolderProvider.notifier).addOrReplaceFolders(state.whereType<TokenFolder>().toList()),
    ]);

    ref.read(draggingSortableProvider.notifier).state = null;
    return newState;
  }
}
