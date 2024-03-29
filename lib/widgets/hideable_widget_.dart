import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/tokens/token.dart';
import '../utils/riverpod_providers.dart';

class HideableWidget extends ConsumerWidget {
  final Token token;
  final bool isHidden;
  final Widget child;
  const HideableWidget({
    required this.child,
    required this.token,
    required this.isHidden,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return token.isLocked && isHidden
        ? IconButton(
            onPressed: () async => ref.read(tokenProvider.notifier).showToken(token),
            icon: const Icon(Icons.remove_red_eye_outlined),
          )
        : child;
  }
}
