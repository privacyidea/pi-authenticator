import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';

import 'no_conflict_import_tokens_tile.dart';

class NoConflictImportTokensList extends StatefulWidget {
  const NoConflictImportTokensList({
    required this.importTokens,
    this.title,
    this.titlePadding = const EdgeInsets.all(0),
    this.borderColor = Colors.green,
    this.leadingDivider = false,
    super.key,
  });

  final String? title;
  final EdgeInsetsGeometry titlePadding;
  final Color? borderColor;
  final bool leadingDivider;

  final List<Token> importTokens;

  @override
  State<NoConflictImportTokensList> createState() => _NoConflictImportTokensListState();
}

class _NoConflictImportTokensListState extends State<NoConflictImportTokensList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.leadingDivider) ...[
          const SizedBox(height: 16),
          const Divider(
            thickness: 2,
            height: 2,
            indent: 4,
            endIndent: 4,
          ),
          const SizedBox(height: 16),
        ],
        if (widget.title != null) ...[
          Padding(
            padding: widget.titlePadding,
            child: Text(
              widget.title!,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
        ],
        for (final token in widget.importTokens)
          NoConflictImportTokensTile(
            token: token,
            selected: token,
            borderColor: widget.borderColor,
          )
      ],
    );
  }
}
