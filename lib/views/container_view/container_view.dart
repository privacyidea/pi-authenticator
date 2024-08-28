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
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/credential_notifier.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/main_view_navigation_buttons/qr_scanner_button.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_tile.dart';

import '../../l10n/app_localizations.dart';
import '../../model/tokens/container_credentials.dart';
import '../../utils/customization/theme_extentions/action_theme.dart';
import '../main_view/main_view_widgets/token_widgets/slideable_action.dart';
import '../../widgets/pi_slideable.dart';
import '../view_interface.dart';

const String groupTag = 'container-actions';

class ContainerView extends ConsumerView {
  static const String routeName = '/container';

  @override
  get routeSettings => const RouteSettings(name: routeName);

  const ContainerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentials = ref.watch(containerCredentialsProvider).whenOrNull(data: (data) => data.credentials) ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Container')),
      floatingActionButton: const QrScannerButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (var containerCredential in credentials) ContainerWidget(containerCredential: containerCredential),
          ],
        ),
      ),
    );
  }
}

class ContainerWidget extends ConsumerWidget {
  final ContainerCredential containerCredential;

  final List<Widget> stack;

  const ContainerWidget({
    required this.containerCredential,
    this.stack = const <Widget>[],
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ClipRRect(
        child: PiSlideable(
          groupTag: groupTag,
          identifier: containerCredential.serial,
          actions: [
            DeleteContainerAction(container: containerCredential, key: Key('${containerCredential.serial}-DeleteContainerAction')),
            EditContainerAction(container: containerCredential, key: Key('${containerCredential.serial}-EditContainerAction')),
          ],
          stack: stack,
          tile: TokenWidgetTile(
            title: Text(containerCredential.serial),
            subtitles: [
              'issuer: ${containerCredential.issuer}',
              'finalizationState: ${containerCredential.finalizationState.name}',
            ],
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Open Slidable
              },
            ),
          ),
        ),
      );
}

class DeleteContainerAction extends PiSlideableAction {
  final ContainerCredential container;

  const DeleteContainerAction({
    required this.container,
    super.key,
  });

  @override
  CustomSlidableAction build(BuildContext context, WidgetRef ref) => CustomSlidableAction(
        onPressed: (BuildContext context) => ref.read(containerCredentialsProvider.notifier).deleteCredential(container),
        backgroundColor: Theme.of(context).extension<ActionTheme>()!.deleteColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.delete_forever),
            Text(
              AppLocalizations.of(context)!.delete,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ],
        ),
      );
}

class EditContainerAction extends PiSlideableAction {
  final ContainerCredential container;

  const EditContainerAction({
    required this.container,
    super.key,
  });

  @override
  CustomSlidableAction build(BuildContext context, WidgetRef ref) => CustomSlidableAction(
        onPressed: (BuildContext context) {},
        backgroundColor: Theme.of(context).extension<ActionTheme>()!.editColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.edit),
            Text(
              AppLocalizations.of(context)!.edit,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ],
        ),
      );
}
