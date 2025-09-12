// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_constraints_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(AppConstraintsNotifier)
const appConstraintsNotifierProvider = AppConstraintsNotifierProvider._();

final class AppConstraintsNotifierProvider
    extends $NotifierProvider<AppConstraintsNotifier, BoxConstraints> {
  const AppConstraintsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appConstraintsNotifierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appConstraintsNotifierHash();

  @$internal
  @override
  AppConstraintsNotifier create() => AppConstraintsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BoxConstraints value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BoxConstraints>(value),
    );
  }
}

String _$appConstraintsNotifierHash() =>
    r'4c7045d74d660a9af7ccc70acd77824f719fe6aa';

abstract class _$AppConstraintsNotifier extends $Notifier<BoxConstraints> {
  BoxConstraints build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<BoxConstraints, BoxConstraints>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BoxConstraints, BoxConstraints>,
              BoxConstraints,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
