import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../enums/token_import_type.dart';

extension TokenImportTypeExtension on TokenImportType {
  IconData get icon => switch (this) {
        const (TokenImportType.backupFile) => Icons.file_present,
        const (TokenImportType.qrScan) => Icons.qr_code_scanner,
        const (TokenImportType.qrFile) => Icons.qr_code_2,
        const (TokenImportType.link) => Icons.link,
      };

  String buttonText(AppLocalizations localizations) => switch (this) {
        const (TokenImportType.backupFile) => localizations.selectFile,
        const (TokenImportType.qrScan) => localizations.scanQrCode,
        const (TokenImportType.qrFile) => localizations.selectFile,
        const (TokenImportType.link) => localizations.enterLink,
      };
}
