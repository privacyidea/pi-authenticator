// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_folder_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tokenFolderNotifierHash() =>
    r'1302c08e0a69caa5abda317a509b3c40f84b24e1';

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

abstract class _$TokenFolderNotifier
    extends BuildlessNotifier<TokenFolderState> {
  late final TokenFolderRepository repo;

  TokenFolderState build({
    required TokenFolderRepository repo,
  });
}

/// See also [TokenFolderNotifier].
@ProviderFor(TokenFolderNotifier)
const tokenFolderNotifierProviderOf = TokenFolderNotifierFamily();

/// See also [TokenFolderNotifier].
class TokenFolderNotifierFamily extends Family<TokenFolderState> {
  /// See also [TokenFolderNotifier].
  const TokenFolderNotifierFamily();

  /// See also [TokenFolderNotifier].
  TokenFolderNotifierProvider call({
    required TokenFolderRepository repo,
  }) {
    return TokenFolderNotifierProvider(
      repo: repo,
    );
  }

  @override
  TokenFolderNotifierProvider getProviderOverride(
    covariant TokenFolderNotifierProvider provider,
  ) {
    return call(
      repo: provider.repo,
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
  String? get name => r'tokenFolderNotifierProviderOf';
}

/// See also [TokenFolderNotifier].
class TokenFolderNotifierProvider
    extends NotifierProviderImpl<TokenFolderNotifier, TokenFolderState> {
  /// See also [TokenFolderNotifier].
  TokenFolderNotifierProvider({
    required TokenFolderRepository repo,
  }) : this._internal(
          () => TokenFolderNotifier()..repo = repo,
          from: tokenFolderNotifierProviderOf,
          name: r'tokenFolderNotifierProviderOf',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tokenFolderNotifierHash,
          dependencies: TokenFolderNotifierFamily._dependencies,
          allTransitiveDependencies:
              TokenFolderNotifierFamily._allTransitiveDependencies,
          repo: repo,
        );

  TokenFolderNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.repo,
  }) : super.internal();

  final TokenFolderRepository repo;

  @override
  TokenFolderState runNotifierBuild(
    covariant TokenFolderNotifier notifier,
  ) {
    return notifier.build(
      repo: repo,
    );
  }

  @override
  Override overrideWith(TokenFolderNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TokenFolderNotifierProvider._internal(
        () => create()..repo = repo,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        repo: repo,
      ),
    );
  }

  @override
  NotifierProviderElement<TokenFolderNotifier, TokenFolderState>
      createElement() {
    return _TokenFolderNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TokenFolderNotifierProvider && other.repo == repo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, repo.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TokenFolderNotifierRef on NotifierProviderRef<TokenFolderState> {
  /// The parameter `repo` of this provider.
  TokenFolderRepository get repo;
}

class _TokenFolderNotifierProviderElement
    extends NotifierProviderElement<TokenFolderNotifier, TokenFolderState>
    with TokenFolderNotifierRef {
  _TokenFolderNotifierProviderElement(super.provider);

  @override
  TokenFolderRepository get repo =>
      (origin as TokenFolderNotifierProvider).repo;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
