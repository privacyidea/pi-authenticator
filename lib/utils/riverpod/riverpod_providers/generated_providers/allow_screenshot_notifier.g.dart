// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allow_screenshot_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allowScreenshotNotifierHash() =>
    r'65722f0e9e3ad83966c09a9c7fad177a1f5a7c15';

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

abstract class _$AllowScreenshotNotifier extends BuildlessAsyncNotifier<bool> {
  late final AllowScreenshotUtils screenshotUtils;

  FutureOr<bool> build({
    required AllowScreenshotUtils screenshotUtils,
  });
}

/// See also [AllowScreenshotNotifier].
@ProviderFor(AllowScreenshotNotifier)
const allowScreenshotNotifierProviderOf = AllowScreenshotNotifierFamily();

/// See also [AllowScreenshotNotifier].
class AllowScreenshotNotifierFamily extends Family<AsyncValue<bool>> {
  /// See also [AllowScreenshotNotifier].
  const AllowScreenshotNotifierFamily();

  /// See also [AllowScreenshotNotifier].
  AllowScreenshotNotifierProvider call({
    required AllowScreenshotUtils screenshotUtils,
  }) {
    return AllowScreenshotNotifierProvider(
      screenshotUtils: screenshotUtils,
    );
  }

  @override
  AllowScreenshotNotifierProvider getProviderOverride(
    covariant AllowScreenshotNotifierProvider provider,
  ) {
    return call(
      screenshotUtils: provider.screenshotUtils,
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
  String? get name => r'allowScreenshotNotifierProviderOf';
}

/// See also [AllowScreenshotNotifier].
class AllowScreenshotNotifierProvider
    extends AsyncNotifierProviderImpl<AllowScreenshotNotifier, bool> {
  /// See also [AllowScreenshotNotifier].
  AllowScreenshotNotifierProvider({
    required AllowScreenshotUtils screenshotUtils,
  }) : this._internal(
          () => AllowScreenshotNotifier()..screenshotUtils = screenshotUtils,
          from: allowScreenshotNotifierProviderOf,
          name: r'allowScreenshotNotifierProviderOf',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$allowScreenshotNotifierHash,
          dependencies: AllowScreenshotNotifierFamily._dependencies,
          allTransitiveDependencies:
              AllowScreenshotNotifierFamily._allTransitiveDependencies,
          screenshotUtils: screenshotUtils,
        );

  AllowScreenshotNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.screenshotUtils,
  }) : super.internal();

  final AllowScreenshotUtils screenshotUtils;

  @override
  FutureOr<bool> runNotifierBuild(
    covariant AllowScreenshotNotifier notifier,
  ) {
    return notifier.build(
      screenshotUtils: screenshotUtils,
    );
  }

  @override
  Override overrideWith(AllowScreenshotNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: AllowScreenshotNotifierProvider._internal(
        () => create()..screenshotUtils = screenshotUtils,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        screenshotUtils: screenshotUtils,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<AllowScreenshotNotifier, bool> createElement() {
    return _AllowScreenshotNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllowScreenshotNotifierProvider &&
        other.screenshotUtils == screenshotUtils;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, screenshotUtils.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AllowScreenshotNotifierRef on AsyncNotifierProviderRef<bool> {
  /// The parameter `screenshotUtils` of this provider.
  AllowScreenshotUtils get screenshotUtils;
}

class _AllowScreenshotNotifierProviderElement
    extends AsyncNotifierProviderElement<AllowScreenshotNotifier, bool>
    with AllowScreenshotNotifierRef {
  _AllowScreenshotNotifierProviderElement(super.provider);

  @override
  AllowScreenshotUtils get screenshotUtils =>
      (origin as AllowScreenshotNotifierProvider).screenshotUtils;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
