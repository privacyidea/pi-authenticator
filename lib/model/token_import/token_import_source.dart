import '../../l10n/app_localizations.dart';

import '../../processors/mixins/token_import_processor.dart';
import '../enums/token_import_type.dart';

class TokenImportSource {
  final TokenImportType type;
  final TokenImportProcessor processor;
  final String Function(AppLocalizations localizations) importHint;

  const TokenImportSource({required this.processor, required this.type, required this.importHint});
}
