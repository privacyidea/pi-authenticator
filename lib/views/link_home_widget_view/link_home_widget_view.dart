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
import 'package:app_minimizer/app_minimizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';

import '../../utils/customization/theme_extentions/extended_text_theme.dart';
import '../../utils/home_widget_utils.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../utils/utils.dart';
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
  @override
  Widget build(BuildContext context) {
    final veilingCharacter = Theme.of(context).extension<ExtendedTextTheme>()?.veilingCharacter ?? '●';
    final otpTokens = ref.watch(tokenProvider).otpTokens;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.linkHomeWidget),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final otpToken = otpTokens[index];
          final folderIsLocked = ref.watch(tokenFolderProvider).currentOfId(otpToken.folderId)?.isLocked ?? false;
          final otpString = otpToken.isLocked || folderIsLocked ? veilingCharacter * otpToken.otpValue.length : otpToken.otpValue;
          return ListTile(
            title: Text(otpToken.label),
            subtitle: Text(insertCharAt(otpString, ' ', (otpString.length / 2).ceil())),
            onTap: alreadyTapped
                ? () {}
                : () async {
                    if (alreadyTapped) return;
                    setState(() => alreadyTapped = true);
                    await HomeWidgetUtils().link(widget.homeWidgetId, otpToken.id);
                    await FlutterAppMinimizer.minimize();
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (context.mounted) Navigator.pop(context);
                  },
          );
        },
        itemCount: otpTokens.length,
      ),
    );
  }
}
