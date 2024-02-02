import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../processors/mixins/token_import_processor.dart';
import '../processors/scheme_processors/token_import_scheme_processors/otp_auth_migration_processor.dart';
import '../processors/scheme_processors/token_import_scheme_processors/otp_auth_processor.dart';
import '../processors/token_import_file_processor/aegis_import_file_processor.dart';
import '../processors/token_import_file_processor/two_fas_import_file_processor.dart';
import 'enums/token_import_type.dart';

class TokenImportOrigin {
  final String appName;
  final String? iconPath;
  final List<TokenImportEntity> importEntitys;

  const TokenImportOrigin({
    required this.appName,
    required this.importEntitys,
    this.iconPath,
  });
}

class TokenImportEntity {
  final TokenImportType type;
  final TokenImportProcessor processor;
  final String Function(BuildContext context) importHint;

  const TokenImportEntity({required this.processor, required this.type, required this.importHint});
}

class TokenImportSourceList {
  static const _importSourceIconFolder = 'assets/images/import_sources/';
  static List<TokenImportOrigin> appList = [
    TokenImportOrigin(
      appName: 'Google Authenticator',
      iconPath: '${_importSourceIconFolder}google_authenticator.png',
      importEntitys: [
        TokenImportEntity(
          processor: const OtpAuthMigrationProcessor(),
          type: TokenImportType.qrScan,
          importHint: (context) => AppLocalizations.of(context)!.importHintGoogleQrScan,
        ),
        TokenImportEntity(
          processor: const OtpAuthMigrationProcessor(),
          type: TokenImportType.qrFile,
          importHint: (context) => AppLocalizations.of(context)!.importHintGoogleQrFile,
        ),
      ],
    ),
    TokenImportOrigin(
      appName: 'Aegis Authenticator',
      iconPath: '${_importSourceIconFolder}aegis_authenticator.png',
      importEntitys: [
        TokenImportEntity(
          processor: const AegisImportFileProcessor(),
          type: TokenImportType.backupFile,
          importHint: (context) => AppLocalizations.of(context)!.importHintAegisBackupFile,
        ),
        TokenImportEntity(
          processor: const OtpAuthProcessor(),
          type: TokenImportType.qrScan,
          importHint: (context) => AppLocalizations.of(context)!.importHintAegisQrScan,
        ),
        TokenImportEntity(
          processor: const OtpAuthProcessor(),
          type: TokenImportType.link,
          importHint: (context) => AppLocalizations.of(context)!.importHintAegisLink,
        ),
      ],
    ),
    TokenImportOrigin(
      appName: '2FAS Authenticator',
      iconPath: '${_importSourceIconFolder}2fas.png',
      importEntitys: [
        TokenImportEntity(
            processor: const TwoFasFileImportProcessor(),
            type: TokenImportType.backupFile,
            importHint: (context) => AppLocalizations.of(context)!.importHint2FAS),
      ],
    ),
  ];
}
