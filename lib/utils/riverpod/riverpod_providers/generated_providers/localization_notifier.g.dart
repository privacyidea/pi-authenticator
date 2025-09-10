// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localization_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(LocalizationNotifier)
const localizationNotifierProvider = LocalizationNotifierProvider._();

final class LocalizationNotifierProvider
    extends $NotifierProvider<LocalizationNotifier, AppLocalizations> {
  const LocalizationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localizationNotifierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localizationNotifierHash();

  @$internal
  @override
  LocalizationNotifier create() => LocalizationNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLocalizations value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLocalizations>(value),
    );
  }
}

String _$localizationNotifierHash() =>
    r'2e87d7cfb7470b202d97fa2bf766a72f2a4debe3';

abstract class _$LocalizationNotifier extends $Notifier<AppLocalizations> {
  AppLocalizations build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AppLocalizations, AppLocalizations>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppLocalizations, AppLocalizations>,
              AppLocalizations,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
