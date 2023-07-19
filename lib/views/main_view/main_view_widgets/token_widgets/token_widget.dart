import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_base.dart';

abstract class TokenWidget extends StatelessWidget {
  const TokenWidget({Key? key}) : super(key: key);

  @override
  TokenWidgetBase build(BuildContext context);
}
