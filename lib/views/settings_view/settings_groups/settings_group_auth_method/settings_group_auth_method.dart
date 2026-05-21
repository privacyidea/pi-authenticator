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

import '../../../../l10n/app_localizations.dart';
import '../../../../model/enums/force_biometric_option.dart';
import '../../../../model/riverpod_states/settings_state.dart';
import '../../../../utils/lock_auth.dart';
import '../../../../utils/logger.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../../settings_view_widgets/settings_group.dart';
import 'dialogs/auth_method_dialog.dart';

class SettingsGroupAuthMethod extends ConsumerWidget {
  const SettingsGroupAuthMethod({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref
        .watch(settingsProvider)
        .whenOrNull(data: (s) => s.appAuthMethod) ??
        SettingsState.appAuthMethodDefault;
    return SettingsGroup(
      title: AppLocalizations.of(context)!.authMethodTitle,
      trailingIcon: _iconFor(current),
      onPressed: () => _open(context, ref),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final selected = await showDialog<ForceBiometricOption>(
      useRootNavigator: false,
      context: context,
      builder: (_) => const AuthMethodDialog(),
    );
    if (selected == null) return;
    final current = ref.read(appAuthMethodProvider);
    if (selected == current) return;
    if (!context.mounted) return;
    final ok = await _confirmTransition(
      context: context,
      ref: ref,
      from: current,
      to: selected,
    );
    if (!ok) return;
    Logger.info('App auth method changing: $current -> $selected');
    await ref.read(settingsProvider.notifier).setAppAuthMethod(selected);
  }

  /// Re-authenticate to authorise the transition. The required method(s) are:
  /// - going from `any` to a stricter option: confirm with the new method;
  /// - going from a stricter option to `any` (or to a different stricter
  ///   option): confirm with the previous method;
  /// - going from one stricter option to another (currently unreachable):
  ///   confirm with both, in turn.
  Future<bool> _confirmTransition({
    required BuildContext context,
    required WidgetRef ref,
    required ForceBiometricOption from,
    required ForceBiometricOption to,
  }) async {
    final localization = AppLocalizations.of(context)!;
    final required = <ForceBiometricOption>{};
    if (from != ForceBiometricOption.any &&
        from != ForceBiometricOption.none) {
      required.add(from);
    }
    if (to != ForceBiometricOption.any && to != ForceBiometricOption.none) {
      required.add(to);
    }

    if (required.isEmpty) return true;

    for (final method in required) {
      final ok = await lockAuth(
        reason: (l) => l.authMethodChangeReason,
        localization: localization,
        forceBiometricOption: method,
      );
      if (!ok) return false;
    }
    return true;
  }

  IconData _iconFor(ForceBiometricOption option) {
    switch (option) {
      case ForceBiometricOption.biometric:
        return Icons.fingerprint;
      case ForceBiometricOption.pin:
        return Icons.pin;
      case ForceBiometricOption.any:
      case ForceBiometricOption.none:
        return Icons.lock_outline;
    }
  }
}
