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
import '../../../../../model/tokens/day_password_token.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/custom_trailing.dart';
import '../../../../../widgets/token_visibility_shield.dart';
import '../token_widget_tile.dart';

class DayPasswordTokenWidgetTile extends ConsumerStatefulWidget {
  final DayPasswordToken token;
  final bool isPreview;

  const DayPasswordTokenWidgetTile(
    this.token, {
    this.isPreview = false,
    super.key,
  });

  @override
  ConsumerState<DayPasswordTokenWidgetTile> createState() =>
      _DayPasswordTokenWidgetTileState();
}

class _DayPasswordTokenWidgetTileState
    extends ConsumerState<DayPasswordTokenWidgetTile> {
  double _secondsLeft = 0;
  late DateTime _lastCount;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.token.durationUntilNextOTP.inMilliseconds / 1000;
    _lastCount = DateTime.now();
    _startCountDown();
  }

  // --- Logic ---

  void _startCountDown() {
    if (!mounted) return;

    final now = DateTime.now();
    final msSinceLastCount = now.difference(_lastCount).inMilliseconds;
    _lastCount = now;

    setState(() {
      final reduction = msSinceLastCount / 1000;
      _secondsLeft = (_secondsLeft - reduction > 0)
          ? _secondsLeft - reduction
          : widget.token.durationUntilNextOTP.inMilliseconds / 1000;
    });

    // +1 ms to avoid 0
    final msUntilNextSecond = (_secondsLeft * 1000).toInt() % 1000 + 1;
    Future.delayed(Duration(milliseconds: msUntilNextSecond), _startCountDown);
  }

  void _copyOtpValue() {
    if (ref.read(disableCopyOtpProvider) ?? false) return;

    ref.read(disableCopyOtpProvider.notifier).state = true;
    Clipboard.setData(ClipboardData(text: widget.token.otpValue));

    showSnackBar(
      AppLocalizations.of(
        context,
      )!.otpValueCopiedMessage(widget.token.otpValue),
    );

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) ref.read(disableCopyOtpProvider.notifier).state = false;
    });
  }

  void _toggleViewMode() {
    final newMode = widget.token.viewMode == DayPasswordTokenViewMode.VALIDFOR
        ? DayPasswordTokenViewMode.VALIDUNTIL
        : DayPasswordTokenViewMode.VALIDFOR;

    ref
        .read(tokenProvider.notifier)
        .updateToken(widget.token, (t) => t.copyWith(viewMode: newMode));
  }

  // --- UI Getters ---

  String get _semanticsLabel => widget.token.isHidden
      ? AppLocalizations.of(context)!.authenticateToShowOtp
      : AppLocalizations.of(context)!.copyOTPToClipboard;

  String get _title => insertCharAt(
    widget.token.otpValue,
    ' ',
    (widget.token.digits / 2).ceil(),
  );

  VoidCallback? get _titleOnTap {
    if (widget.isPreview) return null;
    if (widget.token.isLocked && widget.token.isHidden) {
      return () => ref.read(tokenProvider.notifier).showToken(widget.token);
    }
    return _copyOtpValue;
  }

  List<String> get _additionalSubtitles => widget.isPreview
      ? [
          'Algorithm: ${widget.token.algorithm.name}',
          'Period: ${widget.token.period.toString().split('.').first}',
        ]
      : [];

  String get _durationString =>
      Duration(seconds: _secondsLeft.ceil()).toString().split('.').first;

  String get _validUntilString {
    final locale = Localizations.localeOf(context).languageCode;
    final end = widget.token.nextOTPTimeStart;
    return '${DateFormat.yMMMd(locale).format(end)}\n${DateFormat.E(locale).add_jm().format(end)}';
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    return TokenWidgetTile(
      key: Key('${widget.token.hashCode}TokenWidgetTile'),
      token: widget.token,
      semanticsLabel: _semanticsLabel,
      titleOnTap: _titleOnTap,
      title: _title,
      additionalSubtitles: _additionalSubtitles,
      trailing: _buildTrailing(),
    );
  }

  Widget _buildTrailing() {
    final l10n = AppLocalizations.of(context)!;
    final titleSyle = Theme.of(context).listTileTheme.subtitleTextStyle;
    final titleString = switch (widget.token.viewMode) {
      DayPasswordTokenViewMode.VALIDFOR => l10n.dayPasswordValidFor,
      DayPasswordTokenViewMode.VALIDUNTIL => l10n.dayPasswordValidUntil,
    };
    final timeHeight = Theme.of(context).textTheme.bodyMedium!.fontSize! * 2.5;
    final timeString = switch (widget.token.viewMode) {
      DayPasswordTokenViewMode.VALIDFOR => _durationString,
      DayPasswordTokenViewMode.VALIDUNTIL => _validUntilString,
    };

    return SizedBox(
      height: double.maxFinite,
      child: CustomTrailing(
        fit: BoxFit.none,
        child: TokenVisibilityShield(
          isHidden: widget.token.isHidden && !widget.isPreview,
          token: widget.token,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.isPreview ? null : _toggleViewMode,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: (titleSyle?.fontSize ?? 12) * 1.5,
                  child: Center(
                    child: Text(
                      '$titleString:',
                      style: titleSyle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: timeHeight,
                    minHeight: timeHeight,
                  ),
                  child: Center(
                    child: Text(
                      timeString,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
