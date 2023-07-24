import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token/push_token.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_tile.dart';

class PushTokenWidgetTile extends ConsumerWidget {
  final PushToken token;
  PushTokenWidgetTile(this.token) : super(key: ValueKey(token.id));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TokenWidgetTile(
      leading: token.tokenImage != null
          ? Container(
              width: MediaQuery.of(context).size.width * 0.3,
              height: double.infinity,
              child: Align(
                alignment: Alignment.center,
                child: Image.network(
                  token.tokenImage!,
                  fit: BoxFit.contain,
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) => SizedBox(),
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
      trailing: Icon(
        Icons.notifications,
        size: 26,
      ),
    );
  }
}
