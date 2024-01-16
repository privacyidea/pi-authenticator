import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/tokens/token.dart';
import '../../../processors/token_import_processor/two_fas_import_file_processor.dart';
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.appName),
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.file_present,
                    size: 100,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.fileIsEncrypted,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 80,
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
                        const SizedBox(width: 10),
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: passwordController.text.isEmpty || wrongPassword
                        ? null
                        : () async {
                            try {
                              final tokens = await widget.importFunction(password: passwordController.text);
                              _pushAsync(MaterialPageRoute(
                                builder: (context) => ImportDecryptedFilePage(
                                  importFunction: ({String? password}) => Future.value(tokens),
                                  appName: widget.appName,
                                ),
                              ));
                            } on WrongDecryptionPasswordException catch (_) {
                              setState(() {
                                wrongPassword = true;
                              });
                            }
                          },
                    child: Text(AppLocalizations.of(context)!.decrypt),
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
