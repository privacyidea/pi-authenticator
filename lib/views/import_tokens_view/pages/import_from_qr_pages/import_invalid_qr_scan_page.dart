// import 'package:flutter/material.dart';

// import '../../../../l10n/app_localizations.dart';
// import '../../../../model/token_import_source.dart';
// import '../../../../processors/scheme_processors/token_import_scheme_processors/toke_import_scheme_processor_interface.dart';
// import '../../import_tokens_view.dart';

// class ImportInvalidQrScanPage extends StatelessWidget {
//   final String appName;
//   final TokenImportSchemeProcessor selectedSource;
//   final void Function(BuildContext? Function(), TokenImportSchemeProcessor) qrScan;

//   const ImportInvalidQrScanPage({super.key, required this.selectedSource, required this.qrScan});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(selectedSource.appName),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: ImportTokensView.pagePaddingHorizontal),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.qr_code,
//                   color: Theme.of(context).colorScheme.error,
//                   size: ImportTokensView.iconSize,
//                 ),
//                 const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
//                 Text(
//                   AppLocalizations.of(context)!.scanNoValidBackupFrom(selectedSource.appName),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
//                 ElevatedButton(
//                   onPressed: () => qrScan(() => context, selectedSource),
//                   child: Text(AppLocalizations.of(context)!.selectFile),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
