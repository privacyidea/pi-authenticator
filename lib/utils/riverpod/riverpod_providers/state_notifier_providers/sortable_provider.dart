import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/mixins/sortable_mixin.dart';
import '../../../../model/states/token_folder_state.dart';
import '../../../../model/states/token_state.dart';
import '../../state_notifiers/sortable_notifier.dart';
import '../../../logger.dart';
import 'token_folder_provider.dart';
import 'token_provider.dart';

final sortableProvider = StateNotifierProvider<SortableNotifier, List<SortableMixin>>(
  (ref) {
    final SortableNotifier notifier = SortableNotifier(ref: ref);
    Logger.info("New sortableProvider created", name: 'sortableProvider');
    ref.listen(tokenProvider, (previous, next) => notifier.handleNewStateList(next.tokens));
    ref.listen(tokenFolderProvider, (previous, next) => notifier.handleNewStateList(next.folders));
    Future.wait(
      [ref.read(tokenProvider.notifier).initState, ref.read(tokenFolderProvider.notifier).initState],
    ).then((values) {
      final sortables = <SortableMixin>[];
      for (final v in values) {
        if (v is TokenState) {
          sortables.addAll(v.tokens);
        } else if (v is TokenFolderState) {
          sortables.addAll(v.folders);
        }
      }
      notifier.handleNewStateList(sortables);
    });
    return notifier;
  },
);
