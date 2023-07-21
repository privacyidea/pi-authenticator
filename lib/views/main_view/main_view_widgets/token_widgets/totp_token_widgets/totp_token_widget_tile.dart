import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_tokens/totp_token/totp_token.dart';
import 'package:privacyidea_authenticator/utils/lock_auth.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_tile.dart';
import 'package:privacyidea_authenticator/widgets/custom_texts.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/widgets/hideable_widget_trailing.dart';

class TOTPTokenWidgetTile extends ConsumerStatefulWidget {
  final TOTPToken token;

  TOTPTokenWidgetTile(this.token);

  @override
  ConsumerState<TOTPTokenWidgetTile> createState() => _TOTPTokenWidgetTileState();
}

class _TOTPTokenWidgetTileState extends ConsumerState<TOTPTokenWidgetTile> with SingleTickerProviderStateMixin {
  String otpValue = '';
  late AnimationController _animation;
  final ValueNotifier<bool> isHidden = ValueNotifier<bool>(true);
  @override
  dispose() {
    _animation.dispose(); // you need this
    super.dispose();
  }

  int? calculateRemainingTotpDuration() {
    return widget.token.period - (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) % widget.token.period;
  }

  double calculateRemainingTotpDurationPercent() {
    return (DateTime.now().toUtc().millisecondsSinceEpoch / 1000) % widget.token.period / widget.token.period;
  }

  @override
  void initState() {
    super.initState();
    otpValue = widget.token.otpValue;

    _animation = AnimationController(
      duration: Duration(seconds: widget.token.period),
      value: widget.token.currentProgress,
      // Animate the progress for the duration of the tokens period.
      vsync: this,
    )
      ..addStatusListener((status) {
        // Add listener to restart the animation after the period, also updates the otp value.
        if (status == AnimationStatus.completed) {
          setState(() {
            otpValue = widget.token.otpValue;
          });
          _animation.forward(from: widget.token.currentProgress);
        }
      })
      ..forward(from: widget.token.currentProgress); // Start the animation.

    isHidden.addListener(() {
      setState(() {
        if (isHidden.value == false) {
          Future.delayed(Duration(seconds: 30), () {
            isHidden.value = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TokenWidgetTile(
      title: HideableText(
        key: Key(widget.token.hashCode.toString()),
        text: insertCharAt(otpValue, ' ', widget.token.digits ~/ 2),
        textScaleFactor: 1.9,
        enabled: widget.token.isLocked,
        isHiddenNotifier: isHidden,
        textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.secondary),
      ),
      subtitles: [widget.token.label, widget.token.issuer],
      trailing: HideableWidgetTrailing(
        token: widget.token,
        isHiddenNotifier: isHidden,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                Center(child: Text('${calculateRemainingTotpDuration()}')),
                Center(
                  child: CircularProgressIndicator(
                    value: _animation.value,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      onTap: widget.token.isLocked && isHidden.value
          ? () async {
              if (await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.authenticateToShowOtp)) {
                isHidden.value = false;
              }
            }
          : () {
              Clipboard.setData(ClipboardData(text: otpValue));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context)!.otpValueCopiedMessage(otpValue)),
              ));
            },
    );
  }
}
