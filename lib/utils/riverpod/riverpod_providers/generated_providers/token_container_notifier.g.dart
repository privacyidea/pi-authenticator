// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_container_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TokenContainerNotifier)
const tokenContainerProviderOf = TokenContainerNotifierFamily._();

final class TokenContainerNotifierProvider
    extends
        $AsyncNotifierProvider<TokenContainerNotifier, TokenContainerState> {
  const TokenContainerNotifierProvider._({
    required TokenContainerNotifierFamily super.from,
    required ({
      TokenContainerRepository repo,
      TokenContainerApi containerApi,
      EccUtils eccUtils,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'tokenContainerProviderOf',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tokenContainerNotifierHash();

  @override
  String toString() {
    return r'tokenContainerProviderOf'
        ''
        '$argument';
  }

  @$internal
  @override
  TokenContainerNotifier create() => TokenContainerNotifier();

  @override
  bool operator ==(Object other) {
    return other is TokenContainerNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tokenContainerNotifierHash() =>
    r'445416971629b37af94af24bc921514ea0e2d8d7';

final class TokenContainerNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          TokenContainerNotifier,
          AsyncValue<TokenContainerState>,
          TokenContainerState,
          FutureOr<TokenContainerState>,
          ({
            TokenContainerRepository repo,
            TokenContainerApi containerApi,
            EccUtils eccUtils,
          })
        > {
  const TokenContainerNotifierFamily._()
    : super(
        retry: null,
        name: r'tokenContainerProviderOf',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TokenContainerNotifierProvider call({
    required TokenContainerRepository repo,
    required TokenContainerApi containerApi,
    required EccUtils eccUtils,
  }) => TokenContainerNotifierProvider._(
    argument: (repo: repo, containerApi: containerApi, eccUtils: eccUtils),
    from: this,
  );

  @override
  String toString() => r'tokenContainerProviderOf';
}

abstract class _$TokenContainerNotifier
    extends $AsyncNotifier<TokenContainerState> {
  late final _$args =
      ref.$arg
          as ({
            TokenContainerRepository repo,
            TokenContainerApi containerApi,
            EccUtils eccUtils,
          });
  TokenContainerRepository get repo => _$args.repo;
  TokenContainerApi get containerApi => _$args.containerApi;
  EccUtils get eccUtils => _$args.eccUtils;

  FutureOr<TokenContainerState> build({
    required TokenContainerRepository repo,
    required TokenContainerApi containerApi,
    required EccUtils eccUtils,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      repo: _$args.repo,
      containerApi: _$args.containerApi,
      eccUtils: _$args.eccUtils,
    );
    final ref =
        this.ref as $Ref<AsyncValue<TokenContainerState>, TokenContainerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TokenContainerState>, TokenContainerState>,
              AsyncValue<TokenContainerState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
