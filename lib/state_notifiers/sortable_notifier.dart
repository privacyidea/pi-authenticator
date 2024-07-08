import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/extensions/sortable_list.dart';

import '../model/mixins/sortable_mixin.dart';
import '../model/token_folder.dart';
import '../model/tokens/token.dart';
import '../utils/riverpod_providers.dart';

class SortableNotifier extends StateNotifier<List<SortableMixin>> {
  final StateNotifierProviderRef ref;

  SortableNotifier(this.ref, {List<SortableMixin> initState = const []}) : super(initState);

  void handleNewList<T extends SortableMixin>(List<T> newList) {
    var newState = List<SortableMixin>.from(state);
    newState.removeWhere((element) => element is T);
    newState.addAll(newList);
    state = newState.sorted.fillNullIndices();
    if (newList.any((element) => element.sortIndex == null)) {
      if (newList.any((e) => e is Token)) ref.read(tokenProvider.notifier).addOrReplaceTokens(state.whereType<Token>().toList());
      if (newList.any((e) => e is TokenFolder)) ref.read(tokenFolderProvider.notifier).addOrReplaceFolders(state.whereType<TokenFolder>().toList());
    }
    ref.read(draggingSortableProvider.notifier).state = null;
  }
}
