import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Theme'),
            ListTile(
              title: Text('Theme'),
              subtitle: Text('Description'),
              trailing: FlatButton(
                child: Text('clöck'),
              ),
            ),
            Divider(),
            Text('Behavior'),
            ListTile(
              title: Text('Hide otp'),
              subtitle: Text('Description'),
              trailing: FlatButton(
                child: Text('click'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
