// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_container_provider.dart';

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
    r'ec9832ed16a556f269ac27705af2a3cb27dd5fd1';

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
    extends BuildlessAutoDisposeAsyncNotifier<TokenContainer> {
  late final ContainerCredential credential;

  FutureOr<TokenContainer> build({
    required ContainerCredential credential,
  });
}

/// See also [TokenContainerProvider].
@ProviderFor(TokenContainerProvider)
const tokenContainerProviderOf = TokenContainerProviderFamily();

/// See also [TokenContainerProvider].
class TokenContainerProviderFamily extends Family<AsyncValue<TokenContainer>> {
  /// See also [TokenContainerProvider].
  const TokenContainerProviderFamily();

  /// See also [TokenContainerProvider].
  TokenContainerProviderProvider call({
    required ContainerCredential credential,
  }) {
    return TokenContainerProviderProvider(
      credential: credential,
    );
  }

  @override
  TokenContainerProviderProvider getProviderOverride(
    covariant TokenContainerProviderProvider provider,
  ) {
    return call(
      credential: provider.credential,
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
        TokenContainer> {
  /// See also [TokenContainerProvider].
  TokenContainerProviderProvider({
    required ContainerCredential credential,
  }) : this._internal(
          () => TokenContainerProvider()..credential = credential,
          from: tokenContainerProviderOf,
          name: r'tokenContainerProviderOf',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tokenContainerProviderHash,
          dependencies: TokenContainerProviderFamily._dependencies,
          allTransitiveDependencies:
              TokenContainerProviderFamily._allTransitiveDependencies,
          credential: credential,
        );

  TokenContainerProviderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.credential,
  }) : super.internal();

  final ContainerCredential credential;

  @override
  FutureOr<TokenContainer> runNotifierBuild(
    covariant TokenContainerProvider notifier,
  ) {
    return notifier.build(
      credential: credential,
    );
  }

  @override
  Override overrideWith(TokenContainerProvider Function() create) {
    return ProviderOverride(
      origin: this,
      override: TokenContainerProviderProvider._internal(
        () => create()..credential = credential,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        credential: credential,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<TokenContainerProvider,
      TokenContainer> createElement() {
    return _TokenContainerProviderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TokenContainerProviderProvider &&
        other.credential == credential;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, credential.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TokenContainerProviderRef
    on AutoDisposeAsyncNotifierProviderRef<TokenContainer> {
  /// The parameter `credential` of this provider.
  ContainerCredential get credential;
}

class _TokenContainerProviderProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TokenContainerProvider,
        TokenContainer> with TokenContainerProviderRef {
  _TokenContainerProviderProviderElement(super.provider);

  @override
  ContainerCredential get credential =>
      (origin as TokenContainerProviderProvider).credential;
}

String _$credentialsProviderHash() =>
    r'1cd835b458424a6ab8e1d60850ce455de9d0efa6';

/// See also [CredentialsProvider].
@ProviderFor(CredentialsProvider)
final credentialsProvider =
    AsyncNotifierProvider<CredentialsProvider, CredentialsState>.internal(
  CredentialsProvider.new,
  name: r'credentialsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$credentialsProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CredentialsProvider = AsyncNotifier<CredentialsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
