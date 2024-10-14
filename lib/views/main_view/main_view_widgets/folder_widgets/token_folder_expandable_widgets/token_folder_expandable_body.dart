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

import 'package:flutter/material.dart';

import '../../../../../model/mixins/sortable_mixin.dart';
import '../../../../../model/token_folder.dart';
import '../../../../../model/tokens/token.dart';
import '../../drag_target_divider.dart';
import '../../token_widgets/token_widget_builder.dart';

class TokenFolderExpandableBody extends StatelessWidget {
  final List<Token> tokens;
  final SortableMixin? draggingSortable;
  final TokenFolder folder;
  final bool isFilterd;

  const TokenFolderExpandableBody({
    super.key,
    required this.tokens,
    required this.draggingSortable,
    required this.folder,
    required this.isFilterd,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4, left: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < tokens.length; i++) ...[
              if (draggingSortable != tokens[i] && (i != 0 || draggingSortable is Token))
                isFilterd
                    ? const DefaultDivider()
                    : DragTargetDivider<Token>(
                        dependingFolder: folder,
                        previousSortable: (i - 1) < 0 ? null : tokens[i - 1],
                        nextSortable: tokens[i],
                      ),
              TokenWidgetBuilder.fromToken(token: tokens[i]),
            ],
            if (tokens.isNotEmpty && draggingSortable is Token)
              isFilterd
                  ? const DefaultDivider()
                  : DragTargetDivider<Token>(
                      dependingFolder: folder,
                      previousSortable: tokens.last,
                      nextSortable: null,
                    ),
          ],
        ),
      );
}
