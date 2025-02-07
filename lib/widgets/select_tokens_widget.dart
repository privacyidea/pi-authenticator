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

import '../l10n/app_localizations.dart';
import '../model/tokens/token.dart';
import '../views/main_view/main_view_widgets/token_widgets/token_widget_builder.dart';

class SelectTokensWidget extends StatefulWidget {
  final bool multiSelect;
  final Set<Token> tokens;
  final void Function(Set<Token> selected, Set<Token> unselected) onSelect;
  const SelectTokensWidget({this.multiSelect = true, required this.onSelect, super.key, required this.tokens});

  @override
  State<SelectTokensWidget> createState() => _SelectTokensWidgetState();
}

class _SelectTokensWidgetState extends State<SelectTokensWidget> {
  final Set<Token> _selectedTokens = {};
  late Set<Token> _unselectedTokens;

  @override
  void initState() {
    super.initState();
    _unselectedTokens = widget.tokens;
  }

  void _select(Token token) {
    setState(() {
      if (widget.multiSelect) {
        if (_selectedTokens.contains(token)) {
          _selectedTokens.remove(token);
          _unselectedTokens.add(token);
        } else {
          _selectedTokens.add(token);
          _unselectedTokens.remove(token);
        }
      } else {
        _selectedTokens.clear();
        _selectedTokens.add(token);
        _unselectedTokens = widget.tokens.where((element) => element != token).toSet();
      }
    });
    widget.onSelect(_selectedTokens, _unselectedTokens);
  }

  void _selectAll() {
    setState(() {
      if (_selectedTokens.length == widget.tokens.length) {
        _selectedTokens.clear();
        _unselectedTokens = widget.tokens;
      } else {
        _selectedTokens.addAll(widget.tokens);
        _unselectedTokens.clear();
      }
    });
    widget.onSelect(_selectedTokens, _unselectedTokens);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tokens = widget.tokens;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: (tokens.isEmpty)
          ? Text(
              appLocalizations.nothingToSelect,
              textAlign: TextAlign.center,
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.multiSelect)
                  InkWell(
                    onTap: _selectAll,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          appLocalizations.selectAll,
                          textAlign: TextAlign.right,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Checkbox(value: _selectedTokens.length == tokens.length, onChanged: (_) => _selectAll()),
                        ),
                      ],
                    ),
                  ),
                Flexible(
                  child: SizedBox(
                    width: 9999,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final token in tokens)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: TextButton(
                                style: _selectedTokens.contains(token)
                                    ? ButtonStyle(backgroundColor: WidgetStateProperty.all(theme.colorScheme.secondary.withAlpha(80)))
                                    : null,
                                onPressed: () => _select(token),
                                child: TokenWidgetBuilder.previewFromToken(token),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
