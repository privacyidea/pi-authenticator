// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deeplink_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(DeeplinkNotifier)
const deeplinkNotifierProvider = DeeplinkNotifierProvider._();

final class DeeplinkNotifierProvider
    extends $StreamNotifierProvider<DeeplinkNotifier, DeepLink> {
  const DeeplinkNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deeplinkNotifierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deeplinkNotifierHash();

  @$internal
  @override
  DeeplinkNotifier create() => DeeplinkNotifier();
}

String _$deeplinkNotifierHash() => r'4d2679c2d7edd3efe7b05aa4b64aa1be4b8cdbb4';

abstract class _$DeeplinkNotifier extends $StreamNotifier<DeepLink> {
  Stream<DeepLink> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<DeepLink>, DeepLink>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DeepLink>, DeepLink>,
              AsyncValue<DeepLink>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
