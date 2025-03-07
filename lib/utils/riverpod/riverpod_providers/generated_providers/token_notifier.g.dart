// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenNotifierHash() => r'bfbb09b50fa674457e1615230b2d6f0edd9a81a5';

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

abstract class _$TokenNotifier extends BuildlessNotifier<TokenState> {
  late final TokenRepository repo;
  late final RsaUtils rsaUtils;
  late final PrivacyideaIOClient ioClient;

  TokenState build({
    required TokenRepository repo,
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
  });
}

/// See also [TokenNotifier].
@ProviderFor(TokenNotifier)
const tokenNotifierProviderOf = TokenNotifierFamily();

/// See also [TokenNotifier].
class TokenNotifierFamily extends Family<TokenState> {
  /// See also [TokenNotifier].
  const TokenNotifierFamily();

  /// See also [TokenNotifier].
  TokenNotifierProvider call({
    required TokenRepository repo,
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
  }) {
    return TokenNotifierProvider(
      repo: repo,
      rsaUtils: rsaUtils,
      ioClient: ioClient,
    );
  }

  @override
  TokenNotifierProvider getProviderOverride(
    covariant TokenNotifierProvider provider,
  ) {
    return call(
      repo: provider.repo,
      rsaUtils: provider.rsaUtils,
      ioClient: provider.ioClient,
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
  String? get name => r'tokenNotifierProviderOf';
}

/// See also [TokenNotifier].
class TokenNotifierProvider
    extends NotifierProviderImpl<TokenNotifier, TokenState> {
  /// See also [TokenNotifier].
  TokenNotifierProvider({
    required TokenRepository repo,
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
  }) : this._internal(
          () => TokenNotifier()
            ..repo = repo
            ..rsaUtils = rsaUtils
            ..ioClient = ioClient,
          from: tokenNotifierProviderOf,
          name: r'tokenNotifierProviderOf',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tokenNotifierHash,
          dependencies: TokenNotifierFamily._dependencies,
          allTransitiveDependencies:
              TokenNotifierFamily._allTransitiveDependencies,
          repo: repo,
          rsaUtils: rsaUtils,
          ioClient: ioClient,
        );

  TokenNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.repo,
    required this.rsaUtils,
    required this.ioClient,
  }) : super.internal();

  final TokenRepository repo;
  final RsaUtils rsaUtils;
  final PrivacyideaIOClient ioClient;

  @override
  TokenState runNotifierBuild(
    covariant TokenNotifier notifier,
  ) {
    return notifier.build(
      repo: repo,
      rsaUtils: rsaUtils,
      ioClient: ioClient,
    );
  }

  @override
  Override overrideWith(TokenNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TokenNotifierProvider._internal(
        () => create()
          ..repo = repo
          ..rsaUtils = rsaUtils
          ..ioClient = ioClient,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        repo: repo,
        rsaUtils: rsaUtils,
        ioClient: ioClient,
      ),
    );
  }

  @override
  NotifierProviderElement<TokenNotifier, TokenState> createElement() {
    return _TokenNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TokenNotifierProvider &&
        other.repo == repo &&
        other.rsaUtils == rsaUtils &&
        other.ioClient == ioClient;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, repo.hashCode);
    hash = _SystemHash.combine(hash, rsaUtils.hashCode);
    hash = _SystemHash.combine(hash, ioClient.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TokenNotifierRef on NotifierProviderRef<TokenState> {
  /// The parameter `repo` of this provider.
  TokenRepository get repo;

  /// The parameter `rsaUtils` of this provider.
  RsaUtils get rsaUtils;

  /// The parameter `ioClient` of this provider.
  PrivacyideaIOClient get ioClient;
}

class _TokenNotifierProviderElement
    extends NotifierProviderElement<TokenNotifier, TokenState>
    with TokenNotifierRef {
  _TokenNotifierProviderElement(super.provider);

  @override
  TokenRepository get repo => (origin as TokenNotifierProvider).repo;
  @override
  RsaUtils get rsaUtils => (origin as TokenNotifierProvider).rsaUtils;
  @override
  PrivacyideaIOClient get ioClient =>
      (origin as TokenNotifierProvider).ioClient;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
