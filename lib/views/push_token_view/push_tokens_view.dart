import 'package:flutter/material.dart';

import 'widgets/push_tokens_view_list.dart';

class PushTokensView extends StatelessWidget {
  static const routeName = '/pushTokensView';
  const PushTokensView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Tokens'),
      ),
      body: Stack(
        children: [
          Center(
            child: Icon(Icons.notifications_none, size: 300, color: Colors.grey.withOpacity(0.2)),
          ),
          const PushTokensViwList(),
        ],
      ),
    );
  }
}
