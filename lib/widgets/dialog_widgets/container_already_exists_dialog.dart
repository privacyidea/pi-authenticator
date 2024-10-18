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
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/views/container_view/container_widgets/container_widget.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/cooldown_button.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';

class ContainerAlreadyExistsDialog extends ConsumerStatefulWidget {
  final List<TokenContainer> containers;

  const ContainerAlreadyExistsDialog(this.containers, {super.key});

  @override
  ConsumerState<ContainerAlreadyExistsDialog> createState() => _ContainerAlreadyExistsDialogState();
}

class _ContainerAlreadyExistsDialogState extends ConsumerState<ContainerAlreadyExistsDialog> {
  late final List<TokenContainer> unhandledContainers;
  final List<TokenContainer> replaceContainers = [];

  @override
  void initState() {
    unhandledContainers = widget.containers;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final container = unhandledContainers.firstOrNull;
    if (container == null) return SizedBox.shrink();
    final currentContainer = ref.watch(tokenContainerProvider).valueOrNull?.currentOf(container);
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
          child: Text(appLocalizations.replace),
        ),
      ],
    );
  }

  void _dismiss(TokenContainer container) {
    setState(() => unhandledContainers.remove(container));
    if (unhandledContainers.isEmpty) Navigator.of(context).pop(replaceContainers);
  }

  Future<void> _replace(TokenContainer oldContainer, TokenContainer newContainer) async {
    setState(() {
      unhandledContainers.remove(newContainer);
      replaceContainers.add(newContainer);
    });
    if (unhandledContainers.isEmpty && mounted) Navigator.of(context).pop(replaceContainers);
  }
}
