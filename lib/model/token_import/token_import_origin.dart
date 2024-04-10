import 'token_import_source.dart';

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
