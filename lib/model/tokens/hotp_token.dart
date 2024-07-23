import 'package:json_annotation/json_annotation.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:uuid/uuid.dart';

import '../../utils/errors.dart';
import '../../utils/identifiers.dart';
import '../enums/algorithms.dart';
import '../enums/encodings.dart';
import '../enums/token_types.dart';
import '../extensions/enums/algorithms_extension.dart';
import '../extensions/enums/encodings_extension.dart';
import '../token_import/token_origin_data.dart';
import 'otp_token.dart';
import 'token.dart';

part 'hotp_token.g.dart';

@JsonSerializable()
class HOTPToken extends OTPToken {
  static String get tokenType => TokenTypes.HOTP.name;
  final int counter; // this value is used to calculate the current otp value

  @override
  Duration get showDuration => const Duration(seconds: 30);

  HOTPToken({
    this.counter = 0,
    required super.id,
    required super.algorithm,
    required super.digits,
    required super.secret,
    super.serial,
    String? type, // just for @JsonSerializable(): type of HOTPToken is always TokenTypes.HOTP
    super.tokenImage,
    super.pin,
    super.isLocked,
    super.isHidden,
    super.sortIndex,
    super.folderId,
    super.origin,
    super.label = '',
    super.issuer = '',
  }) : super(type: TokenTypes.HOTP.name);

  @override
  bool sameValuesAs(Token other) => super.sameValuesAs(other) && other is HOTPToken && other.counter == counter;

  @override
  // Counter can be changed even if its the same token
  bool isSameTokenAs(Token other) => super.isSameTokenAs(other) && other is HOTPToken;

  @override
  String get otpValue => algorithm.generateHOTPCodeString(
        secret: secret,
        counter: counter,
        length: digits,
        isGoogle: true,
      );

  HOTPToken withNextCounter() => copyWith(counter: counter + 1);

  @override
  HOTPToken copyWith({
    String? serial,
    int? counter,
    String? label,
    String? issuer,
    String? id,
    Algorithms? algorithm,
    int? digits,
    String? secret,
    String? tokenImage,
    bool? pin,
    bool? isLocked,
    bool? isHidden,
    int? sortIndex,
    int? Function()? folderId,
    TokenOriginData? origin,
  }) =>
      HOTPToken(
        serial: serial ?? this.serial,
        counter: counter ?? this.counter,
        label: label ?? this.label,
        issuer: issuer ?? this.issuer,
        id: id ?? this.id,
        algorithm: algorithm ?? this.algorithm,
        digits: digits ?? this.digits,
        secret: secret ?? this.secret,
        tokenImage: tokenImage ?? this.tokenImage,
        pin: pin ?? this.pin,
        isLocked: isLocked ?? this.isLocked,
        isHidden: isHidden ?? this.isHidden,
        sortIndex: sortIndex ?? this.sortIndex,
        folderId: folderId != null ? folderId() : this.folderId,
        origin: origin ?? this.origin,
      );

  @override
  String toString() {
    return 'H${super.toString()}counter: $counter}';
  }

  @override
  HOTPToken copyWithFromTemplate(TokenTemplate template) {
    final uriMap = template.data;
    return copyWith(
      label: uriMap[URI_LABEL],
      issuer: uriMap[URI_ISSUER],
      id: uriMap[TOKEN_ID],
      algorithm: uriMap[URI_ALGORITHM] != null ? Algorithms.values.byName((uriMap[URI_ALGORITHM] as String).toUpperCase()) : null,
      digits: uriMap[URI_DIGITS],
      secret: uriMap[URI_SECRET] != null ? Encodings.base32.encode(uriMap[URI_SECRET]) : null,
      counter: uriMap[URI_COUNTER],
      tokenImage: uriMap[URI_IMAGE],
      pin: uriMap[URI_PIN],
      isLocked: uriMap[URI_PIN],
      origin: uriMap[URI_ORIGIN],
    );
  }

  factory HOTPToken.fromUriMap(Map<String, dynamic> uriMap) {
    validateUriMap(uriMap);
    return HOTPToken(
      label: uriMap[URI_LABEL] ?? '',
      issuer: uriMap[URI_ISSUER] ?? '',
      id: const Uuid().v4(),
      algorithm: Algorithms.values.byName((uriMap[URI_ALGORITHM] as String? ?? 'SHA1').toUpperCase()),
      digits: uriMap[URI_DIGITS] ?? 6,
      secret: Encodings.base32.encode(uriMap[URI_SECRET]),
      counter: uriMap[URI_COUNTER] ?? 0,
      tokenImage: uriMap[URI_IMAGE],
      pin: uriMap[URI_PIN],
      isLocked: uriMap[URI_PIN],
      origin: uriMap[URI_ORIGIN],
    );
  }

  /// ```dart
  /// URI_TYPE: tokenType,
  /// URI_COUNTER: counter,
  /// ```
  /// ------ OTPTOKEN ------
  /// ```dart
  /// URI_SECRET: Encodings.base32.decode(secret),
  /// URI_ALGORITHM: algorithm.name,
  /// URI_DIGITS: digits,
  /// ```
  /// ------- TOKEN ---------
  /// ```dart
  /// URI_LABEL: label,
  /// URI_ISSUER: issuer,
  /// URI_PIN: pin,
  /// URI_IMAGE: tokenImage,
  /// URI_ORIGIN: jsonEncode(origin!.toJson()),
  /// ```
  @override
  Map<String, dynamic> toUriMap() {
    return super.toUriMap()
      ..addAll({
        URI_COUNTER: counter,
      });
  }

  /// Validates the uriMap for the required fields throws [LocalizedArgumentError] if a field is missing or invalid.
  static void validateUriMap(Map<String, dynamic> uriMap) {
    if (uriMap[URI_SECRET] == null) {
      throw LocalizedArgumentError(
          invalidValue: uriMap[URI_SECRET],
          name: URI_SECRET,
          unlocalizedMessage: 'Secret is required',
          localizedMessage: ((localizations, value, name) => localizations.secretIsRequired));
    }
    if (uriMap[URI_DIGITS] != null && uriMap[URI_DIGITS] < 1) {
      throw LocalizedArgumentError(
          invalidValue: uriMap[URI_DIGITS],
          name: URI_DIGITS,
          unlocalizedMessage: 'Digits must be greater than 0',
          localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter));
    }
    if (uriMap[URI_ALGORITHM] != null) {
      try {
        Algorithms.values.byName((uriMap[URI_ALGORITHM] as String).toUpperCase());
      } catch (e) {
        throw LocalizedArgumentError(
            invalidValue: uriMap[URI_ALGORITHM],
            name: URI_ALGORITHM,
            unlocalizedMessage: 'Algorithm ${uriMap[URI_ALGORITHM]} is not supported',
            localizedMessage: (localizations, value, parameter) => localizations.invalidValueForParameter(value, parameter));
      }
    }
  }

  @override
  Map<String, dynamic> toJson() => _$HOTPTokenToJson(this);
  factory HOTPToken.fromJson(Map<String, dynamic> json) => _$HOTPTokenFromJson(json);
}
