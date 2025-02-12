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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/riverpod_states/token_filter.dart';
import '../../../utils/globals.dart';
import '../../../utils/riverpod/riverpod_providers/state_providers/token_filter_provider.dart';

class SearchTokenWidget extends StatelessWidget {
  final bool searchActive;
  const SearchTokenWidget({required this.searchActive, super.key});

  @override
  Widget build(BuildContext context) => searchActive ? const SearchInputField() : const SizedBox();
}

class SearchInputField extends ConsumerStatefulWidget {
  const SearchInputField({super.key});

  @override
  ConsumerState<SearchInputField> createState() => _SearchInputFieldState();
}

class _SearchInputFieldState extends ConsumerState<SearchInputField> {
  final TextEditingController _controller = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateFilter);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _resetFilter() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalRef?.read(tokenFilterProvider.notifier).state = null;
    });
    return;
  }

  void _updateFilter() {
    ref.read(tokenFilterProvider.notifier).state = TokenFilter(
      // filterCategory: searchCategory,
      searchQuery: _controller.text,
    );
  }

  @override
  void dispose() {
    _resetFilter();
    _focusNode.unfocus();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Label / Serial / Issuer / Type',
          hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          prefixIcon: Icon(Icons.search),
        ),
      );
}
