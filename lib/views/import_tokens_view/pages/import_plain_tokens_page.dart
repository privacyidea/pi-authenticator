/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/enums/token_import_type.dart';
import '../../../model/extensions/enums/token_import_type_extension.dart';
import '../../../model/processor_result.dart';
import '../../../model/token_import/token_import_entry.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../import_tokens_view.dart';
import '../widgets/conflicted_import_tokens_list.dart';
import '../widgets/failed_imports_list.dart';
import '../widgets/no_conflict_import_tokens_list.dart';

class ImportPlainTokensPage extends ConsumerStatefulWidget {
  final String titleName;
  final TokenImportType selectedType;
  // final int numOfDuplicates;
  final List<Token> importedTokens;
  final List<String> failedImports;
  factory ImportPlainTokensPage({
    Key? key,
    required List<ProcessorResult<Token>> processorResults,
    required String titleName,
    required TokenImportType selectedType,
  }) {
    final importedTokens = processorResults.whereType<ProcessorResultSuccess<Token>>().map((e) => e.resultData).toList();
    final failedImports = processorResults.whereType<ProcessorResultFailed>().map((e) => e.message).toList();
    return ImportPlainTokensPage._(
      key: key,
      importedTokens: importedTokens,
      failedImports: failedImports,
      titleName: titleName,
      selectedType: selectedType,
      // numOfDuplicates: duplicates.length,
    );
  }
  const ImportPlainTokensPage._({
    super.key,
    // this.numOfDuplicates = 0,
    required this.importedTokens,
    required this.failedImports,
    required this.titleName,
    required this.selectedType,
  });

  @override
  ConsumerState<ImportPlainTokensPage> createState() => _ImportFileNoPwState();
}

class _ImportFileNoPwState extends ConsumerState<ImportPlainTokensPage> {
  ScrollController scrollController = ScrollController();
  List<Token?>? tokensToKeep;
  bool isMaxScrollOffset = true;

  List<TokenImportEntry> importTokenEntrys = [];
  final List<TokenImportEntry> conflictedImports = [];
  final List<TokenImportEntry> newImports = [];
  final List<TokenImportEntry> appDuplicates = [];
  final List<TokenImportEntry> importDuplicates = [];

  List<TokenImportEntry> _initBuildLists(List<TokenImportEntry> importTokenEntrys) {
    for (var i = 0; i < importTokenEntrys.length; i++) {
      final importTokenEntry = importTokenEntrys[i];
      if ([...newImports, ...appDuplicates, ...conflictedImports].any((import) => import.newToken.isSameTokenAs(importTokenEntry.newToken))) {
        importDuplicates.add(importTokenEntry);
        importTokenEntrys.remove(importTokenEntry);
        i--;
        continue;
      }
      if (importTokenEntry.oldToken == null) {
        newImports.add(importTokenEntry);
        continue;
      }
      if (importTokenEntry.newToken.sameValuesAs(importTokenEntry.oldToken!)) {
        appDuplicates.add(importTokenEntry);
        continue;
      }
      conflictedImports.add(importTokenEntry);
    }
    return importTokenEntrys;
  }

  void _renewLists(List<TokenImportEntry> importTokenEntrys) {
    newImports.clear();
    appDuplicates.clear();
    conflictedImports.clear();
    for (final importTokenEntry in importTokenEntrys) {
      if (importTokenEntry.oldToken == null) {
        newImports.add(importTokenEntry);
        continue;
      }
      if (importTokenEntry.newToken.sameValuesAs(importTokenEntry.oldToken!)) {
        appDuplicates.add(importTokenEntry);
        continue;
      }
      conflictedImports.add(importTokenEntry);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final map = ref.read(tokenProvider).getSameTokens(widget.importedTokens);
      importTokenEntrys = [];
      setState(() {
        map.forEach((key, value) {
          importTokenEntrys.add(TokenImportEntry(newToken: key, oldToken: value));
        });
        importTokenEntrys = _initBuildLists(importTokenEntrys);
        _setTokensToKeep(importTokenEntrys);
      });
    });
    scrollController.addListener(_updateIsMaxScrollExtent);
    _updateIsMaxScrollExtent();
  }

  @override
  void dispose() {
    scrollController.removeListener(_updateIsMaxScrollExtent);
    scrollController.dispose();
    super.dispose();
  }

  void _updateIsMaxScrollExtent() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      if (scrollController.position.maxScrollExtent <= scrollController.offset) {
        if (isMaxScrollOffset || !mounted) return;
        setState(() {
          isMaxScrollOffset = true;
        });
      } else {
        if (!isMaxScrollOffset || !mounted) return;
        setState(() {
          isMaxScrollOffset = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateIsMaxScrollExtent();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titleName),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: ImportTokensView.pagePaddingHorizontal),
                    child: Icon(
                      widget.selectedType.icon,
                      color: Colors.green,
                      size: ImportTokensView.iconSize,
                    ),
                  ),
                  const SizedBox(height: ImportTokensView.itemSpacingHorizontal),
                  Column(
                    children: [
                      if (widget.failedImports.isNotEmpty)
                        FailedImportsList(
                          failedImports: widget.failedImports,
                        ),
                      if (conflictedImports.isNotEmpty)
                        ConflictedImportTokensList(
                          title: AppLocalizations.of(context)!.importConflictToken(conflictedImports.length),
                          titlePadding: const EdgeInsets.symmetric(horizontal: 40),
                          leadingDivider: widget.failedImports.isNotEmpty,
                          importEntries: conflictedImports,
                          onTap: _updateImportTokenEntry,
                        ),
                      if (newImports.isNotEmpty)
                        NoConflictImportTokensList(
                          title: AppLocalizations.of(context)!.importNewToken(newImports.length),
                          titlePadding: const EdgeInsets.symmetric(horizontal: 40),
                          leadingDivider: conflictedImports.isNotEmpty,
                          importEntries: newImports,
                          onTap: _updateImportTokenEntry,
                        ),
                      if (appDuplicates.isNotEmpty)
                        NoConflictImportTokensList(
                          title: AppLocalizations.of(context)!.importExistingToken(appDuplicates.length),
                          titlePadding: const EdgeInsets.symmetric(horizontal: 40),
                          leadingDivider: newImports.isNotEmpty || conflictedImports.isNotEmpty,
                          importEntries: appDuplicates,
                          // borderColor: null,
                        ),
                      if (importDuplicates.isNotEmpty)
                        NoConflictImportTokensList(
                          title: 'The contained duplicates (${importDuplicates.length}) will be ignored.',
                          //  AppLocalizations.of(context)!.importDuplicateToken(importDuplicates.length),''
                          titlePadding: const EdgeInsets.symmetric(horizontal: 40),
                          leadingDivider: newImports.isNotEmpty || conflictedImports.isNotEmpty || appDuplicates.isNotEmpty,
                          importEntries: importDuplicates,
                          borderColor: null,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: isMaxScrollOffset ? 0 : 1,
            duration: const Duration(milliseconds: 250),
            child: const Divider(
              thickness: 2,
              indent: 4,
              endIndent: 4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ImportTokensView.pagePaddingHorizontal,
              0,
              ImportTokensView.pagePaddingHorizontal,
              8,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: tokensToKeep == null || tokensToKeep!.contains(null)
                    ? null
                    : () => Navigator.of(context).pop<List<Token>>(tokensToKeep!.whereType<Token>().toList()),
                child: Text(
                  tokensToKeep != null ? AppLocalizations.of(context)!.importNTokens(tokensToKeep!.length) : AppLocalizations.of(context)!.ok,
                  style: Theme.of(context).textTheme.headlineSmall,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateImportTokenEntry(TokenImportEntry oldEntry, TokenImportEntry newEntry) {
    setState(() {
      importTokenEntrys[importTokenEntrys.indexOf(oldEntry)] = newEntry;
      _renewLists(importTokenEntrys);
      _setTokensToKeep(importTokenEntrys);
    });
  }

  void _setTokensToKeep(List<TokenImportEntry> tokens) {
    tokensToKeep = [];
    for (final importTokenEntry in importTokenEntrys) {
      if (importTokenEntry.oldToken != null) {
        if (importTokenEntry.newToken.sameValuesAs(importTokenEntry.oldToken!)) continue;
        tokensToKeep!.add(importTokenEntry.selectedToken?.copyWith(id: importTokenEntry.oldToken?.id));
      } else {
        if (importTokenEntry.selectedToken != null) tokensToKeep!.add(importTokenEntry.selectedToken);
      }
    }
  }
}
