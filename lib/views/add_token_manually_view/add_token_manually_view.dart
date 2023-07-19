import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_tokens/hotp_token/hotp_token.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_tokens/totp_token/totp_token.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/views/add_token_manually_view/add_token_manually_view_widgets/labeled_dropdown_button.dart';
import 'package:uuid/uuid.dart';

class AddTokenManuallyView extends ConsumerStatefulWidget {
  static const routeName = '/addTokenManually';
  static final List<int> allowedDigits = [6, 8];
  static final List<int> allowedPeriods = [30, 60];

  @override
  ConsumerState<AddTokenManuallyView> createState() => _AddTokenManuallyViewState();
}

class _AddTokenManuallyViewState extends ConsumerState<AddTokenManuallyView> {
  final ValueNotifier<Algorithms> _algorithmNotifier = ValueNotifier(Algorithms.SHA1);
  final ValueNotifier<Encodings> _encodingNotifier = ValueNotifier(Encodings.none);
  final ValueNotifier<TokenTypes> _typeNotifier = ValueNotifier(TokenTypes.HOTP);
  final ValueNotifier<int> _digitsNotifier = ValueNotifier(AddTokenManuallyView.allowedDigits[0]);
  final ValueNotifier<int> _periodNotifier = ValueNotifier(AddTokenManuallyView.allowedPeriods[0]);
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
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.enterDetailsForToken,
          overflow: TextOverflow.ellipsis, // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
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
                  labelText: AppLocalizations.of(context)!.secret,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterASecretForThisToken;
                  } else if (!isValidEncoding(value, _encodingNotifier.value)) {
                    return AppLocalizations.of(context)!.theSecretDoesNotFitTheCurrentEncoding;
                  }
                  return null;
                },
              ),
              LabeledDropdownButton<Encodings>(
                label: AppLocalizations.of(context)!.encoding,
                values: Encodings.values,
                valueNotifier: _encodingNotifier,
              ),
              LabeledDropdownButton<Algorithms>(
                label: AppLocalizations.of(context)!.algorithm,
                values: Algorithms.values,
                valueNotifier: _algorithmNotifier,
              ),
              LabeledDropdownButton<int>(
                label: AppLocalizations.of(context)!.digits,
                values: AddTokenManuallyView.allowedDigits,
                valueNotifier: _digitsNotifier,
              ),
              LabeledDropdownButton<TokenTypes>(
                label: AppLocalizations.of(context)!.type,
                values: List.from(TokenTypes.values)..remove(TokenTypes.PIPUSH),
                valueNotifier: _typeNotifier,
              ),
              Visibility(
                // the period is only used by TOTP tokens
                visible: _typeNotifier.value == TokenTypes.TOTP,
                child: LabeledDropdownButton(
                  label: AppLocalizations.of(context)!.period,
                  values: AddTokenManuallyView.allowedPeriods,
                  valueNotifier: _periodNotifier,
                  postFix: 's' /*seconds*/,
                  //_buildDropdownButtonWithLabel(AppLocalizations.of(context)!.period, _selectedPeriod, allowedPeriods, postFix: 's' /*seconds*/),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text(
                    AppLocalizations.of(context)!.addToken,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  onPressed: () {
                    final token = _buildTokenIfValid(context: context);
                    if (token != null) {
                      ref.read(tokenProvider.notifier).addToken(token);
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

  OTPToken? _buildTokenIfValid({required BuildContext context}) {
    if (_inputIsValid(context) == false) return null;
    Logger.info('Input is valid, building token');
    return switch (_typeNotifier.value) {
      TokenTypes.HOTP => _buildHOTPToken(),
      TokenTypes.TOTP => _buildTOTPToken(),
      // TODO: Uncomment when dayPassword is implemented
      // TokenTypes.dayPassword => _buildDayPasswordToken(),

      _ => null,
    };
  }

  HOTPToken _buildHOTPToken() {
    return HOTPToken(
      label: _labelController.text,
      issuer: '',
      id: Uuid().v4(),
      algorithm: _algorithmNotifier.value,
      digits: _digitsNotifier.value,
      secret: encodeSecretAs(decodeSecretToUint8(_secretController.text, _encodingNotifier.value), Encodings.base32),
    );
  }

  TOTPToken _buildTOTPToken() => TOTPToken(
        label: _labelController.text,
        issuer: '',
        id: Uuid().v4(),
        algorithm: _algorithmNotifier.value,
        digits: _digitsNotifier.value,
        secret: encodeSecretAs(decodeSecretToUint8(_secretController.text, _encodingNotifier.value), Encodings.base32),
        period: _periodNotifier.value,
      );

  /// Validates the inputs, builds the token instances and returns them by
  /// popping the screen.

  /// Validates the inputs of the label and secret. Returns true if the input
  /// is valid and false if not.
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
