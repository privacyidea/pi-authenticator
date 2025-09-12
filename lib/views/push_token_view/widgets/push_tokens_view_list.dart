/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../model/mixins/sortable_mixin.dart';
import '../../../model/tokens/push_token.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/state_providers/dragging_sortable_provider.dart';
import '../../../widgets/default_refresh_indicator.dart';
import '../../../widgets/drag_item_scroller.dart';
import '../../main_view/main_view_widgets/drag_target_divider.dart';
import '../../main_view/main_view_widgets/main_view_tokens_list.dart';

class PushTokensViwList extends ConsumerStatefulWidget {
  const PushTokensViwList({super.key});

  static List<Widget> _buildSortableWidgets({
    required List<SortableMixin> sortables,
    required SortableMixin? draggingSortable,
    // bool hidePushTokens = false,
    // TokenFilter? filter,
  }) {
    if (sortables.isEmpty) return [];
    sortables = sortables.toList();
    sortables = sortables.whereType<PushToken>().toList();
    return MainViewTokensList.buildSortableWidgets(sortables: sortables, draggingSortable: draggingSortable);
  }

  @override
  ConsumerState<PushTokensViwList> createState() => _PushTokensViwListState();
}

class _PushTokensViwListState extends ConsumerState<PushTokensViwList> {
  final listViewKey = GlobalKey();
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final pushTokens = ref.watch(tokenProvider).value?.pushTokens ?? [];
    final draggingSortable = ref.watch(draggingSortableProvider);
    return Stack(
      children: [
        Column(
          children: [
            Flexible(
              child: DefaultRefreshIndicator(
                child: SizedBox(
                  height: 9999,
                  child: Opacity(
                    opacity: 0,
                    child: DragTargetDivider(dependingFolder: null, previousSortable: pushTokens.lastOrNull, nextSortable: null, bottomPadding: 0),
                  ),
                ),
              ),
            ),
          ],
        ),
        DefaultRefreshIndicator(
          listViewKey: listViewKey,
          scrollController: scrollController,
          child: SlidableAutoCloseBehavior(
            child: DragItemScroller(
              listViewKey: listViewKey,
              itemIsDragged: draggingSortable != null,
              scrollController: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: PushTokensViwList._buildSortableWidgets(sortables: pushTokens, draggingSortable: draggingSortable),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
