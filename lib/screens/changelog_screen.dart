import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO Check if the app was updated -> If yes, show this page, make accessible from settings?
// TODO Show Information for each update version / changelog
// TODO Format as Markdown?

class ChangelogScreen extends StatelessWidget {
  final ScrollController _controller = ScrollController(initialScrollOffset: 2);

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
              return Scrollbar(
                controller: _controller,
                isAlwaysShown: true,
                child: Markdown(
                  controller: _controller,
                  data: snapshot.data,
                  onTapLink: (String text, String href, String title) =>
                      _launchURL(href),
                ),
              );
            }
            return Center(
                child: Text(Localization.of(context).somethingWentWrong));
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
