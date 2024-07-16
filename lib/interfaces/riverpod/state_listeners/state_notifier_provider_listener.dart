import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class StateNotifierProviderListener<T extends StateNotifier<S>, S> {
  final StateNotifierProvider<T, S>? provider;
  final void Function(S? previous, S next)? onNewState;
  const StateNotifierProviderListener({this.provider, this.onNewState});
  void buildListen(WidgetRef ref) {
    if (provider == null || onNewState == null) return;
    ref.listen(provider!, onNewState!);
  }
}
