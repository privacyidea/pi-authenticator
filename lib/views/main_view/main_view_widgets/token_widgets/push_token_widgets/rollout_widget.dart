import 'package:flutter/material.dart';

import '../../../../../model/tokens/push_token.dart';
import '../../../../../utils/utils.dart';

class RolloutWidget extends StatelessWidget {
  final PushToken token;
  const RolloutWidget({required this.token, super.key});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          Text(
            rolloutMsg(token.rolloutState, context),
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ],
      );
}
