import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/token_category.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_builder.dart';
import 'package:privacyidea_authenticator/widgets/custom_trailing.dart';

class TokenCategoryWidget extends ConsumerStatefulWidget {
  final TokenCategory category;

  const TokenCategoryWidget(this.category, {Key? key}) : super(key: key);

  @override
  ConsumerState<TokenCategoryWidget> createState() => _TokenCategoryWidgetState();
}

class _TokenCategoryWidgetState extends ConsumerState<TokenCategoryWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      value: 1.0,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ref.watch(tokenProvider).tokensInCategory(widget.category);
    return ExpansionTile(
      key: Key(widget.category.categoryId.toString()),
      childrenPadding: EdgeInsets.only(left: 16),
      onExpansionChanged: (value) {
        if (value) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
      },
      title: Row(
        children: [
          RotationTransition(
            turns: Tween(begin: 0.25, end: 0.0).animate(_controller),
            child: Icon(Icons.arrow_forward_ios_sharp),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.category.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      trailing: CustomTrailing(
          child: Center(
        child: Stack(
          children: [
            Icon(Icons.folder_open, color: Theme.of(context).colorScheme.inverseSurface),
            FadeTransition(
              opacity: _controller,
              child: Icon(Icons.folder),
            ),
          ],
        ),
      )),
      children: [
        for (var i = 0; i < tokens.length; i++)
          TokenWidgetBuilder.fromToken(
            tokens[i],
            withDivider: i < tokens.length - 1,
          ),
      ],
    );
  }
}
