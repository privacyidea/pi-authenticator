import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../processors/token_import_processor/two_fas_import_file_processor.dart';

import '../../l10n/app_localizations.dart';
import '../../model/token_import_source.dart';

import 'pages/import_select_file_page.dart';

class ImportTokensView extends ConsumerStatefulWidget {
  static const routeName = '/import_tokens';
  static const _importSourceIconFolder = 'assets/images/import_sources/';
  static List<TokenImportSource> appList = [
    TokenImportSource(
      appName: 'Google Authenticator',
      importHint: (context) => '', // AppLocalizations.of(context)!.importHintGoogleAuthenticator,
      iconPath: '${_importSourceIconFolder}google_authenticator.png',
      processor: null,
    ),
    TokenImportSource(
      appName: 'Authy',
      importHint: (context) => '', //  AppLocalizations.of(context)!.importHintAuthy,
      iconPath: '${_importSourceIconFolder}authy.png',
      processor: null,
    ),
    TokenImportSource(
      appName: 'FreeOTP',
      importHint: (context) => '', //  AppLocalizations.of(context)!.importHintFreeOTP,
      iconPath: '${_importSourceIconFolder}freeotp.png',
      processor: null,
    ),
    TokenImportSource(
      appName: 'LastPass Authenticator',
      importHint: (context) => '', //  AppLocalizations.of(context)!.importHintLastPassAuthenticator,
      iconPath: '${_importSourceIconFolder}lastpass_authenticator.png',
      processor: null,
    ),
    TokenImportSource(
      appName: 'OTP Auth',
      importHint: (context) => '', //  AppLocalizations.of(context)!.importHintOTPAuth,
      iconPath: '${_importSourceIconFolder}otp_auth.png',
      processor: null,
    ),
    TokenImportSource(
      appName: '2FAS Authenticator',
      importHint: (context) => AppLocalizations.of(context)!.importHint2FAS,
      iconPath: '${_importSourceIconFolder}2fas.png',
      processor: const TwoFasImportFileProcessor(),
    ),
  ];

  final TokenImportSource? selectedSource;
  const ImportTokensView({this.selectedSource, super.key});

  @override
  ConsumerState<ImportTokensView> createState() => _ImportTokensViewState();
}

class _ImportTokensViewState extends ConsumerState<ImportTokensView> {
  String? fileContent;
  TextEditingController? passwordController;
  bool fileContentIsValid = false;
  bool wrongPassword = false;
  bool passwordIsNeeded = false;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController(text: '');
  }

  void onPressed(TokenImportSource tokenImportSource) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImportSelectFilePage(selectedSource: tokenImportSource),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectImportSource),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (final item in ImportTokensView.appList)
                ListTile(
                  // leading: Image.asset(appList[index].iconPath!),
                  title: TextButton(
                    onPressed: () => onPressed(item),
                    child: Text(item.appName),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () => onPressed(item),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
