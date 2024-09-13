// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$containerCredentialsNotifierHash() =>
    r'83daeabb57839b956f33171c95c8f45393049d29';

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

abstract class _$ContainerCredentialsNotifier
    extends BuildlessAsyncNotifier<CredentialsState> {
  late final ContainerCredentialsRepository repo;
  late final PrivacyideaContainerApi containerApi;
  late final EccUtils eccUtils;

  FutureOr<CredentialsState> build({
    required ContainerCredentialsRepository repo,
    required PrivacyideaContainerApi containerApi,
    required EccUtils eccUtils,
  });
}

/// See also [ContainerCredentialsNotifier].
@ProviderFor(ContainerCredentialsNotifier)
const containerCredentialsNotifierProviderOf =
    ContainerCredentialsNotifierFamily();

/// See also [ContainerCredentialsNotifier].
class ContainerCredentialsNotifierFamily
    extends Family<AsyncValue<CredentialsState>> {
  /// See also [ContainerCredentialsNotifier].
  const ContainerCredentialsNotifierFamily();

  /// See also [ContainerCredentialsNotifier].
  ContainerCredentialsNotifierProvider call({
    required ContainerCredentialsRepository repo,
    required PrivacyideaContainerApi containerApi,
    required EccUtils eccUtils,
  }) {
    return ContainerCredentialsNotifierProvider(
      repo: repo,
      containerApi: containerApi,
      eccUtils: eccUtils,
    );
  }

  @override
  ContainerCredentialsNotifierProvider getProviderOverride(
    covariant ContainerCredentialsNotifierProvider provider,
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
  String? get name => r'containerCredentialsNotifierProviderOf';
}

/// See also [ContainerCredentialsNotifier].
class ContainerCredentialsNotifierProvider extends AsyncNotifierProviderImpl<
    ContainerCredentialsNotifier, CredentialsState> {
  /// See also [ContainerCredentialsNotifier].
  ContainerCredentialsNotifierProvider({
    required ContainerCredentialsRepository repo,
    required PrivacyideaContainerApi containerApi,
    required EccUtils eccUtils,
  }) : this._internal(
          () => ContainerCredentialsNotifier()
            ..repo = repo
            ..containerApi = containerApi
            ..eccUtils = eccUtils,
          from: containerCredentialsNotifierProviderOf,
          name: r'containerCredentialsNotifierProviderOf',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$containerCredentialsNotifierHash,
          dependencies: ContainerCredentialsNotifierFamily._dependencies,
          allTransitiveDependencies:
              ContainerCredentialsNotifierFamily._allTransitiveDependencies,
          repo: repo,
          containerApi: containerApi,
          eccUtils: eccUtils,
        );

  ContainerCredentialsNotifierProvider._internal(
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

  final ContainerCredentialsRepository repo;
  final PrivacyideaContainerApi containerApi;
  final EccUtils eccUtils;

  @override
  FutureOr<CredentialsState> runNotifierBuild(
    covariant ContainerCredentialsNotifier notifier,
  ) {
    return notifier.build(
      repo: repo,
      containerApi: containerApi,
      eccUtils: eccUtils,
    );
  }

  @override
  Override overrideWith(ContainerCredentialsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ContainerCredentialsNotifierProvider._internal(
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
  AsyncNotifierProviderElement<ContainerCredentialsNotifier, CredentialsState>
      createElement() {
    return _ContainerCredentialsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerCredentialsNotifierProvider &&
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

mixin ContainerCredentialsNotifierRef
    on AsyncNotifierProviderRef<CredentialsState> {
  /// The parameter `repo` of this provider.
  ContainerCredentialsRepository get repo;

  /// The parameter `containerApi` of this provider.
  PrivacyideaContainerApi get containerApi;

  /// The parameter `eccUtils` of this provider.
  EccUtils get eccUtils;
}

class _ContainerCredentialsNotifierProviderElement
    extends AsyncNotifierProviderElement<ContainerCredentialsNotifier,
        CredentialsState> with ContainerCredentialsNotifierRef {
  _ContainerCredentialsNotifierProviderElement(super.provider);

  @override
  ContainerCredentialsRepository get repo =>
      (origin as ContainerCredentialsNotifierProvider).repo;
  @override
  PrivacyideaContainerApi get containerApi =>
      (origin as ContainerCredentialsNotifierProvider).containerApi;
  @override
  EccUtils get eccUtils =>
      (origin as ContainerCredentialsNotifierProvider).eccUtils;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
