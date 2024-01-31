import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

enum TokenImportType {
  backupFile,
  qrScan,
  qrFile,
  link,
}

extension TokenImportTypeExtension on TokenImportType {
  String get name => toString().split('.').last;
  IconData get icon => switch (this) {
        const (TokenImportType.backupFile) => Icons.file_present,
        const (TokenImportType.qrScan) => Icons.qr_code_scanner,
        const (TokenImportType.qrFile) => Icons.qr_code_2,
        const (TokenImportType.link) => Icons.link,
      };

  String getButtonText(BuildContext context) => switch (this) {
        const (TokenImportType.backupFile) => AppLocalizations.of(context)!.selectFile,
        const (TokenImportType.qrScan) => AppLocalizations.of(context)!.scanQrCode,
        const (TokenImportType.qrFile) => AppLocalizations.of(context)!.selectFile,
        const (TokenImportType.link) => AppLocalizations.of(context)!.enterLink,
      };

  String getErrorText(BuildContext context, {required String appName}) => switch (this) {
        const (TokenImportType.backupFile) => AppLocalizations.of(context)!.invalidBackupFile(appName),
        const (TokenImportType.qrScan) => AppLocalizations.of(context)!.invalidQrScan(appName),
        const (TokenImportType.qrFile) => AppLocalizations.of(context)!.invalidQrFile(appName),
        const (TokenImportType.link) => AppLocalizations.of(context)!.invalidLink(appName),
      };
}
