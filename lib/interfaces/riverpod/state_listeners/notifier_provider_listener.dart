// ignore_for_file: invalid_use_of_internal_member

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

abstract class AsyncNotifierProviderListener<T extends BuildlessAutoDisposeAsyncNotifier<S>, S> {
  final AutoDisposeAsyncNotifierProviderImpl<T, S>? provider;
  final void Function(AsyncValue<S>? previous, AsyncValue<S> next)? onNewState;
  const AsyncNotifierProviderListener({this.provider, this.onNewState});
  void buildListen(WidgetRef ref) {
    if (provider == null || onNewState == null) return;
    ref.listen(provider!, onNewState!);
  }
}
