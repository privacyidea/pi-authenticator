// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_customization_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

/// Only used for the app customizer
@ProviderFor(AppCustomizationNotifier)
const appCustomizationNotifierProvider = AppCustomizationNotifierProvider._();

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
        name: r'appCustomizationNotifierProvider',
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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
