import 'package:flutter/material.dart';

import 'token_widget_base.dart';

abstract class TokenWidget extends StatelessWidget {
  const TokenWidget({Key? key}) : super(key: key);

  @override
  TokenWidgetBase build(BuildContext context);
}
