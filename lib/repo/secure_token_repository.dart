// ignore_for_file: constant_identifier_names

/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2024 NetKnights GmbH

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

import '../interfaces/repo/token_repository.dart';
import '../l10n/app_localizations.dart';
import '../model/tokens/token.dart';
import '../utils/globals.dart';
import '../utils/identifiers.dart';
import '../utils/logger.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../utils/view_utils.dart';
import '../views/settings_view/settings_view_widgets/send_error_dialog.dart';
import '../widgets/dialog_widgets/default_dialog.dart';
import '../widgets/dialog_widgets/default_dialog_button.dart';
import 'secure_storage_mutexed.dart';

// TODO How to test the behavior of this class?
class SecureTokenRepository implements TokenRepository {
  const SecureTokenRepository();

  static const SecureStorageMutexed _storage = SecureStorageMutexed();
  static const String _TOKEN_PREFIX = GLOBAL_SECURE_REPO_PREFIX;

  // ###########################################################################
  // TOKENS
  // ###########################################################################

  @override
  Future<Token?> loadToken(String id) async {
    final token = await _storage.read(key: _TOKEN_PREFIX + id);
    Logger.info('Loading token from secure storage: $id');
    if (token == null) {
      Logger.warning('Token not found in secure storage');
      return null;
    }
    return Token.fromJson(jsonDecode(token));
  }

  /// Returns a list of all tokens that are saved in the secure storage of
  /// this device.
  /// If [loadLegacy] is set to true, will attempt to load old android and ios tokens.
  @override
  Future<List<Token>> loadTokens() async {
    late Map<String, String> keyValueMap;
    try {
      keyValueMap = await _storage.readAll();
    } on PlatformException catch (e, s) {
      Logger.warning("Token found, but could not be decrypted.", error: e, stackTrace: s, verbose: true);
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
        Logger.debug('Value is not a json', name: 'secure_token_repository.dart#loadTokens');
        continue;
      }

      if (valueJson == null) {
        // If valueJson is null or does not contain a type, it can't be a token. Skip it.
        Logger.debug('Value Json is null', name: 'secure_token_repository.dart#loadTokens');
        continue;
      }
      if (!valueJson.containsKey('type')) {
        // If valueJson is null or does not contain a type, it can't be a token. Skip it.
        Logger.debug('Value Json does not contain a type', name: 'secure_token_repository.dart#loadTokens');
        continue;
      }

      // TODO token.version might be deprecated, is there a reason to use it?
      // TODO when the token version (token.version) changed handle this here.
      Logger.info('Loading token from secure storage: ${valueJson['id']}');
      try {
        tokenList.add(Token.fromJson(valueJson));
      } catch (e, s) {
        Logger.error('Could not load token from secure storage', error: e, stackTrace: s);
      }
    }

    //Logger.info('Loaded ${tokenList.length} tokens from secure storage');
    return tokenList;
  }

  /// Saves [token]s securely on the device, if [token] already exists
  /// in the storage the existing value is overwritten.
  /// Returns all tokens that could not be saved.
  @override
  Future<List<T>> saveOrReplaceTokens<T extends Token>(List<T> tokens) async {
    if (tokens.isEmpty) return [];
    final failedTokens = <T>[];
    for (var element in tokens) {
      if (!await saveOrReplaceToken(element)) {
        failedTokens.add(element);
      }
    }
    if (failedTokens.isNotEmpty) {
      Logger.error(
        'Could not save all tokens (${tokens.length - failedTokens.length}/${tokens.length}) to secure storage',
        stackTrace: StackTrace.current,
      );
    } else {
      Logger.info('Saved ${tokens.length}/${tokens.length} tokens to secure storage');
    }
    return failedTokens;
  }

  @override
  Future<bool> saveOrReplaceToken(Token token) async {
    try {
      await _storage.write(key: _TOKEN_PREFIX + token.id, value: jsonEncode(token.toJson()));
    } catch (e) {
      Logger.warning('Could not save token to secure storage', error: e, name: 'secure_token_repository.dart#saveOrReplaceToken', verbose: true);
      return false;
    }
    return true;
  }

  /// Deletes the saved jsons of [tokens] from the secure storage.
  @override
  Future<List<T>> deleteTokens<T extends Token>(List<T> tokens) async {
    final failedTokens = <T>[];
    for (var element in tokens) {
      if (!await deleteToken(element)) {
        failedTokens.add(element);
      }
    }
    if (failedTokens.isNotEmpty) {
      Logger.warning('Could not delete all tokens from secure storage', error: 'Failed tokens: $failedTokens', stackTrace: StackTrace.current);
    }
    return failedTokens;
  }

  /// Deletes the saved json of [token] from the secure storage.
  @override
  Future<bool> deleteToken(Token token) async {
    try {
      _storage.delete(key: _TOKEN_PREFIX + token.id);
    } catch (e, s) {
      Logger.warning('Could not delete token from secure storage', error: e, stackTrace: s);
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
                  Logger.info('Sending error report');
                  await showDialog(
                    context: context,
                    builder: (context) => const SendErrorDialog(),
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
                      child: CircularProgressIndicator.adaptive(),
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
