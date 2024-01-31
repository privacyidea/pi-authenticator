import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/enums/token_import_type.dart';
import '../../../model/tokens/token.dart';
import '../../../processors/mixins/token_import_processor.dart';
import '../../../processors/token_import_file_processor/two_fas_import_file_processor.dart';
import '../import_tokens_view.dart';
import 'import_plain_tokens_page.dart';

class ImportEncryptedDataPage<T, V extends String?> extends StatefulWidget {
  final String appName;
  final T data;
  final TokenImportType selectedType;
  final TokenImportProcessor<T, V> processor;

  const ImportEncryptedDataPage({
    super.key,
    required this.appName,
    required this.data,
    required this.selectedType,
    required this.processor,
  });

  @override
  // ignore: no_logic_in_create_state
  State<ImportEncryptedDataPage> createState() => _ImportEncryptedDataPageState();
}

class _ImportEncryptedDataPageState extends State<ImportEncryptedDataPage> {
  final _passwordController = TextEditingController();
  Future? future;
  bool isPasswordVisible = false;
  bool wrongPassword = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.appName),
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ImportTokensView.pagePaddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.file_present,
                    size: ImportTokensView.iconSize,
                  ),
                  const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                  Text(
                    AppLocalizations.of(context)!.tokensAreEncrypted,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ImportTokensView.itemSpacingHorizontal * 4,
                    child: Row(
                      children: [
                        Flexible(
                          flex: 9,
                          child: TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.password,
                              errorText: wrongPassword ? AppLocalizations.of(context)!.wrongPassword : null,
                            ),
                            onChanged: (value) => setState(() {
                              wrongPassword = false;
                            }),
                            obscureText: !isPasswordVisible,
                          ),
                        ),
                        const SizedBox(width: ImportTokensView.itemSpacingVertical),
                        Flexible(
                          child: GestureDetector(
                            child: const SizedBox(
                              height: 200,
                              width: 200,
                              child: Center(
                                child: Icon(
                                  Icons.visibility,
                                  size: 36,
                                ),
                              ),
                            ),
                            onPanDown: (_) => setState(() => isPasswordVisible = true),
                            onPanStart: (_) => setState(() => isPasswordVisible = true),
                            onPanCancel: () => setState(() => isPasswordVisible = false),
                            onPanEnd: (_) => setState(() => isPasswordVisible = false),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                  future != null
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _passwordController.text.isEmpty || wrongPassword
                                ? null
                                : () async {
                                    setState(() {
                                      future = Future<void>(
                                        () async {
                                          // Future.delayed(const Duration(seconds: 1)).then((value) => null);
                                          List<Token> tokens;
                                          try {
                                            tokens = await widget.processor.processTokenMigrate(widget.data, args: _passwordController.text);
                                          } on BadDecryptionPasswordException catch (_) {
                                            setState(() {
                                              wrongPassword = true;
                                              future = null;
                                            });
                                            return;
                                          }
                                          setState(() {
                                            future = null;
                                          });
                                          _pushImportPlainTokensPage(tokens);
                                        },
                                      );
                                    });
                                  },
                            child: Text(
                              AppLocalizations.of(context)!.decrypt,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      );

  void _pushImportPlainTokensPage(List<Token> tokens) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ImportPlainTokensPage(
          appName: widget.appName,
          importedTokens: tokens,
          selectedType: widget.selectedType,
        ),
      ),
    );
  }
}
