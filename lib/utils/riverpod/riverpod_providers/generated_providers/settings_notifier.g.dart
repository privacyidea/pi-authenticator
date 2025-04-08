// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsNotifierHash() => r'11c70f5634d75c1a724cb4ecaf9dd12def88e469';

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

abstract class _$SettingsNotifier
    extends BuildlessAsyncNotifier<SettingsState> {
  late final SettingsRepository repo;

  FutureOr<SettingsState> build({
    required SettingsRepository repo,
  });
}

/// See also [SettingsNotifier].
@ProviderFor(SettingsNotifier)
const settingsNotifierProviderOf = SettingsNotifierFamily();

/// See also [SettingsNotifier].
class SettingsNotifierFamily extends Family<AsyncValue<SettingsState>> {
  /// See also [SettingsNotifier].
  const SettingsNotifierFamily();

  /// See also [SettingsNotifier].
  SettingsNotifierProvider call({
    required SettingsRepository repo,
  }) {
    return SettingsNotifierProvider(
      repo: repo,
    );
  }

  @override
  SettingsNotifierProvider getProviderOverride(
    covariant SettingsNotifierProvider provider,
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
  String? get name => r'settingsNotifierProviderOf';
}

/// See also [SettingsNotifier].
class SettingsNotifierProvider
    extends AsyncNotifierProviderImpl<SettingsNotifier, SettingsState> {
  /// See also [SettingsNotifier].
  SettingsNotifierProvider({
    required SettingsRepository repo,
  }) : this._internal(
          () => SettingsNotifier()..repo = repo,
          from: settingsNotifierProviderOf,
          name: r'settingsNotifierProviderOf',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$settingsNotifierHash,
          dependencies: SettingsNotifierFamily._dependencies,
          allTransitiveDependencies:
              SettingsNotifierFamily._allTransitiveDependencies,
          repo: repo,
        );

  SettingsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.repo,
  }) : super.internal();

  final SettingsRepository repo;

  @override
  FutureOr<SettingsState> runNotifierBuild(
    covariant SettingsNotifier notifier,
  ) {
    return notifier.build(
      repo: repo,
    );
  }

  @override
  Override overrideWith(SettingsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: SettingsNotifierProvider._internal(
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
  AsyncNotifierProviderElement<SettingsNotifier, SettingsState>
      createElement() {
    return _SettingsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsNotifierProvider && other.repo == repo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, repo.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SettingsNotifierRef on AsyncNotifierProviderRef<SettingsState> {
  /// The parameter `repo` of this provider.
  SettingsRepository get repo;
}

class _SettingsNotifierProviderElement
    extends AsyncNotifierProviderElement<SettingsNotifier, SettingsState>
    with SettingsNotifierRef {
  _SettingsNotifierProviderElement(super.provider);

  @override
  SettingsRepository get repo => (origin as SettingsNotifierProvider).repo;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
