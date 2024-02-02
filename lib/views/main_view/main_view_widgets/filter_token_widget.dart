import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/states/token_filter.dart';
import '../../../utils/riverpod_providers.dart';

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _controller,
        onChanged: (value) => _updateFilter(),
        decoration: const InputDecoration(
          hintText: 'Label / Serial / Issuer / Type',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search),
        ),
      );
}
