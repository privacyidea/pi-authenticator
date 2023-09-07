import 'package:firebase_messaging_platform_interface/src/remote_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/src/response.dart';
import 'package:privacyidea_authenticator/interfaces/repo/settings_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_folder_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/main.dart';
import 'package:privacyidea_authenticator/model/states/settings_state.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/state_notifiers/settings_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_folder_notifier.dart';
import 'package:privacyidea_authenticator/state_notifiers/token_notifier.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/network_utils.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';

export 'package:privacyidea_authenticator/example/privacyidea_app_example.dart';

class PrivacyIEDAAppExample extends StatelessWidget {
  final ExampleSettingsRepository exampleSettingsRepository = ExampleSettingsRepository();
  final ExampleTokenRepository exampleTokenRepository = ExampleTokenRepository();
  final ExampleTokenFolderRepository exampleTokenFolderRepository = ExampleTokenFolderRepository();
  final ExampleFirebaseUtils exampleFirebaseUtils = ExampleFirebaseUtils();
  final ExampleCustomIOClient exampleIOClient = ExampleCustomIOClient();
  PrivacyIEDAAppExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    return ProviderScope(
      overrides: [
        settingsProvider.overrideWith((ref) => SettingsNotifier(repository: exampleSettingsRepository)),
        tokenProvider.overrideWith((ref) => TokenNotifier(
              repository: exampleTokenRepository,
              firebaseUtils: exampleFirebaseUtils,
              ioClient: exampleIOClient,
            )),
        tokenFolderProvider.overrideWith((ref) => TokenFolderNotifier(repository: exampleTokenFolderRepository)),
      ],
      child: const PrivacyIDEAAuthenticator(),
    );
  }
}

class ExampleSettingsRepository implements SettingsRepository {
  @override
  Future<SettingsState> loadSettings() {
    // TODO: implement loadSettings
    throw UnimplementedError();
  }

  @override
  Future<bool> saveSettings(SettingsState settings) {
    // TODO: implement saveSettings
    throw UnimplementedError();
  }
}

class ExampleTokenRepository implements TokenRepository {
  @override
  Future<List<Token>> deleteTokens(List<Token> tokens) {
    // TODO: implement deleteTokens
    throw UnimplementedError();
  }

  @override
  Future<List<Token>> saveOrReplaceTokens(List<Token> tokens) {
    // TODO: implement saveOrReplaceTokens
    throw UnimplementedError();
  }

  @override
  Future<List<Token>> loadTokens() {
    // TODO: implement loadTokens
    throw UnimplementedError();
  }
}

class ExampleTokenFolderRepository implements TokenFolderRepository {
  @override
  Future<List<TokenFolder>> loadFolders() {
    // TODO: implement loadFolders
    throw UnimplementedError();
  }

  @override
  Future<List<TokenFolder>> saveOrReplaceFolders(List<TokenFolder> folders) {
    // TODO: implement saveOrReplaceFolders
    throw UnimplementedError();
  }

  @override
  Future<List<TokenFolder>> deleteFolders(List<TokenFolder> folders) {
    // TODO: implement deleteFolders
    throw UnimplementedError();
  }
}

class ExampleFirebaseUtils implements FirebaseUtils {
  @override
  Future<String?> getFBToken() {
    // TODO: implement getFBToken
    throw UnimplementedError();
  }

  @override
  Future<void> initFirebase(
      {required Future<void> Function(RemoteMessage p1) foregroundHandler,
      required Future<void> Function(RemoteMessage p1) backgroundHandler,
      required void Function(String? p1) updateFirebaseToken}) {
    // TODO: implement initFirebase
    throw UnimplementedError();
  }
}

class ExampleCustomIOClient implements CustomIOClient {
  @override
  Future<Response> doGet({required Uri url, required Map<String, String?> parameters, bool sslVerify = true}) {
    // TODO: implement doGet
    throw UnimplementedError();
  }

  @override
  Future<Response> doPost({required Uri url, required Map<String, String?> body, bool sslVerify = true}) {
    // TODO: implement doPost
    throw UnimplementedError();
  }

  @override
  Future<void> triggerNetworkAccessPermission({required Uri url, bool sslVerify = true}) {
    // TODO: implement triggerNetworkAccessPermission
    throw UnimplementedError();
  }
}
