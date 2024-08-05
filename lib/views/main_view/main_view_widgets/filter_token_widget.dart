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
        decoration: const InputDecoration(
          hintText: 'Label / Serial / Issuer / Type',
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          prefixIcon: Icon(Icons.search),
        ),
      );
}
