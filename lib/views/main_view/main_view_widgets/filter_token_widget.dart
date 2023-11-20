import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/states/token_filter.dart';
import '../../../utils/riverpod_providers.dart';
import '../../../utils/utils.dart';

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
  TokenFilterCategory searchCategory = TokenFilterCategory.label;
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
        decoration: InputDecoration(
          hintText: 'Label / Serial / Issuer',
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Container(
            margin: const EdgeInsets.only(right: 12),
            height: 24,
            child: DropdownButton<TokenFilterCategory>(
              value: searchCategory,
              items: TokenFilterCategory.values
                  .map((element) => DropdownMenuItem(
                      value: element,
                      child: Text(
                        enumAsString(element),
                      )))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  searchCategory = value;
                });
                if (_controller.text.isNotEmpty) _updateFilter();
              },
            ),
          ),
        ),
      );
}
