import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../model/tokens/push_token.dart';
import '../../utils/riverpod/riverpod_providers/state_notifier_providers/token_provider.dart';
import '../../widgets/push_request_listener.dart';
import '../view_interface.dart';
import 'settings_groups/settings_group_error_log.dart';
import 'settings_groups/settings_group_general.dart';
import 'settings_groups/settings_group_import_export_tokens.dart';
import 'settings_groups/settings_group_language.dart';
import 'settings_groups/settings_group_push_token.dart';
import 'settings_groups/settings_group_theme.dart';

class SettingsView extends ConsumerView {
  @override
  RouteSettings get routeSettings => const RouteSettings(name: routeName);
  static const String routeName = '/settings';

  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(tokenProvider).tokens;
    final enrolledPushTokenList = tokens.whereType<PushToken>().where((e) => e.isRolledOut).toList();
    final unsupportedPushTokens = enrolledPushTokenList.where((e) => e.url == null).toList();
    final enablePushSettingsGroup = enrolledPushTokenList.isNotEmpty;

    return PushRequestListener(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.settings,
            overflow: TextOverflow.ellipsis, // maxLines: 2 only works like this.
            maxLines: 2, // Title can be shown on small screens too.
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsGroupGeneral(),
              const Divider(),
              const SettingsGroupImportExportTokens(),
              const Divider(),
              const SettingsGroupTheme(),
              const Divider(),
              const SettingsGroupLanguage(),
              SettingsGroupPushToken(
                enablePushSettingsGroup: enablePushSettingsGroup,
                unsupportedPushTokens: unsupportedPushTokens,
              ),
              const Divider(),
              const SettingsGroupErrorLog(),
            ],
          ),
        ),
      ),
    );
  }
}
