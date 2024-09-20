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

import '../../../../l10n/app_localizations.dart';
import '../../../../model/tokens/token.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../widgets/button_widgets/mutex_button.dart';

class AddTokenButton extends ConsumerWidget {
  final ValueNotifier<bool> autoValidateLabel;
  final ValueNotifier<bool> autoValidateSecret;
  final Token? Function() tokenBuilder;
  const AddTokenButton({
    required this.autoValidateLabel,
    required this.autoValidateSecret,
    required this.tokenBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => SizedBox(
        width: double.infinity,
        child: MutexButton(
          onPressed: () async {
            if (!context.mounted) return;
            final token = tokenBuilder();
            if (token == null) return;
            Navigator.pop(context);
            await ref.read(tokenProvider.notifier).addOrReplaceToken(token);
          },
          child: Text(
            AppLocalizations.of(context)!.addToken,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      );
}
