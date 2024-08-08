// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_container_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenContainerNotifierHash() =>
    r'fa7e50e1970516f60df6ba4b2ccf19dad3ab5736';

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

abstract class _$TokenContainerNotifier
    extends BuildlessAutoDisposeAsyncNotifier<TokenContainer> {
  late final ContainerCredential credential;

  FutureOr<TokenContainer> build({
    required ContainerCredential credential,
  });
}

/// See also [TokenContainerNotifier].
@ProviderFor(TokenContainerNotifier)
const tokenContainerNotifierProviderOf = TokenContainerNotifierFamily();

/// See also [TokenContainerNotifier].
class TokenContainerNotifierFamily extends Family<AsyncValue<TokenContainer>> {
  /// See also [TokenContainerNotifier].
  const TokenContainerNotifierFamily();

  /// See also [TokenContainerNotifier].
  TokenContainerNotifierProvider call({
    required ContainerCredential credential,
  }) {
    return TokenContainerNotifierProvider(
      credential: credential,
    );
  }

  @override
  TokenContainerNotifierProvider getProviderOverride(
    covariant TokenContainerNotifierProvider provider,
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
  String? get name => r'tokenContainerNotifierProviderOf';
}

/// See also [TokenContainerNotifier].
class TokenContainerNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<TokenContainerNotifier,
        TokenContainer> {
  /// See also [TokenContainerNotifier].
  TokenContainerNotifierProvider({
    required ContainerCredential credential,
  }) : this._internal(
          () => TokenContainerNotifier()..credential = credential,
          from: tokenContainerNotifierProviderOf,
          name: r'tokenContainerNotifierProviderOf',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tokenContainerNotifierHash,
          dependencies: TokenContainerNotifierFamily._dependencies,
          allTransitiveDependencies:
              TokenContainerNotifierFamily._allTransitiveDependencies,
          credential: credential,
        );

  TokenContainerNotifierProvider._internal(
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
    covariant TokenContainerNotifier notifier,
  ) {
    return notifier.build(
      credential: credential,
    );
  }

  @override
  Override overrideWith(TokenContainerNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TokenContainerNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<TokenContainerNotifier,
      TokenContainer> createElement() {
    return _TokenContainerNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TokenContainerNotifierProvider &&
        other.credential == credential;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, credential.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TokenContainerNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<TokenContainer> {
  /// The parameter `credential` of this provider.
  ContainerCredential get credential;
}

class _TokenContainerNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TokenContainerNotifier,
        TokenContainer> with TokenContainerNotifierRef {
  _TokenContainerNotifierProviderElement(super.provider);

  @override
  ContainerCredential get credential =>
      (origin as TokenContainerNotifierProvider).credential;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
