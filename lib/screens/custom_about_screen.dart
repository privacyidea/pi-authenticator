/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info/package_info.dart';
import 'package:privacyidea_authenticator/screens/changelog_screen.dart';
import 'package:privacyidea_authenticator/utils/appCustomizer.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomLicenseScreen extends StatefulWidget {
  final Widget applicationIcon = Image.asset(
    ApplicationCustomizer.appIcon,
    width: 330,
  );
  final String applicationLegalese = 'Apache License 2.0';
  final String gitHubLink = 'https://github.com/privacyidea/pi-authenticator';
  final String websiteLink = ApplicationCustomizer.websiteLink;

  @override
  State<StatefulWidget> createState() => _CustomLicenseScreenState();
}

class _CustomLicenseScreenState extends State<CustomLicenseScreen> {
  Future<PackageInfo>? _info;

  Stream<List<Widget>> widgetListStream() async* {
    List<Widget> initialList = [
      Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: Column(
          children: <Widget>[
            Text(
              ApplicationCustomizer.appName,
              //'${widget.applicationName}',
              style: Theme.of(context).textTheme.headline5,
            ),
            widget.applicationIcon,
            FutureBuilder<PackageInfo>(
              future: _info,
              builder: (context, snapshot) {
                if (snapshot.hasData)
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Version ${snapshot.data!.version}'),
                      TextButton(
                        child: Text('Changelog'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangelogScreen(),
                          ),
                        ),
                      ),
                    ],
                  );
                else
                  return CircularProgressIndicator();
              },
            ),
            TextButton(
              child: Text(
                '${widget.applicationLegalese}',
              ),
              onPressed: _showAppLicenseDialog,
            ),
            TextButton(
              child: Text(
                '${widget.gitHubLink}',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
              onPressed: () => _launch(widget.gitHubLink),
            ),
            TextButton(
              child: Text(
                '${widget.websiteLink}',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
              onPressed: () => _launch(widget.websiteLink),
            ),
          ],
        ),
      ),
    ];

    // Put initial content with loading indicator:
    yield [
      ...initialList,
      Align(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    ];

    // Put initial content and licenses:
    List<LicenseEntry> licenses = await LicenseRegistry.licenses.toList();
    yield [
      ...initialList,
      for (LicenseEntry entry in licenses) _buildSingleLicense(entry)
    ];
  }

  @override
  void initState() {
    super.initState();
    _info = PackageInfo.fromPlatform();
  }

  void _launch(String url) async {
    if (await canLaunch(url)) {
      launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.about,
        ),
      ),
      body: StreamBuilder<List<Widget>>(
        stream: widgetListStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) => snapshot.data![index],
            );
          } else
            return Column();
        },
      ),
    );
  }

  void _showAppLicenseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: StreamBuilder<LicenseEntry>(
            stream: LicenseRegistry.licenses.where((event) =>
                event.packages.contains('privacyIDEA Authenticator')),
            builder: (context, snapshot) {
              if (snapshot.hasData)
                return SingleChildScrollView(
                  child: _buildSingleLicense(snapshot.data!),
                );
              else
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[CircularProgressIndicator()],
                );
            },
          ),
        );
      },
    );
  }

  Widget _buildSingleLicense(LicenseEntry entry) {
    List<Widget> paragraphs = [];

    double spaceBetweenParagraphs = 8;

    TextStyle textStyle = Theme.of(context).textTheme.caption!;

    for (LicenseParagraph paragraph in entry.paragraphs) {
      if (paragraph.indent == LicenseParagraph.centeredIndent) {
        paragraphs.add(Padding(
          padding: EdgeInsets.only(
            top: spaceBetweenParagraphs,
          ),
          child: Text(
            paragraph.text,
            style: textStyle,
          ),
        ));
      } else {
        paragraphs.add(Padding(
          padding: EdgeInsets.only(
            top: spaceBetweenParagraphs,
            left: paragraph.indent * 8.0,
          ),
          child: Text(
            paragraph.text,
            style: textStyle,
          ),
        ));
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Column(
        children: <Widget>[
          Text(
            entry.packages.join(', '),
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          Divider(),
          ...paragraphs,
        ],
      ),
    );
  }
}
