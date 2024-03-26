// ignore_for_file: constant_identifier_names

/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2023 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';

import '../utils/identifiers.dart';
import '../views/settings_view/settings_view_widgets/send_error_dialog.dart';
import '../widgets/dialog_widgets/default_dialog.dart';
import '../widgets/dialog_widgets/default_dialog_button.dart';

// TODO How to test the behavior of this class?
class SecureTokenRepository implements TokenRepository {
  const SecureTokenRepository();

  // Use this to lock critical sections of code.
  static final Mutex _m = Mutex();

  /// Function [f] is executed, protected by Mutex [_m].
  /// That means, that calls of this method will always be executed serial.
  static Future<T> _protect<T>(Future<T> Function() f) => _m.protect<T>(f);
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _TOKEN_PREFIX = GLOBAL_SECURE_REPO_PREFIX;

  // ###########################################################################
  // TOKENS
  // ###########################################################################

  @override
  Future<Token?> loadToken(String id) => _protect<Token?>(() async {
        final token = await _storage.read(key: _TOKEN_PREFIX + id);
        if (token == null) {
          Logger.warning('Token not found in secure storage', name: 'secure_token_repository.dart#loadToken');
          return null;
        }
        return Token.fromJson(jsonDecode(token));
      });

  /// Returns a list of all tokens that are saved in the secure storage of
  /// this device.
  /// If [loadLegacy] is set to true, will attempt to load old android and ios tokens.
  @override
  Future<List<Token>> loadTokens() => _protect<List<Token>>(() async {
        late Map<String, String> keyValueMap;
        try {
          keyValueMap = await _storage.readAll();
        } on PlatformException catch (e, s) {
          Logger.warning("Token found, but could not be decrypted.", name: 'secure_token_repository.dart#loadTokens', error: e, stackTrace: s, verbose: true);
          _decryptErrorDialog();
          return [];
        }

        List<Token> tokenList = [];

        for (var i = 0; i < keyValueMap.length; i++) {
          final value = keyValueMap.values.elementAt(i);
          final key = keyValueMap.keys.elementAt(i);
          Map<String, dynamic>? valueJson;
          if (!key.startsWith(_TOKEN_PREFIX)) {
            // Every token should start with the global prefix.
            // But not everything that starts with the global prefix is a token.
            continue;
          }

          try {
            valueJson = jsonDecode(value);
          } on FormatException catch (_) {
            // Value should be a json. Skip everything that is not a json.
            continue;
          }

          if (valueJson == null || !valueJson.containsKey('type')) {
            Logger.warning(
                'Could not deserialize token from secure storage. Value: $value\nserializedToken = $valueJson\ncontainsKey(type) = ${valueJson?.containsKey('type')} ',
                name: 'secure_token_repository.dart#loadAllTokens');
            // If valueJson is null or does not contain a type, it can't be a token. Skip it.
            continue;
          }

          // TODO token.version might be deprecated, is there a reason to use it?
          // TODO when the token version (token.version) changed handle this here.
          Logger.info('Loading token from secure storage: $valueJson');
          try {
            tokenList.add(Token.fromJson(valueJson));
          } catch (e, s) {
            Logger.error('Could not load token from secure storage', name: 'secure_token_repository.dart#loadTokens', error: e, stackTrace: s);
          }
        }

        //Logger.info('Loaded ${tokenList.length} tokens from secure storage');
        return tokenList;
      });

  /// Saves [token]s securely on the device, if [token] already exists
  /// in the storage the existing value is overwritten.
  /// Returns all tokens that could not be saved.
  @override
  Future<List<T>> saveOrReplaceTokens<T extends Token>(List<T> tokens) => _protect<List<T>>(() async {
        final failedTokens = <T>[];
        for (var element in tokens) {
          if (!await _saveOrReplaceToken(element)) {
            failedTokens.add(element);
          }
        }
        if (failedTokens.isNotEmpty) {
          Logger.warning('Could not save all tokens to secure storage',
              name: 'secure_token_repository.dart#saveOrReplaceTokens', stackTrace: StackTrace.current);
        } else {
          Logger.info('Saved all (${tokens.length}) tokens to secure storage');
        }
        return failedTokens;
      });

  @override
  Future<bool> saveOrReplaceToken(Token token) => _protect<bool>(() => _saveOrReplaceToken(token));

  Future<bool> _saveOrReplaceToken(Token token) async {
    try {
      await _storage.write(key: _TOKEN_PREFIX + token.id, value: jsonEncode(token));
    } catch (_) {
      return false;
    }
    return true;
  }

  /// Deletes the saved jsons of [tokens] from the secure storage.
  @override
  Future<List<T>> deleteTokens<T extends Token>(List<T> tokens) => _protect<List<T>>(() async {
        final failedTokens = <T>[];
        for (var element in tokens) {
          if (!await _deleteToken(element)) {
            failedTokens.add(element);
          }
        }
        if (failedTokens.isNotEmpty) {
          Logger.warning('Could not delete all tokens from secure storage',
              name: 'secure_token_repository.dart#deleteTokens', error: 'Failed tokens: $failedTokens', stackTrace: StackTrace.current);
        }
        return failedTokens;
      });

  /// Deletes the saved json of [token] from the secure storage.
  @override
  Future<bool> deleteToken(Token token) => _protect<bool>(() => _deleteToken(token));

  Future<bool> _deleteToken(Token token) async {
    try {
      _storage.delete(key: _TOKEN_PREFIX + token.id);
    } catch (e, s) {
      Logger.warning('Could not delete token from secure storage', name: 'secure_token_repository.dart#deleteToken', error: e, stackTrace: s);
      return false;
    }
    Logger.info('Token deleted from secure storage');
    return true;
  }

  // ###########################################################################
  // ERROR HANDLING
  // ###########################################################################

  Future<void> _decryptErrorDialog() => showAsyncDialog(
        barrierDismissible: false,
        builder: (context) => DefaultDialog(
          title: Text(AppLocalizations.of(context)!.decryptErrorTitle),
          content: Text(AppLocalizations.of(context)!.decryptErrorContent),
          actions: [
            DefaultDialogButton(
              onPressed: () async {
                final isDataDeleted = await _decryptErrorDeleteTokenConfirmationDialog();
                if (isDataDeleted == true) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  globalRef?.read(tokenProvider.notifier).loadStateFromRepo();
                }
              },
              child: Text(
                AppLocalizations.of(context)!.decryptErrorButtonDelete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            DefaultDialogButton(
                child: Text(AppLocalizations.of(context)!.decryptErrorButtonSendError),
                onPressed: () async {
                  Logger.info('Sending error report', name: 'secure_token_repository.dart#_decryptErrorDialog');
                  await showDialog(
                    context: context,
                    builder: (context) => SendErrorDialog(),
                    useRootNavigator: false,
                  );
                }),
            DefaultDialogButton(
              onPressed: () async {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => const Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
                await Future.delayed(
                  const Duration(milliseconds: 500),
                );
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                globalRef?.read(tokenProvider.notifier).loadStateFromRepo();
              },
              child: Text(AppLocalizations.of(context)!.decryptErrorButtonRetry),
            ),
          ],
        ),
      );

  Future<bool?> _decryptErrorDeleteTokenConfirmationDialog() => showAsyncDialog<bool>(
        builder: (context) => DefaultDialog(
          title: Text(AppLocalizations.of(context)!.decryptErrorTitle),
          content: Text(AppLocalizations.of(context)!.decryptErrorDeleteConfirmationContent),
          actions: [
            DefaultDialogButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            DefaultDialogButton(
              onPressed: () async {
                Logger.info(
                  'Deleting all tokens from secure storage',
                  name: 'secure_token_repository.dart#_decryptErrorDeleteTokenConfirmationDialog',
                  verbose: true,
                );
                Navigator.pop(context, true);
                await SecureTokenRepository._storage.deleteAll();
              },
              child: Text(
                AppLocalizations.of(context)!.decryptErrorButtonDelete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      );
}
