import 'package:flutter/material.dart';

import '../../processors/mixins/token_import_processor.dart';
import '../enums/token_import_type.dart';

class TokenImportOrigin {
  final String appName;
  final String? iconPath;
  final List<TokenImportSource> importSources;

  const TokenImportOrigin({
    required this.appName,
    required this.importSources,
    this.iconPath,
  });
}

class TokenImportSource {
  final TokenImportType type;
  final TokenImportProcessor processor;
  final String Function(BuildContext context) importHint;

  const TokenImportSource({required this.processor, required this.type, required this.importHint});
}
