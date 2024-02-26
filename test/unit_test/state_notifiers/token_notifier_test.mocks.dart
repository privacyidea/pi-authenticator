// Mocks generated by Mockito 5.4.4 from annotations
// in privacyidea_authenticator/test/unit_test/state_notifiers/token_notifier_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:typed_data' as _i9;

import 'package:firebase_messaging/firebase_messaging.dart' as _i13;
import 'package:http/http.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i8;
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart' as _i14;
import 'package:pointycastle/export.dart' as _i2;
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart'
    as _i4;
import 'package:privacyidea_authenticator/model/tokens/push_token.dart' as _i10;
import 'package:privacyidea_authenticator/model/tokens/token.dart' as _i6;
import 'package:privacyidea_authenticator/utils/firebase_utils.dart' as _i12;
import 'package:privacyidea_authenticator/utils/network_utils.dart' as _i11;
import 'package:privacyidea_authenticator/utils/rsa_utils.dart' as _i7;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeRSAPublicKey_0 extends _i1.SmartFake implements _i2.RSAPublicKey {
  _FakeRSAPublicKey_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeRSAPrivateKey_1 extends _i1.SmartFake implements _i2.RSAPrivateKey {
  _FakeRSAPrivateKey_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAsymmetricKeyPair_2<B extends _i2.PublicKey,
        V extends _i2.PrivateKey> extends _i1.SmartFake
    implements _i2.AsymmetricKeyPair<B, V> {
  _FakeAsymmetricKeyPair_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeResponse_3 extends _i1.SmartFake implements _i3.Response {
  _FakeResponse_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [TokenRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockTokenRepository extends _i1.Mock implements _i4.TokenRepository {
  MockTokenRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<_i6.Token?> loadToken(String? id) => (super.noSuchMethod(
        Invocation.method(
          #loadToken,
          [id],
        ),
        returnValue: _i5.Future<_i6.Token?>.value(),
      ) as _i5.Future<_i6.Token?>);

  @override
  _i5.Future<List<_i6.Token>> loadTokens() => (super.noSuchMethod(
        Invocation.method(
          #loadTokens,
          [],
        ),
        returnValue: _i5.Future<List<_i6.Token>>.value(<_i6.Token>[]),
      ) as _i5.Future<List<_i6.Token>>);

  @override
  _i5.Future<bool> saveOrReplaceToken(_i6.Token? token) => (super.noSuchMethod(
        Invocation.method(
          #saveOrReplaceToken,
          [token],
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<List<T>> saveOrReplaceTokens<T extends _i6.Token>(
          List<T>? tokens) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveOrReplaceTokens,
          [tokens],
        ),
        returnValue: _i5.Future<List<T>>.value(<T>[]),
      ) as _i5.Future<List<T>>);

  @override
  _i5.Future<bool> deleteToken(_i6.Token? token) => (super.noSuchMethod(
        Invocation.method(
          #deleteToken,
          [token],
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<List<T>> deleteTokens<T extends _i6.Token>(List<T>? tokens) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteTokens,
          [tokens],
        ),
        returnValue: _i5.Future<List<T>>.value(<T>[]),
      ) as _i5.Future<List<T>>);
}

/// A class which mocks [RsaUtils].
///
/// See the documentation for Mockito's code generation for more information.
class MockRsaUtils extends _i1.Mock implements _i7.RsaUtils {
  MockRsaUtils() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.RSAPublicKey deserializeRSAPublicKeyPKCS1(String? keyStr) =>
      (super.noSuchMethod(
        Invocation.method(
          #deserializeRSAPublicKeyPKCS1,
          [keyStr],
        ),
        returnValue: _FakeRSAPublicKey_0(
          this,
          Invocation.method(
            #deserializeRSAPublicKeyPKCS1,
            [keyStr],
          ),
        ),
      ) as _i2.RSAPublicKey);

  @override
  String serializeRSAPublicKeyPKCS1(_i2.RSAPublicKey? publicKey) =>
      (super.noSuchMethod(
        Invocation.method(
          #serializeRSAPublicKeyPKCS1,
          [publicKey],
        ),
        returnValue: _i8.dummyValue<String>(
          this,
          Invocation.method(
            #serializeRSAPublicKeyPKCS1,
            [publicKey],
          ),
        ),
      ) as String);

  @override
  _i2.RSAPublicKey deserializeRSAPublicKeyPKCS8(String? keyStr) =>
      (super.noSuchMethod(
        Invocation.method(
          #deserializeRSAPublicKeyPKCS8,
          [keyStr],
        ),
        returnValue: _FakeRSAPublicKey_0(
          this,
          Invocation.method(
            #deserializeRSAPublicKeyPKCS8,
            [keyStr],
          ),
        ),
      ) as _i2.RSAPublicKey);

  @override
  String serializeRSAPublicKeyPKCS8(_i2.RSAPublicKey? key) =>
      (super.noSuchMethod(
        Invocation.method(
          #serializeRSAPublicKeyPKCS8,
          [key],
        ),
        returnValue: _i8.dummyValue<String>(
          this,
          Invocation.method(
            #serializeRSAPublicKeyPKCS8,
            [key],
          ),
        ),
      ) as String);

  @override
  String serializeRSAPrivateKeyPKCS1(_i2.RSAPrivateKey? key) =>
      (super.noSuchMethod(
        Invocation.method(
          #serializeRSAPrivateKeyPKCS1,
          [key],
        ),
        returnValue: _i8.dummyValue<String>(
          this,
          Invocation.method(
            #serializeRSAPrivateKeyPKCS1,
            [key],
          ),
        ),
      ) as String);

  @override
  _i2.RSAPrivateKey deserializeRSAPrivateKeyPKCS1(String? keyStr) =>
      (super.noSuchMethod(
        Invocation.method(
          #deserializeRSAPrivateKeyPKCS1,
          [keyStr],
        ),
        returnValue: _FakeRSAPrivateKey_1(
          this,
          Invocation.method(
            #deserializeRSAPrivateKeyPKCS1,
            [keyStr],
          ),
        ),
      ) as _i2.RSAPrivateKey);

  @override
  bool verifyRSASignature(
    _i2.RSAPublicKey? publicKey,
    _i9.Uint8List? signedMessage,
    _i9.Uint8List? signature,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #verifyRSASignature,
          [
            publicKey,
            signedMessage,
            signature,
          ],
        ),
        returnValue: false,
      ) as bool);

  @override
  _i5.Future<String?> trySignWithToken(
    _i10.PushToken? token,
    String? message,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #trySignWithToken,
          [
            token,
            message,
          ],
        ),
        returnValue: _i5.Future<String?>.value(),
      ) as _i5.Future<String?>);

  @override
  _i5.Future<_i2.AsymmetricKeyPair<_i2.RSAPublicKey, _i2.RSAPrivateKey>>
      generateRSAKeyPair() => (super.noSuchMethod(
            Invocation.method(
              #generateRSAKeyPair,
              [],
            ),
            returnValue: _i5.Future<
                    _i2.AsymmetricKeyPair<_i2.RSAPublicKey,
                        _i2.RSAPrivateKey>>.value(
                _FakeAsymmetricKeyPair_2<_i2.RSAPublicKey, _i2.RSAPrivateKey>(
              this,
              Invocation.method(
                #generateRSAKeyPair,
                [],
              ),
            )),
          ) as _i5.Future<
              _i2.AsymmetricKeyPair<_i2.RSAPublicKey, _i2.RSAPrivateKey>>);

  @override
  String createBase32Signature(
    _i2.RSAPrivateKey? privateKey,
    _i9.Uint8List? dataToSign,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #createBase32Signature,
          [
            privateKey,
            dataToSign,
          ],
        ),
        returnValue: _i8.dummyValue<String>(
          this,
          Invocation.method(
            #createBase32Signature,
            [
              privateKey,
              dataToSign,
            ],
          ),
        ),
      ) as String);

  @override
  _i9.Uint8List createRSASignature(
    _i2.RSAPrivateKey? privateKey,
    _i9.Uint8List? dataToSign,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #createRSASignature,
          [
            privateKey,
            dataToSign,
          ],
        ),
        returnValue: _i9.Uint8List(0),
      ) as _i9.Uint8List);
}

/// A class which mocks [PrivacyIdeaIOClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockPrivacyIdeaIOClient extends _i1.Mock
    implements _i11.PrivacyIdeaIOClient {
  MockPrivacyIdeaIOClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<bool> triggerNetworkAccessPermission({
    required Uri? url,
    bool? sslVerify = true,
    bool? isRetry = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #triggerNetworkAccessPermission,
          [],
          {
            #url: url,
            #sslVerify: sslVerify,
            #isRetry: isRetry,
          },
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<_i3.Response> doPost({
    required Uri? url,
    required Map<String, String?>? body,
    bool? sslVerify = true,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #doPost,
          [],
          {
            #url: url,
            #body: body,
            #sslVerify: sslVerify,
          },
        ),
        returnValue: _i5.Future<_i3.Response>.value(_FakeResponse_3(
          this,
          Invocation.method(
            #doPost,
            [],
            {
              #url: url,
              #body: body,
              #sslVerify: sslVerify,
            },
          ),
        )),
      ) as _i5.Future<_i3.Response>);

  @override
  _i5.Future<_i3.Response> doGet({
    required Uri? url,
    required Map<String, String?>? parameters,
    bool? sslVerify = true,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #doGet,
          [],
          {
            #url: url,
            #parameters: parameters,
            #sslVerify: sslVerify,
          },
        ),
        returnValue: _i5.Future<_i3.Response>.value(_FakeResponse_3(
          this,
          Invocation.method(
            #doGet,
            [],
            {
              #url: url,
              #parameters: parameters,
              #sslVerify: sslVerify,
            },
          ),
        )),
      ) as _i5.Future<_i3.Response>);
}

/// A class which mocks [FirebaseUtils].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseUtils extends _i1.Mock implements _i12.FirebaseUtils {
  MockFirebaseUtils() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<void> initFirebase({
    required _i5.Future<void> Function(_i13.RemoteMessage)? foregroundHandler,
    required _i5.Future<void> Function(_i13.RemoteMessage)? backgroundHandler,
    required dynamic Function(String?)? updateFirebaseToken,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #initFirebase,
          [],
          {
            #foregroundHandler: foregroundHandler,
            #backgroundHandler: backgroundHandler,
            #updateFirebaseToken: updateFirebaseToken,
          },
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<String?> getFBToken() => (super.noSuchMethod(
        Invocation.method(
          #getFBToken,
          [],
        ),
        returnValue: _i5.Future<String?>.value(),
      ) as _i5.Future<String?>);
}

/// A class which mocks [LegacyUtils].
///
/// See the documentation for Mockito's code generation for more information.
class MockLegacyUtils extends _i1.Mock implements _i14.LegacyUtils {
  MockLegacyUtils() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<String> sign(
    String? serial,
    String? message,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #sign,
          [
            serial,
            message,
          ],
        ),
        returnValue: _i5.Future<String>.value(_i8.dummyValue<String>(
          this,
          Invocation.method(
            #sign,
            [
              serial,
              message,
            ],
          ),
        )),
      ) as _i5.Future<String>);

  @override
  _i5.Future<bool> verify(
    String? serial,
    String? signedData,
    String? signature,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #verify,
          [
            serial,
            signedData,
            signature,
          ],
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);
}
