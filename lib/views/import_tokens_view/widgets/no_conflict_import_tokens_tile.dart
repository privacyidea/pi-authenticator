import 'package:flutter/material.dart';

import '../../../model/tokens/token.dart';
import '../../main_view/main_view_widgets/token_widgets/token_widget_builder.dart';

class NoConflictImportTokensTile extends StatelessWidget {
  final Token token;
  final Token? selected;
  final void Function()? onTap;
  final Alignment? alignment;
  final double? width;
  final Color? borderColor;
  const NoConflictImportTokensTile({
    required this.token,
    required this.selected,
    this.onTap,
    this.alignment,
    this.width,
    this.borderColor = Colors.green,
    super.key,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Card(
          elevation: 2,
          color: selected == token ? borderColor : null,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [TokenWidgetBuilder.previewFromToken(token)],
                ),
              ),
            ),
          ),
        ),
      );
}
