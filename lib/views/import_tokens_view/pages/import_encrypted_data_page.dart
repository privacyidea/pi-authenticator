/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/enums/token_import_type.dart';
import '../../../model/processor_result.dart';
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
  final _passwordFocusNode = FocusNode();
  Future? processingFuture;
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
                            focusNode: _passwordFocusNode,
                            enabled: processingFuture == null,
                            style: Theme.of(context).textTheme.bodyMedium,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.password,
                              labelStyle: Theme.of(context).textTheme.titleSmall,
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
                  processingFuture != null
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _passwordController.text.isEmpty || wrongPassword
                                ? null
                                : () async {
                                    setState(() {
                                      processingFuture = Future<void>(
                                        () async {
                                          try {
                                            final processorResults = await widget.processor.processTokenMigrate(widget.data, args: _passwordController.text);
                                            if (processorResults == null) return;
                                            _pushImportPlainTokensPage(processorResults);
                                          } on BadDecryptionPasswordException catch (_) {
                                            setState(() {
                                              wrongPassword = true;
                                              processingFuture = null;
                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                _passwordFocusNode.requestFocus();
                                              });
                                            });
                                            return;
                                          }
                                        },
                                      )..then((_) => setState(() => processingFuture = null));
                                    });
                                  },
                            child: Text(
                              AppLocalizations.of(context)!.decrypt,
                              style: Theme.of(context).textTheme.headlineSmall,
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

  void _pushImportPlainTokensPage(List<ProcessorResult<Token>> processorResults) async {
    final tokensToImport = await Navigator.of(context).push<List<Token>>(
      MaterialPageRoute(
        builder: (context) => ImportPlainTokensPage(
          titleName: widget.appName,
          processorResults: processorResults,
          selectedType: widget.selectedType,
        ),
      ),
    );
    if (tokensToImport != null) {
      if (!mounted) return;
      Navigator.of(context).pop(tokensToImport);
    }
  }
}
