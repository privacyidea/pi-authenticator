// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localization_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocalizationNotifier)
final localizationProvider = LocalizationNotifierProvider._();

final class LocalizationNotifierProvider
    extends $NotifierProvider<LocalizationNotifier, AppLocalizations> {
  LocalizationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localizationProvider',
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
    final ref = this.ref as $Ref<AppLocalizations, AppLocalizations>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppLocalizations, AppLocalizations>,
              AppLocalizations,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
