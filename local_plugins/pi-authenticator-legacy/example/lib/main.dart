import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            'Plugin example app',
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
        body: Center(
          child: Text(
            'Running on: $platformVersion\n',
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}
