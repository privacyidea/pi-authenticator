// Mocks generated by Mockito 5.4.4 from annotations
// in privacyidea_authenticator/test/unit_test/state_notifiers/token_notifier_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;
import 'dart:typed_data' as _i11;

import 'package:firebase_messaging/firebase_messaging.dart' as _i15;
import 'package:http/http.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i10;
import 'package:pointycastle/export.dart' as _i3;
import 'package:privacyidea_authenticator/interfaces/repo/settings_repository.dart'
    as _i8;
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart'
    as _i5;
import 'package:privacyidea_authenticator/model/states/settings_state.dart'
    as _i2;
import 'package:privacyidea_authenticator/model/tokens/push_token.dart' as _i12;
import 'package:privacyidea_authenticator/model/tokens/token.dart' as _i7;
import 'package:privacyidea_authenticator/utils/firebase_utils.dart' as _i14;
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart'
    as _i13;
import 'package:privacyidea_authenticator/utils/rsa_utils.dart' as _i9;

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

class _FakeSettingsState_0 extends _i1.SmartFake implements _i2.SettingsState {
  _FakeSettingsState_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeRSAPublicKey_1 extends _i1.SmartFake implements _i3.RSAPublicKey {
  _FakeRSAPublicKey_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeRSAPrivateKey_2 extends _i1.SmartFake implements _i3.RSAPrivateKey {
  _FakeRSAPrivateKey_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAsymmetricKeyPair_3<B extends _i3.PublicKey,
        V extends _i3.PrivateKey> extends _i1.SmartFake
    implements _i3.AsymmetricKeyPair<B, V> {
  _FakeAsymmetricKeyPair_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeResponse_4 extends _i1.SmartFake implements _i4.Response {
  _FakeResponse_4(
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
class MockTokenRepository extends _i1.Mock implements _i5.TokenRepository {
  MockTokenRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<_i7.Token?> loadToken(String? id) => (super.noSuchMethod(
        Invocation.method(
          #loadToken,
          [id],
        ),
        returnValue: _i6.Future<_i7.Token?>.value(),
      ) as _i6.Future<_i7.Token?>);

  @override
  _i6.Future<List<_i7.Token>> loadTokens() => (super.noSuchMethod(
        Invocation.method(
          #loadTokens,
          [],
        ),
        returnValue: _i6.Future<List<_i7.Token>>.value(<_i7.Token>[]),
      ) as _i6.Future<List<_i7.Token>>);

  @override
  _i6.Future<bool> saveOrReplaceToken(_i7.Token? token) => (super.noSuchMethod(
        Invocation.method(
          #saveOrReplaceToken,
          [token],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<List<T>> saveOrReplaceTokens<T extends _i7.Token>(
          List<T>? tokens) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveOrReplaceTokens,
          [tokens],
        ),
        returnValue: _i6.Future<List<T>>.value(<T>[]),
      ) as _i6.Future<List<T>>);

  @override
  _i6.Future<bool> deleteToken(_i7.Token? token) => (super.noSuchMethod(
        Invocation.method(
          #deleteToken,
          [token],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<List<T>> deleteTokens<T extends _i7.Token>(List<T>? tokens) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteTokens,
          [tokens],
        ),
        returnValue: _i6.Future<List<T>>.value(<T>[]),
      ) as _i6.Future<List<T>>);
}

/// A class which mocks [SettingsRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockSettingsRepository extends _i1.Mock
    implements _i8.SettingsRepository {
  MockSettingsRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<bool> saveSettings(_i2.SettingsState? settings) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveSettings,
          [settings],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<_i2.SettingsState> loadSettings() => (super.noSuchMethod(
        Invocation.method(
          #loadSettings,
          [],
        ),
        returnValue: _i6.Future<_i2.SettingsState>.value(_FakeSettingsState_0(
          this,
          Invocation.method(
            #loadSettings,
            [],
          ),
        )),
      ) as _i6.Future<_i2.SettingsState>);
}

/// A class which mocks [RsaUtils].
///
/// See the documentation for Mockito's code generation for more information.
class MockRsaUtils extends _i1.Mock implements _i9.RsaUtils {
  MockRsaUtils() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.RSAPublicKey deserializeRSAPublicKeyPKCS1(String? keyStr) =>
      (super.noSuchMethod(
        Invocation.method(
          #deserializeRSAPublicKeyPKCS1,
          [keyStr],
        ),
        returnValue: _FakeRSAPublicKey_1(
          this,
          Invocation.method(
            #deserializeRSAPublicKeyPKCS1,
            [keyStr],
          ),
        ),
      ) as _i3.RSAPublicKey);

  @override
  String serializeRSAPublicKeyPKCS1(_i3.RSAPublicKey? publicKey) =>
      (super.noSuchMethod(
        Invocation.method(
          #serializeRSAPublicKeyPKCS1,
          [publicKey],
        ),
        returnValue: _i10.dummyValue<String>(
          this,
          Invocation.method(
            #serializeRSAPublicKeyPKCS1,
            [publicKey],
          ),
        ),
      ) as String);

  @override
  _i3.RSAPublicKey deserializeRSAPublicKeyPKCS8(String? keyStr) =>
      (super.noSuchMethod(
        Invocation.method(
          #deserializeRSAPublicKeyPKCS8,
          [keyStr],
        ),
        returnValue: _FakeRSAPublicKey_1(
          this,
          Invocation.method(
            #deserializeRSAPublicKeyPKCS8,
            [keyStr],
          ),
        ),
      ) as _i3.RSAPublicKey);

  @override
  String serializeRSAPublicKeyPKCS8(_i3.RSAPublicKey? key) =>
      (super.noSuchMethod(
        Invocation.method(
          #serializeRSAPublicKeyPKCS8,
          [key],
        ),
        returnValue: _i10.dummyValue<String>(
          this,
          Invocation.method(
            #serializeRSAPublicKeyPKCS8,
            [key],
          ),
        ),
      ) as String);

  @override
  String serializeRSAPrivateKeyPKCS1(_i3.RSAPrivateKey? key) =>
      (super.noSuchMethod(
        Invocation.method(
          #serializeRSAPrivateKeyPKCS1,
          [key],
        ),
        returnValue: _i10.dummyValue<String>(
          this,
          Invocation.method(
            #serializeRSAPrivateKeyPKCS1,
            [key],
          ),
        ),
      ) as String);

  @override
  _i3.RSAPrivateKey deserializeRSAPrivateKeyPKCS1(String? keyStr) =>
      (super.noSuchMethod(
        Invocation.method(
          #deserializeRSAPrivateKeyPKCS1,
          [keyStr],
        ),
        returnValue: _FakeRSAPrivateKey_2(
          this,
          Invocation.method(
            #deserializeRSAPrivateKeyPKCS1,
            [keyStr],
          ),
        ),
      ) as _i3.RSAPrivateKey);

  @override
  bool verifyRSASignature(
    _i3.RSAPublicKey? publicKey,
    _i11.Uint8List? signedMessage,
    _i11.Uint8List? signature,
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
  _i6.Future<String?> trySignWithToken(
    _i12.PushToken? token,
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
        returnValue: _i6.Future<String?>.value(),
      ) as _i6.Future<String?>);

  @override
  _i6.Future<_i3.AsymmetricKeyPair<_i3.RSAPublicKey, _i3.RSAPrivateKey>>
      generateRSAKeyPair() => (super.noSuchMethod(
            Invocation.method(
              #generateRSAKeyPair,
              [],
            ),
            returnValue: _i6.Future<
                    _i3.AsymmetricKeyPair<_i3.RSAPublicKey,
                        _i3.RSAPrivateKey>>.value(
                _FakeAsymmetricKeyPair_3<_i3.RSAPublicKey, _i3.RSAPrivateKey>(
              this,
              Invocation.method(
                #generateRSAKeyPair,
                [],
              ),
            )),
          ) as _i6.Future<
              _i3.AsymmetricKeyPair<_i3.RSAPublicKey, _i3.RSAPrivateKey>>);

  @override
  String createBase32Signature(
    _i3.RSAPrivateKey? privateKey,
    _i11.Uint8List? dataToSign,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #createBase32Signature,
          [
            privateKey,
            dataToSign,
          ],
        ),
        returnValue: _i10.dummyValue<String>(
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
  _i11.Uint8List createRSASignature(
    _i3.RSAPrivateKey? privateKey,
    _i11.Uint8List? dataToSign,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #createRSASignature,
          [
            privateKey,
            dataToSign,
          ],
        ),
        returnValue: _i11.Uint8List(0),
      ) as _i11.Uint8List);
}

/// A class which mocks [PrivacyideaIOClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockPrivacyideaIOClient extends _i1.Mock
    implements _i13.PrivacyideaIOClient {
  MockPrivacyideaIOClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<bool> triggerNetworkAccessPermission({
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
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<_i4.Response> doPost({
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
        returnValue: _i6.Future<_i4.Response>.value(_FakeResponse_4(
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
      ) as _i6.Future<_i4.Response>);

  @override
  _i6.Future<_i4.Response> doGet({
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
        returnValue: _i6.Future<_i4.Response>.value(_FakeResponse_4(
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
      ) as _i6.Future<_i4.Response>);
}

/// A class which mocks [FirebaseUtils].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseUtils extends _i1.Mock implements _i14.FirebaseUtils {
  MockFirebaseUtils() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<void> initFirebase({
    required _i6.Future<void> Function(_i15.RemoteMessage)? foregroundHandler,
    required _i6.Future<void> Function(_i15.RemoteMessage)? backgroundHandler,
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
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<String?> getFBToken() => (super.noSuchMethod(
        Invocation.method(
          #getFBToken,
          [],
        ),
        returnValue: _i6.Future<String?>.value(),
      ) as _i6.Future<String?>);

  @override
  _i6.Future<bool> deleteFirebaseToken() => (super.noSuchMethod(
        Invocation.method(
          #deleteFirebaseToken,
          [],
        ),
        returnValue: _i6.Future<bool>.value(false),
      ) as _i6.Future<bool>);

  @override
  _i6.Future<void> setCurrentFirebaseToken(String? str) => (super.noSuchMethod(
        Invocation.method(
          #setCurrentFirebaseToken,
          [str],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<String?> getCurrentFirebaseToken() => (super.noSuchMethod(
        Invocation.method(
          #getCurrentFirebaseToken,
          [],
        ),
        returnValue: _i6.Future<String?>.value(),
      ) as _i6.Future<String?>);

  @override
  _i6.Future<void> setNewFirebaseToken(String? str) => (super.noSuchMethod(
        Invocation.method(
          #setNewFirebaseToken,
          [str],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<String?> getNewFirebaseToken() => (super.noSuchMethod(
        Invocation.method(
          #getNewFirebaseToken,
          [],
        ),
        returnValue: _i6.Future<String?>.value(),
      ) as _i6.Future<String?>);
}
