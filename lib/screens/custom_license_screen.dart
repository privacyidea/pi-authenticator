/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2020 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomLicenseScreen extends StatefulWidget {
  final String applicationName = "privacyIDEA Authenticator";
  final Widget applicationIcon = Padding(
    padding: EdgeInsets.all(40.0),
    child: Image.asset('res/logo/app_logo_light.png'),
  );
  final String applicationLegalese = "Apache License 2.0";
  final Uri gitHubLink =
      Uri.parse("https://github.com/privacyidea/pi-authenticator");
  final Uri websiteLink = Uri.parse("https://netknights.it");

  @override
  State<StatefulWidget> createState() => _CustomLicenseScreenState();
}

class _CustomLicenseScreenState extends State<CustomLicenseScreen> {
  List<Widget> widgetList;
  bool _isLoading = true;
  Future<PackageInfo> info;

  @override
  void initState() {
    super.initState();

    info = PackageInfo.fromPlatform();
    buildAllLicenses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    widgetList ??= [
      Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: Column(
          children: <Widget>[
            Text(
              "${widget.applicationName}",
              style: Theme.of(context).textTheme.headline5,
            ),
            widget.applicationIcon,
            FutureBuilder(
              future: info,
              builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
                if (snapshot.hasData)
                  return Text('Version ${snapshot.data.version}');
                else
                  return CircularProgressIndicator();
              },
            ),
            Container(
              height: 16,
            ),
            FlatButton(
              child: Text(
                "${widget.applicationLegalese}",
                style: Theme.of(context).textTheme.caption,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Text('lol');
                  },
                );
              }, // TODO Show licnese text on click
            ),
            FlatButton(
              child: Text(
                '${widget.gitHubLink}',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
              onPressed: () => _launchUri(widget.gitHubLink),
            ),
            FlatButton(
              child: Text(
                '${widget.websiteLink}',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
              onPressed: () => _launchUri(widget.websiteLink),
            ),
//            Padding(
//              padding: EdgeInsets.symmetric(vertical: 16),
//              child: Text("Powered by flutter"),
//            ),
          ],
        ),
      )
    ];
  }

  void _launchUri(Uri link) async {
    String uri = link.toString();
    if (await canLaunch(uri)) launch(uri);
  }

  // TODO Rebuild this using future builder.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            LTen.of(context).about,
            textScaleFactor: screenTitleScaleFactor,
          ),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                    itemCount: widgetList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return widgetList[index];
                    }),
              ),
            ),
            Visibility(
              visible: _isLoading,
              child: Align(
                alignment: Alignment.center,
                child: LinearProgressIndicator(),
              ),
            ),
          ],
        ));
  }

  void buildAllLicenses() async {
    List<LicenseEntry> licenseList = await LicenseRegistry.licenses.toList();

    List<Widget> _licenseList = List<Widget>();

    for (LicenseEntry entry in licenseList) {
      _licenseList.add(_buildSingleLicense(entry));
    }

    setState(() {
      widgetList.addAll(_licenseList);
      _isLoading = false;
    });
  }

  Widget _buildSingleLicense(LicenseEntry entry) {
    List<Widget> paragraphs = List<Widget>();

    double spaceBetweenParagraphs = 8;

    TextStyle textStyle = Theme.of(context).textTheme.caption;

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
                .caption
                .copyWith(fontWeight: FontWeight.bold),
          ),
          Divider(),
          ...paragraphs,
        ],
      ),
    );
  }
}
