/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../model/enums/algorithms.dart';
import '../../model/enums/encodings.dart';
import '../../model/enums/token_types.dart';
import 'add_token_manually_view_widgets/add_tokens_manually/add_daypassword_manually.dart';
import 'add_token_manually_view_widgets/add_tokens_manually/add_hotp_manually.dart';
import 'add_token_manually_view_widgets/add_tokens_manually/add_steam_manually.dart';
import 'add_token_manually_view_widgets/add_tokens_manually/add_token_manually_interface.dart';
import 'add_token_manually_view_widgets/add_tokens_manually/add_totp_manually.dart';
import 'add_token_manually_view_widgets/link_input_field.dart';
import 'add_token_manually_view_widgets/page_view_indicator.dart';

class AddTokenManuallyView extends ConsumerStatefulWidget {
  static const routeName = '/add_token_manually';

  const AddTokenManuallyView({super.key});

  @override
  ConsumerState<AddTokenManuallyView> createState() => _AddTokenManuallyViewState();
}

class _AddTokenManuallyViewState extends ConsumerState<AddTokenManuallyView> {
  late ValueNotifier<TokenTypes> selectedTypeNotifier;

  late TextEditingController labelController;
  late TextEditingController secretController;
  final PageController pageController = PageController();

  // fields needed to manage the widget

  late ValueNotifier<bool> autoValidateLabel;
  late ValueNotifier<bool> autoValidateSecret;
  late ValueNotifier<Encodings> encodingNofitier;
  late ValueNotifier<Algorithms> algorithmsNotifier;
  late ValueNotifier<int?> digitsNotifier;
  late ValueNotifier<int?> counterNotifier;
  late ValueNotifier<Duration?> periodNotifierTOTP;
  late ValueNotifier<Duration?> periodNotifierDayPassword;

  @override
  void initState() {
    super.initState();
    selectedTypeNotifier = ValueNotifier(TokenTypes.HOTP);
    selectedTypeNotifier.addListener(() => setState(() {}));
    labelController = TextEditingController();
    secretController = TextEditingController();
    autoValidateLabel = ValueNotifier(false);
    autoValidateSecret = ValueNotifier(false);
    encodingNofitier = ValueNotifier(Encodings.base32);
    algorithmsNotifier = ValueNotifier(Algorithms.SHA1);
    digitsNotifier = ValueNotifier(null);
    counterNotifier = ValueNotifier(null);
    periodNotifierTOTP = ValueNotifier(null);
    periodNotifierDayPassword = ValueNotifier(null);
  }

  @override
  void dispose() {
    selectedTypeNotifier.dispose();
    labelController.dispose();
    secretController.dispose();
    autoValidateLabel.dispose();
    autoValidateSecret.dispose();
    encodingNofitier.dispose();
    algorithmsNotifier.dispose();
    digitsNotifier.dispose();
    counterNotifier.dispose();
    periodNotifierTOTP.dispose();
    periodNotifierDayPassword.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AddTokenManuallyPage page = switch (selectedTypeNotifier.value) {
      const (TokenTypes.HOTP) => AddHotpManually(
          labelController: labelController,
          secretController: secretController,
          autoValidateLabel: autoValidateLabel,
          autoValidateSecret: autoValidateSecret,
          encodingNofitier: encodingNofitier,
          algorithmsNotifier: algorithmsNotifier,
          digitsNotifier: digitsNotifier,
          counterNotifier: counterNotifier,
          typeNotifier: selectedTypeNotifier,
        ),
      TokenTypes.TOTP => AddTotpManually(
          labelController: labelController,
          secretController: secretController,
          autoValidateLabel: autoValidateLabel,
          autoValidateSecret: autoValidateSecret,
          encodingNofitier: encodingNofitier,
          algorithmsNotifier: algorithmsNotifier,
          digitsNotifier: digitsNotifier,
          periodNotifier: periodNotifierTOTP,
          typeNotifier: selectedTypeNotifier,
        ),
      TokenTypes.DAYPASSWORD => AddDayPasswordManually(
          labelController: labelController,
          secretController: secretController,
          autoValidateLabel: autoValidateLabel,
          autoValidateSecret: autoValidateSecret,
          encodingNofitier: encodingNofitier,
          algorithmsNotifier: algorithmsNotifier,
          digitsNotifier: digitsNotifier,
          periodNotifier: periodNotifierDayPassword,
          typeNotifier: selectedTypeNotifier,
        ),
      TokenTypes.STEAM => AddSteamManually(
          labelController: labelController,
          secretController: secretController,
          autoValidateLabel: autoValidateLabel,
          autoValidateSecret: autoValidateSecret,
          typeNotifier: selectedTypeNotifier,
        ),
      TokenTypes.PIPUSH => throw UnimplementedError(),
      TokenTypes.PUSH => throw UnimplementedError(),
    };

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.enterDetailsForToken,
          overflow: TextOverflow.ellipsis, // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
        ),
      ),
      body: Column(
        children: [
          PageViewIndicator(
            controller: pageController,
            icons: [
              Icon(Icons.edit),
              Icon(Icons.link),
            ],
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  child: page,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                  child: LinkInputView(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
