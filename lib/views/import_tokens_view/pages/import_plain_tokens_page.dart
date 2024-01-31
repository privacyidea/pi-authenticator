import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/enums/token_import_type.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/tokens/token.dart';
import '../../../utils/riverpod_providers.dart';
import '../import_tokens_view.dart';
import '../widgets/import_token_entrys_list_tile.dart';
import '../widgets/import_tokens_list.dart';

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
  bool isMaxScrollExtent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final map = ref.read(tokenProvider).tokensWithSameSectet(widget.importedTokens);
      final List<ImportTokenEntry> importTokenEntries = [];
      map.forEach((key, value) {
        importTokenEntries.add(ImportTokenEntry(newToken: key, oldToken: value));
      });
      _setImportTokens(importTokenEntries);
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
    final List<ImportTokenEntry> duplicates = [];
    for (final importTokenEntry in importTokenEntrys) {
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

  void _setImportTokens(List<ImportTokenEntry> newImportTokenEntrys) {
    setState(() {
      importTokenEntrys = newImportTokenEntrys;
      final newImportTokens = <Token?>[];
      for (final importTokenEntry in newImportTokenEntrys) {
        if (importTokenEntry.oldToken == null) {
          newImportTokens.add(importTokenEntry.newToken);
          continue;
        }
        if (importTokenEntry.newToken.sameValuesAs(importTokenEntry.oldToken!)) continue;
        newImportTokens.add(importTokenEntry.selectedToken?.copyWith(id: importTokenEntry.oldToken!.id));
      }
      tokensToKeep = newImportTokens;
    });
  }
}
