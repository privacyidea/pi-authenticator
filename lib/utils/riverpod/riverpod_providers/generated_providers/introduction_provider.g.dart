// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'introduction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(IntroductionNotifier)
const introductionNotifierProviderOf = IntroductionNotifierFamily._();

final class IntroductionNotifierProvider
    extends $AsyncNotifierProvider<IntroductionNotifier, IntroductionState> {
  const IntroductionNotifierProvider._({
    required IntroductionNotifierFamily super.from,
    required IntroductionRepository super.argument,
  }) : super(
         retry: null,
         name: r'introductionNotifierProviderOf',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$introductionNotifierHash();

  @override
  String toString() {
    return r'introductionNotifierProviderOf'
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
  const IntroductionNotifierFamily._()
    : super(
        retry: null,
        name: r'introductionNotifierProviderOf',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  IntroductionNotifierProvider call({required IntroductionRepository repo}) =>
      IntroductionNotifierProvider._(argument: repo, from: this);

  @override
  String toString() => r'introductionNotifierProviderOf';
}

abstract class _$IntroductionNotifier
    extends $AsyncNotifier<IntroductionState> {
  late final _$args = ref.$arg as IntroductionRepository;
  IntroductionRepository get repo => _$args;

  FutureOr<IntroductionState> build({required IntroductionRepository repo});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(repo: _$args);
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
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
