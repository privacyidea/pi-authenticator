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
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/token_folder.dart';
import '../../../../utils/logger.dart';
import '../../../../utils/riverpod/riverpod_providers/state_providers/dragging_sortable_provider.dart';
import '../../../../utils/utils.dart';
import 'token_folder_expandable.dart';

class TokenFolderWidget extends ConsumerWidget {
  final TokenFolder folder;

  const TokenFolderWidget(this.folder, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draggingSortable = ref.watch(draggingSortableProvider);
    final TokenFolder? draggingFolder = draggingSortable is TokenFolder ? draggingSortable : null;
    return draggingSortable == null
        ? LongPressDraggable(
            maxSimultaneousDrags: 1,
            dragAnchorStrategy: (draggable, context, position) {
              final textSize = textSizeOf(
                text: folder.label,
                style: Theme.of(context).textTheme.titleMedium!,
                textScaler: MediaQuery.of(context).textScaler,
                maxLines: 1,
              );
              return Offset(max(textSize.width / 2, 30), textSize.height / 2 + 30);
            },
            onDragStarted: () => draggingSortableNotifier.state = folder,
            onDragCompleted: () {
              Logger.info('Draggable completed');
              // Will be handled by the sortableNotifier
            },
            onDraggableCanceled: (velocity, offset) {
              Logger.info('Draggable canceled');
              draggingSortableNotifier.state = null;
            },
            data: folder,
            childWhenDragging: const SizedBox(),
            feedback: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.folder, size: 60),
                Material(
                  color: Colors.transparent,
                  child: Text(
                    folder.label,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TokenFolderExpandable(
                folder: folder,
                key: Key('TokenFolderExpandable#${folder.folderId}'),
              ),
            ),
          )
        : (draggingFolder == folder)
            ? const SizedBox()
            : TokenFolderExpandable(folder: folder);
  }
}
