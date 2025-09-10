// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sortable_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
