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
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';

import '../../model/enums/introduction.dart';
import '../../model/mixins/sortable_mixin.dart';
import '../../model/token_folder.dart';
import '../../model/tokens/otp_token.dart';
import '../../utils/default_inkwell.dart';
import '../../utils/home_widget_utils.dart';
import '../../utils/lock_auth.dart';
import '../../utils/logger.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../widgets/custom_trailing.dart';
import '../main_view/main_view_widgets/drag_target_divider.dart';
import '../main_view/main_view_widgets/folder_widgets/token_folder_expandable_widgets/token_folder_expandable_header_icon.dart';
import '../main_view/main_view_widgets/token_widgets/token_widget_builder.dart';
import '../view_interface.dart';

class LinkHomeWidgetView extends ConsumerStatefulView {
  @override
  RouteSettings get routeSettings => const RouteSettings(name: routeName);

  static const routeName = '/link_home_widget';

  final String homeWidgetId;

  const LinkHomeWidgetView({super.key, required this.homeWidgetId});

  @override
  ConsumerState<LinkHomeWidgetView> createState() => _LinkHomeWidgetViewState();
}

class _LinkHomeWidgetViewState extends ConsumerState<LinkHomeWidgetView> {
  bool alreadyTapped = false;

  /// Kept on this page only, the folders of the main list stay as they are.
  late final Set<int> _expandedFolderIds;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _expandedFolderIds = {
      for (final folder in ref.read(tokenFolderProvider).folders)
        if (folder.isExpanded && !folder.isLocked) folder.folderId,
    };
    _lifecycleListener = AppLifecycleListener(onHide: _collapseLockedFolders);
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _collapseLockedFolders() {
    final lockedIds = ref
        .read(tokenFolderProvider)
        .folders
        .where((folder) => folder.isLocked)
        .map((folder) => folder.folderId);
    setState(() => _expandedFolderIds.removeAll(lockedIds));
  }

  Future<void> _toggleFolder(TokenFolder folder) async {
    if (_expandedFolderIds.contains(folder.folderId)) {
      setState(() => _expandedFolderIds.remove(folder.folderId));
      return;
    }
    if (folder.isLocked &&
        !await lockAuthWithSettings(
          ref: ref,
          reason: (localization) => localization.expandLockedFolder,
          localization: AppLocalizations.of(context)!,
        )) {
      return;
    }
    if (!mounted) return;
    setState(() => _expandedFolderIds.add(folder.folderId));
  }

  Future<void> _link(OTPToken otpToken) async {
    if (alreadyTapped) return;
    setState(() => alreadyTapped = true);
    try {
      await HomeWidgetUtils().link(widget.homeWidgetId, otpToken.id);
      await ref
          .read(introductionNotifierProvider.notifier)
          .complete(Introduction.homeWidgetSetUp);
    } catch (e, s) {
      if (mounted) setState(() => alreadyTapped = false);
      Logger.error('Linking the home widget failed', error: e, stackTrace: s);
      return;
    }
    await SystemNavigator.pop();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final otpTokens = ref.watch(tokenProvider).value?.otpTokens ?? [];
    final folders = ref.watch(tokenFolderProvider).folders;
    final folderTokens = {
      for (final folder in folders)
        folder.folderId:
            otpTokens.where((t) => t.folderId == folder.folderId).toList()
              ..sort((a, b) => a.compareTo(b)),
    };
    final sortables = <SortableMixin>[
      for (final folder in folders)
        if (folderTokens[folder.folderId]!.isNotEmpty) folder,
      for (final token in otpTokens)
        if (!folderTokens.containsKey(token.folderId)) token,
    ]..sort((a, b) => a.compareTo(b));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.linkHomeWidgetViewTitle,
          overflow: TextOverflow.ellipsis, // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
        ),
      ),
      body: ListView(
        children: [
          for (final (index, sortable) in sortables.indexed) ...[
            if (index > 0) const DefaultDivider(),
            switch (sortable) {
              TokenFolder() => _folderEntry(
                sortable,
                folderTokens[sortable.folderId]!,
              ),
              OTPToken() => _tokenEntry(sortable),
              _ => const SizedBox(),
            },
          ],
        ],
      ),
    );
  }

  Widget _tokenEntry(OTPToken token) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: DefaultInkWell(
      onTap: alreadyTapped ? () {} : () => _link(token),
      child: TokenWidgetBuilder.previewFromToken(token, showDetails: false),
    ),
  );

  Widget _folderEntry(TokenFolder folder, List<OTPToken> tokens) {
    final isExpanded = _expandedFolderIds.contains(folder.folderId);
    const double borderRadius = 6;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8, left: 14, right: 14),
            decoration: BoxDecoration(
              color: isExpanded
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Colors.transparent,
              borderRadius: const BorderRadius.all(
                Radius.circular(borderRadius),
              ),
              boxShadow: [
                if (isExpanded)
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Column(
            children: [
              AnimatedPadding(
                duration: const Duration(milliseconds: 250),
                padding: isExpanded
                    ? const EdgeInsets.fromLTRB(22, 0, 14, 0)
                    : const EdgeInsets.only(left: 8),
                child: SizedBox(
                  height: 50,
                  child: DefaultInkWell(
                    onTap: () => _toggleFolder(folder),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: isExpanded ? 0.25 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const SizedBox.square(
                            dimension: 25,
                            child: Icon(Icons.arrow_forward_ios_sharp),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Text(
                            folder.label,
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                        ),
                        CustomTrailing(
                          child: TokenFolderExpandableHeaderIcon(
                            showEmptyFolderIcon: false,
                            isLocked: folder.isLocked,
                            isExpanded: isExpanded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
                  child: Column(
                    children: [
                      for (final (index, token) in tokens.indexed) ...[
                        if (index > 0) const DefaultDivider(),
                        _tokenEntry(token),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
