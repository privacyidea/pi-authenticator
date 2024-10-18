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
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/main_view_navigation_buttons/qr_scanner_button.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../view_interface.dart';
import 'container_widgets/container_widget.dart';

const String groupTag = 'container-actions';

class ContainerView extends ConsumerView {
  static const String routeName = '/container';

  @override
  get routeSettings => const RouteSettings(name: routeName);

  const ContainerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final container = ref.watch(tokenContainerProvider).whenOrNull(data: (data) => data.containerList) ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.container),
      ),
      floatingActionButton: const QrScannerButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Center(
        child: SlidableAutoCloseBehavior(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for (var containerCredential in container) ContainerWidget(container: containerCredential),
            ],
          ),
        ),
      ),
    );
  }
}
