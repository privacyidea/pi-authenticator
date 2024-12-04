// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenNotifierHash() => r'e1caf9d769fe53c8ecdd382d9c414a3252d0ec49';

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
  late final FirebaseUtils firebaseUtils;

  TokenState build({
    required TokenRepository repo,
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required FirebaseUtils firebaseUtils,
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
    required FirebaseUtils firebaseUtils,
  }) {
    return TokenNotifierProvider(
      repo: repo,
      rsaUtils: rsaUtils,
      ioClient: ioClient,
      firebaseUtils: firebaseUtils,
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
      firebaseUtils: provider.firebaseUtils,
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
    required FirebaseUtils firebaseUtils,
  }) : this._internal(
          () => TokenNotifier()
            ..repo = repo
            ..rsaUtils = rsaUtils
            ..ioClient = ioClient
            ..firebaseUtils = firebaseUtils,
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
          firebaseUtils: firebaseUtils,
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
    required this.firebaseUtils,
  }) : super.internal();

  final TokenRepository repo;
  final RsaUtils rsaUtils;
  final PrivacyideaIOClient ioClient;
  final FirebaseUtils firebaseUtils;

  @override
  TokenState runNotifierBuild(
    covariant TokenNotifier notifier,
  ) {
    return notifier.build(
      repo: repo,
      rsaUtils: rsaUtils,
      ioClient: ioClient,
      firebaseUtils: firebaseUtils,
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
          ..ioClient = ioClient
          ..firebaseUtils = firebaseUtils,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        repo: repo,
        rsaUtils: rsaUtils,
        ioClient: ioClient,
        firebaseUtils: firebaseUtils,
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
        other.ioClient == ioClient &&
        other.firebaseUtils == firebaseUtils;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, repo.hashCode);
    hash = _SystemHash.combine(hash, rsaUtils.hashCode);
    hash = _SystemHash.combine(hash, ioClient.hashCode);
    hash = _SystemHash.combine(hash, firebaseUtils.hashCode);

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

  /// The parameter `firebaseUtils` of this provider.
  FirebaseUtils get firebaseUtils;
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
  @override
  FirebaseUtils get firebaseUtils =>
      (origin as TokenNotifierProvider).firebaseUtils;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
