/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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
  State<ConflictedImportTokensTile> createState() =>
      _ConflictedImportTokensTileState();
}

class _ConflictedImportTokensTileState
    extends State<ConflictedImportTokensTile> {
  late ScrollController scrollController;
  // importTokenEntry is mutated in place rather than replaced, so comparing
  // oldWidget.importTokenEntry to widget.importTokenEntry in didUpdateWidget
  // would always see the same (already-mutated) object. Track our own
  // snapshot of the value that matters instead.
  Token? _lastSelectedToken;

  @override
  void initState() {
    super.initState();
    _lastSelectedToken = widget.importTokenEntry.selectedToken;
    scrollController = ScrollController(
      initialScrollOffset: widget.importTokenEntry.oldToken != null
          ? widget.initialScreenSize.width * 1 / 4
          : 0,
    );
    _setScrollPosition();
  }

  @override
  void didUpdateWidget(covariant ConflictedImportTokensTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectionChanged =
        _lastSelectedToken != widget.importTokenEntry.selectedToken;
    // initialScreenSize is a plain immutable field on the widget itself (not
    // on the mutable importTokenEntry), so comparing oldWidget to widget here
    // is safe and reflects a real orientation/layout change.
    final screenSizeChanged =
        oldWidget.initialScreenSize != widget.initialScreenSize;
    if (selectionChanged || screenSizeChanged) {
      _lastSelectedToken = widget.importTokenEntry.selectedToken;
      _setScrollPosition();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _setScrollPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients != true) return;
      const fullScrollDuration = Duration(milliseconds: 300);
      double? scrollTarget;
      if (widget.importTokenEntry.oldToken == null) {
        if (scrollController.offset != 0.0) {
          scrollTarget = 0.0;
        } else {
          return;
        }
      }
      final isLandscape =
          widget.initialScreenSize.width > widget.initialScreenSize.height;
      if (widget.importTokenEntry.selectedToken == null || isLandscape) {
        // Mid of the Row
        scrollTarget ??=
            (scrollController.position.minScrollExtent +
                scrollController.position.maxScrollExtent) /
            2;
      } else if (widget.importTokenEntry.selectedToken ==
          widget.importTokenEntry.oldToken) {
        // Show Right Tile
        scrollTarget ??= scrollController.position.maxScrollExtent;
      } else if (widget.importTokenEntry.selectedToken ==
          widget.importTokenEntry.newToken) {
        // Show Left Tile
        scrollTarget ??= scrollController.position.minScrollExtent;
      }
      if (scrollTarget == null ||
          scrollController.position.maxScrollExtent == 0.0) {
        return;
      }
      final scrollDifferencePercent =
          (scrollController.offset - scrollTarget).abs() /
          scrollController.position.maxScrollExtent;
      scrollController.animateTo(
        scrollTarget,
        duration: fullScrollDuration * scrollDifferencePercent,
        curve: Curves.easeIn,
      );
    });
  }

  void _setSelectedToken(Token tappedToken) {
    final importTokenEntry = widget.importTokenEntry;
    if (tappedToken == widget.importTokenEntry.selectedToken) {
      importTokenEntry.selectedToken = null;
    } else {
      importTokenEntry.selectedToken = tappedToken;
    }

    widget.selectTokenCallback(importTokenEntry);
  }

  @override
  Widget build(BuildContext context) {
    final quarterScreenWidth = MediaQuery.of(context).size.width / 4;
    final isLandscape =
        widget.initialScreenSize.width > widget.initialScreenSize.height;
    Logger.debug('Building ConflictedImportTokensTile ');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      physics: const NeverScrollableScrollPhysics(),
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          final primaryVelocity = details.primaryVelocity ?? 0.0;
          if (primaryVelocity.abs() < 100) return;
          if (primaryVelocity < 0) {
            if (widget.importTokenEntry.selectedToken !=
                widget.importTokenEntry.oldToken) {
              _setSelectedToken(widget.importTokenEntry.oldToken!);
            }
          } else {
            if (widget.importTokenEntry.selectedToken !=
                widget.importTokenEntry.newToken) {
              _setSelectedToken(widget.importTokenEntry.newToken);
            }
          }
        },
        child: SizedBox(
          width: quarterScreenWidth * (isLandscape ? 4 : 6),
          child: Row(
            children: [
              if (widget.importTokenEntry.newToken !=
                      widget.importTokenEntry.selectedToken &&
                  !isLandscape)
                SizedBox(width: quarterScreenWidth),
              NoConflictImportTokensTile(
                width:
                    widget.importTokenEntry.newToken ==
                            widget.importTokenEntry.selectedToken &&
                        !isLandscape
                    ? quarterScreenWidth * 3
                    : quarterScreenWidth * 2,
                token: widget.importTokenEntry.newToken,
                selected: widget.importTokenEntry.selectedToken,
                onTap: widget.importTokenEntry.oldToken != null
                    ? () => _setSelectedToken(widget.importTokenEntry.newToken)
                    : null,
              ),
              NoConflictImportTokensTile(
                width:
                    widget.importTokenEntry.oldToken ==
                            widget.importTokenEntry.selectedToken &&
                        !isLandscape
                    ? quarterScreenWidth * 3
                    : quarterScreenWidth * 2,
                token: widget.importTokenEntry.oldToken!,
                selected: widget.importTokenEntry.selectedToken,
                onTap: () =>
                    _setSelectedToken(widget.importTokenEntry.oldToken!),
              ),
              if (widget.importTokenEntry.oldToken != null &&
                  widget.importTokenEntry.oldToken !=
                      widget.importTokenEntry.selectedToken &&
                  !isLandscape)
                SizedBox(width: quarterScreenWidth),
            ],
          ),
        ),
      ),
    );
  }
}
