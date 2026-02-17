// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'introduction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IntroductionNotifier)
final introductionProviderOf = IntroductionNotifierFamily._();

final class IntroductionNotifierProvider
    extends $AsyncNotifierProvider<IntroductionNotifier, IntroductionState> {
  IntroductionNotifierProvider._({
    required IntroductionNotifierFamily super.from,
    required IntroductionRepository super.argument,
  }) : super(
         retry: null,
         name: r'introductionProviderOf',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$introductionNotifierHash();

  @override
  String toString() {
    return r'introductionProviderOf'
        ''
        '($argument)';
  }

  @$internal
  @override
  IntroductionNotifier create() => IntroductionNotifier();

  @override
  bool operator ==(Object other) {
    return other is IntroductionNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$introductionNotifierHash() =>
    r'de3ab6d291606999944ddfc6aa3804b9c0ed04ca';

final class IntroductionNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          IntroductionNotifier,
          AsyncValue<IntroductionState>,
          IntroductionState,
          FutureOr<IntroductionState>,
          IntroductionRepository
        > {
  IntroductionNotifierFamily._()
    : super(
        retry: null,
        name: r'introductionProviderOf',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  IntroductionNotifierProvider call({required IntroductionRepository repo}) =>
      IntroductionNotifierProvider._(argument: repo, from: this);

  @override
  String toString() => r'introductionProviderOf';
}

abstract class _$IntroductionNotifier
    extends $AsyncNotifier<IntroductionState> {
  late final _$args = ref.$arg as IntroductionRepository;
  IntroductionRepository get repo => _$args;

  FutureOr<IntroductionState> build({required IntroductionRepository repo});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<IntroductionState>, IntroductionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<IntroductionState>, IntroductionState>,
              AsyncValue<IntroductionState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(repo: _$args));
  }
}
