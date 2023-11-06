import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

abstract class TokenAction extends ConsumerWidget {
  const TokenAction({super.key});
  @override
  CustomSlidableAction build(BuildContext context, WidgetRef ref);
}
