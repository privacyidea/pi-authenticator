import 'package:flutter/material.dart';

import '../processors/token_import_processor/token_import_file_processor_interface.dart';

class TokenImportSource {
  final String appName;
  final String Function(BuildContext context) importHint;
  final String? iconPath;
  final TokenImportProcessor? processor;

  const TokenImportSource({
    required this.appName,
    required this.importHint,
    this.iconPath,
    this.processor,
  });
}
