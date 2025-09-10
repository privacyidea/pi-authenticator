// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(TokenNotifier)
const tokenNotifierProviderOf = TokenNotifierFamily._();

final class TokenNotifierProvider
    extends $AsyncNotifierProvider<TokenNotifier, TokenState> {
  const TokenNotifierProvider._({
    required TokenNotifierFamily super.from,
    required ({
      TokenRepository repo,
      RsaUtils rsaUtils,
      PrivacyideaIOClient ioClient,
      FirebaseUtils firebaseUtils,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'tokenNotifierProviderOf',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tokenNotifierHash();

  @override
  String toString() {
    return r'tokenNotifierProviderOf'
        ''
        '$argument';
  }

  @$internal
  @override
  TokenNotifier create() => TokenNotifier();

  @override
  bool operator ==(Object other) {
    return other is TokenNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tokenNotifierHash() => r'efd5f84a819f806c68793f59ba403007504edac7';

final class TokenNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          TokenNotifier,
          AsyncValue<TokenState>,
          TokenState,
          FutureOr<TokenState>,
          ({
            TokenRepository repo,
            RsaUtils rsaUtils,
            PrivacyideaIOClient ioClient,
            FirebaseUtils firebaseUtils,
          })
        > {
  const TokenNotifierFamily._()
    : super(
        retry: null,
        name: r'tokenNotifierProviderOf',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TokenNotifierProvider call({
    required TokenRepository repo,
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required FirebaseUtils firebaseUtils,
  }) => TokenNotifierProvider._(
    argument: (
      repo: repo,
      rsaUtils: rsaUtils,
      ioClient: ioClient,
      firebaseUtils: firebaseUtils,
    ),
    from: this,
  );

  @override
  String toString() => r'tokenNotifierProviderOf';
}

abstract class _$TokenNotifier extends $AsyncNotifier<TokenState> {
  late final _$args =
      ref.$arg
          as ({
            TokenRepository repo,
            RsaUtils rsaUtils,
            PrivacyideaIOClient ioClient,
            FirebaseUtils firebaseUtils,
          });
  TokenRepository get repo => _$args.repo;
  RsaUtils get rsaUtils => _$args.rsaUtils;
  PrivacyideaIOClient get ioClient => _$args.ioClient;
  FirebaseUtils get firebaseUtils => _$args.firebaseUtils;

  FutureOr<TokenState> build({
    required TokenRepository repo,
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required FirebaseUtils firebaseUtils,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      repo: _$args.repo,
      rsaUtils: _$args.rsaUtils,
      ioClient: _$args.ioClient,
      firebaseUtils: _$args.firebaseUtils,
    );
    final ref = this.ref as $Ref<AsyncValue<TokenState>, TokenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TokenState>, TokenState>,
              AsyncValue<TokenState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
