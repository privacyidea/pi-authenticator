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

import '../../../../../l10n/app_localizations.dart';
import '../../../../../widgets/pi_circular_progress_indicator.dart';

class TotpTokenWidgetTileCountdown extends StatelessWidget {
  final int period;
  // final Function onPeriodEnd;
  final Color currentColor;
  final double secondsUntilNextOTP;
  const TotpTokenWidgetTileCountdown({
    required this.currentColor,
    required this.secondsUntilNextOTP,
    super.key,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final value = secondsUntilNextOTP.ceil();
    return FittedBox(
      clipBehavior: Clip.hardEdge,
      fit: BoxFit.contain,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '$value',
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          PiCircularProgressIndicator(
            1 - (secondsUntilNextOTP / period),
            foregroundColor: currentColor,
            semanticsLabel: AppLocalizations.of(context)!.a11ySecondsUntilNextOTP(value),
            semanticsValue: '$value',
          ),
        ],
      ),
    );
  }
}
