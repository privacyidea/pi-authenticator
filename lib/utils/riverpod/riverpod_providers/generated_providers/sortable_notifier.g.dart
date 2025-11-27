// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sortable_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sortables)
const sortablesProvider = SortablesProvider._();

final class SortablesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SortableMixin>>,
          List<SortableMixin>,
          FutureOr<List<SortableMixin>>
        >
    with
        $FutureModifier<List<SortableMixin>>,
        $FutureProvider<List<SortableMixin>> {
  const SortablesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortablesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortablesHash();

  @$internal
  @override
  $FutureProviderElement<List<SortableMixin>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SortableMixin>> create(Ref ref) {
    return sortables(ref);
  }
}

String _$sortablesHash() => r'a17f494a326e388526c8397c0e4c0d21755e3c7d';
