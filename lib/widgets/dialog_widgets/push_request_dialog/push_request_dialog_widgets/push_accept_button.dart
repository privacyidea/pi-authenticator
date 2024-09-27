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

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/customization/theme_extentions/push_request_theme.dart';
import '../../../button_widgets/press_button.dart';
import '../push_request_dialog.dart';

class PushAcceptButton extends StatelessWidget {
  final Future<void> Function() onAccept;
  final double? height;

  const PushAcceptButton({
    super.key,
    required this.onAccept,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final pushRequestTheme = (Theme.of(context).extensions[PushRequestTheme] as PushRequestTheme);
    final localizations = AppLocalizations.of(context)!;
    return CooldownButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(pushRequestTheme.acceptColor),
        shape: PushRequestDialog.getButtonShape(context),
      ),
      onPressed: () => onAccept(),
      child: SizedBox(
        height: height,
        child: Center(
          child: Text(
            localizations.accept,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
