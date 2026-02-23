// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messenger_stack.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MessengerStack)
final messengerStackProvider = MessengerStackProvider._();

final class MessengerStackProvider
    extends $NotifierProvider<MessengerStack, List<BuildContext>> {
  MessengerStackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messengerStackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messengerStackHash();

  @$internal
  @override
  MessengerStack create() => MessengerStack();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<BuildContext> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<BuildContext>>(value),
    );
  }
}

String _$messengerStackHash() => r'936f24f0c8f0e8c4c79f9008754a362bf0914f80';

abstract class _$MessengerStack extends $Notifier<List<BuildContext>> {
  List<BuildContext> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<BuildContext>, List<BuildContext>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<BuildContext>, List<BuildContext>>,
              List<BuildContext>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
