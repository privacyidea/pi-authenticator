// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_folder_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(TokenFolderNotifier)
const tokenFolderNotifierProviderOf = TokenFolderNotifierFamily._();

final class TokenFolderNotifierProvider
    extends $NotifierProvider<TokenFolderNotifier, TokenFolderState> {
  const TokenFolderNotifierProvider._({
    required TokenFolderNotifierFamily super.from,
    required TokenFolderRepository super.argument,
  }) : super(
         retry: null,
         name: r'tokenFolderNotifierProviderOf',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tokenFolderNotifierHash();

  @override
  String toString() {
    return r'tokenFolderNotifierProviderOf'
        ''
        '($argument)';
  }

  @$internal
  @override
  TokenFolderNotifier create() => TokenFolderNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenFolderState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenFolderState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TokenFolderNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tokenFolderNotifierHash() =>
    r'68ed2236cd7c4405693cd095b32ec34978e47c7d';

final class TokenFolderNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          TokenFolderNotifier,
          TokenFolderState,
          TokenFolderState,
          TokenFolderState,
          TokenFolderRepository
        > {
  const TokenFolderNotifierFamily._()
    : super(
        retry: null,
        name: r'tokenFolderNotifierProviderOf',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TokenFolderNotifierProvider call({required TokenFolderRepository repo}) =>
      TokenFolderNotifierProvider._(argument: repo, from: this);

  @override
  String toString() => r'tokenFolderNotifierProviderOf';
}

abstract class _$TokenFolderNotifier extends $Notifier<TokenFolderState> {
  late final _$args = ref.$arg as TokenFolderRepository;
  TokenFolderRepository get repo => _$args;

  TokenFolderState build({required TokenFolderRepository repo});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(repo: _$args);
    final ref = this.ref as $Ref<TokenFolderState, TokenFolderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TokenFolderState, TokenFolderState>,
              TokenFolderState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
