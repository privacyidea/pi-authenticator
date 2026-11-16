/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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
import '../../../utils/home_widget_utils.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../link_home_widget_view/link_home_widget_view.dart';
import '../settings_view_widgets/settings_group.dart';

/// Opens the token list, the chosen token gets a new home screen widget.
class SettingsGroupHomeWidget extends ConsumerStatefulWidget {
  /// Only tests hand this in, the app uses [HomeWidgetUtils.new].
  final HomeWidgetUtils? utils;

  const SettingsGroupHomeWidget({super.key, this.utils});

  /// Lets a test replace the token list.
  @visibleForTesting
  static Widget Function()? debugLinkViewBuilder;

  @override
  ConsumerState<SettingsGroupHomeWidget> createState() =>
      _SettingsGroupHomeWidgetState();
}

class _SettingsGroupHomeWidgetState
    extends ConsumerState<SettingsGroupHomeWidget> {
  late final Future<bool> _canPinWidget =
      (widget.utils ?? HomeWidgetUtils()).canPinWidget;

  void _openTokenList() {
    final builder =
        SettingsGroupHomeWidget.debugLinkViewBuilder ??
        () => LinkHomeWidgetView(utils: widget.utils);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => builder()));
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _canPinWidget,
    builder: (context, snapshot) => snapshot.data == true
        ? SettingsGroup(
            title: AppLocalizations.of(context)!.homeWidget,
            isActive:
                ref.watch(tokenProvider).value?.otpTokens.isNotEmpty ?? false,
            onPressed: _openTokenList,
            trailingIcon: Icons.widgets_outlined,
          )
        : const SizedBox.shrink(),
  );
}
