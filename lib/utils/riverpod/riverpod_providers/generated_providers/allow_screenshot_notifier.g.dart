// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allow_screenshot_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AllowScreenshotNotifier)
const allowScreenshotProviderOf = AllowScreenshotNotifierFamily._();

final class AllowScreenshotNotifierProvider
    extends $AsyncNotifierProvider<AllowScreenshotNotifier, bool> {
  const AllowScreenshotNotifierProvider._({
    required AllowScreenshotNotifierFamily super.from,
    required AllowScreenshotUtils super.argument,
  }) : super(
         retry: null,
         name: r'allowScreenshotProviderOf',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$allowScreenshotNotifierHash();

  @override
  String toString() {
    return r'allowScreenshotProviderOf'
        ''
        '($argument)';
  }

  @$internal
  @override
  AllowScreenshotNotifier create() => AllowScreenshotNotifier();

  @override
  bool operator ==(Object other) {
    return other is AllowScreenshotNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$allowScreenshotNotifierHash() =>
    r'8b1c26b634d675771c6467e1c3bbd2144da430d0';

final class AllowScreenshotNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          AllowScreenshotNotifier,
          AsyncValue<bool>,
          bool,
          FutureOr<bool>,
          AllowScreenshotUtils
        > {
  const AllowScreenshotNotifierFamily._()
    : super(
        retry: null,
        name: r'allowScreenshotProviderOf',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  AllowScreenshotNotifierProvider call({
    required AllowScreenshotUtils screenshotUtils,
  }) =>
      AllowScreenshotNotifierProvider._(argument: screenshotUtils, from: this);

  @override
  String toString() => r'allowScreenshotProviderOf';
}

abstract class _$AllowScreenshotNotifier extends $AsyncNotifier<bool> {
  late final _$args = ref.$arg as AllowScreenshotUtils;
  AllowScreenshotUtils get screenshotUtils => _$args;

  FutureOr<bool> build({required AllowScreenshotUtils screenshotUtils});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(screenshotUtils: _$args);
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
