import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/appCustomizer.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_actions/token_action.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DefaultEditAction extends TokenAction {
  final Token token;
  DefaultEditAction({required this.token, Key? key}) : super(key: key);

  @override
  SlidableAction build(BuildContext context) {
    return SlidableAction(
        label: AppLocalizations.of(context)!.rename,
        backgroundColor: Theme.of(context).brightness == Brightness.light ? ApplicationCustomizer.renameColorLight : ApplicationCustomizer.renameColorDark,
        foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
        icon: Icons.edit,
        onPressed: (context) {
          TextEditingController _nameInputController = TextEditingController(text: token.label);
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.renameToken),
                  content: TextFormField(
                    autofocus: true,
                    controller: _nameInputController,
                    onChanged: (value) {},
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.name;
                      }
                      return null;
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text(
                        AppLocalizations.of(context)!.rename,
                      ),
                      onPressed: () {
                        final newLabel = _nameInputController.text.trim();
                        if (newLabel.isEmpty) return;
                        globalRef?.read(tokenProvider.notifier).updateToken(token.copyWith(label: newLabel));

                        Logger.info(
                          'Renamed token:',
                          name: 'token_widget_base.dart#TextButton#renameClicked',
                          error: '\'${token.label}\' changed to \'$newLabel\'',
                        );

                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
        });
  }
}
