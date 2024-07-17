import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mutex/mutex.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import '../../interfaces/repo/container_repository.dart';
import '../../model/states/token_container_state.dart';

class SecureTokenContainerStateRepository implements TokenContainerStateRepository {
  static String prefix = 'token_container_state_';
  String get containerIdKey => _keyOf('containerId');
  String _keyOf(String id) => prefix + repoName + id;

  final Mutex _m = Mutex();
  Future<void> _protect(Future<void> Function() f) => _m.protect(f);

  final String repoName;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  SecureTokenContainerStateRepository({required this.repoName});

  Future<void> _write(String key, String value) => _protect(() => _storage.write(key: key, value: value));
  Future<String?> _read(String key) async {
    String? value;
    await _protect(() async => value = await _storage.read(key: key));
    return value;
  }

  Future<void> _delete(String key) => _protect(() => _storage.delete(key: key));
  Future<Map<String, String>> _readAll() async {
    Map<String, String>? keys;
    await _protect(() async => keys = await _storage.readAll());
    keys!.removeWhere((key, value) => !key.startsWith(prefix + repoName));
    return keys!;
  }

  @override


  Future<TokenContainerState> saveContainerState(TokenContainerState containerState) async {
    for (var template in containerState.tokenTemplates) {
      if (template.id == null) {
        Logger.warning('Cannot save token template without id');
        continue;
      }
      _write(_keyOf(template.id!), jsonEncode(template.toJson()));
    }
    _write(containerIdKey, containerState.containerId);
    return containerState;
  }

  @override

  /// Load the container state from the shared preferences
  Future<TokenContainerState> loadContainer() async {
    final keys = await _storage.readAll();
    final templates = <TokenTemplate>[];
    for (var key in keys.keys) {
      if (key.startsWith(prefix + repoName)) {
        final templateJson = await _storage.read(key: key);
        if (templateJson == null) {
          Logger.warning('Failed to read token template from shared preferences');
          continue;
        }
        final templateMap = jsonDecode(templateJson);
        templates.add(TokenTemplate.fromJson(templateMap));
      }
    }
    return TokenContainerState(
      containerId: '',
      description: '',
      type: '',
      tokenTemplates: templates,
    );
  }

  @override
  Future<TokenTemplate> loadTokenTemplate(String tokenTemplateId) {
    // TODO: implement loadTokenTemplate
    throw UnimplementedError();
  }

  @override
  Future<TokenTemplate> saveTokenTemplate(TokenTemplate tokenTemplate) {
    // TODO: implement saveTokenTemplate
    throw UnimplementedError();
  }
}
