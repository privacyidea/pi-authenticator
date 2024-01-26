import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/riverpod_providers.dart';
import '../widgets/import_token_entrys_list_tile.dart';
import '../widgets/import_tokens_list.dart';

class ImportDecryptedFilePage extends ConsumerStatefulWidget {
  final Future<List<Token>> Function() importFunction;
  final String appName;
  const ImportDecryptedFilePage({super.key, required this.importFunction, required this.appName});

  @override
  ConsumerState<ImportDecryptedFilePage> createState() => _ImportFileNoPwState();
}

class _ImportFileNoPwState extends ConsumerState<ImportDecryptedFilePage> {
  ScrollController scrollController = ScrollController();
  Future<List<ImportTokenEntry>>? initImportTokenEntries;
  List<Token?>? importTokens;
  bool isMaxScrollExtent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initImportTokenEntries = Future(() async {
        final map = ref.read(tokenProvider).tokensWithSameSectet(await widget.importFunction());
        final List<ImportTokenEntry> importTokenEntries = [];
        map.forEach((key, value) {
          importTokenEntries.add(ImportTokenEntry(
            newToken: key,
            oldToken: value,
          ));
        });
        return importTokenEntries;
      });
      initImportTokenEntries!.then((value) => _setImportTokens(value));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.addListener(_updateIsMaxScrollExtent);
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_updateIsMaxScrollExtent);
    scrollController.dispose();
    super.dispose();
  }

  void _popAll() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _updateIsMaxScrollExtent() {
    if (scrollController.position.maxScrollExtent <= scrollController.offset) {
      if (isMaxScrollExtent) return;
      setState(() {
        isMaxScrollExtent = true;
      });
    } else {
      if (!isMaxScrollExtent) return;
      setState(() {
        isMaxScrollExtent = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIsMaxScrollExtent();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appName),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Icon(
                      Icons.file_present,
                      color: Colors.green,
                      size: 100,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder(
                      future: initImportTokenEntries,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting || snapshot.hasData == false) {
                          return const CircularProgressIndicator();
                        }
                        final List<ImportTokenEntry> conflictedImports = [];
                        final List<ImportTokenEntry> newImports = [];
                        final List<ImportTokenEntry> duplicates = [];
                        for (final importTokenEntry in snapshot.data as List<ImportTokenEntry>) {
                          if (importTokenEntry.oldToken == null) {
                            newImports.add(importTokenEntry);
                            continue;
                          }
                          if (importTokenEntry.newToken.sameValuesAs(importTokenEntry.oldToken!)) {
                            duplicates.add(importTokenEntry);
                            continue;
                          }
                          conflictedImports.add(importTokenEntry);
                        }

                        return Column(
                          children: [
                            if (conflictedImports.isNotEmpty)
                              ImportTokensList(
                                title: AppLocalizations.of(context)!.importConflictToken(conflictedImports.length),
                                titlePadding: const EdgeInsets.symmetric(horizontal: 40),
                                leadingDivider: false,
                                importTokenEntries: conflictedImports,
                                selectCallback: (newImportTokenEntrys) => _setImportTokens(newImportTokenEntrys),
                              ),
                            if (newImports.isNotEmpty)
                              ImportTokensList(
                                title: AppLocalizations.of(context)!.importNewToken(newImports.length),
                                titlePadding: const EdgeInsets.symmetric(horizontal: 40),
                                leadingDivider: conflictedImports.isNotEmpty,
                                importTokens: newImports.map((e) => e.newToken).toList(),
                              ),
                            if (duplicates.isNotEmpty)
                              ImportTokensList(
                                title: AppLocalizations.of(context)!.importExistingToken(duplicates.length),
                                titlePadding: const EdgeInsets.symmetric(horizontal: 40),
                                leadingDivider: newImports.isNotEmpty || conflictedImports.isNotEmpty,
                                importTokens: duplicates.map((e) => e.oldToken!).toList(),
                                borderColor: null,
                              ),
                          ],
                        );
                      }),
                ],
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: isMaxScrollExtent ? 0 : 1,
            duration: const Duration(milliseconds: 250),
            child: const Divider(
              thickness: 2,
              indent: 4,
              endIndent: 4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: ElevatedButton(
              onPressed: importTokens == null || importTokens!.contains(null)
                  ? null
                  : () => ref.read(tokenProvider.notifier).addOrReplaceTokens(importTokens!.cast<Token>()).then((_) => _popAll()),
              child: Text(
                importTokens?.isEmpty == false ? AppLocalizations.of(context)!.importTokens : AppLocalizations.of(context)!.ok,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setImportTokens(List<ImportTokenEntry> newImportTokenEntrys) {
    setState(() {
      final newImportTokens = <Token?>[];
      for (final importTokenEntry in newImportTokenEntrys) {
        if (importTokenEntry.oldToken == null) {
          newImportTokens.add(importTokenEntry.newToken);
          continue;
        }
        if (importTokenEntry.newToken.sameValuesAs(importTokenEntry.oldToken!)) continue;
        newImportTokens.add(importTokenEntry.selectedToken?.copyWith(id: importTokenEntry.oldToken!.id));
      }
      importTokens = newImportTokens;
    });
  }
}
