import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// TODO Check if the app was updated -> If yes, show this page, make accessible from settings?
// TODO Show Information for each update version / changelog
// TODO Format as Markdown?

class UpdateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Markdown(data: 'Hallo');
  }
}
