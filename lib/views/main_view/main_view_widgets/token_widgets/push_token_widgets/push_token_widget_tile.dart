import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/push_token_widgets/actions/edit_push_token_action.dart';

import '../../../../../model/tokens/push_token.dart';
import '../token_widget_tile.dart';

class PushTokenWidgetTile extends ConsumerWidget {
  final PushToken token;
  PushTokenWidgetTile(this.token) : super(key: ValueKey(token.id));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TokenWidgetTile(
      token: token,
      editAction: EditPushTokenAction(token: token),
      key: Key('${token.hashCode}TokenWidgetTile'),
      tokenIsLocked: token.isLocked,
      tokenImage: token.tokenImage,
      title: Text(
        token.label,
        textScaleFactor: 1.9,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      trailing: const Icon(
        Icons.notifications,
        size: 26,
      ),
    );
  }
}
