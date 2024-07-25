// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_container_state_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CredentialsState _$CredentialsStateFromJson(Map<String, dynamic> json) =>
    CredentialsState(
      credentials: (json['credentials'] as List<dynamic>)
          .map((e) => ContainerCredential.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CredentialsStateToJson(CredentialsState instance) =>
    <String, dynamic>{
      'credentials': instance.credentials,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenContainerProviderHash() =>
    r'2a5840df5d339ba273d534ea610bdeb00ce20f89';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$TokenContainerProvider
    extends BuildlessAutoDisposeAsyncNotifier<TokenContainer?> {
  late final String containerSerial;

  FutureOr<TokenContainer?> build({
    required String containerSerial,
  });
}

/// See also [TokenContainerProvider].
@ProviderFor(TokenContainerProvider)
const tokenContainerProviderOf = TokenContainerProviderFamily();

/// See also [TokenContainerProvider].
class TokenContainerProviderFamily extends Family<AsyncValue<TokenContainer?>> {
  /// See also [TokenContainerProvider].
  const TokenContainerProviderFamily();

  /// See also [TokenContainerProvider].
  TokenContainerProviderProvider call({
    required String containerSerial,
  }) {
    return TokenContainerProviderProvider(
      containerSerial: containerSerial,
    );
  }

  @override
  TokenContainerProviderProvider getProviderOverride(
    covariant TokenContainerProviderProvider provider,
  ) {
    return call(
      containerSerial: provider.containerSerial,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tokenContainerProviderOf';
}

/// See also [TokenContainerProvider].
class TokenContainerProviderProvider
    extends AutoDisposeAsyncNotifierProviderImpl<TokenContainerProvider,
        TokenContainer?> {
  /// See also [TokenContainerProvider].
  TokenContainerProviderProvider({
    required String containerSerial,
  }) : this._internal(
          () => TokenContainerProvider()..containerSerial = containerSerial,
          from: tokenContainerProviderOf,
          name: r'tokenContainerProviderOf',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tokenContainerProviderHash,
          dependencies: TokenContainerProviderFamily._dependencies,
          allTransitiveDependencies:
              TokenContainerProviderFamily._allTransitiveDependencies,
          containerSerial: containerSerial,
        );

  TokenContainerProviderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.containerSerial,
  }) : super.internal();

  final String containerSerial;

  @override
  FutureOr<TokenContainer?> runNotifierBuild(
    covariant TokenContainerProvider notifier,
  ) {
    return notifier.build(
      containerSerial: containerSerial,
    );
  }

  @override
  Override overrideWith(TokenContainerProvider Function() create) {
    return ProviderOverride(
      origin: this,
      override: TokenContainerProviderProvider._internal(
        () => create()..containerSerial = containerSerial,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        containerSerial: containerSerial,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<TokenContainerProvider,
      TokenContainer?> createElement() {
    return _TokenContainerProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TokenContainerProviderProvider &&
        other.containerSerial == containerSerial;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, containerSerial.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TokenContainerProviderRef
    on AutoDisposeAsyncNotifierProviderRef<TokenContainer?> {
  /// The parameter `containerSerial` of this provider.
  String get containerSerial;
}

class _TokenContainerProviderProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TokenContainerProvider,
        TokenContainer?> with TokenContainerProviderRef {
  _TokenContainerProviderProviderElement(super.provider);

  @override
  String get containerSerial =>
      (origin as TokenContainerProviderProvider).containerSerial;
}

String _$credentialsProviderHash() =>
    r'992a1e466ed24e4d0bc3eabbeaf33ff6ada90ee1';

/// See also [CredentialsProvider].
@ProviderFor(CredentialsProvider)
final credentialsProvider = AutoDisposeAsyncNotifierProvider<
    CredentialsProvider, CredentialsState>.internal(
  CredentialsProvider.new,
  name: r'credentialsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$credentialsProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CredentialsProvider = AutoDisposeAsyncNotifier<CredentialsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
