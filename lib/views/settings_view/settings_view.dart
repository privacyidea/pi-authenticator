import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../model/tokens/push_token.dart';
import '../../utils/globals.dart';
import '../../utils/home_widget_utils.dart';
import '../../utils/riverpod_providers.dart';
import '../../widgets/push_request_listener.dart';
import '../feedback_view/feedback_view.dart';
import '../import_tokens_view/import_tokens_view.dart';
import '../license_view/license_view.dart';
import '../view_interface.dart';
import 'settings_view_widgets/logging_menu.dart';
import 'settings_view_widgets/settings_groups.dart';
import 'settings_view_widgets/settings_list_tile_button.dart';
import 'settings_view_widgets/update_firebase_token_dialog.dart';

class SettingsView extends ConsumerView {
  @override
  RouteSettings get routeSettings => const RouteSettings(name: routeName);
  static const String routeName = '/settings';

  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(tokenProvider).tokens;
    final enrolledPushTokenList = tokens.whereType<PushToken>().where((e) => e.isRolledOut).toList();
    final unsupported = enrolledPushTokenList.where((e) => e.url == null).toList();
    final showPushSettingsGroup = enrolledPushTokenList.isNotEmpty;

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
              SettingsGroup(
                title: AppLocalizations.of(context)!.settingsGroupGeneral,
                children: [
                  SettingsListTileButton(
                    onPressed: () async {
                      if (!await launchUrl(policyStatementUri)) {
                        throw Exception('Could not launch $policyStatementUri');
                      }
                    },
                    title: Text(
                      AppLocalizations.of(context)!.privacyPolicy,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                  SettingsListTileButton(
                    onPressed: () {
                      Navigator.pushNamed(context, LicenseView.routeName);
                    },
                    title: Text(
                      AppLocalizations.of(context)!.licensesAndVersion,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                  SettingsListTileButton(
                    onPressed: () {
                      Navigator.pushNamed(context, FeedbackView.routeName);
                    },
                    title: Text(
                      'Feedback',
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    icon: const Icon(FluentIcons.chat_32_regular),
                  ),
                  SettingsListTileButton(
                    onPressed: () {
                      Navigator.pushNamed(context, ImportTokensView.routeName);
                    },
                    title: Text(
                      AppLocalizations.of(context)!.importTokens,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    icon: const RotatedBox(
                      quarterTurns: 1,
                      child: Icon(FluentIcons.arrow_enter_20_filled),
                    ),
                  )
                ],
              ),
              const Divider(),
              SettingsGroup(
                title: AppLocalizations.of(context)!.theme,
                children: [
                  RadioListTile(
                    title: Text(
                      AppLocalizations.of(context)!.lightTheme,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    value: ThemeMode.light,
                    groupValue: EasyDynamicTheme.of(context).themeMode,
                    controlAffinity: ListTileControlAffinity.trailing,
                    onChanged: (dynamic value) {
                      EasyDynamicTheme.of(context).changeTheme(dynamic: false, dark: false);
                      HomeWidgetUtils().setCurrentThemeMode(ThemeMode.light);
                    },
                  ),
                  RadioListTile(
                    title: Text(
                      AppLocalizations.of(context)!.darkTheme,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    value: ThemeMode.dark,
                    groupValue: EasyDynamicTheme.of(context).themeMode,
                    controlAffinity: ListTileControlAffinity.trailing,
                    onChanged: (dynamic value) {
                      EasyDynamicTheme.of(context).changeTheme(dynamic: false, dark: true);
                      HomeWidgetUtils().setCurrentThemeMode(ThemeMode.dark);
                    },
                  ),
                  RadioListTile(
                    title: Text(
                      AppLocalizations.of(context)!.systemTheme,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    value: ThemeMode.system,
                    groupValue: EasyDynamicTheme.of(context).themeMode,
                    controlAffinity: ListTileControlAffinity.trailing,
                    onChanged: (dynamic value) {
                      EasyDynamicTheme.of(context).changeTheme(dynamic: true, dark: false);
                      HomeWidgetUtils().setCurrentThemeMode(ThemeMode.system);
                    },
                  ),
                ],
              ),
              const Divider(),
              SettingsGroup(
                title: AppLocalizations.of(context)!.language,
                children: [
                  SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.useDeviceLocaleTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.useDeviceLocaleDescription,
                        overflow: TextOverflow.fade,
                      ),
                      value: ref.watch(settingsProvider).useSystemLocale,
                      onChanged: (value) => ref.read(settingsProvider.notifier).setUseSystemLocale(value)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DropdownButton<Locale>(
                      disabledHint: Text(
                        '${ref.watch(settingsProvider).currentLocale}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                      isExpanded: true,
                      value: ref.watch(settingsProvider).currentLocale,
                      items: AppLocalizations.supportedLocales.map<DropdownMenuItem<Locale>>((Locale itemLocale) {
                        return DropdownMenuItem<Locale>(
                          value: itemLocale,
                          child: Text(
                            '$itemLocale',
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ),
                        );
                      }).toList(),
                      onChanged:
                          ref.watch(settingsProvider).useSystemLocale ? null : (value) => ref.read(settingsProvider.notifier).setLocalePreference(value!),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: showPushSettingsGroup,
                child: SettingsGroup(
                  title: AppLocalizations.of(context)!.pushToken,
                  children: [
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context)!.synchronizePushTokens,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.synchronizesTokensWithServer,
                        overflow: TextOverflow.fade,
                      ),
                      trailing: ElevatedButton(
                        child: Text(
                          AppLocalizations.of(context)!.sync,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                        onPressed: () {
                          showDialog(
                            useRootNavigator: false,
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const UpdateFirebaseTokenDialog(),
                          );
                        },
                      ),
                    ),
                    ListTile(
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context)!.enablePolling,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            // Add clickable icon to inform user of unsupported push tokens (for polling)
                            WidgetSpan(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: unsupported.isNotEmpty && enrolledPushTokenList.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {}, // () => _showPollingInfo(unsupported),
                                        child: const Icon(
                                          Icons.info_outline,
                                          color: Colors.red,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.requestPushChallengesPeriodically,
                        overflow: TextOverflow.fade,
                      ),
                      trailing: Switch(
                        value: ref.watch(settingsProvider).enablePolling,
                        onChanged: (value) => ref.read(settingsProvider.notifier).setPolling(value),
                      ),
                    ),
                    if (ref.watch(tokenProvider).hasHOTPTokens)
                      ListTile(
                        title: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(context)!.hidePushTokens,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        subtitle: Text(
                          AppLocalizations.of(context)!.hidePushTokensDescription,
                          overflow: TextOverflow.fade,
                        ),
                        trailing: Switch(
                          value: ref.watch(settingsProvider).hidePushTokens,
                          onChanged: (value) => ref.read(settingsProvider.notifier).setHidePushTokens(value),
                        ),
                      )
                  ],
                ),
              ),
              const Divider(),
              SettingsGroup(
                title: AppLocalizations.of(context)!.errorLogTitle,
                children: [
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.logMenu,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    style: ListTileStyle.list,
                    trailing: ElevatedButton(
                      child: Text(
                        AppLocalizations.of(context)!.open,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => const LoggingMenu(),
                        useRootNavigator: false,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
