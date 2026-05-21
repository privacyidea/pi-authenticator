/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

// Error code ranges:
// - HTTP status codes:           3 digits (100-599)        — see [HttpStatusCodes]
// - privacyIDEA server codes:    3-4 digits                — see [PiServerResultErrorCodes]
// - In-app error codes:          5 digits, grouped         — see [InAppErrorCodes]
//
// Number overlaps between HTTP and privacyIDEA codes are often historical/coincidental
// rather than semantic. Treat them as independent code spaces.

/// Standard HTTP status codes (RFC 9110) plus Cloudflare-specific 5xx codes.
///
/// User-facing descriptions are provided by `AppLocalizations.httpStatus(code)`.
///
/// The classifier [HttpStatusChecker] handles range-based predicates;
/// this class is for matching/identifying specific codes.
class HttpStatusCodes {
  // 1xx Informational
  static const continue_ = 100;
  static const switchingProtocols = 101;
  static const processing = 102;
  static const earlyHints = 103;

  // 2xx Success
  static const ok = 200;
  static const created = 201;
  static const accepted = 202;
  static const nonAuthoritativeInformation = 203;
  static const noContent = 204;
  static const resetContent = 205;
  static const partialContent = 206;
  static const multiStatus = 207;
  static const alreadyReported = 208;
  static const imUsed = 226;

  // 3xx Redirection
  static const multipleChoices = 300;
  static const movedPermanently = 301;
  static const found = 302;
  static const seeOther = 303;
  static const notModified = 304;
  static const useProxy = 305;
  static const temporaryRedirect = 307;
  static const permanentRedirect = 308;

  // 4xx Client Error
  static const badRequest = 400;
  static const unauthorized = 401;
  static const paymentRequired = 402;
  static const forbidden = 403;
  static const notFound = 404;
  static const methodNotAllowed = 405;
  static const notAcceptable = 406;
  static const proxyAuthenticationRequired = 407;
  static const requestTimeout = 408;
  static const conflict = 409;
  static const gone = 410;
  static const lengthRequired = 411;
  static const preconditionFailed = 412;
  static const payloadTooLarge = 413;
  static const uriTooLong = 414;
  static const unsupportedMediaType = 415;
  static const rangeNotSatisfiable = 416;
  static const expectationFailed = 417;
  static const imATeapot = 418;
  static const misdirectedRequest = 421;
  static const unprocessableEntity = 422;
  static const locked = 423;
  static const failedDependency = 424;
  static const tooEarly = 425;
  static const upgradeRequired = 426;
  static const preconditionRequired = 428;
  static const tooManyRequests = 429;
  static const requestHeaderFieldsTooLarge = 431;
  static const unavailableForLegalReasons = 451;

  // 5xx Server Error
  static const internalServerError = 500;
  static const notImplemented = 501;
  static const badGateway = 502;
  static const serviceUnavailable = 503;
  static const gatewayTimeout = 504;
  static const httpVersionNotSupported = 505;
  static const variantAlsoNegotiates = 506;
  static const insufficientStorage = 507;
  static const loopDetected = 508;
  static const notExtended = 510;
  static const networkAuthenticationRequired = 511;

  // 5xx Cloudflare-specific
  static const webServerReturnedUnknownError = 520;
  static const webServerIsDown = 521;
  static const connectionTimedOut = 522;
  static const originIsUnreachable = 523;
  static const aTimeoutOccurred = 524;
  static const sslHandshakeFailed = 525;
  static const invalidSslCertificate = 526;
  static const railgunError = 527;
}

/// Error codes returned by the privacyIDEA server in the `result.error.code` field.
///
/// Canonical source: `privacyidea/lib/error.py` (class `Error`).
/// Naming follows the canonical privacyIDEA identifiers, not HTTP semantics —
/// number overlaps with HTTP status codes are coincidental.
///
/// Numbering convention:
/// - 3-digit codes denote a **category** (e.g. `403 AUTHENTICATE`, `905 PARAMETER`)
/// - 4-digit codes are **subcategories** that embed their parent's digits
///   (e.g. `4031, 4032, 4033` are subs of `403`; `9051` is a sub of `905`).
///
/// Note: a few legacy subcodes (`4304-4307`) break the embedding convention but
/// still belong to category `403 AUTHENTICATE`.
class PiServerResultErrorCodes {
  // Subscription / Admin (100–300)
  static const subscription = 101;
  static const tokenAdmin = 301;
  static const configAdmin = 302;
  static const policy = 303;
  static const importAdmin = 304;

  // Validation & Authentication (400s)
  static const validate = 401;
  static const registration = 402;
  static const authenticate = 403;
  static const authenticateWrongCredentials = 4031;
  static const authenticateMissingUsername = 4032;
  static const authenticateAuthHeader = 4033;
  static const authenticateDecodingError = 4304;
  static const authenticateTokenExpired = 4305;
  static const authenticateMissingRight = 4306;
  static const authenticateIllegalMethod = 4307;
  static const enrollment = 404;

  // CA & Resources (500–600)
  static const ca = 503;
  static const caCsrInvalid = 504;
  static const caCsrPending = 505;
  static const resourceNotFound = 601;

  // System & Database (700–900)
  static const hsm = 707;
  static const selfservice = 807;
  static const database = 902;
  static const server = 903;
  static const user = 904;
  static const parameter = 905;
  static const parameterUserMissing = 9051;
  static const resolver = 907;

  // Container (3000s)
  static const container = 3000;
  static const containerNotRegistered = 3001;
  static const containerInvalidChallenge = 3002;
  static const containerRollover = 3003;

  // Additional codes raised inline in the server (not part of the canonical Error class)
  static const genkeyOrOtpkey = 344; // tokenclass.py:654 — genkey or otpkey, but not both
  static const tokenLocked = 1007; // decorators.py:44, token.py:2524
  static const noUniqueTokenToCopyFrom = 1016; // decorators.py:141
  static const noUniqueTokenToCopyTo = 1017; // decorators.py:145
  static const tokenAlreadyAssigned = 1103; // token.py:1513
  static const tokenAssignFailed = 1105; // token.py:1526
  static const tokenFailCounterUpdateFailed = 1106; // tokenclass.py:1027
  static const multipleTokensMatchOtp = 1200; // token.py:1078
  static const userParamNotString = 1212; // token.py:1636
  static const createTokenclassObjectFailed = 1609; // token.py:164
  static const unknownTokenType = 1610; // token.py:1302
  static const lostTokenOnlyForAssigned = 2012; // token.py:2193
  static const radiusSecretTooLong = 2234; // radiusserver.py:262

  /// Developer-facing English description for a given privacyIDEA server code.
  /// Returns `null` for codes not explicitly named here.
  /// Intended for logs/debug output — NOT for user-facing UI (use localizations).
  static String? describe(int code) => switch (code) {
        subscription => 'Subscription error',
        tokenAdmin => 'Token administration error',
        configAdmin => 'Config administration error',
        policy => 'Policy error',
        importAdmin => 'Import administration error',
        validate => 'Token validation error',
        registration => 'Registration error',
        authenticate => 'Authentication error (root category)',
        authenticateWrongCredentials => 'Authentication: wrong credentials',
        authenticateMissingUsername => 'Authentication: missing username',
        authenticateAuthHeader => 'Authentication: bad auth header',
        authenticateDecodingError => 'Authentication: decoding error',
        authenticateTokenExpired => 'Authentication: auth token expired',
        authenticateMissingRight => 'Authentication: missing right/permission',
        authenticateIllegalMethod => 'Authentication: illegal HTTP method',
        enrollment => 'Enrollment failed',
        ca => 'CA error',
        caCsrInvalid => 'CA: CSR invalid',
        caCsrPending => 'CA: CSR pending',
        resourceNotFound => 'Resource not found',
        hsm => 'HSM error',
        selfservice => 'Self-service error',
        database => 'Database error',
        server => 'Server error',
        user => 'User error',
        parameter => 'Parameter error',
        parameterUserMissing => 'Parameter: user missing',
        resolver => 'Resolver error',
        container => 'Container error (root category)',
        containerNotRegistered => 'Container is not registered',
        containerInvalidChallenge => 'Container challenge could not be verified',
        containerRollover => 'Container rollover error',
        genkeyOrOtpkey => 'genkey or otpkey, but not both',
        tokenLocked => 'Token is locked',
        noUniqueTokenToCopyFrom => 'No unique token to copy from',
        noUniqueTokenToCopyTo => 'No unique token to copy to',
        tokenAlreadyAssigned => 'Token already assigned to user',
        tokenAssignFailed => 'Token assign/unassign failed',
        tokenFailCounterUpdateFailed => 'Token fail counter update failed',
        multipleTokensMatchOtp => 'Multiple tokens match OTP',
        userParamNotString => 'User parameter must not be a string',
        createTokenclassObjectFailed => 'create_tokenclass_object failed',
        unknownTokenType => 'Unknown token type',
        lostTokenOnlyForAssigned => 'Lost token only for assigned tokens',
        radiusSecretTooLong => 'RADIUS secret too long',
        _ => null,
      };
}

/// In-app error codes (5 digits).
///
/// Codes are grouped by category to make their origin recognizable at a glance:
///
/// - `1xxxx` Parsing / serialization (JSON, response validation, decoding)
/// - `2xxxx` Network / I/O (transport failures not represented by HTTP status)
/// - `3xxxx` Storage / repository (secure storage, local persistence)
/// - `4xxxx` Crypto / security (signature, key handling, encryption)
/// - `5xxxx` Container / token state (illegal state transitions, missing entities)
/// - `9xxxx` Generic / unknown (fallback / uncategorized failures)
class InAppErrorCodes {
  // 1xxxx — Parsing / serialization
  static const jsonParseError = 10001;

  // 4xxxx — Crypto / security
  static const failedToEncryptTokens = 40001;
  static const failedToDecryptTokens = 40002;
  static const failedToGenerateExportUri = 40003;
  static const failedToGenerateQrCode = 40004;
  static const failedToParseTokenFromUri = 40005;

  // 5xxxx — Container / token state
  static const containerWasRemoved = 50001;

  /// Developer-facing English description for a given in-app code.
  /// Returns `null` for codes not explicitly named here.
  /// Intended for logs/debug output — NOT for user-facing UI (use localizations).
  static String? describe(int code) => switch (code) {
        jsonParseError => 'Failed to parse JSON response (non-JSON body)',
        failedToEncryptTokens => 'Failed to encrypt tokens',
        failedToDecryptTokens => 'Failed to decrypt tokens',
        failedToGenerateExportUri => 'Failed to generate export URI',
        failedToGenerateQrCode => 'Failed to generate QR code',
        failedToParseTokenFromUri => 'Failed to parse token from URI',
        containerWasRemoved => 'Container was removed',
        _ => null,
      };
}
