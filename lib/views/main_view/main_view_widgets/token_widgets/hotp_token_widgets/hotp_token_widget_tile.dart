import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_tokens/hotp_token/hotp_token.dart';
import 'package:privacyidea_authenticator/utils/lock_auth.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_base.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_tile.dart';
import 'package:privacyidea_authenticator/widgets/custom_texts.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HOTPTokenWidgetTile extends ConsumerStatefulWidget {
  final HOTPToken token;

  HOTPTokenWidgetTile({required this.token, super.key});

  @override
  _HOTPTokenWidgetTileState createState() {
    return _HOTPTokenWidgetTileState();
  }
}

class _HOTPTokenWidgetTileState extends ConsumerState<HOTPTokenWidgetTile> {
  bool buttonIsDisabled = false;
  final ValueNotifier<bool> isHidden = ValueNotifier<bool>(true);

  void _updateOtpValue() {
    setState(() {
      globalRef?.read(tokenProvider.notifier).incrementCounter(widget.token);
      buttonIsDisabled = true;
    });
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        buttonIsDisabled = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
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
          textScaleFactor: 1.9,
          isHiddenNotifier: isHidden,
          text: insertCharAt(widget.token.otpValue, ' ', widget.token.digits ~/ 2),
          enabled: widget.token.isLocked,
          textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.secondary),
        ),
        subtitles: [widget.token.label],
        trailing: HideableWidgetTrailing(
          token: widget.token,
          isHiddenNotifier: isHidden,
          child: IconButton(
            iconSize: 32,
            onPressed: buttonIsDisabled ? null : () => _updateOtpValue(),
            icon: Icon(
              Icons.replay,
            ),
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
              });
  }
}
