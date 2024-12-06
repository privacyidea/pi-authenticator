// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_request_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pushRequestNotifierHash() =>
    r'1a2cb2d1f2e197a93cc7a836346c1a2ff749c676';

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

abstract class _$PushRequestNotifier
    extends BuildlessAsyncNotifier<PushRequestState> {
  late final RsaUtils rsaUtils;
  late final PrivacyideaIOClient ioClient;
  late final PushProvider pushProvider;
  late final PushRequestRepository pushRepo;

  FutureOr<PushRequestState> build({
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required PushProvider pushProvider,
    required PushRequestRepository pushRepo,
  });
}

/// See also [PushRequestNotifier].
@ProviderFor(PushRequestNotifier)
const pushRequestNotifierProviderOf = PushRequestNotifierFamily();

/// See also [PushRequestNotifier].
class PushRequestNotifierFamily extends Family<AsyncValue<PushRequestState>> {
  /// See also [PushRequestNotifier].
  const PushRequestNotifierFamily();

  /// See also [PushRequestNotifier].
  PushRequestNotifierProvider call({
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required PushProvider pushProvider,
    required PushRequestRepository pushRepo,
  }) {
    return PushRequestNotifierProvider(
      rsaUtils: rsaUtils,
      ioClient: ioClient,
      pushProvider: pushProvider,
      pushRepo: pushRepo,
    );
  }

  @override
  PushRequestNotifierProvider getProviderOverride(
    covariant PushRequestNotifierProvider provider,
  ) {
    return call(
      rsaUtils: provider.rsaUtils,
      ioClient: provider.ioClient,
      pushProvider: provider.pushProvider,
      pushRepo: provider.pushRepo,
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
  String? get name => r'pushRequestNotifierProviderOf';
}

/// See also [PushRequestNotifier].
class PushRequestNotifierProvider
    extends AsyncNotifierProviderImpl<PushRequestNotifier, PushRequestState> {
  /// See also [PushRequestNotifier].
  PushRequestNotifierProvider({
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required PushProvider pushProvider,
    required PushRequestRepository pushRepo,
  }) : this._internal(
          () => PushRequestNotifier()
            ..rsaUtils = rsaUtils
            ..ioClient = ioClient
            ..pushProvider = pushProvider
            ..pushRepo = pushRepo,
          from: pushRequestNotifierProviderOf,
          name: r'pushRequestNotifierProviderOf',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$pushRequestNotifierHash,
          dependencies: PushRequestNotifierFamily._dependencies,
          allTransitiveDependencies:
              PushRequestNotifierFamily._allTransitiveDependencies,
          rsaUtils: rsaUtils,
          ioClient: ioClient,
          pushProvider: pushProvider,
          pushRepo: pushRepo,
        );

  PushRequestNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.rsaUtils,
    required this.ioClient,
    required this.pushProvider,
    required this.pushRepo,
  }) : super.internal();

  final RsaUtils rsaUtils;
  final PrivacyideaIOClient ioClient;
  final PushProvider pushProvider;
  final PushRequestRepository pushRepo;

  @override
  FutureOr<PushRequestState> runNotifierBuild(
    covariant PushRequestNotifier notifier,
  ) {
    return notifier.build(
      rsaUtils: rsaUtils,
      ioClient: ioClient,
      pushProvider: pushProvider,
      pushRepo: pushRepo,
    );
  }

  @override
  Override overrideWith(PushRequestNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: PushRequestNotifierProvider._internal(
        () => create()
          ..rsaUtils = rsaUtils
          ..ioClient = ioClient
          ..pushProvider = pushProvider
          ..pushRepo = pushRepo,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        rsaUtils: rsaUtils,
        ioClient: ioClient,
        pushProvider: pushProvider,
        pushRepo: pushRepo,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<PushRequestNotifier, PushRequestState>
      createElement() {
    return _PushRequestNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PushRequestNotifierProvider &&
        other.rsaUtils == rsaUtils &&
        other.ioClient == ioClient &&
        other.pushProvider == pushProvider &&
        other.pushRepo == pushRepo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, rsaUtils.hashCode);
    hash = _SystemHash.combine(hash, ioClient.hashCode);
    hash = _SystemHash.combine(hash, pushProvider.hashCode);
    hash = _SystemHash.combine(hash, pushRepo.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PushRequestNotifierRef on AsyncNotifierProviderRef<PushRequestState> {
  /// The parameter `rsaUtils` of this provider.
  RsaUtils get rsaUtils;

  /// The parameter `ioClient` of this provider.
  PrivacyideaIOClient get ioClient;

  /// The parameter `pushProvider` of this provider.
  PushProvider get pushProvider;

  /// The parameter `pushRepo` of this provider.
  PushRequestRepository get pushRepo;
}

class _PushRequestNotifierProviderElement
    extends AsyncNotifierProviderElement<PushRequestNotifier, PushRequestState>
    with PushRequestNotifierRef {
  _PushRequestNotifierProviderElement(super.provider);

  @override
  RsaUtils get rsaUtils => (origin as PushRequestNotifierProvider).rsaUtils;
  @override
  PrivacyideaIOClient get ioClient =>
      (origin as PushRequestNotifierProvider).ioClient;
  @override
  PushProvider get pushProvider =>
      (origin as PushRequestNotifierProvider).pushProvider;
  @override
  PushRequestRepository get pushRepo =>
      (origin as PushRequestNotifierProvider).pushRepo;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
