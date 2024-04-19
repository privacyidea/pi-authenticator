import '../mains/main_netknights.dart';
import '../model/enums/token_import_type.dart';
import '../model/token_import/token_import_origin.dart';
import '../model/token_import/token_import_source.dart';
import '../processors/scheme_processors/token_import_scheme_processors/free_otp_plus_qr_processor.dart';
import '../processors/scheme_processors/token_import_scheme_processors/google_authenticator_qr_processor.dart';
import '../processors/scheme_processors/token_import_scheme_processors/otp_auth_processor.dart';
import '../processors/scheme_processors/token_import_scheme_processors/privacyidea_authenticator_qr_processor.dart';
import '../processors/token_import_file_processor/aegis_import_file_processor.dart';
import '../processors/token_import_file_processor/authenticator_pro_import_file_processor.dart';
import '../processors/token_import_file_processor/free_otp_plus_import_file_processor.dart';
import '../processors/token_import_file_processor/privacyidea_authenticator_import_file_processor.dart';
import '../processors/token_import_file_processor/two_fas_import_file_processor.dart';

class TokenImportOrigins {
  static final List<TokenImportOrigin> appList = [
    privacyIDEAAuthenticator,
    googleAuthenticator,
    aegisAuthenticator,
    twoFasAuthenticator,
    authenticatorPro,
    freeOtpPlus,
  ];

  static const _importSourceIconFolder = 'assets/images/import_sources/';

  static final privacyIDEAAuthenticator = TokenImportOrigin(
    appName: PrivacyIDEAAuthenticator.currentCustomization?.appName ?? 'privacyIDEA Authenticator',
    iconPath: '${_importSourceIconFolder}privacyidea_authenticator.png',
    importSources: [
      TokenImportSource(
        processor: const PrivacyIDEAAuthenticatorQrProcessor(),
        type: TokenImportType.qrScan,
        importHint: (localizations) => 'localizations.importHintPrivacyIDEAQrScan',
      ),
      TokenImportSource(
          processor: const PrivacyIDEAAuthenticatorImportFileProcessor(),
          type: TokenImportType.backupFile,
          importHint: (localizations) => 'localizations.importHintPrivacyIDEAFile'),
    ],
  );

  static final googleAuthenticator = TokenImportOrigin(
    appName: 'Google Authenticator',
    iconPath: '${_importSourceIconFolder}google_authenticator.png',
    importSources: [
      TokenImportSource(
        processor: const GoogleAuthenticatorQrProcessor(),
        type: TokenImportType.qrScan,
        importHint: (localizations) => localizations.importHintGoogleQrScan,
      ),
      TokenImportSource(
        processor: const GoogleAuthenticatorQrProcessor(),
        type: TokenImportType.qrFile,
        importHint: (localizations) => localizations.importHintGoogleQrFile,
      ),
    ],
  );
  static final aegisAuthenticator = TokenImportOrigin(
    appName: 'Aegis Authenticator',
    iconPath: '${_importSourceIconFolder}aegis_authenticator.png',
    importSources: [
      TokenImportSource(
        processor: const AegisImportFileProcessor(),
        type: TokenImportType.backupFile,
        importHint: (localizations) => localizations.importHintAegisBackupFile,
      ),
      TokenImportSource(
        processor: const OtpAuthProcessor(),
        type: TokenImportType.qrScan,
        importHint: (localizations) => localizations.importHintAegisQrScan,
      ),
      TokenImportSource(
        processor: const OtpAuthProcessor(),
        type: TokenImportType.link,
        importHint: (localizations) => localizations.importHintAegisLink,
      ),
    ],
  );
  static final twoFasAuthenticator = TokenImportOrigin(
    appName: '2FAS Authenticator',
    iconPath: '${_importSourceIconFolder}2fas.png',
    importSources: [
      TokenImportSource(
        processor: const TwoFasAuthenticatorImportFileProcessor(),
        type: TokenImportType.backupFile,
        importHint: (localizations) => localizations.importHint2FAS,
      ),
    ],
  );
  static final authenticatorPro = TokenImportOrigin(
    appName: 'Authenticator Pro',
    iconPath: '${_importSourceIconFolder}authenticator_pro.png',
    importSources: [
      TokenImportSource(
        processor: const AuthenticatorProImportFileProcessor(),
        type: TokenImportType.backupFile,
        importHint: (localizations) => localizations.importHintAuthenticatorProFile,
      ),
    ],
  );
  static final freeOtpPlus = TokenImportOrigin(
    appName: 'FreeOTP+',
    iconPath: '${_importSourceIconFolder}freeotp_plus.png',
    importSources: [
      TokenImportSource(
        processor: const FreeOtpPlusQrProcessor(),
        type: TokenImportType.qrScan,
        importHint: (localizations) => localizations.importHintFreeOtpPlusQrScan,
      ),
      TokenImportSource(
        processor: const FreeOtpPlusImportFileProcessor(),
        type: TokenImportType.backupFile,
        importHint: (localizations) => localizations.importHintFreeOtpPlusFile,
      ),
    ],
  );
}
