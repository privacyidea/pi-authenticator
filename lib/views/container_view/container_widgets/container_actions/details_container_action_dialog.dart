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
import 'package:privacyidea_authenticator/model/extensions/enums/sync_state_extension.dart';
import 'package:privacyidea_authenticator/widgets/enable_text_edit_after_many_taps.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/token_container.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../main_view/main_view_widgets/token_widgets/default_token_actions/default_edit_action_dialog.dart';

class DetailsContainerDialog extends ConsumerStatefulWidget {
  final BuildContext context;
  final TokenContainer container;

  const DetailsContainerDialog(this.context, {super.key, required this.container});

  @override
  ConsumerState<DetailsContainerDialog> createState() => _DetailsContainerDialogState();
}

class _DetailsContainerDialogState extends ConsumerState<DetailsContainerDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.container.serverUrl.toString());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      title: Text(AppLocalizations.of(context)!.containerDetails),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReadOnlyTextFormField(
            labelText: AppLocalizations.of(context)!.containerSerial,
            text: widget.container.serial,
          ),
          ReadOnlyTextFormField(
            labelText: AppLocalizations.of(context)!.issuer,
            text: widget.container.issuer,
          ),
          if (widget.container is TokenContainerFinalized)
            ReadOnlyTextFormField(
              labelText: AppLocalizations.of(context)!.syncState,
              text: (widget.container as TokenContainerFinalized).syncState.localizedName(AppLocalizations.of(context)!),
            ),
          EnableTextEditAfterManyTaps(
            labelText: AppLocalizations.of(context)!.containerSyncUrl,
            controller: controller,
          ),
          ReadOnlyTextFormField(
            labelText: AppLocalizations.of(context)!.finalizationState,
            text: widget.container.finalizationState.rolloutMsgLocalized(AppLocalizations.of(context)!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: Uri.tryParse(controller.text) != null
              ? () {
                  ref.read(tokenContainerProvider.notifier).updateContainer(widget.container, (c) => c.copyWith(serverUrl: Uri.parse(controller.text)));
                  Navigator.of(context).pop();
                }
              : null,
          child: Text(AppLocalizations.of(context)!.saveButton),
        ),
      ],
    );
  }
}
