import 'package:flutter/material.dart';

import '../../widgets/push_request_listener.dart';
import '../view_interface.dart';
import 'widgets/push_tokens_view_list.dart';

class PushTokensView extends StatelessView {
  @override
  RouteSettings get routeSettings => const RouteSettings(name: routeName);
  static const routeName = '/push_tokens';
  const PushTokensView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Push Tokens'),
      ),
      body: PushRequestListener(
        child: Stack(
          children: [
            Center(
              child: Icon(Icons.notifications_none, size: 300, color: Colors.grey.withOpacity(0.2)),
            ),
            const PushTokensViwList(),
          ],
        ),
      ),
    );
  }
}
