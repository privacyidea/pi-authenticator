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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../../../utils/view_utils.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/enums/day_password_token_view_mode.dart';
import '../../../../../model/riverpod_states/settings_state.dart';
import '../../../../../model/tokens/day_password_token.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/custom_trailing.dart';
import '../../../../../widgets/hideable_widget_.dart';
import '../token_widget_tile.dart';

class DayPasswordTokenWidgetTile extends ConsumerStatefulWidget {
  final DayPasswordToken token;
  final bool isPreview;
  const DayPasswordTokenWidgetTile(this.token, {this.isPreview = false, super.key});

  @override
  ConsumerState<DayPasswordTokenWidgetTile> createState() => _DayPasswordTokenWidgetTileState();
}

class _DayPasswordTokenWidgetTileState extends ConsumerState<DayPasswordTokenWidgetTile> {
  double secondsLeft = 0;
  late DateTime lastCount;

  @override
  void initState() {
    super.initState();
    secondsLeft = widget.token.durationUntilNextOTP.inMilliseconds / 1000;
    lastCount = DateTime.now();
    _startCountDown();
  }

  void _startCountDown() {
    final now = DateTime.now();
    final msSinceLastCount = now.difference(lastCount).inMilliseconds;
    lastCount = now;
    if (!mounted) return;
    if (secondsLeft - (msSinceLastCount / 1000) > 0) {
      setState(() => secondsLeft -= msSinceLastCount / 1000);
    } else {
      setState(() => secondsLeft = widget.token.durationUntilNextOTP.inMilliseconds / 1000);
    }
    final msUntilNextSecond = (secondsLeft * 1000).toInt() % 1000 + 1; // +1 to avoid 0
    Future.delayed(Duration(milliseconds: msUntilNextSecond), () => _startCountDown());
  }

  void _copyOtpValue() {
    if (ref.read(disableCopyOtpProvider) ?? false) return;

    ref.read(disableCopyOtpProvider.notifier).state = true;
    Clipboard.setData(ClipboardData(text: widget.token.otpValue));
    showSnackBar(AppLocalizations.of(context)!.otpValueCopiedMessage(widget.token.otpValue));
    Future.delayed(const Duration(seconds: 5), () {
      ref.read(disableCopyOtpProvider.notifier).state = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(settingsProvider).whenOrNull(data: (data) => data.currentLocale) ?? SettingsState.localeDefault;
    final dateTimeTokenEnd = widget.token.nextOTPTimeStart;
    final yMdFormat = DateFormat.yMMMd(currentLocale.languageCode);
    final yMdString = yMdFormat.format(dateTimeTokenEnd);
    final ejmFormat = DateFormat.E(currentLocale.languageCode).add_jm();
    final ejmString = ejmFormat.format(dateTimeTokenEnd);
    final duration = Duration(seconds: secondsLeft.ceil());
    final durationString = duration.toString().split('.').first;
    return TokenWidgetTile(
      key: Key('${widget.token.hashCode}TokenWidgetTile'),
      token: widget.token,
      semanticsLabel: widget.token.isHidden ? AppLocalizations.of(context)!.authenticateToShowOtp : AppLocalizations.of(context)!.copyOTPToClipboard,
      titleOnTap: widget.isPreview
          ? null
          : widget.token.isLocked && widget.token.isHidden
              ? () async => await ref.read(tokenProvider.notifier).showToken(widget.token)
              : _copyOtpValue,
      title: insertCharAt(widget.token.otpValue, ' ', (widget.token.digits / 2).ceil()),
      additionalSubtitles: widget.isPreview
          ? [
              'Algorithm: ${widget.token.algorithm.name}',
              'Period: ${widget.token.period.toString().split('.').first}',
            ]
          : [],
      trailing: SizedBox(
        height: double.maxFinite,
        child: CustomTrailing(
          padding: const EdgeInsets.all(0),
          fit: BoxFit.none,
          child: HideableWidget(
            isHidden: widget.token.isHidden && !widget.isPreview,
            token: widget.token,
            child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onTap: widget.isPreview
                  ? null
                  : () {
                      if (widget.token.viewMode == DayPasswordTokenViewMode.VALIDFOR) {
                        ref.read(tokenProvider.notifier).updateToken(widget.token, (p0) => p0.copyWith(viewMode: DayPasswordTokenViewMode.VALIDUNTIL));
                        return;
                      }
                      if (widget.token.viewMode == DayPasswordTokenViewMode.VALIDUNTIL) {
                        ref.read(tokenProvider.notifier).updateToken(widget.token, (p0) => p0.copyWith(viewMode: DayPasswordTokenViewMode.VALIDFOR));
                        return;
                      }
                    },
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: Theme.of(context).listTileTheme.subtitleTextStyle!.fontSize! * 1.5,
                      child: Center(
                        child: Text(
                          switch (widget.token.viewMode) {
                            DayPasswordTokenViewMode.VALIDFOR => '${AppLocalizations.of(context)!.dayPasswordValidFor}:',
                            DayPasswordTokenViewMode.VALIDUNTIL => '${AppLocalizations.of(context)!.dayPasswordValidUntil}:',
                          },
                          style: Theme.of(context).listTileTheme.subtitleTextStyle,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: double.infinity,
                        maxHeight: Theme.of(context).textTheme.bodyLarge!.fontSize! * 3,
                        minHeight: Theme.of(context).textTheme.bodyLarge!.fontSize! * 3,
                      ),
                      child: Center(
                        child: Text(
                          switch (widget.token.viewMode) {
                            DayPasswordTokenViewMode.VALIDFOR => durationString,
                            DayPasswordTokenViewMode.VALIDUNTIL => '$yMdString\n$ejmString',
                          },
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
