// // GENERATED CODE - DO NOT MODIFY BY HAND

// part of 'progress_state_provider.dart';

// // **************************************************************************
// // RiverpodGenerator
// // **************************************************************************

// String _$progressStateNotifierHash() =>
//     r'f2da79434b36425d91169f5eb0f82cbd48ef8949';

// /// Copied from Dart SDK
// class _SystemHash {
//   _SystemHash._();

//   static int combine(int hash, int value) {
//     // ignore: parameter_assignments
//     hash = 0x1fffffff & (hash + value);
//     // ignore: parameter_assignments
//     hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
//     return hash ^ (hash >> 6);
//   }

//   static int finish(int hash) {
//     // ignore: parameter_assignments
//     hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
//     // ignore: parameter_assignments
//     hash = hash ^ (hash >> 11);
//     return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
//   }
// }

// abstract class _$ProgressStateNotifier
//     extends BuildlessAutoDisposeNotifier<ProgressState> {
//   late final Type type;

//   ProgressState build(
//     Type type,
//   );
// }

// /// See also [ProgressStateNotifier].
// @ProviderFor(ProgressStateNotifier)
// const progressStateNotifierProviderOf = ProgressStateNotifierFamily();

// /// See also [ProgressStateNotifier].
// class ProgressStateNotifierFamily extends Family<ProgressState> {
//   /// See also [ProgressStateNotifier].
//   const ProgressStateNotifierFamily();

//   /// See also [ProgressStateNotifier].
//   ProgressStateNotifierProvider call(
//     Type type,
//   ) {
//     return ProgressStateNotifierProvider(
//       type,
//     );
//   }

//   @override
//   ProgressStateNotifierProvider getProviderOverride(
//     covariant ProgressStateNotifierProvider provider,
//   ) {
//     return call(
//       provider.type,
//     );
//   }

//   static const Iterable<ProviderOrFamily>? _dependencies = null;

//   @override
//   Iterable<ProviderOrFamily>? get dependencies => _dependencies;

//   static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

//   @override
//   Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
//       _allTransitiveDependencies;

//   @override
//   String? get name => r'progressStateNotifierProviderOf';
// }

// /// See also [ProgressStateNotifier].
// class ProgressStateNotifierProvider extends AutoDisposeNotifierProviderImpl<
//     ProgressStateNotifier, ProgressState> {
//   /// See also [ProgressStateNotifier].
//   ProgressStateNotifierProvider(
//     Type type,
//   ) : this._internal(
//           () => ProgressStateNotifier()..type = type,
//           from: progressStateNotifierProviderOf,
//           name: r'progressStateNotifierProviderOf',
//           debugGetCreateSourceHash:
//               const bool.fromEnvironment('dart.vm.product')
//                   ? null
//                   : _$progressStateNotifierHash,
//           dependencies: ProgressStateNotifierFamily._dependencies,
//           allTransitiveDependencies:
//               ProgressStateNotifierFamily._allTransitiveDependencies,
//           type: type,
//         );

//   ProgressStateNotifierProvider._internal(
//     super._createNotifier, {
//     required super.name,
//     required super.dependencies,
//     required super.allTransitiveDependencies,
//     required super.debugGetCreateSourceHash,
//     required super.from,
//     required this.type,
//   }) : super.internal();

//   final Type type;

//   @override
//   ProgressState runNotifierBuild(
//     covariant ProgressStateNotifier notifier,
//   ) {
//     return notifier.build(
//       type,
//     );
//   }

//   @override
//   Override overrideWith(ProgressStateNotifier Function() create) {
//     return ProviderOverride(
//       origin: this,
//       override: ProgressStateNotifierProvider._internal(
//         () => create()..type = type,
//         from: from,
//         name: null,
//         dependencies: null,
//         allTransitiveDependencies: null,
//         debugGetCreateSourceHash: null,
//         type: type,
//       ),
//     );
//   }

//   @override
//   AutoDisposeNotifierProviderElement<ProgressStateNotifier, ProgressState>
//       createElement() {
//     return _ProgressStateNotifierProviderElement(this);
//   }

//   @override
//   bool operator ==(Object other) {
//     return other is ProgressStateNotifierProvider && other.type == type;
//   }

//   @override
//   int get hashCode {
//     var hash = _SystemHash.combine(0, runtimeType.hashCode);
//     hash = _SystemHash.combine(hash, type.hashCode);

//     return _SystemHash.finish(hash);
//   }
// }

// mixin ProgressStateNotifierRef
//     on AutoDisposeNotifierProviderRef<ProgressState> {
//   /// The parameter `type` of this provider.
//   Type get type;
// }

// class _ProgressStateNotifierProviderElement
//     extends AutoDisposeNotifierProviderElement<ProgressStateNotifier,
//         ProgressState> with ProgressStateNotifierRef {
//   _ProgressStateNotifierProviderElement(super.provider);

//   @override
//   Type get type => (origin as ProgressStateNotifierProvider).type;
// }
// // ignore_for_file: type=lint
// // ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
