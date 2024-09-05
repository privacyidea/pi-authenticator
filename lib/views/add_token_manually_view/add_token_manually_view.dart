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

class AddTokenManuallyView extends ConsumerStatefulWidget {
  static const routeName = '/add_token_manually';

  const AddTokenManuallyView({super.key});

  @override
  ConsumerState<AddTokenManuallyView> createState() => _AddTokenManuallyViewState();
}

class _AddTokenManuallyViewState extends ConsumerState<AddTokenManuallyView> {
  late ValueNotifier<TokenTypes> selectedTypeNotifier;

  final PageController pageController = PageController();

  // fields needed to manage the widget
  final _labelInputKey = GlobalKey<FormFieldState>();
  final _secretInputKey = GlobalKey<FormFieldState>();

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
    final AddTokenManually column = switch (selectedTypeNotifier.value) {
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
                  child: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  key: _labelInputKey,
                                  controller: _labelController,
                                  autovalidateMode: _autoValidateLabel,
                                  focusNode: _labelFieldFocus,
                                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return AppLocalizations.of(context)!.pleaseEnterANameForThisToken;
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  key: _secretInputKey,
                                  controller: _secretController,
                                  autovalidateMode: _autoValidateSecret,
                                  focusNode: _secretFieldFocus,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!.secretKey,
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return AppLocalizations.of(context)!.pleaseEnterASecretForThisToken;
                                    } else if ((_typeNotifier.value == TokenTypes.STEAM && Encodings.base32.isInvalidEncoding(value)) ||
                                        (_typeNotifier.value != TokenTypes.STEAM && _encodingNotifier.value.isInvalidEncoding(value))) {
                                      return AppLocalizations.of(context)!.theSecretDoesNotFitTheCurrentEncoding;
                                    }
                                    return null;
                                  },
                                ),
                                Visibility(
                                  visible: _typeNotifier.value != TokenTypes.STEAM,
                                  child: LabeledDropdownButton<Encodings>(
                                    label: AppLocalizations.of(context)!.encoding,
                                    values: Encodings.values,
                                    valueNotifier: _encodingNotifier,
                                  ),
                                ),
                                Visibility(
                                  visible: _typeNotifier.value != TokenTypes.STEAM,
                                  child: LabeledDropdownButton<Algorithms>(
                                    label: AppLocalizations.of(context)!.algorithm,
                                    values: Algorithms.values.reversed.toList(),
                                    valueNotifier: _algorithmNotifier,
                                  ),
                                ),
                                Visibility(
                                  visible: _typeNotifier.value != TokenTypes.STEAM,
                                  child: LabeledDropdownButton<int>(
                                    label: AppLocalizations.of(context)!.digits,
                                    values: AddTokenManuallyView.allowedDigits,
                                    valueNotifier: _digitsNotifier,
                                  ),
                                ),
                                LabeledDropdownButton<TokenTypes>(
                                  label: AppLocalizations.of(context)!.type,
                                  values: List.from(TokenTypes.values)..remove(TokenTypes.PIPUSH),
                                  valueNotifier: _typeNotifier,
                                ),
                                Visibility(
                                  // the period is only used by TOTP tokens
                                  visible: _typeNotifier.value == TokenTypes.TOTP,
                                  child: LabeledDropdownButton<int>(
                                    label: AppLocalizations.of(context)!.period,
                                    values: AddTokenManuallyView.allowedPeriodsTOTP,
                                    valueNotifier: _periodNotifier,
                                    postFix: 's' /*seconds*/,
                                  ),
                                ),
                                Visibility(
                                  // the period is only used by DayPassword tokens
                                  visible: _typeNotifier.value == TokenTypes.DAYPASSWORD,
                                  child: LabeledDropdownButton<int>(
                                    label: AppLocalizations.of(context)!.period,
                                    values: AddTokenManuallyView.allowedPeriodsDayPassword,
                                    valueNotifier: _periodDayPasswordNotifier,
                                    postFix: 'h' /*hours*/,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            child: Text(
                              AppLocalizations.of(context)!.addToken,
                              style: Theme.of(context).textTheme.headlineSmall,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                            onPressed: () {
                              final token = _buildTokenIfValid(context: context);
                              if (token != null) {
                                ref.read(tokenProvider.notifier).addOrReplaceToken(token);
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
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
