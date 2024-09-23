// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'introduction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$introductionNotifierHash() =>
    r'7b60b259a94bafa9de1dff73189b79b685271cb8';

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

abstract class _$IntroductionNotifier
    extends BuildlessAsyncNotifier<IntroductionState> {
  late final IntroductionRepository repo;

  FutureOr<IntroductionState> build({
    required IntroductionRepository repo,
  });
}

/// See also [IntroductionNotifier].
@ProviderFor(IntroductionNotifier)
const introductionNotifierProviderOf = IntroductionNotifierFamily();

/// See also [IntroductionNotifier].
class IntroductionNotifierFamily extends Family<AsyncValue<IntroductionState>> {
  /// See also [IntroductionNotifier].
  const IntroductionNotifierFamily();

  /// See also [IntroductionNotifier].
  IntroductionNotifierProvider call({
    required IntroductionRepository repo,
  }) {
    return IntroductionNotifierProvider(
      repo: repo,
    );
  }

  @override
  IntroductionNotifierProvider getProviderOverride(
    covariant IntroductionNotifierProvider provider,
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
  String? get name => r'introductionNotifierProviderOf';
}

/// See also [IntroductionNotifier].
class IntroductionNotifierProvider
    extends AsyncNotifierProviderImpl<IntroductionNotifier, IntroductionState> {
  /// See also [IntroductionNotifier].
  IntroductionNotifierProvider({
    required IntroductionRepository repo,
  }) : this._internal(
          () => IntroductionNotifier()..repo = repo,
          from: introductionNotifierProviderOf,
          name: r'introductionNotifierProviderOf',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$introductionNotifierHash,
          dependencies: IntroductionNotifierFamily._dependencies,
          allTransitiveDependencies:
              IntroductionNotifierFamily._allTransitiveDependencies,
          repo: repo,
        );

  IntroductionNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.repo,
  }) : super.internal();

  final IntroductionRepository repo;

  @override
  FutureOr<IntroductionState> runNotifierBuild(
    covariant IntroductionNotifier notifier,
  ) {
    return notifier.build(
      repo: repo,
    );
  }

  @override
  Override overrideWith(IntroductionNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: IntroductionNotifierProvider._internal(
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
  AsyncNotifierProviderElement<IntroductionNotifier, IntroductionState>
      createElement() {
    return _IntroductionNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IntroductionNotifierProvider && other.repo == repo;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, repo.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IntroductionNotifierRef on AsyncNotifierProviderRef<IntroductionState> {
  /// The parameter `repo` of this provider.
  IntroductionRepository get repo;
}

class _IntroductionNotifierProviderElement extends AsyncNotifierProviderElement<
    IntroductionNotifier, IntroductionState> with IntroductionNotifierRef {
  _IntroductionNotifierProviderElement(super.provider);

  @override
  IntroductionRepository get repo =>
      (origin as IntroductionNotifierProvider).repo;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
