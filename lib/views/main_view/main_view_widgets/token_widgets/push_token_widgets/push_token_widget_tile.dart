import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../model/tokens/push_token.dart';
import '../token_widget_tile.dart';

class PushTokenWidgetTile extends ConsumerWidget {
  final PushToken token;
  PushTokenWidgetTile(this.token) : super(key: ValueKey(token.id));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TokenWidgetTile(
      tokenIsLocked: token.isLocked,
      leading: token.tokenImage != null
          ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              height: double.infinity,
              child: Align(
                alignment: Alignment.center,
                child: Image.network(
                  token.tokenImage!,
                  fit: BoxFit.contain,
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) => const SizedBox(),
                ),
              ),
            )
          : null,
      title: Text(
        token.label,
        textScaleFactor: 1.9,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.secondary),
      ),
      subtitles: [
        if (token.issuer.isNotEmpty) token.issuer,
      ],
      trailing: const Icon(
        Icons.notifications,
        size: 26,
      ),
    );
  }
}
