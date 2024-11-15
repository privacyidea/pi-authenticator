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
import 'package:privacyidea_authenticator/utils/view_utils.dart';

import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../../../model/token_container.dart';
import '../../../../../../../views/container_view/container_widgets/container_widget.dart';
import '../../../../../../../widgets/button_widgets/cooldown_button.dart';
import '../../../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';

class ContainerAlreadyExistsDialog extends ConsumerStatefulWidget {
  final List<TokenContainerUnfinalized> newContainers;

  static Future<List<TokenContainerUnfinalized>?> showDialog(List<TokenContainerUnfinalized> newContainers) =>
      showAsyncDialog<List<TokenContainerUnfinalized>>(builder: (context) => ContainerAlreadyExistsDialog(newContainers));

  const ContainerAlreadyExistsDialog(this.newContainers, {super.key});

  @override
  ConsumerState<ContainerAlreadyExistsDialog> createState() => _ContainerAlreadyExistsDialogState();
}

class _ContainerAlreadyExistsDialogState extends ConsumerState<ContainerAlreadyExistsDialog> {
  late final List<TokenContainerUnfinalized> unhandledContainers;
  final List<TokenContainerUnfinalized> replaceContainers = [];

  @override
  void initState() {
    assert(widget.newContainers.isNotEmpty);
    unhandledContainers = widget.newContainers;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final container = unhandledContainers.firstOrNull;
    if (container == null) return SizedBox.shrink();
    final currentContainer = ref.watch(tokenContainerProvider).valueOrNull?.currentOf<TokenContainer>(container);
    if (currentContainer == null) return SizedBox.shrink();
    final appLocalizations = AppLocalizations.of(context)!;
    return DefaultDialog(
      title: Text(appLocalizations.containerAlreadyExists),
      content: ContainerWidget(container: currentContainer, isPreview: true),
      actions: [
        TextButton(
          onPressed: () => _dismiss(container),
          child: Text(appLocalizations.dismiss),
        ),
        CooldownButton(
          onPressed: () => _replace(currentContainer, container),
          child: Text(appLocalizations.replaceButton),
        ),
      ],
    );
  }

  void _dismiss(TokenContainer container) {
    setState(() => unhandledContainers.remove(container));
    if (unhandledContainers.isEmpty) Navigator.of(context).pop<List<TokenContainerUnfinalized>>(replaceContainers);
  }

  Future<void> _replace(TokenContainer oldContainer, TokenContainerUnfinalized newContainer) async {
    setState(() {
      unhandledContainers.removeWhere((element) => element.serial == oldContainer.serial);
      replaceContainers.add(newContainer);
    });
    if (unhandledContainers.isEmpty) Navigator.of(context).pop<List<TokenContainerUnfinalized>>(replaceContainers);
  }
}
