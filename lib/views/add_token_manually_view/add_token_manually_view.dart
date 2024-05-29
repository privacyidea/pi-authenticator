import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../mains/main_netknights.dart';
import '../../model/enums/algorithms.dart';
import '../../model/enums/encodings.dart';
import '../../model/enums/token_origin_source_type.dart';
import '../../model/enums/token_types.dart';
import '../../model/extensions/enums/encodings_extension.dart';
import '../../model/extensions/enums/token_origin_source_type.dart';
import '../../model/tokens/token.dart';
import '../../utils/identifiers.dart';
import '../../utils/logger.dart';
import '../../utils/riverpod_providers.dart';
import 'add_token_manually_view_widgets/labeled_dropdown_button.dart';

class AddTokenManuallyView extends ConsumerStatefulWidget {
  static const routeName = '/add_token_manually';
  static final List<int> allowedDigits = [6, 8];
  static final List<int> allowedPeriodsTOTP = [30, 60];
  static final List<int> allowedPeriodsDayPassword = [24, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1];

  const AddTokenManuallyView({super.key});

  @override
  ConsumerState<AddTokenManuallyView> createState() => _AddTokenManuallyViewState();
}

class _AddTokenManuallyViewState extends ConsumerState<AddTokenManuallyView> {
  final ValueNotifier<Algorithms> _algorithmNotifier = ValueNotifier(Algorithms.SHA512);
  final ValueNotifier<Encodings> _encodingNotifier = ValueNotifier(Encodings.none);
  final ValueNotifier<TokenTypes> _typeNotifier = ValueNotifier(TokenTypes.HOTP);
  final ValueNotifier<int> _digitsNotifier = ValueNotifier(AddTokenManuallyView.allowedDigits[0]);
  final ValueNotifier<int> _periodNotifier = ValueNotifier(AddTokenManuallyView.allowedPeriodsTOTP[0]);
  final ValueNotifier<int> _periodDayPasswordNotifier = ValueNotifier(AddTokenManuallyView.allowedPeriodsDayPassword[0]);
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();

  // fields needed to manage the widget
  final _labelInputKey = GlobalKey<FormFieldState>();
  final _secretInputKey = GlobalKey<FormFieldState>();

  // used to handle focusing certain input fields
  final FocusNode _labelFieldFocus = FocusNode();
  final FocusNode _secretFieldFocus = FocusNode();

  AutovalidateMode _autoValidateLabel = AutovalidateMode.disabled;
  AutovalidateMode _autoValidateSecret = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    _typeNotifier.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.enterDetailsForToken,
          overflow: TextOverflow.ellipsis, // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          child: Column(
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text(
                    AppLocalizations.of(context)!.addToken,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
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
    );
  }

  Token? _buildTokenIfValid({required BuildContext context}) {
    if (_inputIsValid(context) == false) return null;
    Logger.info('Input is valid, building token');

    final uriMap = <String, dynamic>{
      URI_TYPE: _typeNotifier.value.name,
      URI_LABEL: _labelController.text,
      URI_ISSUER: '',
      URI_ALGORITHM: _algorithmNotifier.value.name,
      URI_DIGITS: _digitsNotifier.value,
      URI_SECRET: _encodingNotifier.value.decode(_secretController.text),
      URI_COUNTER: 0,
      URI_PERIOD: _typeNotifier.value == TokenTypes.DAYPASSWORD ? _periodDayPasswordNotifier.value * 60 * 60 : _periodNotifier.value,
    };
    uriMap.addAll({
      URI_ORIGIN: TokenOriginSourceType.manually.toTokenOrigin(
        data: jsonEncode(uriMap),
        originName: PrivacyIDEAAuthenticator.currentCustomization?.appName,
        isPrivacyIdeaToken: false,
      ),
    });
    return Token.fromUriMap(uriMap);
  }

  /// Validates the inputs of the label and secret.
  bool _inputIsValid(BuildContext context) {
    if (_labelInputKey.currentState!.validate()) {
      _labelInputKey.currentState!.save();
    } else {
      setState(() {
        _autoValidateLabel = AutovalidateMode.always;
      });
      FocusScope.of(context).requestFocus(_labelFieldFocus);
      return false;
    }

    if (_secretInputKey.currentState!.validate()) {
      _secretInputKey.currentState!.save();
    } else {
      setState(() {
        _autoValidateSecret = AutovalidateMode.always;
      });
      FocusScope.of(context).requestFocus(_secretFieldFocus);
      return false;
    }

    return true;
  }
}
