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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/extensions/token_list_extension.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/token_container.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../../../widgets/elevated_delete_button.dart';
import 'delete_container_force_dialog.dart';
import 'delete_container_token_dialog.dart';

class DeleteContainerDialog extends ConsumerWidget {
  final TokenContainer container;
  final String? titleOverride;
  final String? contentOverride;

  static void showDialog(
    TokenContainer container, {
    String? titleOverride,
    String? contentOverride,
  }) => showAsyncDialog(
    builder: (context) => DeleteContainerDialog(
      container,
      titleOverride: titleOverride,
      contentOverride: contentOverride,
    ),
  );

  const DeleteContainerDialog(
    this.container, {
    this.titleOverride,
    this.contentOverride,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containerToken =
        ref.watch(tokenProvider).value?.containerTokens(container.serial) ?? [];
    return DefaultDialog(
      title: Text(
        titleOverride ??
            AppLocalizations.of(
              context,
            )!.deleteContainerDialogTitle(container.serial),
      ),
      content: Text(
        contentOverride ??
            AppLocalizations.of(context)!.deleteContainerDialogContent,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedDeleteButton(
          onPressed: () async {
            final deleteContainerTokens = containerToken.isEmpty
                ? false
                : await DeleteContainerTokenDialog.showDialog(container);
            if (deleteContainerTokens == null) return;

            var wasContainerDeleted = await _deleteContainer(ref);
            if (!wasContainerDeleted) {
              wasContainerDeleted =
                  (await ForceDeleteContainerDialog.showDialog(container)) ==
                  true;
            }
            final containerTokens = (await ref.read(
              tokenProvider.future,
            )).containerTokens(container.serial);
            if (!context.mounted) return;
            if (wasContainerDeleted) {
              if (deleteContainerTokens) {
                await ref
                    .read(tokenProvider.notifier)
                    .removeTokens(containerTokens.noOffline);
              } else {
                Logger.info(
                  "Container ${container.serial} deleted, but tokens were not removed.",
                );
                Logger.info(
                  "Tokens: ${containerTokens.noOffline.map((token) => token.serial).join(", ")}",
                );
                await ref
                    .read(tokenProvider.notifier)
                    .updateTokens(
                      containerTokens.noOffline,
                      (token) => token.copyWith(
                        containerSerial: () => null,
                        checkedContainer: [
                          ...token.checkedContainer,
                          container.serial,
                        ],
                      ),
                    );
              }
            }

            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          text: AppLocalizations.of(context)!.delete,
        ),
      ],
    );
  }

  Future<bool> _deleteContainer(WidgetRef ref) {
    if (container is TokenContainerFinalized) {
      return ref
          .read(tokenContainerProvider.notifier)
          .unregisterDelete(container as TokenContainerFinalized);
    } else {
      return ref
          .read(tokenContainerProvider.notifier)
          .deleteContainer(container);
    }
  }
}
