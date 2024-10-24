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

import '../../../../model/enums/sync_state.dart';
import '../../../../model/tokens/token.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';

class ContainerTokenSyncIcon extends ConsumerWidget {
  final Token token;

  const ContainerTokenSyncIcon(this.token, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(tokenContainerProvider).valueOrNull?.getSyncState(token);
    if (syncState == null) return const SizedBox.shrink();
    final color = Theme.of(context).listTileTheme.subtitleTextStyle?.color ?? Colors.grey;
    return Icon(
      color: color,
      switch (syncState) {
        SyncState.notStarted => Icons.sync,
        SyncState.syncing => Icons.cloud_sync_outlined,
        SyncState.failed => Icons.cloud_off_outlined,
        SyncState.completed => Icons.cloud_done_outlined,
      },
    );
  }
}
