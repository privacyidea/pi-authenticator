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
import '../../utils/view_utils.dart';
import '../../widgets/custom_trailing.dart';
import '../../widgets/dialog_widgets/default_dialog.dart';
import '../main_view/main_view_widgets/drag_target_divider.dart';
import '../main_view/main_view_widgets/folder_widgets/token_folder_expandable_widgets/token_folder_expandable_header_icon.dart';
import '../main_view/main_view_widgets/token_widgets/token_widget_builder.dart';
import '../view_interface.dart';

class LinkHomeWidgetView extends ConsumerStatefulView {
  @override
  RouteSettings get routeSettings => const RouteSettings(name: routeName);

  static const routeName = '/link_home_widget';

  /// The widget to link. Without one, the launcher is asked to add a widget
  /// for the chosen token.
  final String? homeWidgetId;

  /// Only tests hand this in, the app uses [HomeWidgetUtils.new].
  final HomeWidgetUtils? utils;

  const LinkHomeWidgetView({super.key, this.homeWidgetId, this.utils});

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
    _lifecycleListener = AppLifecycleListener(
      onHide: _collapseLockedFolders,
      onResume: _linkAddedWidget,
    );
    _loadLinkedTokenIds();
  }

  Set<String> _linkedTokenIds = {};

  /// The widget of the gear, only until it got its token. Afterwards the
  /// page acts like the one opened from the settings.
  late String? _selectedWidgetId = widget.homeWidgetId;

  /// The token the widget of the gear shows right now.
  String? _ownTokenId;

  Future<void> _loadLinkedTokenIds() async {
    final Set<String> linked;
    try {
      linked = await _utils.linkedTokenIds();
      final widgetId = _selectedWidgetId;
      _ownTokenId = widgetId == null
          ? null
          : await _utils.getTokenIdOfWidgetId(widgetId);
    } catch (e, s) {
      Logger.warning(
        'Could not read the tokens that already have a widget',
        error: e,
        stackTrace: s,
      );
      return;
    }
    if (mounted) setState(() => _linkedTokenIds = linked);
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

  late final HomeWidgetUtils _utils = widget.utils ?? HomeWidgetUtils();

  /// The launcher may bind the widget a moment after the app is back.
  static const _attempts = 5;
  static const _attemptDelay = Duration(milliseconds: 500);

  /// Set while the launcher is asked to add a widget for [token].
  ({OTPToken token, Set<String> widgetIdsBefore})? _pendingRequest;

  Future<void> _link(OTPToken otpToken) async {
    if (alreadyTapped) return;
    setState(() => alreadyTapped = true);
    if (_linkedTokenIds.contains(otpToken.id) &&
        (_selectedWidgetId == null || otpToken.id == _ownTokenId)) {
      return _unlink(otpToken);
    }
    if (_isLocked(otpToken) && !await _confirmLockedToken()) {
      if (mounted) setState(() => alreadyTapped = false);
      return;
    }
    final widgetId = _selectedWidgetId ?? await _utils.unlinkedWidgetId();
    if (widgetId == null) return _requestWidgetFor(otpToken);
    await _linkTo(widgetId, otpToken);
  }

  Future<void> _unlink(OTPToken otpToken) async {
    if (await _confirmUnlink()) {
      try {
        await _utils.unlinkToken(otpToken.id);
      } catch (e, s) {
        Logger.error(
          'Unlinking the home widget failed',
          error: e,
          stackTrace: s,
        );
      }
      await _loadLinkedTokenIds();
    }
    if (mounted) setState(() => alreadyTapped = false);
  }

  Future<bool> _confirmUnlink() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DefaultDialog(
        title: Text(l.homeWidgetUnlinkTitle),
        content: Text(l.homeWidgetUnlinkContent),
        actions: [
          DialogAction(
            label: l.cancel,
            intent: ActionIntent.cancel,
            onPressed: () => Navigator.pop(context, false),
          ),
          DialogAction(
            label: l.homeWidgetUnlinkButton,
            intent: ActionIntent.confirm,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  /// The widget treats a token in a locked folder as locked as well.
  bool _isLocked(OTPToken token) =>
      token.isLocked ||
      ref
          .read(tokenFolderProvider)
          .folders
          .any(
            (folder) => folder.folderId == token.folderId && folder.isLocked,
          );

  /// A locked token shows no code on the widget, the widget opens the app.
  Future<bool> _confirmLockedToken() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DefaultDialog(
        title: Text(l.homeWidgetLockedTokenTitle),
        content: Text(l.homeWidgetLockedTokenContent),
        actions: [
          DialogAction(
            label: l.cancel,
            intent: ActionIntent.cancel,
            onPressed: () => Navigator.pop(context, false),
          ),
          DialogAction(
            label: l.continueButton,
            intent: ActionIntent.confirm,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _requestWidgetFor(OTPToken otpToken) async {
    try {
      _pendingRequest = (
        token: otpToken,
        widgetIdsBefore: await _utils.installedWidgetIds(),
      );
      await _utils.requestPinWidget();
    } catch (e) {
      _pendingRequest = null;
      if (mounted) setState(() => alreadyTapped = false);
      showErrorStatusMessage(
        message: (l) => l.homeWidget,
        details: (_) => '$e',
      );
    }
  }

  Future<void> _linkAddedWidget() async {
    final request = _pendingRequest;
    if (request == null) return;
    _pendingRequest = null;
    for (var attempt = 0; attempt < _attempts; attempt++) {
      if (attempt > 0) await Future<void>.delayed(_attemptDelay);
      final widgetId = await _utils.newUnlinkedWidgetId(
        request.widgetIdsBefore,
      );
      if (widgetId == null) continue;
      await _linkTo(widgetId, request.token);
      return;
    }
    if (mounted) setState(() => alreadyTapped = false);
  }

  Future<void> _linkTo(String widgetId, OTPToken otpToken) async {
    try {
      await _utils.link(widgetId, otpToken.id);
      await ref
          .read(introductionNotifierProvider.notifier)
          .complete(Introduction.homeWidgetSetUp);
    } catch (e, s) {
      if (mounted) setState(() => alreadyTapped = false);
      Logger.error('Linking the home widget failed', error: e, stackTrace: s);
      return;
    }
    _selectedWidgetId = null;
    await SystemNavigator.pop();
    if (mounted) setState(() => alreadyTapped = false);
    await _loadLinkedTokenIds();
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
      child: Stack(
        children: [
          TokenWidgetBuilder.previewFromToken(token, showDetails: false),
          if (_linkedTokenIds.contains(token.id))
            const Positioned(
              top: 6,
              right: 10,
              child: Icon(Icons.link, size: 18),
            ),
        ],
      ),
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
