// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_customization_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Only used for the app customizer

@ProviderFor(AppCustomizationNotifier)
const appCustomizationProvider = AppCustomizationNotifierProvider._();

/// Only used for the app customizer
final class AppCustomizationNotifierProvider
    extends
        $AsyncNotifierProvider<
          AppCustomizationNotifier,
          ApplicationCustomization
        > {
  /// Only used for the app customizer
  const AppCustomizationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appCustomizationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appCustomizationNotifierHash();

  @$internal
  @override
  AppCustomizationNotifier create() => AppCustomizationNotifier();
}

String _$appCustomizationNotifierHash() =>
    r'517fa51213f099d53d79386fcc0370af75d41964';

/// Only used for the app customizer

abstract class _$AppCustomizationNotifier
    extends $AsyncNotifier<ApplicationCustomization> {
  FutureOr<ApplicationCustomization> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ApplicationCustomization>,
              ApplicationCustomization
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ApplicationCustomization>,
                ApplicationCustomization
              >,
              AsyncValue<ApplicationCustomization>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
