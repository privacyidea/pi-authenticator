import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/day_password_token_widgets/day_password_token_widget_tile.dart';

import '../../../../../model/tokens/totp_token.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/custom_texts.dart';
import '../../../../../widgets/hideable_widget_.dart';
import '../token_widget_tile.dart';

class TOTPTokenWidgetTile extends ConsumerStatefulWidget {
  final TOTPToken token;

  const TOTPTokenWidgetTile(this.token, {super.key});

  @override
  ConsumerState<TOTPTokenWidgetTile> createState() => _TOTPTokenWidgetTileState();
}

class _TOTPTokenWidgetTileState extends ConsumerState<TOTPTokenWidgetTile> with SingleTickerProviderStateMixin {
  int secondsLeft = 0;
  late AnimationController _animation;
  final ValueNotifier<bool> isHidden = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    secondsLeft = widget.token.secondsUntilNextOTP;
    _animation = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.token.period),
      lowerBound: 0.0,
      upperBound: widget.token.period.toDouble(),
      value: widget.token.secondsUntilNextOTP.toDouble(),
    );
    GlobalTimer.addListener(_setNewTimer);
  }

  @override
  dispose() {
    _animation.dispose(); // you need this
    super.dispose();
  }

  void _setNewTimer() {
    if (mounted) {
      if (secondsLeft > 0) {
        setState(() {
          secondsLeft--;
        });
      } else {
        setState(() {
          secondsLeft = widget.token.secondsUntilNextOTP;
        });
      }
    } else {
      GlobalTimer.removeListener(_setNewTimer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TokenWidgetTile(
      tokenIsLocked: widget.token.isLocked,
      title: HideableText(
        key: Key(widget.token.hashCode.toString()),
        text: insertCharAt(widget.token.otpValue, ' ', widget.token.digits ~/ 2),
        textScaleFactor: 1.9,
        enabled: widget.token.isLocked,
        isHiddenNotifier: isHidden,
        textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.secondary),
      ),
      subtitles: [widget.token.label, widget.token.issuer],
      trailing: HideableWidget(
        token: widget.token,
        isHiddenNotifier: isHidden,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                Center(child: Text('$secondsLeft')),
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
              Clipboard.setData(ClipboardData(text: widget.token.otpValue));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context)!.otpValueCopiedMessage(widget.token.otpValue)),
              ));
            },
    );
  }
}
