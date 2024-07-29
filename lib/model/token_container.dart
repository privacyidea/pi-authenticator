// We need some unnecessary_overrides to force to add the fields in factory constructors
// ignore_for_file: unnecessary_overrides

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';

import 'token_import/token_origin_data.dart';
import 'tokens/token.dart';

part 'token_container.g.dart';
part 'token_container.freezed.dart';

@freezed
sealed class TokenContainer with _$TokenContainer {
  const TokenContainer._();
  // Overriding fields resutls in a error when someone
  // forgot to add the field in a new factory constructor
  // On error "The getter '...' isn't defined in a superclass of 'TokenContainer'."
  //  add the '...' field to the every factory constructor to get rid of this error
  @override
  String get serverName => super.serverName;
  @override
  DateTime? get lastSyncAt => super.lastSyncAt;
  @override
  String get serial => super.serial;
  @override
  String get description => super.description;
  @override
  List<TokenTemplate> get syncedTokenTemplates => super.syncedTokenTemplates;
  @override
  List<TokenTemplate> get localTokenTemplates => super.localTokenTemplates;

  const factory TokenContainer.uninitialized({
    // Base fields
    @Default('PrivacyIDEA') String serverName,
    @Default(null) DateTime? lastSyncAt,
    @Default('none') String serial,
    @Default('Uninitialized') String description,
    @Default([]) List<TokenTemplate> syncedTokenTemplates,
    @Default([]) List<TokenTemplate> localTokenTemplates,
    // Base fields end
  }) = TokenContainerUninitialized;
  const factory TokenContainer.synced({
    // Base fields
    @Default('PrivacyIDEA') String serverName,
    required DateTime lastSyncAt,
    required String serial,
    required String description,
    required List<TokenTemplate> syncedTokenTemplates,
    required List<TokenTemplate> localTokenTemplates,
    // Base fields end
  }) = TokenContainerSynced;
  const factory TokenContainer.modified({
    // Base fields
    @Default('PrivacyIDEA') String serverName,
    @Default(null) DateTime? lastSyncAt,
    required String serial,
    required String description,
    required List<TokenTemplate> syncedTokenTemplates,
    required List<TokenTemplate> localTokenTemplates,
    // Base fields end
    required DateTime lastModifiedAt,
  }) = TokenContainerModified;
  const factory TokenContainer.unsynced({
    // Base fields
    @Default('PrivacyIDEA') String serverName,
    @Default(null) DateTime? lastSyncAt,
    required String serial,
    required String description,
    required List<TokenTemplate> syncedTokenTemplates,
    required List<TokenTemplate> localTokenTemplates,
    // Base fields end
    String? message,
  }) = TokenContainerUnsynced;
  const factory TokenContainer.notFound({
    // Base fields
    @Default('PrivacyIDEA') String serverName,
    DateTime? lastSyncAt,
    required String serial,
    required String description,
    required List<TokenTemplate> syncedTokenTemplates,
    required List<TokenTemplate> localTokenTemplates,
    // Base fields end
    required String message,
  }) = TokenContainerNotFound;
  const factory TokenContainer.error({
    // Base fields
    @Default('PrivacyIDEA') String serverName,
    @Default(null) DateTime? lastSyncAt,
    @Default('none') String serial,
    @Default('Error') String description,
    @Default([]) List<TokenTemplate> syncedTokenTemplates,
    @Default([]) List<TokenTemplate> localTokenTemplates,
    // Base fields end
    required dynamic error,
  }) = TokenContainerError;

  T copyTransformInto<T extends TokenContainer>({
    // Base fields
    String? serverName,
    DateTime? lastSyncAt,
    String? serial,
    String? description,
    List<TokenTemplate>? syncedTokenTemplates,
    List<TokenTemplate>? localTokenTemplates,
    // Base fields end
    Map<String, dynamic>? args,
  }) =>
      switch (T) {
        const (TokenContainerSynced) => TokenContainerSynced(
            serverName: serverName ?? this.serverName,
            lastSyncAt: lastSyncAt ?? this.lastSyncAt!,
            serial: serial ?? this.serial,
            description: description ?? this.description,
            syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
            localTokenTemplates: localTokenTemplates ?? this.localTokenTemplates,
          ) as T,
        const (TokenContainerUnsynced) => TokenContainerUnsynced(
            serverName: serverName ?? this.serverName,
            lastSyncAt: lastSyncAt ?? this.lastSyncAt,
            serial: serial ?? this.serial,
            description: description ?? this.description,
            syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
            localTokenTemplates: localTokenTemplates ?? this.localTokenTemplates,
          ) as T,
        const (TokenContainerNotFound) => TokenContainerNotFound(
            serverName: serverName ?? this.serverName,
            lastSyncAt: lastSyncAt ?? this.lastSyncAt,
            serial: serial ?? this.serial,
            description: description ?? this.description,
            syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
            localTokenTemplates: localTokenTemplates ?? this.localTokenTemplates,
            message: args != null && args['message'] != null ? args['message'] : 'Unknown message',
          ) as T,
        const (TokenContainerError) => TokenContainerError(
            serverName: serverName ?? this.serverName,
            lastSyncAt: lastSyncAt ?? this.lastSyncAt,
            serial: serial ?? this.serial,
            description: description ?? this.description,
            syncedTokenTemplates: syncedTokenTemplates ?? this.syncedTokenTemplates,
            localTokenTemplates: localTokenTemplates ?? this.localTokenTemplates,
            error: args != null && args['error'] != null ? args['error'] : 'Unknown error',
          ) as T,
        _ => throw UnimplementedError('Unknown TokenContainer type: $T'),
      };

  factory TokenContainer.fromJson(Map<String, dynamic> json) => _$TokenContainerFromJson(json);
}


@freezed
class TokenTemplate with _$TokenTemplate {
  TokenTemplate._();
  factory TokenTemplate({
    required Map<String, dynamic> data,
  }) = _TokenTemplate;

  String? get serial {
    final serial = data[URI_SERIAL];
    if (serial is! String?) {
      Logger.error('TokenTemplate id is not a string');
    }
    return serial;
  }

  @override
  operator ==(Object other) {
    if (other is! TokenTemplate) {
      print('other is not TokenTemplate');
      return false;
    }
    if (data.length != other.data.length) {
      print('data length is not equal');
      return false;
    }
    for (var key in data.keys) {
      if (data[key].toString() != other.data[key].toString()) {
        print('data[$key] (${data[key]}) is not equal to other.data[$key] (${other.data[key]})');
        return false;
      }
    }
    print('TokenTemplate is equal');
    return true;
  }



  factory TokenTemplate.fromJson(Map<String, dynamic> json) => _$TokenTemplateFromJson(json);

  String get label => data[URI_LABEL] ?? 'No label';

  Token toToken(TokenContainer container) => Token.fromUriMap(data).copyWith(
        containerSerial: () => container.serial,
        origin: TokenOriginData(
          appName: '${container.serverName} ${container.serial}',
          data: data.toString(),
          source: TokenOriginSourceType.container,
          isPrivacyIdeaToken: true,
        ),
      );

  /// Adds all key/value pairs of [other] to this map.
  ///
  /// If a key of [other] is already in this map, its value is overwritten.
  ///
  /// The operation is equivalent to doing `this[key] = value` for each key
  /// and associated value in other. It iterates over [other], which must
  /// therefore not change during the iteration.
  /// ```dart
  /// final planets = <int, String>{1: 'Mercury', 2: 'Earth'};
  /// planets.addAll({5: 'Jupiter', 6: 'Saturn'});
  /// print(planets); // {1: Mercury, 2: Earth, 5: Jupiter, 6: Saturn}
  /// ```
  TokenTemplate copyAddAll(Map<String, dynamic> addData) {
    final newData = Map<String, dynamic>.from(data)..addAll(addData);
    return TokenTemplate(data: newData);
  }

  @override
  int get hashCode => Object.hashAllUnordered(data.keys.map((key) => '$key:${data[key]}'));

}
