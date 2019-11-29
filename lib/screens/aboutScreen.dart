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
