import '../l10n/app_localizations.dart';

class Validators {
  final AppLocalizations appLocalizations;
  const Validators(this.appLocalizations);

  String? password(String? value) {
    if (value == null || value.isEmpty) return appLocalizations.passwordCannotBeEmpty;
    if (value.length < 8) return appLocalizations.passwordMustBeAtLeast8Characters;
    if (value.contains(RegExp(r'\s'))) return appLocalizations.passwordCannotContainWhitespace;
    if (!value.contains(RegExp(r'[a-z]'))) return appLocalizations.passwordMustContainLowercaseLetter;
    if (!value.contains(RegExp(r'[A-Z]'))) return appLocalizations.passwordMustContainUppercaseLetter;
    if (!value.contains(RegExp(r'[0-9]'))) return appLocalizations.passwordMustContainNumber;
    if (!value.contains(RegExp(r"[!@#$%^&*()_+{}|:<>?`~\-=[\]\\;\',./]"))) return appLocalizations.passwordMustContainSpecialCharacter;
    return null;
  }

  String? confirmPassword(String? password, String? confirmPassword) {
    if (password != confirmPassword) return appLocalizations.passwordsDoNotMatch;
    return null;
  }
}
