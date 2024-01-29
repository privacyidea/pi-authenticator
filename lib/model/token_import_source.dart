import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/processors/mixins/token_migrate_processor.dart';
import 'package:privacyidea_authenticator/processors/scheme_processors/token_scheme_processors/otp_auth_migration_processor.dart';

import '../processors/token_migrate_file_processor/aegis_migrate_file_processor.dart';
import '../processors/token_migrate_file_processor/token_migrate_file_processor_interface.dart';
import '../processors/token_migrate_file_processor/two_fas_migrate_file_processor.dart';

abstract class TokenImportSource {
  final String appName;
  final String Function(BuildContext context) importHint;
  final String? iconPath;
  final TokenMigrateProcessor _processor;

  TokenMigrateProcessor get processor => _processor;

  const TokenImportSource({
    required this.appName,
    required this.importHint,
    required TokenMigrateProcessor processor,
    this.iconPath,
  }) : _processor = processor;
}

class TokenImportQrScanSource extends TokenImportSource {
  @override
  OtpAuthMigrationProcessor get processor => super.processor as OtpAuthMigrationProcessor;

  const TokenImportQrScanSource({
    required super.appName,
    required super.importHint,
    required OtpAuthMigrationProcessor processor,
    super.iconPath,
  }) : super(processor: processor);
}

class TokenImportFileSource extends TokenImportSource {
  @override
  TokenMigrateFileProcessor get processor => super.processor as TokenMigrateFileProcessor;

  const TokenImportFileSource({
    required super.appName,
    required super.importHint,
    required TokenMigrateFileProcessor processor,
    super.iconPath,
  }) : super(processor: processor);
}

class TokenImportSourceList {
  static const _importSourceIconFolder = 'assets/images/import_sources/';
  static List<TokenImportSource> appList = [
    TokenImportQrScanSource(
      appName: 'Google Authenticator',
      importHint: (context) => '', // AppLocalizations.of(context)!.importHintGoogleAuthenticator,
      iconPath: '${_importSourceIconFolder}google_authenticator.png',
      processor: const OtpAuthMigrationProcessor(),
    ),
    TokenImportFileSource(
      appName: 'Aegis Authenticator',
      importHint: (context) => '', //  AppLocalizations.of(context)!.importHintAegisAuthenticator,
      iconPath: '${_importSourceIconFolder}aegis_authenticator.png',
      processor: const AegisImportFileProcessor(),
    ),
    TokenImportFileSource(
      appName: '2FAS Authenticator',
      importHint: (context) => '', // AppLocalizations.of(context)!.importHint2FAS,
      iconPath: '${_importSourceIconFolder}2fas.png',
      processor: const TwoFasFileImportProcessor(),
    ),
  ];
}
