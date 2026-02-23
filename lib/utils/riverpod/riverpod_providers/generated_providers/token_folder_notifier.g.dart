// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_folder_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TokenFolderNotifier)
final tokenFolderProviderOf = TokenFolderNotifierFamily._();

final class TokenFolderNotifierProvider
    extends $NotifierProvider<TokenFolderNotifier, TokenFolderState> {
  TokenFolderNotifierProvider._({
    required TokenFolderNotifierFamily super.from,
    required TokenFolderRepository super.argument,
  }) : super(
         retry: null,
         name: r'tokenFolderProviderOf',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tokenFolderNotifierHash();

  @override
  String toString() {
    return r'tokenFolderProviderOf'
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
  TokenFolderNotifierFamily._()
    : super(
        retry: null,
        name: r'tokenFolderProviderOf',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TokenFolderNotifierProvider call({required TokenFolderRepository repo}) =>
      TokenFolderNotifierProvider._(argument: repo, from: this);

  @override
  String toString() => r'tokenFolderProviderOf';
}

abstract class _$TokenFolderNotifier extends $Notifier<TokenFolderState> {
  late final _$args = ref.$arg as TokenFolderRepository;
  TokenFolderRepository get repo => _$args;

  TokenFolderState build({required TokenFolderRepository repo});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TokenFolderState, TokenFolderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TokenFolderState, TokenFolderState>,
              TokenFolderState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(repo: _$args));
  }
}
