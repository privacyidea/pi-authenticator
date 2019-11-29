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
import 'package:flutter/material.dart';

import 'mainScreen.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    AboutScreenArguments args = ModalRoute.of(context).settings.arguments;

    List<String> keys = args.components.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("About the app"),
      ),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  args.applicationName,
                  textScaleFactor: 1.8,
                ),
                Text(
                  "Version ${args.version}",
                  textScaleFactor: 1.0,
                ),
                Text(
                  args.developerName,
                  textScaleFactor: 1.3,
                ),
              ],
            ),
            ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) => ListTile(
                      onTap: _showLicense(keys[index], args.licenseMap),
                      title: Center(
                        child: Text(keys.toList()[index]),
                      ),
                      subtitle: Center(
                        child: Text(args.components[keys[index]]),
                      ),
                    ),
                separatorBuilder: (context, index) => Divider(),
                itemCount: keys.length),
          ],
        ),
      ),
    );
  }

  _showLicense(String licenseName, Map<String, String> licenseMap) {
    String licenseDescription = licenseMap[licenseName];

    // TODO show the corresponding license.
  }
}
