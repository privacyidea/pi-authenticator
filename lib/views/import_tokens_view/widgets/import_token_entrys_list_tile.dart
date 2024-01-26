import 'package:flutter/material.dart';

import '../../../model/tokens/token.dart';
import 'import_tokens_list_tile.dart';

class ImportTokenEntryListTile extends StatefulWidget {
  final ImportTokenEntry importTokenEntry;
  final void Function(ImportTokenEntry) selectCallback;
  final Size initialScreenSize;
  ImportTokenEntryListTile({
    super.key,
    required this.importTokenEntry,
    required this.initialScreenSize,
    required this.selectCallback,
  }) : assert(importTokenEntry.oldToken != null);

  @override
  State<ImportTokenEntryListTile> createState() => _ImportTokenEntryListTileState();
}

class _ImportTokenEntryListTileState extends State<ImportTokenEntryListTile> {
  late ImportTokenEntry importTokenEntry;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    importTokenEntry = widget.importTokenEntry;
    scrollController = ScrollController(initialScrollOffset: importTokenEntry.oldToken != null ? widget.initialScreenSize.width * 1 / 4 : 0);
  }

  _setScrollPosition() {
    if (scrollController.hasClients != true) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      const fullScrollDuration = Duration(milliseconds: 300);
      double? scrolltarget;
      if (importTokenEntry.oldToken == null) {
        if (scrollController.offset != 0.0) {
          scrolltarget ??= 0.0;
        } else {
          return;
        }
      }
      if (importTokenEntry.selectedToken == null) {
        scrolltarget ??= (scrollController.position.minScrollExtent + scrollController.position.maxScrollExtent) / 2;
      }
      if (importTokenEntry.selectedToken == importTokenEntry.oldToken) {
        scrolltarget ??= scrollController.position.maxScrollExtent;
      }
      if (importTokenEntry.selectedToken == importTokenEntry.newToken) {
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
    setState(() {
      if (tapedToken == importTokenEntry.selectedToken) {
        importTokenEntry.selectedToken = null;
      } else {
        importTokenEntry.selectedToken = tapedToken;
      }
    });
    widget.selectCallback(importTokenEntry);
  }

  @override
  Widget build(BuildContext context) {
    final quarterScreenWidth = MediaQuery.of(context).size.width / 4;
    _setScrollPosition();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      physics: const NeverScrollableScrollPhysics(),
      child: MediaQuery.of(context).orientation == Orientation.landscape
          ? SizedBox(
              width: quarterScreenWidth * 3,
              child: Row(
                children: [
                  Flexible(
                    child: ImportTokensListTile(
                      token: widget.importTokenEntry.newToken,
                      selected: widget.importTokenEntry.selectedToken,
                      alignment: Alignment.centerRight,
                      onTap: widget.importTokenEntry.oldToken != null ? () => _setSelectedToken(importTokenEntry.newToken) : null,
                    ),
                  ),
                  Flexible(
                    child: ImportTokensListTile(
                      token: widget.importTokenEntry.oldToken!,
                      selected: widget.importTokenEntry.selectedToken,
                      alignment: Alignment.centerLeft,
                      onTap: () => _setSelectedToken(importTokenEntry.oldToken!),
                    ),
                  ),
                ],
              ),
            )
          : GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity!.abs() < 100) return;
                if (details.primaryVelocity! < 0) {
                  if (importTokenEntry.selectedToken != importTokenEntry.oldToken) {
                    _setSelectedToken(importTokenEntry.oldToken!);
                  }
                } else {
                  if (importTokenEntry.selectedToken != importTokenEntry.newToken) {
                    _setSelectedToken(importTokenEntry.newToken);
                  }
                }
              },
              child: SizedBox(
                width: quarterScreenWidth * 6,
                child: Row(
                  children: [
                    if (importTokenEntry.newToken != importTokenEntry.selectedToken)
                      SizedBox(
                        width: quarterScreenWidth,
                      ),
                    ImportTokensListTile(
                      width: importTokenEntry.newToken == importTokenEntry.selectedToken ? quarterScreenWidth * 3 : quarterScreenWidth * 2,
                      token: widget.importTokenEntry.newToken,
                      selected: widget.importTokenEntry.selectedToken,
                      alignment: Alignment.centerRight,
                      onTap: widget.importTokenEntry.oldToken != null ? () => _setSelectedToken(importTokenEntry.newToken) : null,
                    ),
                    ImportTokensListTile(
                      width: importTokenEntry.oldToken == importTokenEntry.selectedToken ? quarterScreenWidth * 3 : quarterScreenWidth * 2,
                      token: widget.importTokenEntry.oldToken!,
                      selected: widget.importTokenEntry.selectedToken,
                      alignment: Alignment.centerLeft,
                      onTap: () => _setSelectedToken(importTokenEntry.oldToken!),
                    ),
                    if (widget.importTokenEntry.oldToken != null && importTokenEntry.oldToken != importTokenEntry.selectedToken)
                      SizedBox(width: quarterScreenWidth),
                  ],
                ),
              ),
            ),
    );
  }
}

class ImportTokenEntry {
  final Token newToken;
  final Token? oldToken;
  Token? selectedToken;
  ImportTokenEntry({
    required this.newToken,
    this.oldToken,
  }) : selectedToken = oldToken == null ? newToken : null;
}
