// TODO legal notice

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/screens/mainScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo', // TODO rename this
      theme: ThemeData(
        textTheme: TextTheme(
          title: TextStyle(
            fontSize: 19,
            color: Colors.white,
          ),
        ),
        primarySwatch: Colors.deepPurple,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.deepPurple,
          textTheme: ButtonTextTheme.primary,
        ),
      ), // TODO move this theme to another file
      home:
          MainScreen(title: 'Flutter Demo Home Page'), // TODO set proper title
    );
  }
}
