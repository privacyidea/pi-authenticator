// TODO legal notice

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/util.dart';

class HOTPWidget extends StatefulWidget {
  final HOTPToken token;

  HOTPWidget({this.token});

  @override
  State<StatefulWidget> createState() => _HOTPWidgetState(
        token: token,
      );
}

class _HOTPWidgetState extends State<HOTPWidget> {
  final HOTPToken token;
  String otpValue;

  _HOTPWidgetState({this.token}) {
    otpValue = calculateHotpValue(token);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListTile(
          title: Center(
            child: Text(
              insertCharAt(otpValue, " ", otpValue.length ~/ 2),
              textScaleFactor: 2.5,
            ),
          ),
          subtitle: Center(
            child: Text(
              token.label,
              textScaleFactor: 2.0,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: RaisedButton(
            onPressed: () => _updateOtpValue(),
            child: Text(
              "Next",
              textScaleFactor: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  _updateOtpValue() {
    setState(() {
      token.incrementCounter();
      otpValue = calculateHotpValue(token);
    });
  }
}
