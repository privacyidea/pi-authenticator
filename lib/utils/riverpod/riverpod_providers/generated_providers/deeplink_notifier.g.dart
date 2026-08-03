// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deeplink_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeeplinkNotifier)
final deeplinkProvider = DeeplinkNotifierProvider._();

final class DeeplinkNotifierProvider
    extends $StreamNotifierProvider<DeeplinkNotifier, DeepLink> {
  DeeplinkNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deeplinkProvider',
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

String _$deeplinkNotifierHash() => r'9d97c7f0b0f581a674308344b44a73c68205fa57';

abstract class _$DeeplinkNotifier extends $StreamNotifier<DeepLink> {
  Stream<DeepLink> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DeepLink>, DeepLink>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DeepLink>, DeepLink>,
              AsyncValue<DeepLink>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
