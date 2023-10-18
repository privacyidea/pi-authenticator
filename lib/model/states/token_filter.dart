import '../tokens/push_token.dart';

import '../tokens/token.dart';

class TokenFilter {
  TokenFilterCategory filterCategory;
  String searchQuery;
  TokenFilter({required this.filterCategory, required this.searchQuery});
  List<Token> filterTokens(List<Token> tokens) => switch (filterCategory) {
        TokenFilterCategory.issuer => tokens.where((token) => token.issuer.toLowerCase().contains(searchQuery.toLowerCase())).toList(),
        TokenFilterCategory.label => tokens.where((token) => token.label.toLowerCase().contains(searchQuery.toLowerCase())).toList(),
        TokenFilterCategory.serial => tokens.whereType<PushToken>().where((token) => token.serial.toLowerCase().contains(searchQuery.toLowerCase())).toList(),
      };
}

enum TokenFilterCategory {
  label,
  serial,
  issuer,
}
