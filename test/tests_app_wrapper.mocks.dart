// Mocks generated by Mockito 5.4.4 from annotations
// in privacyidea_authenticator/test/tests_app_wrapper.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i11;
import 'dart:typed_data' as _i17;

import 'package:firebase_messaging/firebase_messaging.dart' as _i19;
import 'package:http/http.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i16;
import 'package:pointycastle/export.dart' as _i4;
import 'package:privacyidea_authenticator/interfaces/repo/introduction_repository.dart'
    as _i20;
import 'package:privacyidea_authenticator/interfaces/repo/push_request_repository.dart'
    as _i23;
import 'package:privacyidea_authenticator/interfaces/repo/settings_repository.dart'
    as _i13;
import 'package:privacyidea_authenticator/interfaces/repo/token_folder_repository.dart'
    as _i14;
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart'
    as _i10;
import 'package:privacyidea_authenticator/model/push_request.dart' as _i22;
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart'
    as _i5;
import 'package:privacyidea_authenticator/model/riverpod_states/push_request_state.dart'
    as _i9;
import 'package:privacyidea_authenticator/model/riverpod_states/settings_state.dart'
    as _i2;
import 'package:privacyidea_authenticator/model/token_folder.dart' as _i15;
import 'package:privacyidea_authenticator/model/tokens/push_token.dart' as _i18;
import 'package:privacyidea_authenticator/model/tokens/token.dart' as _i12;
import 'package:privacyidea_authenticator/utils/firebase_utils.dart' as _i6;
import 'package:privacyidea_authenticator/utils/privacyidea_io_client.dart'
    as _i7;
import 'package:privacyidea_authenticator/utils/push_provider.dart' as _i21;
import 'package:privacyidea_authenticator/utils/rsa_utils.dart' as _i8;

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

class _FakeResponse_1 extends _i1.SmartFake implements _i3.Response {
  _FakeResponse_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeRSAPublicKey_2 extends _i1.SmartFake implements _i4.RSAPublicKey {
  _FakeRSAPublicKey_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeRSAPrivateKey_3 extends _i1.SmartFake implements _i4.RSAPrivateKey {
  _FakeRSAPrivateKey_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAsymmetricKeyPair_4<B extends _i4.PublicKey,
        V extends _i4.PrivateKey> extends _i1.SmartFake
    implements _i4.AsymmetricKeyPair<B, V> {
  _FakeAsymmetricKeyPair_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeIntroductionState_5 extends _i1.SmartFake
    implements _i5.IntroductionState {
  _FakeIntroductionState_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFirebaseUtils_6 extends _i1.SmartFake implements _i6.FirebaseUtils {
  _FakeFirebaseUtils_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePrivacyideaIOClient_7 extends _i1.SmartFake
    implements _i7.PrivacyideaIOClient {
  _FakePrivacyideaIOClient_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeRsaUtils_8 extends _i1.SmartFake implements _i8.RsaUtils {
  _FakeRsaUtils_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePushRequestState_9 extends _i1.SmartFake
    implements _i9.PushRequestState {
  _FakePushRequestState_9(
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
class MockTokenRepository extends _i1.Mock implements _i10.TokenRepository {
  @override
  _i11.Future<_i12.Token?> loadToken(String? id) => (super.noSuchMethod(
        Invocation.method(
          #loadToken,
          [id],
        ),
        returnValue: _i11.Future<_i12.Token?>.value(),
        returnValueForMissingStub: _i11.Future<_i12.Token?>.value(),
      ) as _i11.Future<_i12.Token?>);

  @override
  _i11.Future<List<_i12.Token>> loadTokens() => (super.noSuchMethod(
        Invocation.method(
          #loadTokens,
          [],
        ),
        returnValue: _i11.Future<List<_i12.Token>>.value(<_i12.Token>[]),
        returnValueForMissingStub:
            _i11.Future<List<_i12.Token>>.value(<_i12.Token>[]),
      ) as _i11.Future<List<_i12.Token>>);

  @override
  _i11.Future<bool> saveOrReplaceToken(_i12.Token? token) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveOrReplaceToken,
          [token],
        ),
        returnValue: _i11.Future<bool>.value(false),
        returnValueForMissingStub: _i11.Future<bool>.value(false),
      ) as _i11.Future<bool>);

  @override
  _i11.Future<List<T>> saveOrReplaceTokens<T extends _i12.Token>(
          List<T>? tokens) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveOrReplaceTokens,
          [tokens],
        ),
        returnValue: _i11.Future<List<T>>.value(<T>[]),
        returnValueForMissingStub: _i11.Future<List<T>>.value(<T>[]),
      ) as _i11.Future<List<T>>);

  @override
  _i11.Future<bool> deleteToken(_i12.Token? token) => (super.noSuchMethod(
        Invocation.method(
          #deleteToken,
          [token],
        ),
        returnValue: _i11.Future<bool>.value(false),
        returnValueForMissingStub: _i11.Future<bool>.value(false),
      ) as _i11.Future<bool>);

  @override
  _i11.Future<List<T>> deleteTokens<T extends _i12.Token>(List<T>? tokens) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteTokens,
          [tokens],
        ),
        returnValue: _i11.Future<List<T>>.value(<T>[]),
        returnValueForMissingStub: _i11.Future<List<T>>.value(<T>[]),
      ) as _i11.Future<List<T>>);
}

/// A class which mocks [SettingsRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockSettingsRepository extends _i1.Mock
    implements _i13.SettingsRepository {
  @override
  _i11.Future<bool> saveSettings(_i2.SettingsState? settings) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveSettings,
          [settings],
        ),
        returnValue: _i11.Future<bool>.value(false),
        returnValueForMissingStub: _i11.Future<bool>.value(false),
      ) as _i11.Future<bool>);

  @override
  _i11.Future<_i2.SettingsState> loadSettings() => (super.noSuchMethod(
        Invocation.method(
          #loadSettings,
          [],
        ),
        returnValue: _i11.Future<_i2.SettingsState>.value(_FakeSettingsState_0(
          this,
          Invocation.method(
            #loadSettings,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i11.Future<_i2.SettingsState>.value(_FakeSettingsState_0(
          this,
          Invocation.method(
            #loadSettings,
            [],
          ),
        )),
      ) as _i11.Future<_i2.SettingsState>);
}

/// A class which mocks [TokenFolderRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockTokenFolderRepository extends _i1.Mock
    implements _i14.TokenFolderRepository {
  @override
  _i11.Future<bool> saveReplaceList(List<_i15.TokenFolder>? folders) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveReplaceList,
          [folders],
        ),
        returnValue: _i11.Future<bool>.value(false),
        returnValueForMissingStub: _i11.Future<bool>.value(false),
      ) as _i11.Future<bool>);

  @override
  _i11.Future<List<_i15.TokenFolder>> loadFolders() => (super.noSuchMethod(
        Invocation.method(
          #loadFolders,
          [],
        ),
        returnValue:
            _i11.Future<List<_i15.TokenFolder>>.value(<_i15.TokenFolder>[]),
        returnValueForMissingStub:
            _i11.Future<List<_i15.TokenFolder>>.value(<_i15.TokenFolder>[]),
      ) as _i11.Future<List<_i15.TokenFolder>>);
}

/// A class which mocks [PrivacyideaIOClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockPrivacyideaIOClient extends _i1.Mock
    implements _i7.PrivacyideaIOClient {
  @override
  _i11.Future<bool> triggerNetworkAccessPermission({
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
        returnValue: _i11.Future<bool>.value(false),
        returnValueForMissingStub: _i11.Future<bool>.value(false),
      ) as _i11.Future<bool>);

  @override
  _i11.Future<_i3.Response> doPost({
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
        returnValue: _i11.Future<_i3.Response>.value(_FakeResponse_1(
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
        returnValueForMissingStub:
            _i11.Future<_i3.Response>.value(_FakeResponse_1(
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
      ) as _i11.Future<_i3.Response>);

  @override
  _i11.Future<_i3.Response> doGet({
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
        returnValue: _i11.Future<_i3.Response>.value(_FakeResponse_1(
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
        returnValueForMissingStub:
            _i11.Future<_i3.Response>.value(_FakeResponse_1(
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
      ) as _i11.Future<_i3.Response>);
}

/// A class which mocks [RsaUtils].
///
/// See the documentation for Mockito's code generation for more information.
class MockRsaUtils extends _i1.Mock implements _i8.RsaUtils {
  @override
  _i4.RSAPublicKey deserializeRSAPublicKeyPKCS1(String? keyStr) =>
      (super.noSuchMethod(
        Invocation.method(
          #deserializeRSAPublicKeyPKCS1,
          [keyStr],
        ),
        returnValue: _FakeRSAPublicKey_2(
          this,
          Invocation.method(
            #deserializeRSAPublicKeyPKCS1,
            [keyStr],
          ),
        ),
        returnValueForMissingStub: _FakeRSAPublicKey_2(
          this,
          Invocation.method(
            #deserializeRSAPublicKeyPKCS1,
            [keyStr],
          ),
        ),
      ) as _i4.RSAPublicKey);

  @override
  String serializeRSAPublicKeyPKCS1(_i4.RSAPublicKey? publicKey) =>
      (super.noSuchMethod(
        Invocation.method(
          #serializeRSAPublicKeyPKCS1,
          [publicKey],
        ),
        returnValue: _i16.dummyValue<String>(
          this,
          Invocation.method(
            #serializeRSAPublicKeyPKCS1,
            [publicKey],
          ),
        ),
        returnValueForMissingStub: _i16.dummyValue<String>(
          this,
          Invocation.method(
            #serializeRSAPublicKeyPKCS1,
            [publicKey],
          ),
        ),
      ) as String);

  @override
  _i4.RSAPublicKey deserializeRSAPublicKeyPKCS8(String? keyStr) =>
      (super.noSuchMethod(
        Invocation.method(
          #deserializeRSAPublicKeyPKCS8,
          [keyStr],
        ),
        returnValue: _FakeRSAPublicKey_2(
          this,
          Invocation.method(
            #deserializeRSAPublicKeyPKCS8,
            [keyStr],
          ),
        ),
        returnValueForMissingStub: _FakeRSAPublicKey_2(
          this,
          Invocation.method(
            #deserializeRSAPublicKeyPKCS8,
            [keyStr],
          ),
        ),
      ) as _i4.RSAPublicKey);

  @override
  String serializeRSAPublicKeyPKCS8(_i4.RSAPublicKey? key) =>
      (super.noSuchMethod(
        Invocation.method(
          #serializeRSAPublicKeyPKCS8,
          [key],
        ),
        returnValue: _i16.dummyValue<String>(
          this,
          Invocation.method(
            #serializeRSAPublicKeyPKCS8,
            [key],
          ),
        ),
        returnValueForMissingStub: _i16.dummyValue<String>(
          this,
          Invocation.method(
            #serializeRSAPublicKeyPKCS8,
            [key],
          ),
        ),
      ) as String);

  @override
  String serializeRSAPrivateKeyPKCS1(_i4.RSAPrivateKey? key) =>
      (super.noSuchMethod(
        Invocation.method(
          #serializeRSAPrivateKeyPKCS1,
          [key],
        ),
        returnValue: _i16.dummyValue<String>(
          this,
          Invocation.method(
            #serializeRSAPrivateKeyPKCS1,
            [key],
          ),
        ),
        returnValueForMissingStub: _i16.dummyValue<String>(
          this,
          Invocation.method(
            #serializeRSAPrivateKeyPKCS1,
            [key],
          ),
        ),
      ) as String);

  @override
  _i4.RSAPrivateKey deserializeRSAPrivateKeyPKCS1(String? keyStr) =>
      (super.noSuchMethod(
        Invocation.method(
          #deserializeRSAPrivateKeyPKCS1,
          [keyStr],
        ),
        returnValue: _FakeRSAPrivateKey_3(
          this,
          Invocation.method(
            #deserializeRSAPrivateKeyPKCS1,
            [keyStr],
          ),
        ),
        returnValueForMissingStub: _FakeRSAPrivateKey_3(
          this,
          Invocation.method(
            #deserializeRSAPrivateKeyPKCS1,
            [keyStr],
          ),
        ),
      ) as _i4.RSAPrivateKey);

  @override
  bool verifyRSASignature(
    _i4.RSAPublicKey? publicKey,
    _i17.Uint8List? signedMessage,
    _i17.Uint8List? signature,
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
        returnValueForMissingStub: false,
      ) as bool);

  @override
  _i11.Future<String?> trySignWithToken(
    _i18.PushToken? token,
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
        returnValue: _i11.Future<String?>.value(),
        returnValueForMissingStub: _i11.Future<String?>.value(),
      ) as _i11.Future<String?>);

  @override
  _i11.Future<_i4.AsymmetricKeyPair<_i4.RSAPublicKey, _i4.RSAPrivateKey>>
      generateRSAKeyPair() => (super.noSuchMethod(
            Invocation.method(
              #generateRSAKeyPair,
              [],
            ),
            returnValue: _i11.Future<
                    _i4.AsymmetricKeyPair<_i4.RSAPublicKey,
                        _i4.RSAPrivateKey>>.value(
                _FakeAsymmetricKeyPair_4<_i4.RSAPublicKey, _i4.RSAPrivateKey>(
              this,
              Invocation.method(
                #generateRSAKeyPair,
                [],
              ),
            )),
            returnValueForMissingStub: _i11.Future<
                    _i4.AsymmetricKeyPair<_i4.RSAPublicKey,
                        _i4.RSAPrivateKey>>.value(
                _FakeAsymmetricKeyPair_4<_i4.RSAPublicKey, _i4.RSAPrivateKey>(
              this,
              Invocation.method(
                #generateRSAKeyPair,
                [],
              ),
            )),
          ) as _i11.Future<
              _i4.AsymmetricKeyPair<_i4.RSAPublicKey, _i4.RSAPrivateKey>>);

  @override
  String createBase32Signature(
    _i4.RSAPrivateKey? privateKey,
    _i17.Uint8List? dataToSign,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #createBase32Signature,
          [
            privateKey,
            dataToSign,
          ],
        ),
        returnValue: _i16.dummyValue<String>(
          this,
          Invocation.method(
            #createBase32Signature,
            [
              privateKey,
              dataToSign,
            ],
          ),
        ),
        returnValueForMissingStub: _i16.dummyValue<String>(
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
  _i17.Uint8List createRSASignature(
    _i4.RSAPrivateKey? privateKey,
    _i17.Uint8List? dataToSign,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #createRSASignature,
          [
            privateKey,
            dataToSign,
          ],
        ),
        returnValue: _i17.Uint8List(0),
        returnValueForMissingStub: _i17.Uint8List(0),
      ) as _i17.Uint8List);
}

/// A class which mocks [FirebaseUtils].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseUtils extends _i1.Mock implements _i6.FirebaseUtils {
  @override
  _i11.Future<void> initFirebase({
    required _i11.Future<void> Function(_i19.RemoteMessage)? foregroundHandler,
    required _i11.Future<void> Function(_i19.RemoteMessage)? backgroundHandler,
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
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);

  @override
  _i11.Future<String?> getFBToken() => (super.noSuchMethod(
        Invocation.method(
          #getFBToken,
          [],
        ),
        returnValue: _i11.Future<String?>.value(),
        returnValueForMissingStub: _i11.Future<String?>.value(),
      ) as _i11.Future<String?>);

  @override
  _i11.Future<bool> deleteFirebaseToken() => (super.noSuchMethod(
        Invocation.method(
          #deleteFirebaseToken,
          [],
        ),
        returnValue: _i11.Future<bool>.value(false),
        returnValueForMissingStub: _i11.Future<bool>.value(false),
      ) as _i11.Future<bool>);

  @override
  _i11.Future<void> setCurrentFirebaseToken(String? str) => (super.noSuchMethod(
        Invocation.method(
          #setCurrentFirebaseToken,
          [str],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);

  @override
  _i11.Future<String?> getCurrentFirebaseToken() => (super.noSuchMethod(
        Invocation.method(
          #getCurrentFirebaseToken,
          [],
        ),
        returnValue: _i11.Future<String?>.value(),
        returnValueForMissingStub: _i11.Future<String?>.value(),
      ) as _i11.Future<String?>);

  @override
  _i11.Future<void> setNewFirebaseToken(String? str) => (super.noSuchMethod(
        Invocation.method(
          #setNewFirebaseToken,
          [str],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);

  @override
  _i11.Future<String?> getNewFirebaseToken() => (super.noSuchMethod(
        Invocation.method(
          #getNewFirebaseToken,
          [],
        ),
        returnValue: _i11.Future<String?>.value(),
        returnValueForMissingStub: _i11.Future<String?>.value(),
      ) as _i11.Future<String?>);
}

/// A class which mocks [IntroductionRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockIntroductionRepository extends _i1.Mock
    implements _i20.IntroductionRepository {
  @override
  _i11.Future<bool> saveCompletedIntroductions(
          _i5.IntroductionState? introductions) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveCompletedIntroductions,
          [introductions],
        ),
        returnValue: _i11.Future<bool>.value(false),
        returnValueForMissingStub: _i11.Future<bool>.value(false),
      ) as _i11.Future<bool>);

  @override
  _i11.Future<_i5.IntroductionState> loadCompletedIntroductions() =>
      (super.noSuchMethod(
        Invocation.method(
          #loadCompletedIntroductions,
          [],
        ),
        returnValue:
            _i11.Future<_i5.IntroductionState>.value(_FakeIntroductionState_5(
          this,
          Invocation.method(
            #loadCompletedIntroductions,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i11.Future<_i5.IntroductionState>.value(_FakeIntroductionState_5(
          this,
          Invocation.method(
            #loadCompletedIntroductions,
            [],
          ),
        )),
      ) as _i11.Future<_i5.IntroductionState>);
}

/// A class which mocks [PushProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockPushProvider extends _i1.Mock implements _i21.PushProvider {
  @override
  bool get pollingIsEnabled => (super.noSuchMethod(
        Invocation.getter(#pollingIsEnabled),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  set pollingIsEnabled(bool? _pollingIsEnabled) => super.noSuchMethod(
        Invocation.setter(
          #pollingIsEnabled,
          _pollingIsEnabled,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i6.FirebaseUtils get firebaseUtils => (super.noSuchMethod(
        Invocation.getter(#firebaseUtils),
        returnValue: _FakeFirebaseUtils_6(
          this,
          Invocation.getter(#firebaseUtils),
        ),
        returnValueForMissingStub: _FakeFirebaseUtils_6(
          this,
          Invocation.getter(#firebaseUtils),
        ),
      ) as _i6.FirebaseUtils);

  @override
  _i7.PrivacyideaIOClient get ioClient => (super.noSuchMethod(
        Invocation.getter(#ioClient),
        returnValue: _FakePrivacyideaIOClient_7(
          this,
          Invocation.getter(#ioClient),
        ),
        returnValueForMissingStub: _FakePrivacyideaIOClient_7(
          this,
          Invocation.getter(#ioClient),
        ),
      ) as _i7.PrivacyideaIOClient);

  @override
  _i8.RsaUtils get rsaUtils => (super.noSuchMethod(
        Invocation.getter(#rsaUtils),
        returnValue: _FakeRsaUtils_8(
          this,
          Invocation.getter(#rsaUtils),
        ),
        returnValueForMissingStub: _FakeRsaUtils_8(
          this,
          Invocation.getter(#rsaUtils),
        ),
      ) as _i8.RsaUtils);

  @override
  void setPollingEnabled(bool? enablePolling) => super.noSuchMethod(
        Invocation.method(
          #setPollingEnabled,
          [enablePolling],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i11.Future<void> pollForChallenges({required bool? isManually}) =>
      (super.noSuchMethod(
        Invocation.method(
          #pollForChallenges,
          [],
          {#isManually: isManually},
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);

  @override
  _i11.Future<void> pollForChallenge(
    _i18.PushToken? token, {
    bool? isManually = true,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #pollForChallenge,
          [token],
          {#isManually: isManually},
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);

  @override
  _i11.Future<
      (List<_i18.PushToken>, List<_i18.PushToken>)?> updateFirebaseToken(
          [String? firebaseToken]) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateFirebaseToken,
          [firebaseToken],
        ),
        returnValue:
            _i11.Future<(List<_i18.PushToken>, List<_i18.PushToken>)?>.value(),
        returnValueForMissingStub:
            _i11.Future<(List<_i18.PushToken>, List<_i18.PushToken>)?>.value(),
      ) as _i11.Future<(List<_i18.PushToken>, List<_i18.PushToken>)?>);

  @override
  void unsubscribe(void Function(_i22.PushRequest)? newRequest) =>
      super.noSuchMethod(
        Invocation.method(
          #unsubscribe,
          [newRequest],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void subscribe(void Function(_i22.PushRequest)? newRequest) =>
      super.noSuchMethod(
        Invocation.method(
          #subscribe,
          [newRequest],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [PushRequestRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockPushRequestRepository extends _i1.Mock
    implements _i23.PushRequestRepository {
  @override
  _i11.Future<_i9.PushRequestState> loadState() => (super.noSuchMethod(
        Invocation.method(
          #loadState,
          [],
        ),
        returnValue:
            _i11.Future<_i9.PushRequestState>.value(_FakePushRequestState_9(
          this,
          Invocation.method(
            #loadState,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i11.Future<_i9.PushRequestState>.value(_FakePushRequestState_9(
          this,
          Invocation.method(
            #loadState,
            [],
          ),
        )),
      ) as _i11.Future<_i9.PushRequestState>);

  @override
  _i11.Future<void> saveState(_i9.PushRequestState? pushRequestState) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveState,
          [pushRequestState],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);

  @override
  _i11.Future<void> clearState() => (super.noSuchMethod(
        Invocation.method(
          #clearState,
          [],
        ),
        returnValue: _i11.Future<void>.value(),
        returnValueForMissingStub: _i11.Future<void>.value(),
      ) as _i11.Future<void>);

  @override
  _i11.Future<_i9.PushRequestState> add(
    _i22.PushRequest? pushRequest, {
    _i9.PushRequestState? state,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #add,
          [pushRequest],
          {#state: state},
        ),
        returnValue:
            _i11.Future<_i9.PushRequestState>.value(_FakePushRequestState_9(
          this,
          Invocation.method(
            #add,
            [pushRequest],
            {#state: state},
          ),
        )),
        returnValueForMissingStub:
            _i11.Future<_i9.PushRequestState>.value(_FakePushRequestState_9(
          this,
          Invocation.method(
            #add,
            [pushRequest],
            {#state: state},
          ),
        )),
      ) as _i11.Future<_i9.PushRequestState>);

  @override
  _i11.Future<_i9.PushRequestState> remove(
    _i22.PushRequest? pushRequest, {
    _i9.PushRequestState? state,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #remove,
          [pushRequest],
          {#state: state},
        ),
        returnValue:
            _i11.Future<_i9.PushRequestState>.value(_FakePushRequestState_9(
          this,
          Invocation.method(
            #remove,
            [pushRequest],
            {#state: state},
          ),
        )),
        returnValueForMissingStub:
            _i11.Future<_i9.PushRequestState>.value(_FakePushRequestState_9(
          this,
          Invocation.method(
            #remove,
            [pushRequest],
            {#state: state},
          ),
        )),
      ) as _i11.Future<_i9.PushRequestState>);
}
