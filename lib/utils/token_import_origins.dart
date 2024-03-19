import '../l10n/app_localizations.dart';
import '../model/enums/token_import_type.dart';
import '../model/token_import/token_import_origin.dart';
import '../processors/scheme_processors/token_import_scheme_processors/free_otp_plus_qr_processor.dart';
import '../processors/scheme_processors/token_import_scheme_processors/otp_auth_migration_processor.dart';
import '../processors/scheme_processors/token_import_scheme_processors/otp_auth_processor.dart';
import '../processors/token_import_file_processor/aegis_import_file_processor.dart';
import '../processors/token_import_file_processor/authenticator_pro_import_file_processor.dart';
import '../processors/token_import_file_processor/free_otp_plus_file_processor.dart';
import '../processors/token_import_file_processor/two_fas_import_file_processor.dart';

class TokenImportOrigins {
  static const _importSourceIconFolder = 'assets/images/import_sources/';
  static List<TokenImportOrigin> appList = [
    TokenImportOrigin(
      appName: 'Google Authenticator',
      iconPath: '${_importSourceIconFolder}google_authenticator.png',
      importSources: [
        TokenImportSource(
          processor: const OtpAuthMigrationProcessor(),
          type: TokenImportType.qrScan,
          importHint: (context) => AppLocalizations.of(context)!.importHintGoogleQrScan,
        ),
        TokenImportSource(
          processor: const OtpAuthMigrationProcessor(),
          type: TokenImportType.qrFile,
          importHint: (context) => AppLocalizations.of(context)!.importHintGoogleQrFile,
        ),
      ],
    ),
    TokenImportOrigin(
      appName: 'Aegis Authenticator',
      iconPath: '${_importSourceIconFolder}aegis_authenticator.png',
      importSources: [
        TokenImportSource(
          processor: const AegisImportFileProcessor(),
          type: TokenImportType.backupFile,
          importHint: (context) => AppLocalizations.of(context)!.importHintAegisBackupFile,
        ),
        TokenImportSource(
          processor: const OtpAuthProcessor(),
          type: TokenImportType.qrScan,
          importHint: (context) => AppLocalizations.of(context)!.importHintAegisQrScan,
        ),
        TokenImportSource(
          processor: const OtpAuthProcessor(),
          type: TokenImportType.link,
          importHint: (context) => AppLocalizations.of(context)!.importHintAegisLink,
        ),
      ],
    ),
    TokenImportOrigin(
      appName: '2FAS Authenticator',
      iconPath: '${_importSourceIconFolder}2fas.png',
      importSources: [
        TokenImportSource(
            processor: const TwoFasFileImportProcessor(),
            type: TokenImportType.backupFile,
            importHint: (context) => AppLocalizations.of(context)!.importHint2FAS),
      ],
    ),
    TokenImportOrigin(
      appName: 'Authenticator Pro',
      importSources: [
        TokenImportSource(
          processor: const AuthenticatorProImportFileProcessor(),
          type: TokenImportType.backupFile,
          importHint: (context) => AppLocalizations.of(context)!.importHintAuthenticatorProFile,
        ),
      ],
    ),
    TokenImportOrigin(appName: 'Free OTP+', importSources: [
      TokenImportSource(
          processor: const FreeOtpPlusQrProcessor(),
          type: TokenImportType.qrScan,
          importHint: (context) => 'Test' // AppLocalizations.of(context)!.importHintFreeOtpPlusQrScan,
          ),
      TokenImportSource(
          processor: const FreeOtpPlusFileProcessor(),
          type: TokenImportType.backupFile,
          importHint: (context) => 'Test' // AppLocalizations.of(context)!.importHintFreeOtpPlusFile,
          ),
    ]),
  ];
}
