import 'package:flutter/material.dart';

import '../../../../utils/logger.dart';

class DeleteErrorlogButton extends StatelessWidget {
  const DeleteErrorlogButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        title: ElevatedButton(
          onPressed: () => _pressClearErrorLog(context),
          child: const Text(
            'Fehlerprotokoll löschen', //TODO: Translate
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      ),
    );
  }

  void _pressClearErrorLog(BuildContext context) {
    Navigator.pop(context);
    Logger.clearErrorLog();
  }
}
