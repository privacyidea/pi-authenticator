import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/states/token_filter.dart';
import '../../../utils/riverpod_providers.dart';
import '../../../utils/utils.dart';

class SearchTokenWidget extends ConsumerStatefulWidget {
  final bool searchActive;
  const SearchTokenWidget({required this.searchActive, super.key});

  @override
  ConsumerState<SearchTokenWidget> createState() => _SearchTokenWidgetState();
}

class _SearchTokenWidgetState extends ConsumerState<SearchTokenWidget> {
  TokenFilterCategory searchCategory = TokenFilterCategory.label;
  final TextEditingController _controller = TextEditingController();

  void _resetFilter() {
    ref.read(tokenFilterProvider.notifier).state = null;
    setState(() {
      searchCategory = TokenFilterCategory.label;
      _controller.clear();
    });
    return;
  }

  void _updateFilter() {
    ref.read(tokenFilterProvider.notifier).state = TokenFilter(
      filterCategory: searchCategory,
      searchQuery: _controller.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.searchActive == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _resetFilter());
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: _controller,
        onChanged: (value) => value.isEmpty ? _resetFilter() : _updateFilter(),
        decoration: InputDecoration(
          hintText: 'Label / Serial / Issuer',
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: SizedBox(
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
      ),
    );
  }
}
