import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO Make accessible from settings?

class ChangelogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Changelog',
            // TODO Translate (?) This stays in english for the moment
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
                onTapLink: (String text, String href, String title) =>
                    _launchURL(href),
              );
            }
            return CircularProgressIndicator();
          },
        ));
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      log('Could not launch url $url', name: 'changelog_screen.dart');
    }
  }
}
