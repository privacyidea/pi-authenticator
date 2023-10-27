import 'package:flutter/material.dart';

import 'token_widget_base.dart';

abstract class TokenWidget extends StatelessWidget {
  const TokenWidget({super.key});

  @override
  TokenWidgetBase build(BuildContext context);
}
