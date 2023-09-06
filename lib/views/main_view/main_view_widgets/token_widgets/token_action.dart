import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

abstract class TokenAction extends StatelessWidget {
  const TokenAction({Key? key}) : super(key: key);
  @override
  CustomSlidableAction build(BuildContext context);
}
