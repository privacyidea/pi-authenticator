import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/no_conflict_import_tokens_list.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/enums/token_import_type.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/riverpod_providers.dart';
import '../import_tokens_view.dart';
import '../widgets/conflicted_import_tokens_tile.dart';
import '../widgets/conflicted_import_tokens_list.dart';

class ImportPlainTokensPage extends ConsumerStatefulWidget {
  final String appName;
  final TokenImportType selectedType;
  final List<Token> importedTokens;
  const ImportPlainTokensPage({super.key, required this.importedTokens, required this.appName, required this.selectedType});

  @override
  ConsumerState<ImportPlainTokensPage> createState() => _ImportFileNoPwState();
}

class _ImportFileNoPwState extends ConsumerState<ImportPlainTokensPage> {
  ScrollController scrollController = ScrollController();
  List<Token?>? tokensToKeep;
  List<ImportTokenEntry> importTokenEntrys = [];
  bool isMaxScrollExtent = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final map = ref.read(tokenProvider).tokensWithSameSectet(widget.importedTokens);
      importTokenEntrys = [];
      setState(() {
        map.forEach((key, value) {
          importTokenEntrys.add(ImportTokenEntry(newToken: key, oldToken: value));
        });
      });
      _setTokensToKeep(importTokenEntrys);
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

    final List<ImportTokenEntry> conflictedImports = [];
    final List<ImportTokenEntry> newImports = [];
    final List<ImportTokenEntry> duplicateImport = [];
    for (final importTokenEntry in importTokenEntrys) {
      if (importTokenEntry.oldToken == null) {
        newImports.add(importTokenEntry);
        continue;
      }
      if (importTokenEntry.newToken.sameValuesAs(importTokenEntry.oldToken!)) {
        duplicateImport.add(importTokenEntry);
        continue;
      }
      conflictedImports.add(importTokenEntry);
    }

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
                      if (conflictedImports.isNotEmpty)
                        ConflictedImportTokensList(
                          title: AppLocalizations.of(context)!.importConflictToken(conflictedImports.length),
                          titlePadding: const EdgeInsets.symmetric(horizontal: 40),
                          leadingDivider: false,
                          importEntries: conflictedImports,
                          updateImportTokenEntry: _updateImportTokenEntry,
                        ),
                      if (newImports.isNotEmpty)
                        NoConflictImportTokensList(
                          title: AppLocalizations.of(context)!.importNewToken(newImports.length),
                          titlePadding: const EdgeInsets.symmetric(horizontal: 40),
                          leadingDivider: conflictedImports.isNotEmpty,
                          importTokens: newImports.map((e) => e.newToken).toList(),
                        ),
                      if (duplicateImport.isNotEmpty)
                        NoConflictImportTokensList(
                          title: AppLocalizations.of(context)!.importExistingToken(duplicateImport.length),
                          titlePadding: const EdgeInsets.symmetric(horizontal: 40),
                          leadingDivider: newImports.isNotEmpty || conflictedImports.isNotEmpty,
                          importTokens: duplicateImport.map((e) => e.oldToken!).toList(),
                          borderColor: null,
                        ),
                    ],
                  ),
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
                    : () => ref.read(tokenProvider.notifier).addOrReplaceTokens(tokensToKeep!.cast<Token>()).then((_) => _popAll()),
                child: Text(
                  tokensToKeep?.isEmpty == false ? AppLocalizations.of(context)!.importTokens : AppLocalizations.of(context)!.ok,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
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

  void _updateImportTokenEntry(ImportTokenEntry oldEntry, ImportTokenEntry newEntry) {
    setState(() {
      importTokenEntrys[importTokenEntrys.indexOf(oldEntry)] = newEntry;
    });
    _setTokensToKeep(importTokenEntrys);
  }

  void _setTokensToKeep(List<ImportTokenEntry> tokens) {
    setState(() {
      tokensToKeep = [];
      for (final importTokenEntry in importTokenEntrys) {
        if (importTokenEntry.oldToken == null) {
          tokensToKeep!.add(importTokenEntry.newToken);
          continue;
        }
        if (importTokenEntry.newToken.sameValuesAs(importTokenEntry.oldToken!)) continue;
        tokensToKeep!.add(importTokenEntry.selectedToken?.copyWith(id: importTokenEntry.oldToken!.id));
      }
    });
  }
}
