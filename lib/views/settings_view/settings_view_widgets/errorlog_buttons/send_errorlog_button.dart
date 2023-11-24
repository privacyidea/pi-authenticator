import 'package:flutter/material.dart';

import '../../../../utils/logger.dart';
import '../send_error_dialog.dart';

class SendErrorLogButton extends StatelessWidget {
  const SendErrorLogButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        title: ElevatedButton(
          onPressed: () => _pressSendErrorLog(context),
          child: const Text(
            'Fehlerbericht senden', //TODO: Translate
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}

void _pressSendErrorLog(BuildContext context) {
  if (Logger.instance.logfileHasContent) {
    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) => const SendErrorDialog(),
    );
  } else {
    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) => const NoLogDialog(),
    );
  }
}
