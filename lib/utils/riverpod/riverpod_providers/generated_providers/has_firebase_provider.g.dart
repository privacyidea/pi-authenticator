// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'has_firebase_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hasFirebase)
final hasFirebaseProvider = HasFirebaseProvider._();

final class HasFirebaseProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  HasFirebaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasFirebaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasFirebaseHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return hasFirebase(ref);
  }
}

String _$hasFirebaseHash() => r'8f0681b6ee9998d3cfc4fb4987aa6d30960d4cd2';
