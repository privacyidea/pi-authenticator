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

import '../../../../../../../utils/logger.dart';
import '../../../model/token_import/token_import_entry.dart';
import '../../../model/tokens/token.dart';
import 'no_conflict_import_tokens_tile.dart';

class ConflictedImportTokensTile extends StatefulWidget {
  final TokenImportEntry importTokenEntry;
  final void Function(TokenImportEntry) selectTokenCallback;
  // Cannot use MediaQuery.of(context).size in initState
  final Size initialScreenSize;
  ConflictedImportTokensTile({
    super.key,
    required this.importTokenEntry,
    required this.initialScreenSize,
    required this.selectTokenCallback,
  }) : assert(importTokenEntry.oldToken != null);

  @override
  State<ConflictedImportTokensTile> createState() => _ConflictedImportTokensTileState();
}

class _ConflictedImportTokensTileState extends State<ConflictedImportTokensTile> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(initialScrollOffset: widget.importTokenEntry.oldToken != null ? widget.initialScreenSize.width * 1 / 4 : 0);
  }

  _setScrollPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients != true) return;
      const fullScrollDuration = Duration(milliseconds: 300);
      double? scrolltarget;
      if (widget.importTokenEntry.oldToken == null) {
        if (scrollController.offset != 0.0) {
          scrolltarget = 0.0;
        } else {
          return;
        }
      }
      final isLandScape = widget.initialScreenSize.width > widget.initialScreenSize.height;
      if (widget.importTokenEntry.selectedToken == null || isLandScape) {
        // Mid of the Row
        scrolltarget ??= (scrollController.position.minScrollExtent + scrollController.position.maxScrollExtent) / 2;
      } else if (widget.importTokenEntry.selectedToken == widget.importTokenEntry.oldToken) {
        // Show Right Tile
        scrolltarget ??= scrollController.position.maxScrollExtent;
      } else if (widget.importTokenEntry.selectedToken == widget.importTokenEntry.newToken) {
        // Show Left Tile
        scrolltarget ??= scrollController.position.minScrollExtent;
      }
      if (scrolltarget == null || scrollController.position.maxScrollExtent == 0.0) return;
      final scrollDifferencePercent = (scrollController.offset - scrolltarget).abs() / scrollController.position.maxScrollExtent;
      scrollController.animateTo(
        scrolltarget,
        duration: fullScrollDuration * scrollDifferencePercent,
        curve: Curves.easeIn,
      );
    });
  }

  _setSelectedToken(Token tapedToken) {
    final importTokenEntry = widget.importTokenEntry;
    if (tapedToken == widget.importTokenEntry.selectedToken) {
      importTokenEntry.selectedToken = null;
    } else {
      importTokenEntry.selectedToken = tapedToken;
    }

    widget.selectTokenCallback(importTokenEntry);
  }

  @override
  Widget build(BuildContext context) {
    final quarterScreenWidth = MediaQuery.of(context).size.width / 4;
    final isLandScape = widget.initialScreenSize.width > widget.initialScreenSize.height;
    Logger.debug('Building ConflictedImportTokensTile ');

    _setScrollPosition();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      physics: const NeverScrollableScrollPhysics(),
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity!.abs() < 100) return;
          if (details.primaryVelocity! < 0) {
            if (widget.importTokenEntry.selectedToken != widget.importTokenEntry.oldToken) {
              _setSelectedToken(widget.importTokenEntry.oldToken!);
            }
          } else {
            if (widget.importTokenEntry.selectedToken != widget.importTokenEntry.newToken) {
              _setSelectedToken(widget.importTokenEntry.newToken);
            }
          }
        },
        child: SizedBox(
          width: quarterScreenWidth * (isLandScape ? 4 : 6),
          child: Row(
            children: [
              if (widget.importTokenEntry.newToken != widget.importTokenEntry.selectedToken && !isLandScape)
                SizedBox(
                  width: quarterScreenWidth,
                ),
              NoConflictImportTokensTile(
                width:
                    widget.importTokenEntry.newToken == widget.importTokenEntry.selectedToken && !isLandScape ? quarterScreenWidth * 3 : quarterScreenWidth * 2,
                token: widget.importTokenEntry.newToken,
                selected: widget.importTokenEntry.selectedToken,
                alignment: Alignment.centerRight,
                onTap: widget.importTokenEntry.oldToken != null ? () => _setSelectedToken(widget.importTokenEntry.newToken) : null,
              ),
              NoConflictImportTokensTile(
                width:
                    widget.importTokenEntry.oldToken == widget.importTokenEntry.selectedToken && !isLandScape ? quarterScreenWidth * 3 : quarterScreenWidth * 2,
                token: widget.importTokenEntry.oldToken!,
                selected: widget.importTokenEntry.selectedToken,
                alignment: Alignment.centerLeft,
                onTap: () => _setSelectedToken(widget.importTokenEntry.oldToken!),
              ),
              if (widget.importTokenEntry.oldToken != null && widget.importTokenEntry.oldToken != widget.importTokenEntry.selectedToken && !isLandScape)
                SizedBox(width: quarterScreenWidth),
            ],
          ),
        ),
      ),
    );
  }
}
