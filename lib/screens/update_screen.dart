import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// TODO Check if the app was updated -> If yes, show this page, make accessible from settings?
// TODO Show Information for each update version / changelog
// TODO Format as Markdown?

class UpdateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Changelog', // TODO Translate (?)
            overflow: TextOverflow.ellipsis,
            // maxLines: 2 only works like this.
            maxLines: 2, // Title can be shown on small screens too.
          ),
        ),
        body: FutureBuilder<String>(
          future: DefaultAssetBundle.of(context).loadString('CHANGELOG.md'),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Markdown(
                data: snapshot.data,
              );
            }
            return CircularProgressIndicator();
          },
        ));
  }
}
