import '../tokens/token.dart';

class TokenImportEntry {
  final Token newToken;
  final Token? oldToken;
  Token? selectedToken;

  TokenImportEntry._(
    this.newToken,
    this.oldToken,
    this.selectedToken,
  );

  TokenImportEntry({
    required this.newToken,
    this.oldToken,
  }) : selectedToken = oldToken == null ? newToken : null;

  TokenImportEntry copySelect(Token? selectedToken) {
    assert(selectedToken == null || selectedToken == newToken || selectedToken == oldToken);
    return TokenImportEntry._(newToken, oldToken, selectedToken);
  }
}
