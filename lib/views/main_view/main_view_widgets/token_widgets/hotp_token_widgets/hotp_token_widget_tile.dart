import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../model/tokens/hotp_token.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/custom_texts.dart';
import '../../../../../widgets/hideable_widget_.dart';
import '../token_widget_tile.dart';

class HOTPTokenWidgetTile extends ConsumerStatefulWidget {
  final HOTPToken token;

  const HOTPTokenWidgetTile({required this.token, super.key});

  @override
  ConsumerState<HOTPTokenWidgetTile> createState() => _HOTPTokenWidgetTileState();
}

class _HOTPTokenWidgetTileState extends ConsumerState<HOTPTokenWidgetTile> {
  bool buttonIsDisabled = false;
  final ValueNotifier<bool> isHidden = ValueNotifier<bool>(true);

  void _updateOtpValue() {
    setState(() {
      globalRef?.read(tokenProvider.notifier).incrementCounter(widget.token);
      buttonIsDisabled = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
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
          Future.delayed(const Duration(seconds: 30), () {
            isHidden.value = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TokenWidgetTile(
        tokenIsLocked: widget.token.isLocked,
        title: HideableText(
          textScaleFactor: 1.9,
          isHiddenNotifier: isHidden,
          text: insertCharAt(widget.token.otpValue, ' ', widget.token.digits ~/ 2),
          enabled: widget.token.isLocked,
          textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.secondary),
        ),
        subtitles: [widget.token.label],
        trailing: HideableWidget(
          token: widget.token,
          isHiddenNotifier: isHidden,
          child: IconButton(
            iconSize: 32,
            onPressed: buttonIsDisabled ? null : () => _updateOtpValue(),
            icon: const Icon(
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
