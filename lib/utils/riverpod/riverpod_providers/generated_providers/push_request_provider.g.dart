// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_request_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PushRequestNotifier)
final pushRequestProviderOf = PushRequestNotifierFamily._();

final class PushRequestNotifierProvider
    extends $AsyncNotifierProvider<PushRequestNotifier, PushRequestState> {
  PushRequestNotifierProvider._({
    required PushRequestNotifierFamily super.from,
    required ({
      RsaUtils rsaUtils,
      PrivacyideaIOClient ioClient,
      PushProvider pushProvider,
      PushRequestRepository pushRepo,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'pushRequestProviderOf',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pushRequestNotifierHash();

  @override
  String toString() {
    return r'pushRequestProviderOf'
        ''
        '$argument';
  }

  @$internal
  @override
  PushRequestNotifier create() => PushRequestNotifier();

  @override
  bool operator ==(Object other) {
    return other is PushRequestNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pushRequestNotifierHash() =>
    r'510748444491c599d6bed898a1ae5df7abc46dd5';

final class PushRequestNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          PushRequestNotifier,
          AsyncValue<PushRequestState>,
          PushRequestState,
          FutureOr<PushRequestState>,
          ({
            RsaUtils rsaUtils,
            PrivacyideaIOClient ioClient,
            PushProvider pushProvider,
            PushRequestRepository pushRepo,
          })
        > {
  PushRequestNotifierFamily._()
    : super(
        retry: null,
        name: r'pushRequestProviderOf',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  PushRequestNotifierProvider call({
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required PushProvider pushProvider,
    required PushRequestRepository pushRepo,
  }) => PushRequestNotifierProvider._(
    argument: (
      rsaUtils: rsaUtils,
      ioClient: ioClient,
      pushProvider: pushProvider,
      pushRepo: pushRepo,
    ),
    from: this,
  );

  @override
  String toString() => r'pushRequestProviderOf';
}

abstract class _$PushRequestNotifier extends $AsyncNotifier<PushRequestState> {
  late final _$args =
      ref.$arg
          as ({
            RsaUtils rsaUtils,
            PrivacyideaIOClient ioClient,
            PushProvider pushProvider,
            PushRequestRepository pushRepo,
          });
  RsaUtils get rsaUtils => _$args.rsaUtils;
  PrivacyideaIOClient get ioClient => _$args.ioClient;
  PushProvider get pushProvider => _$args.pushProvider;
  PushRequestRepository get pushRepo => _$args.pushRepo;

  FutureOr<PushRequestState> build({
    required RsaUtils rsaUtils,
    required PrivacyideaIOClient ioClient,
    required PushProvider pushProvider,
    required PushRequestRepository pushRepo,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PushRequestState>, PushRequestState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PushRequestState>, PushRequestState>,
              AsyncValue<PushRequestState>,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(
        rsaUtils: _$args.rsaUtils,
        ioClient: _$args.ioClient,
        pushProvider: _$args.pushProvider,
        pushRepo: _$args.pushRepo,
      ),
    );
  }
}
