import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/tokens/token.dart';
import '../../../../processors/token_migrate_file_processor/two_fas_migrate_file_processor.dart';
import '../../import_tokens_view.dart';
import 'import_decrypted_file_page.dart';

class ImportEncryptedFilePage extends StatefulWidget {
  final Future<List<Token>> Function({required String password}) importFunction;
  final String appName;

  const ImportEncryptedFilePage({super.key, required this.importFunction, required this.appName});

  @override
  State<ImportEncryptedFilePage> createState() => _ImportEncryptedFilePageState();
}

class _ImportEncryptedFilePageState extends State<ImportEncryptedFilePage> {
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool wrongPassword = false;
  Future<void>? future;

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
                            controller: passwordController,
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
                            onPressed: passwordController.text.isEmpty || wrongPassword
                                ? null
                                : () async {
                                    setState(() {
                                      future = Future<void>(
                                        () async {
                                          // Future.delayed(const Duration(seconds: 1)).then((value) => null);
                                          List<Token> tokens;
                                          try {
                                            tokens = await widget.importFunction(password: passwordController.text);
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
                                          _pushAsync(MaterialPageRoute(
                                            builder: (context) => ImportDecryptedFilePage(
                                              importFunction: ({String? password}) => Future(() => tokens),
                                              appName: widget.appName,
                                            ),
                                          ));
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
  void _pushAsync(Route route) async {
    await Navigator.pushReplacement(context, route);
  }
}
