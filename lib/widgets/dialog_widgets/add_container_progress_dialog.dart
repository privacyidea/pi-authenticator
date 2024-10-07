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
import 'package:privacyidea_authenticator/model/extensions/enums/rollout_state_extension.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_state.dart';

import '../../l10n/app_localizations.dart';
import '../../model/token_container.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../views/container_view/container_widgets/container_widget.dart';
import '../../views/main_view/main_view_widgets/token_widgets/token_widget_builder.dart';
import 'default_dialog.dart';

class AddContainerProgressDialog extends StatefulWidget {
  final List<String> serials;

  const AddContainerProgressDialog(this.serials, {super.key});

  @override
  State<AddContainerProgressDialog> createState() => _AddContainerProgressDialogState();
}

class _AddContainerProgressDialogState extends State<AddContainerProgressDialog> {
  late final Map<String, ValueNotifier<bool>> _notifiers = Map.fromEntries(
    widget.serials.map((serial) => MapEntry(serial, ValueNotifier(false))),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      hasCloseButton: true,
      title: Text('Adding container'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var serial in widget.serials) ...[
              AddContainerProgressDialogTile(serial, _notifiers[serial]),
              if (serial != widget.serials.last) const Divider(),
            ]
          ],
        ),
      ),
      actions: [
        if (!_notifiers.values.any((v) => v.value == false))
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
      ],
    );
  }
}

class AddContainerProgressDialogTile extends ConsumerWidget {
  final String serial;
  final ValueNotifier<bool>? _notifier;

  const AddContainerProgressDialogTile(this.serial, this._notifier, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final container = ref.watch(tokenContainerProvider).value?.ofSerial(serial);
    final containerTokens = ref.watch(tokenProvider).tokens.ofContainer(serial);
    if (container == null) return SizedBox();
    final children = <Widget>[
      ContainerWidget(container: container, isPreview: true),
    ];
    if (container.finalizationState.isFailed) return Column(children: children);
    if (container is! TokenContainerFinalized) return Column(children: children);
    if (container.syncState == SyncState.syncing) return Column(children: children);
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifier?.value = true);
    if (containerTokens.isNotEmpty) {
      children.add(Divider());
      for (final token in containerTokens) {
        children.add(
          SizedBox(
            width: 99999,
            child: TokenWidgetBuilder.previewFromToken(token),
          ),
        );
      }
    }
    return Column(children: children);
  }
}
