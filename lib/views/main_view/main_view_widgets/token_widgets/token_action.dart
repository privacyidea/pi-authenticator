import 'package:flutter/material.dart';

abstract class TokenAction {
  const TokenAction();

  void handle(BuildContext context);
}
