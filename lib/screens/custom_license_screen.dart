/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

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
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';

class CustomLicenseScreen extends StatefulWidget {
  final String applicationName;
  final String applicationVersion;
  final Widget applicationIcon;
  final String applicationLegalese;

  CustomLicenseScreen({
    this.applicationName,
    this.applicationVersion,
    this.applicationIcon,
    this.applicationLegalese,
  });

  @override
  State<StatefulWidget> createState() => _CustomLicenseScreenState();
}

class _CustomLicenseScreenState extends State<CustomLicenseScreen> {
  bool _isLoaded = false;
  Column _licenses;

  List<Widget> widgetList = [];

  @override
  void initState() {
    super.initState();

    buildAllLicenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            L10n.of(context).about,
            textScaleFactor: screenTitleScaleFactor,
          ),
        ),
        body: Scrollbar(
          child: Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Column(
              children: <Widget>[
                Text(
                  "${widget.applicationName}",
                  style: Theme.of(context).textTheme.headline,
                ),
                widget.applicationIcon,
                Text("Version ${widget.applicationVersion}"),
                Container(
                  height: 16,
                ),
                Text(
                  "${widget.applicationLegalese}",
                  style: Theme.of(context).textTheme.caption,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text("Powered by flutter"),
                ),
              ],
            ),
          ),
//          child:
//          ListView.builder(
//              itemCount: widgetList.length,
//              itemBuilder: (BuildContext context, int index) {
//                return widgetList[index];
//              }),
        ));
  }

  void buildAllLicenses() async {
    print('Start loading');

    List<LicenseEntry> licenseList = await LicenseRegistry.licenses.toList();

    List<Widget> _licenseList = List<Widget>();

    for (LicenseEntry entry in licenseList) {
      _licenseList.add(_buildSingleLicense(entry));
    }

    setState(() {
//      _licenses = Column(
//        children: <Widget>[..._licenseList],
//      );

      widgetList.addAll(_licenseList);
      _isLoaded = true;
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
