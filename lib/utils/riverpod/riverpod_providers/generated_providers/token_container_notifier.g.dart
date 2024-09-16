// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_container_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenContainerNotifierHash() =>
    r'cf5aaebd080b94a5bff442a564a8f29280f56871';

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
    extends BuildlessAsyncNotifier<TokenContainerState> {
  late final TokenContainerRepository repo;
  late final PrivacyideaContainerApi containerApi;
  late final EccUtils eccUtils;

  FutureOr<TokenContainerState> build({
    required TokenContainerRepository repo,
    required PrivacyideaContainerApi containerApi,
    required EccUtils eccUtils,
  });
}

/// See also [TokenContainerNotifier].
@ProviderFor(TokenContainerNotifier)
const tokenContainerNotifierProviderOf = TokenContainerNotifierFamily();

/// See also [TokenContainerNotifier].
class TokenContainerNotifierFamily
    extends Family<AsyncValue<TokenContainerState>> {
  /// See also [TokenContainerNotifier].
  const TokenContainerNotifierFamily();

  /// See also [TokenContainerNotifier].
  TokenContainerNotifierProvider call({
    required TokenContainerRepository repo,
    required PrivacyideaContainerApi containerApi,
    required EccUtils eccUtils,
  }) {
    return TokenContainerNotifierProvider(
      repo: repo,
      containerApi: containerApi,
      eccUtils: eccUtils,
    );
  }

  @override
  TokenContainerNotifierProvider getProviderOverride(
    covariant TokenContainerNotifierProvider provider,
  ) {
    return call(
      repo: provider.repo,
      containerApi: provider.containerApi,
      eccUtils: provider.eccUtils,
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
class TokenContainerNotifierProvider extends AsyncNotifierProviderImpl<
    TokenContainerNotifier, TokenContainerState> {
  /// See also [TokenContainerNotifier].
  TokenContainerNotifierProvider({
    required TokenContainerRepository repo,
    required PrivacyideaContainerApi containerApi,
    required EccUtils eccUtils,
  }) : this._internal(
          () => TokenContainerNotifier()
            ..repo = repo
            ..containerApi = containerApi
            ..eccUtils = eccUtils,
          from: tokenContainerNotifierProviderOf,
          name: r'tokenContainerNotifierProviderOf',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tokenContainerNotifierHash,
          dependencies: TokenContainerNotifierFamily._dependencies,
          allTransitiveDependencies:
              TokenContainerNotifierFamily._allTransitiveDependencies,
          repo: repo,
          containerApi: containerApi,
          eccUtils: eccUtils,
        );

  TokenContainerNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.repo,
    required this.containerApi,
    required this.eccUtils,
  }) : super.internal();

  final TokenContainerRepository repo;
  final PrivacyideaContainerApi containerApi;
  final EccUtils eccUtils;

  @override
  FutureOr<TokenContainerState> runNotifierBuild(
    covariant TokenContainerNotifier notifier,
  ) {
    return notifier.build(
      repo: repo,
      containerApi: containerApi,
      eccUtils: eccUtils,
    );
  }

  @override
  Override overrideWith(TokenContainerNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TokenContainerNotifierProvider._internal(
        () => create()
          ..repo = repo
          ..containerApi = containerApi
          ..eccUtils = eccUtils,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        repo: repo,
        containerApi: containerApi,
        eccUtils: eccUtils,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<TokenContainerNotifier, TokenContainerState>
      createElement() {
    return _TokenContainerNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TokenContainerNotifierProvider &&
        other.repo == repo &&
        other.containerApi == containerApi &&
        other.eccUtils == eccUtils;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, repo.hashCode);
    hash = _SystemHash.combine(hash, containerApi.hashCode);
    hash = _SystemHash.combine(hash, eccUtils.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TokenContainerNotifierRef
    on AsyncNotifierProviderRef<TokenContainerState> {
  /// The parameter `repo` of this provider.
  TokenContainerRepository get repo;

  /// The parameter `containerApi` of this provider.
  PrivacyideaContainerApi get containerApi;

  /// The parameter `eccUtils` of this provider.
  EccUtils get eccUtils;
}

class _TokenContainerNotifierProviderElement
    extends AsyncNotifierProviderElement<TokenContainerNotifier,
        TokenContainerState> with TokenContainerNotifierRef {
  _TokenContainerNotifierProviderElement(super.provider);

  @override
  TokenContainerRepository get repo =>
      (origin as TokenContainerNotifierProvider).repo;
  @override
  PrivacyideaContainerApi get containerApi =>
      (origin as TokenContainerNotifierProvider).containerApi;
  @override
  EccUtils get eccUtils => (origin as TokenContainerNotifierProvider).eccUtils;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
