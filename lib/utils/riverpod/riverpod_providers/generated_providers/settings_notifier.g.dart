// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SettingsNotifier)
const settingsProviderOf = SettingsNotifierFamily._();

final class SettingsNotifierProvider
    extends $AsyncNotifierProvider<SettingsNotifier, SettingsState> {
  const SettingsNotifierProvider._({
    required SettingsNotifierFamily super.from,
    required SettingsRepository super.argument,
  }) : super(
         retry: null,
         name: r'settingsProviderOf',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$settingsNotifierHash();

  @override
  String toString() {
    return r'settingsProviderOf'
        ''
        '($argument)';
  }

  @$internal
  @override
  SettingsNotifier create() => SettingsNotifier();

  @override
  bool operator ==(Object other) {
    return other is SettingsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$settingsNotifierHash() => r'153f57fa9a5b365e5af6159082baaf95e9af5d76';

final class SettingsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          SettingsNotifier,
          AsyncValue<SettingsState>,
          SettingsState,
          FutureOr<SettingsState>,
          SettingsRepository
        > {
  const SettingsNotifierFamily._()
    : super(
        retry: null,
        name: r'settingsProviderOf',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SettingsNotifierProvider call({required SettingsRepository repo}) =>
      SettingsNotifierProvider._(argument: repo, from: this);

  @override
  String toString() => r'settingsProviderOf';
}

abstract class _$SettingsNotifier extends $AsyncNotifier<SettingsState> {
  late final _$args = ref.$arg as SettingsRepository;
  SettingsRepository get repo => _$args;

  FutureOr<SettingsState> build({required SettingsRepository repo});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(repo: _$args);
    final ref = this.ref as $Ref<AsyncValue<SettingsState>, SettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SettingsState>, SettingsState>,
              AsyncValue<SettingsState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
